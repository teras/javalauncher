import tables, strutils, json
export tables

proc parseManifestLine(line:string, dict:TableRef[string,string]) =
    if line.len == 0:
        return
    let colon = line.find(':')
    if colon < 1: raise newException(Exception, "Error in manifest file: no colon found")
    dict[line.substr(0, colon-1).strip.toLowerAscii] = line.substr(colon+1).strip

proc parseManifest*(data:string) : TableRef[string,string] =
    result = newTable[string,string]()
    var prev = ""
    for line in data.splitLines():
        if line.len > 0:
            if line[0] == ' ':
                if prev.len == 0: raise newException(Exception, "Error in manifest file, wrong multiline argument")
                prev = prev & line.substr(1)
            else:
                if prev.len > 0: parseManifestLine(prev, result)
                prev = line
    if prev.len > 0: parseManifestLine(prev, result)


proc injectManifestProperty(json:JsonNode, manifest:TableRef[string,string], key:string) =
    let data = if manifest.hasKey(key): manifest[key] else: ""
    if data.len > 0 : json.add(key, newJString(data))

proc injectManifest*(json:JsonNode, manifest:TableRef[string,string]) =
    json.injectManifestProperty(manifest, "main-class")
    json.injectManifestProperty(manifest, "splashscreen-image")
    json.injectManifestProperty(manifest, "class-path")
