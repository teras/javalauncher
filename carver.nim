import nim_miniz, debug, json, hound, os, manifest
from strutils import replace

const LAUNCHER_FILE = "javalauncher.json"
const LAUNCHER_INF = "META-INF/LAUNCHER.INF"
const MANIFEST_MF = "META-INF/MANIFEST.MF"

proc updateJsonFromJar*(file: string, fileJson: JsonNode): JsonNode =
    result = fileJson
    var manifest: TableRef[string, string]
    var zip:Zip
    if not zip.open(file):
        debug("Error while opening JAR file " & file)
        return nil
    for i, fname in zip:
        if fname == LAUNCHER_INF and result == nil:
            result = parseJson(zip.extract_file_to_string(fname))
        elif fname == MANIFEST_MF:
            manifest = parseManifest(zip.extract_file_to_string(fname))
    zip.close()
    if result == nil: result = newJObject()
    result.injectManifest(manifest)
    debug "Jar JSON: " & $result

proc loadJsonFromFile*(launcherDir: string): JsonNode =
    template returnIf(file: string): untyped =
        let target = findFile(launcherDir, file)
        if target.fileExists:
            debug "Found javalauncher file at " & target
            result = parseJson(readFile(target))
            debug "File JSON: " & $result
            return
    returnIf LAUNCHER_FILE
    returnIf "." & LAUNCHER_FILE
    return nil

proc findJarName*(selfName:string, json:JsonNode) : string =
    if json == nil: result = selfName
    else: result = json.getOrDefault("jar").getStr(selfName)
    debug "JAR name is " & result

proc populateArguments*(json: JsonNode, vmargs:var seq[string], postArgs:var seq[string],
        mainclass:var string, splashscreen:var string, classpath:var string,
        jarDir:string, launcherDir:string)  =
    proc asArg(item: string): string =
        return item
            .replace("@@JAR_LOCATION@@", jarDir)
            .replace("@@LAUNCH_LOCATION@@", launcherDir)
    template populateList(args: var seq[string], jsonNode: JsonNode): void =
        if jsonNode != nil:
            for arg in jsonNode:
                args.add(arg.getStr.asArg)
    template populateItem(tag:string) :string = json.getOrDefault(tag).getStr("")
    populateList(vmargs, json.getOrDefault "jvmargs")
    populateList(postArgs, json.getOrDefault "args")
    let sysroot = json.getOrDefault system.hostOS
    if sysroot != nil:
        populateList(vmargs, sysroot.getOrDefault "jvmargs")
        populateList(postArgs, sysroot.getOrDefault "args")
    mainclass = populateItem("main-class")
    splashscreen = populateItem("splashscreen-image")
    classpath = populateItem("class-path")
