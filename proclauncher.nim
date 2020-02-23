import posix, debug

proc launch*(cmd:string, args:seq[string]) =
    var cargs:cstringArray = allocCStringArray([])
    cargs[0] = cmd
    for i in 1..args.len:
        cargs[i] = cstring(args[i-1])
    discard execv(cstring(cmd), cargs)
    deallocCStringArray(cargs)
    error "Unable to launch `" & cmd & "`"

{.compile: "launchjvm.c".}
proc launchjvm* (jvmlib:cstring, jvmopts:cstringArray, c_jvmopts:int, args:cstringArray, c_args:int, mainclass:cstring ) {.importc.}
