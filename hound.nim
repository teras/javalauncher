import debug, os, strutils

const JAVA = when system.hostOS == "windows": "javaw.exe" else: "java"

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

proc findSelf*(): string {.inline.} = getAppFilename().absolutePath().normalizedPath()

proc find_java*(): string =
    template returnIf(location: string): untyped =
        let javabin = location & DirSep & JAVA
        if javabin.fileExists:
            return javabin
    template returnIf(locations: seq[string]): untyped =
        for path in locations:
            returnIf path
    template returnIfRec(location: string): untyped =
        for dir in walkDir location:
            if dir.kind == PathComponent.pcDir:
                returnIf dir.path & DirSep & "bin"

    var current = findSelf().parentDir()
    returnIfRec current
    returnIfRec current.parentDir
    returnIf getEnv("JAVA_HOME") & DirSep & "bin"
    returnIf getEnv("PATH").split(PathSep)
    returnIf PATHS
    error "Unable to locate Java executable"


proc find_jar*(selfName : string): string =
    template returnIf(dir: string, jar: string): untyped =
        var file = dir & DirSep & jar
        if file.fileExists:
            return file
        file = dir & DirSep & jar.toLowerAscii
        if file.fileExists:
            return file

    let full = findSelf()
    let dir = full.parentDir()

    var filename = full.extractFilename()
    if filename.endsWith(".exe"):
        filename.delete(filename.len-3, filename.len)
    if filename.endsWith("32") or filename.endsWith("64"):
        filename.delete(filename.len-1, filename.len)
        if (filename == ""):
            error "Not a valid executable"
    filename.add(".jar")

    returnIf dir, filename
    returnIf dir & DirSep & "lib", filename
    returnIf dir.parentDir & DirSep & "Java", filename
    returnIf dir.parentDir & DirSep & "lib", filename
    error "Unable to locate JAR"
