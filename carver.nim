import nim_miniz, debug, json

proc get_file_name(zadrr: ptr mz_zip_archive, i:mz_uint): string {.inline.} =
    var size = zadrr.mz_zip_reader_get_filename(i.mz_uint, result, 0)
    result.setLen(size.int)
    doAssert zadrr.mz_zip_reader_get_filename(i.mz_uint, result, size) > 0.mz_uint
    # drop trailing byte.
    result = result[0..<result.high]

proc extractData*(file:string):string =
    var zip:mz_zip_archive
    var filestat:mz_zip_archive_file_stat
    let zadrr:ptr mz_zip_archive = zip.addr
 
    if mz_zip_reader_init_file(zadrr, file, 0) != MZ_TRUE:
        debug("Error while opening JAR file")
        return ""
    
    var json = ""
    for i in 0..<mz_zip_reader_get_num_files(zadrr):
        let fname = get_file_name(zadrr, i)
        if fname == "META-INF/LAUNCHER.INF":
            if mz_zip_reader_file_stat(zadrr, i, filestat.addr) != MZ_TRUE:
                debug "Error while locating information"
                break
            json.setLen(filestat.m_uncomp_size)
            if mz_zip_reader_extract_to_mem(zadrr, i, json[0].addr, filestat.m_uncomp_size.csize, 0) != MZ_TRUE:
                debug "Error while reading information"
                json = ""
            break

    discard mz_zip_reader_end(zadrr)
    return json

template populateList(args:var seq[string], json:JsonNode): void =
    if json != nil:
        for arg in json:
            args.add(arg.getStr())
    
proc findArgs*(json:string, vmargs:var seq[string], postArgs:var seq[string]) =
    let root = parseJson(json)
    populateList(vmargs, root["jvmargs"])
    populateList(postArgs, root["args"])
