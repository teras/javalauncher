import nim_miniz, debug, json, hound, os, manifest
from strutils import replace

const LAUNCHER_FILE = "javalauncher.json"
const LAUNCHER_INF = "META-INF/LAUNCHER.INF"
const MANIFEST_MF = "META-INF/MANIFEST.MF"

proc getFilename(zadrr: ptr mz_zip_archive, i: mz_uint): string =
    var size = zadrr.mz_zip_reader_get_filename(i.mz_uint, result, 0)
    result.setLen(size.int)
    doAssert zadrr.mz_zip_reader_get_filename(i.mz_uint, result,
            size) > 0.mz_uint
    # drop trailing byte.
    result = result[0..<result.high]


proc readZipEntry(ftype: string, zadrr: ptr mz_zip_archive, zipIndex: mz_uint): string =
    var filestat: mz_zip_archive_file_stat
    if mz_zip_reader_file_stat(zadrr, zipIndex, filestat.addr) != MZ_TRUE:
        error "Error while locating " & ftype & " information"
    result.setLen(filestat.m_uncomp_size)
    if mz_zip_reader_extract_to_mem(zadrr, zipIndex, result[0].addr,
            filestat.m_uncomp_size.csize, 0) != MZ_TRUE:
        error "Error while reading information"

proc updateJsonFromJar*(file: string, fileJson: JsonNode): JsonNode =
    var zip: mz_zip_archive
    result = fileJson
    let zadrr: ptr mz_zip_archive = zip.addr
    if mz_zip_reader_init_file(zadrr, file, 0) != MZ_TRUE:
        debug("Error while opening JAR file " & file)
        return nil
    var manifest: TableRef[string, string]
    for i in 0..<mz_zip_reader_get_num_files(zadrr):
        let fname = getFilename(zadrr, i)
        if fname == LAUNCHER_INF and result == nil:
            result = parseJson(readZipEntry("JSON", zadrr, i))
        elif fname == MANIFEST_MF:
            manifest = parseManifest(readZipEntry("manifest", zadrr, i))
    discard mz_zip_reader_end(zadrr)
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
