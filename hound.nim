import debug, os, ospaths, strutils, unicode

const JAVA = when system.hostOS == "windows": "java.exe" else: "java"

const PATHS = @[
    "/usr/bin",
    "/etc/alternatives",
    "/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands",
    "/bin",
    "/usr/local/bin",
    "/usr/lib/bin",
    "/opt/bin",
    "/opt/local/bin",
    "/opt/shared/bin"
]

template returnIfExists(dir:string, jar:string): untyped =
    var file = dir & DirSep & jar
    if file.fileExists:
        return file
    var file = dir & DirSep & jar.toLower
    if file.fileExists:
        return file

template returnIfExists(locations:seq[string]): untyped =
    for path in locations:
        let javabin = path & DirSep & JAVA
        if javabin.fileExists:
            return javabin


proc find_java*(): string =
    returnIfExists(@[getEnv("JAVA_HOME") & DirSep & "bin"])
    returnIfExists(getEnv("PATH").split(PathSep))
    returnIfExists(PATHS)
    error "Unable to locate Java executable"

proc find_jar*() : string =
    let full = getAppFilename()
    let dir = full.parentDir()

    var filename = full.extractFilename()
    if (filename.endsWith("32") or filename.endsWith("64")):
        filename.delete(filename.len-1, filename.len)
        if (filename == ""):
            error "Not a valid executable"
    filename.add(".jar")

    returnIfExists dir, filename
    returnIfExists dir & DirSep & "lib", filename
    returnIfExists dir.parentDir & DirSep & "Java", filename
    returnIfExists dir.parentDir & DirSep & "lib", filename
    error "Unable to locate JAR"
