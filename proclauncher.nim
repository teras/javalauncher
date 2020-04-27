import posix, debug, sequtils, strutils, os, system, winres

const CP_SEP = when system.hostOS == "windows": ";" else: ":"

{.compile: "launchjvm.c".}
proc launchjvm (jvmlib:cstring, vmArgs:cstringArray, vmArgs_size:int, appArgs:cstringArray, appArgs_size:int, mainclass:cstring ) :int {.importc.}
proc launchjli(jlilib:cstring, argc:int, argv:cstringArray) :int {.importc.}

proc isalreadyParsed*() : bool =
    for arg in commandLineParams():
        if arg.startsWith("-Dself.exec="):
            debug "Will rerun using JLI library"
            return true
    return false

proc constructClassPath(jarfile:string, classpath:string) : string =
    result = jarfile
    let basepath = jarfile.parentDir
    for jar in classpath.splitWhitespace:
        let newfile = joinPath(basepath, jar)
        if not newfile.existsFile:
            echo "WARNING: Unable to locate JAR file " & newfile
        else:
            result = result & CP_SEP & newfile
    debug "Classpath: " & result

proc launchJvm*(jvmlib:string, vmArgs:seq[string], jarfile:string, appArgs:seq[string],
        mainclass:string, splashscreen:string, classpath:string) =
    
    let vmArgsC = allocCStringArray(concat(@["-Djava.class.path=" & constructClassPath(jarfile, classpath)], vmArgs))
    let vmArgsL = vmArgs.len+1
    let appArgsC = allocCStringArray(appArgs)
    let appArgsL = appArgs.len
    debug "Launching (jvm): " & jvmlib & "\n  " & $vmArgs & "\n  " & $appArgs & "\n  " & mainclass
    let exitCode = launchjvm(jvmlib, vmArgsC, vmArgsL, appArgsC, appArgsL, mainclass.replace('.', '/').cstring)
    deallocCStringArray(vmArgsC)
    deallocCStringArray(appArgsC)
    quit(exitCode)


proc launchJli*(jlilib:string, args:seq[string]) =
    debug "Launching (jli): " & jlilib & " " & $args
    let cargs:cstringArray = allocCStringArray(args)
    let exitcode = launchjli(jlilib.cstring, args.len, cargs)
    deallocCStringArray(cargs)
    quit(exitcode)

proc launchJre*(javabin:string, args:seq[string]) =
    when system.hostOS == "windows":
        var args = args
        for i in 0..<args.len:
            args[i] = args[i].quoteShellWindows
    debug "Launching (java): " & javabin & " " & $args
    let cargs:cstringArray = allocCStringArray(args)
    discard execv(cstring(javabin), cargs)
    deallocCStringArray(cargs)
    error "Unable to launch `" & javabin & "`"
