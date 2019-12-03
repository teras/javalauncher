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


proc findJar*(enclosingDir:string, name:string): string {.inline.} =
    var name = name
    template returnIf(dir: string, jar: string): untyped =
        var file = dir & DirSep & jar
        if file.fileExists:
            return file
        file = dir & DirSep & jar.toLowerAscii
        if file.fileExists:
            return file

    if name.endsWith(".exe"):
        name.delete(name.len-3, name.len)
    if name.endsWith("32") or name.endsWith("64"):
        name.delete(name.len-1, name.len)
        if (name == ""):
            error "Not a valid executable"
    name.add(".jar")

    returnIf enclosingDir, name
    returnIf enclosingDir & DirSep & "lib", name
    returnIf enclosingDir.parentDir & DirSep & "Java", name
    returnIf enclosingDir.parentDir & DirSep & "lib", name
    error "Unable to locate JAR"
