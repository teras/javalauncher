import nim_miniz, debug, json, hound, os

const LAUNCHER_FILE = "javalauncher.json"
const LAUNCHER_INF = "META-INF/LAUNCHER.INF"

proc getFilename(zadrr: ptr mz_zip_archive, i: mz_uint): string {.inline.} =
    var size = zadrr.mz_zip_reader_get_filename(i.mz_uint, result, 0)
    result.setLen(size.int)
    doAssert zadrr.mz_zip_reader_get_filename(i.mz_uint, result,
            size) > 0.mz_uint
    # drop trailing byte.
    result = result[0..<result.high]

proc loadJsonFromZip*(file: string): string =
    var zip: mz_zip_archive
    var filestat: mz_zip_archive_file_stat
    let zadrr: ptr mz_zip_archive = zip.addr

    if mz_zip_reader_init_file(zadrr, file, 0) != MZ_TRUE:
        debug("Error while opening JAR file " & file)
        return ""

    var json = ""
    for i in 0..<mz_zip_reader_get_num_files(zadrr):
        let fname = getFilename(zadrr, i)
        if fname == LAUNCHER_INF:
            if mz_zip_reader_file_stat(zadrr, i, filestat.addr) != MZ_TRUE:
                debug "Error while locating information"
                break
            json.setLen(filestat.m_uncomp_size)
            if mz_zip_reader_extract_to_mem(zadrr, i, json[0].addr,
                    filestat.m_uncomp_size.csize, 0) != MZ_TRUE:
                debug "Error while reading information"
                json = ""
            break

    discard mz_zip_reader_end(zadrr)
    return json

proc loadJsonFromFile*(launcherDir: string): string =
    template returnIf(file: string): untyped =
        let target = findFile(launcherDir, file)
        if target.fileExists:
            debug "Found javalauncher file at " & target
            return readFile(target)
    returnIf LAUNCHER_FILE
    returnIf "." & LAUNCHER_FILE
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

