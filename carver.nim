import json

const SIGNATURE* = "jrlc"
const SIGLEN = SIGNATURE.len
const SIZELEN = 2

proc loadJson*(launcherPath: string): string {.inline.} =
    result = ""
    var file  = open(launcherPath)
    var signature = newString(SIGLEN)
    file.setFilePos(-SIGLEN, fspEnd)
    if (file.readChars(signature, 0, SIGLEN) == SIGLEN and signature == "jrlc"):
        var lengthBuffer : array[SIZELEN, uint8];
        file.setFilePos(-SIGLEN-SIZELEN, fspEnd)
        if (file.readBytes(lengthBuffer, 0, SIZELEN) == SIZELEN):
            let length : int = int(lengthBuffer[0]) * 256 + int(lengthBuffer[1])
            file.setFilePos(-length-SIGLEN-SIZELEN, fspEnd)
            var json = newString(length)
            if (file.readChars(json, 0, length) == length):
                result = json
    file.close()


proc findArgs*(json: string, vmargs: var seq[string], postArgs: var seq[string]) : string =
    template populateList(args: var seq[string], json: JsonNode): void =
        if json != nil:
            for arg in json:
                args.add(arg.getStr())

    result = ""
    if json == "" : return
    let root = parseJson(json)
    result = root.getOrDefault("jarname").getStr("koko")
    echo result
    populateList(vmargs, root.getOrDefault "jvmargs")
    populateList(postArgs, root.getOrDefault "args")

    let sysroot = root.getOrDefault system.hostOS
    if sysroot != nil:
        populateList(vmargs, sysroot.getOrDefault "jvmargs")
        populateList(postArgs, sysroot.getOrDefault "args")

