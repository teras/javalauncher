import debug, os, strutils, pure/strformat

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

# When given at compile time, the JRE/JAR paths could be pinned
const JARPATH {.strdefine.} = ""
const JREPATH {.strdefine.} = ""

proc findSelf*(): string {.inline.} = getAppFilename().absolutePath().normalizedPath()

proc findJliLib*(local:bool): string =
    template returnIf(loc: string): untyped =
        let target = loc / JLILIB
        if target.fileExists:
            debug "Found JLI under " & target
            return target
    template returnIfBoth(location:string): untyped =
        returnIf location / "lib" / "jli"
        returnIf location / "lib"
        returnIf location / "bin"

    if local:
        let current = findSelf().parentDir()
        if JREPATH!="":
            returnIfBoth if JREPATH.isAbsolute: JREPATH else: current / JREPATH
        returnIfBoth current.parentDir / "jre"
        returnIfBoth current.parentDir / "Java"
        returnIfBoth current / "jre"
        returnIfBoth current / "Java"
    else:
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

proc findJvmLib*(local:bool): string =
    template returnIf(loc: string): untyped =
        let target = loc / JVMLIB
        if target.fileExists:
            debug "Found JVM under " & target
            return target
    template returnIfBoth(location:string): untyped =
        returnIf location / "lib" / "server"
        returnIf location / "bin" / "server"

    if local:
        let current = findSelf().parentDir()
        if JREPATH!="":
            returnIfBoth if JREPATH.isAbsolute: JREPATH else: current / JREPATH
        returnIfBoth current.parentDir / "jre"
        returnIfBoth current.parentDir / "Java"
        returnIfBoth current / "jre"
        returnIfBoth current / "Java"
    else:
        returnIfBoth getEnv("JAVA_HOME") / "jre"
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

proc findJava*(local:bool): string =
    template returnIf(location: string): untyped =
        let javabin = location / JAVA
        if javabin.fileExists:
            debug "Found Java under " & javabin
            return javabin
    template returnIf(locations: seq[string]): untyped =
        for path in locations:
            returnIf path
    template returnIfRec(location: string): untyped =
        for dir in walkDir location:
            if dir.kind == PathComponent.pcDir:
                returnIf dir.path / "bin"

    if local:
        var current = findSelf().parentDir()
        if JREPATH!="":
            returnIf if JREPATH.isAbsolute: JREPATH / "bin" else: current / JREPATH / "bin"
        returnIfRec current
        returnIfRec current.parentDir
    else:
        returnIf getEnv("JAVA_HOME") / "bin"
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
                var target = dir / fullname
                if target.fileExists:
                    return target
                target = dir / fullname.toLowerAscii
                if target.fileExists:
                    return target
    returnIf path, name
    returnIf path / "lib", name
    returnIf path / "app", name
    returnIf path.parentDir / "Java", name
    returnIf path.parentDir / "lib", name
    returnIf path.parentDir / "app", name
    returnIf path.parentDir / "Resources" / "Java", name
    return if fuzzy: "" else: findFile(path, name, ext, true)

proc stripName*(name:string):string=
    var name = name
    if name.toLowerAscii().endsWith(".exe"):
        name.delete(name.len-4..name.len-1)
    if name.endsWith("32") or name.endsWith("64"):
        name.delete(name.len-1..name.len-1)
        if (name == ""):
            error "Not a valid executable"
    return name

proc findJar*(enclosingDir:string, name:string): string =
    let enclosingDir = if enclosingDir.toLower.endsWith("macos"): enclosingDir.parentDir else: enclosingDir
    if JARPATH!="":
        if JARPATH.isAbsolute:
            if JARPATH.fileExists:
                return JARPATH
        else:
            if (enclosingDir / JARPATH).fileExists:
                return (enclosingDir / JARPATH)
    let found = findFile(enclosingDir, stripName(name) , "jar")
    if found != "" : result = found else: error "Unable to locate JAR around location " & enclosingDir
    debug "JAR path is " & result
