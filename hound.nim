import debug, os, strutils

const JAVA = when system.hostOS == "windows": "javaw.exe" else: "java"
const JVMLIB = when system.hostOS == "macosx": "libjvm.dylib"
    elif system.hostOS == "windows": "jvm.lib"
    elif system.hostOS == "linux": "libjvm.so"
    else: "--"
const JLILIB = when system.hostOS == "macosx": "libjli.dylib"
    elif system.hostOS == "windows": "jvm.lib"
    elif system.hostOS == "linux": "libjli.so"
    else: "--"

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

const JVMPATHS = @[
    "/Library/Java/JavaVirtualMachines",
    "/usr/lib/jvm/"
]

proc findSelf*(): string {.inline.} = getAppFilename().absolutePath().normalizedPath()

proc findJliLib*(): string =
    template returnIf(loc: string): untyped =
        let target = loc & DirSep & JLILIB
        if target.fileExists: return target
    template returnIfBoth(location:string): untyped =
        returnIf location & DirSep & "lib" & DirSep & "jli"
        returnIf location & DirSep & "bin"

    let current = findSelf().parentDir()
    returnIfBoth current.parentDir & DirSep & "jre"
    returnIfBoth current.parentDir & DirSep & "Java"
    returnIfBoth current & DirSep & "jre"
    returnIfBoth current & DirSep & "Java"
    returnIfBoth getEnv("JAVA_HOME")
    for jvmpath in JVMPATHS:
        for dir in walkDir jvmpath:
            if dir.kind == PathComponent.pcDir:
                let path = dir.path
                when system.hostOS == "macosx":
                    returnIfBoth path & "/Contents/Home/jre"
                when system.hostOS == "linux":
                    returnIfBoth path & "/jre/lib/amd64"
    ""

proc findJvmLib*(): string =
    template returnIf(loc: string): untyped =
        let target = loc & DirSep & JVMLIB
        if target.fileExists: return target
    template returnIfBoth(location:string): untyped =
        returnIf location & DirSep & "lib" & DirSep & "server"
        returnIf location & DirSep & "bin" & DirSep & "server"

    let current = findSelf().parentDir()
    returnIfBoth current.parentDir & DirSep & "jre"
    returnIfBoth current.parentDir & DirSep & "Java"
    returnIfBoth current & DirSep & "jre"
    returnIfBoth current & DirSep & "Java"
    returnIfBoth getEnv("JAVA_HOME") & DirSep & "jre"
    returnIfBoth getEnv("JAVA_HOME")
    for jvmpath in JVMPATHS:
        for dir in walkDir jvmpath:
            if dir.kind == PathComponent.pcDir:
                let path = dir.path
                when system.hostOS == "macosx":
                    returnIfBoth path & "/Contents/Home/jre"
                when system.hostOS == "linux":
                    returnIfBoth path & "/jre/lib/amd64"
    ""

proc findJava*(): string =
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

proc findFile*(path: string, name: string, ext:string, fuzzy=false): string =
    template returnIf(dir: string, file: string): untyped =
        if dir.dirExists:
            if fuzzy:
                let cext = "." & ext
                var bestMatch:string = ""
                for (comp,path) in dir.walkDir:
                    if comp == pcFile:
                        let filename = path.extractFilename.toLowerAscii
                        if filename.startsWith(file) and filename.endsWith(cext):
                            if bestMatch == "" or bestMatch.len > path.len:
                                bestMatch = path
                if bestMatch != "" :
                    return bestMatch
            else:
                let fullname = file & "." & ext
                var target = dir & DirSep & fullname
                if target.fileExists:
                    return target
                target = dir & DirSep & fullname.toLowerAscii
                if target.fileExists:
                    return target
    returnIf path, name
    returnIf path & DirSep & "lib", name
    returnIf path.parentDir & DirSep & "Java", name
    returnIf path.parentDir & DirSep & "lib", name
    returnIf path.parentDir & DirSep & "Resources" & DirSep & "Java", name
    return if fuzzy: "" else: findFile(path, name, ext, true)

proc stripName*(name:string):string=
    var name = name
    if name.toLowerAscii().endsWith(".exe"):
        name.delete(name.len-4, name.len)
    if name.endsWith("32") or name.endsWith("64"):
        name.delete(name.len-1, name.len)
        if (name == ""):
            error "Not a valid executable"
    return name

proc findJar*(enclosingDir:string, name:string): string =
    let found = findFile(enclosingDir, stripName(name) , "jar")
    if found != "" : result = found else: error "Unable to locate JAR around location " & enclosingDir
    debug "JAR path is " & result
