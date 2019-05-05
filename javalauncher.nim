
import hound, carver, debug, ospaths, os

template addArgs(arg:string, list:seq[string]): void =
    for item in list:
        arg.add(" " & item.quoteShell)
    
var javabin = find_java()
var jar = find_jar()

var vmargs:seq[string]
var postArgs:seq[string]
let json = extractData(jar)
if json != "":
    findArgs(json, vmargs, postArgs)

var args = javabin.quoteShell
args.addArgs vmargs
args.addArgs @["-jar", jar]
args.addArgs postArgs
args.addArgs commandLineParams()

debug args

quit execShellCmd(args)