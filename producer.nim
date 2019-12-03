import os, debug, carver

proc isInProducerMode*() : bool {.inline} =
    let params = commandLineParams()
    params.len > 0 and params[0] == "--javalauncher-creator"

proc produce*(selfExec:string) =
    var params = commandLineParams()
    params.delete(0)
    var output = "javalauncher.out"
    var json = ""
    while params.len > 0:
        case params[0]
        of "--output", "-o", "--out":
            params.delete(0)
            if (params.len > 0):
                output = params[0]
                params.delete(0)
            else: error "Requesting to define output but no file provided"
        of "--json", "-j":
            params.delete(0)
            if (params.len > 0):
                json = params[0]
                params.delete(0)
            else: error "Requesting to define json but no file provided"
        of "--help", "-h", "-?":
            params.delete(0)
            echo "Usage:\n  javalauncher --javalauncher-creator --output|--out|-o OUTPUT_FILE --json|-j JSON_TO_EMBED [--help|-h|-?]"
            quit()
        else:
            error "Unable to parse argument `" & params[0] & "`"
    
    if output == "": error "Unable to produce empty binary"
    else: debug "Producing executable " & output & (if json=="": "" else: " with JSON " & json)

    output = output.absolutePath().normalizedPath()
    if output == selfExec:
        error "Output file and source file are the same: " & output
    if output.existsFile():
        error "Output file exists: " & output

    var jsonData = ""
    var length = -1
    if json != "":
        if not json.existsFile(): error "JSON file " & json & " does not exist"
        let jsonfile = json.absolutePath().normalizedPath()
        if jsonfile == selfExec or jsonfile == output: error "JSON file should not be self referenced"
        if jsonfile.getFileSize() >= 65535:
            error "The size of the appendable JSON file " & json & " is bigger than 64K"
        jsonData = readFile(jsonfile)
        length = jsonData.len()

    writeFile(output, readFile(selfExec))
    if length > 0:
        let file  = open(output, fmAppend)
        file.write(jsonData)
        file.write(char((length shr 8) and 0xFF))
        file.write(char(length and 0xFF))
        file.write(SIGNATURE)
        file.close()
    setFilePermissions(output, getFilePermissions(selfExec))