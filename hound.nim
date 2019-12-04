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

proc findJava*(): string {.inline.} =
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

proc findFile*(path: string, name: string): string =
    template returnIf(dir: string, file: string): untyped =
        var target = dir & DirSep & file
        if target.fileExists:
            return target
        target = dir & DirSep & file.toLowerAscii
        if target.fileExists:
            return target
    returnIf path, name
    returnIf path & DirSep & "lib", name
    returnIf path.parentDir & DirSep & "Java", name
    returnIf path.parentDir & DirSep & "lib", name
    return ""

proc findJar*(enclosingDir:string, name:string): string {.inline.} =
    var name = name
    if name.endsWith(".exe"):
        name.delete(name.len-3, name.len)
    if name.endsWith("32") or name.endsWith("64"):
        name.delete(name.len-1, name.len)
        if (name == ""):
            error "Not a valid executable"
    name.add(".jar")
    let found = findFile(enclosingDir, name)
    if found != "" : return found else: error "Unable to locate JAR"
