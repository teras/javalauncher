import json, hound, os, debug

const LAUNCHER_INF = "javalauncher.json"

proc loadJson*(launcherDir: string): string =
    template returnIf(file: string): untyped =
        let target = findFile(launcherDir, file)
        if target.fileExists:
            debug "Found javalauncher file at " & target
            return readFile(target)
    returnIf LAUNCHER_INF
    returnIf "." & LAUNCHER_INF
    ""

proc parseJson*(json: string, selfName: string, vmargs: var seq[string], postArgs: var seq[string]) : string =
    template populateList(args: var seq[string], json: JsonNode): void =
        if json != nil:
            for arg in json:
                args.add(arg.getStr())

    if json == "" : return selfName
    let root = parseJson(json)
    result = root.getOrDefault("jar").getStr(selfName)
    populateList(vmargs, root.getOrDefault "jvmargs")
    populateList(postArgs, root.getOrDefault "args")

    let sysroot = root.getOrDefault system.hostOS
    if sysroot != nil:
        populateList(vmargs, sysroot.getOrDefault "jvmargs")
        populateList(postArgs, sysroot.getOrDefault "args")

