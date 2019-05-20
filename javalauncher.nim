import hound, carver, debug, ospaths, os
from strutils import replace

template addArgs(arg: string, list: seq[string]): void =
    for item in list:
        arg.add(" " & item
            .replace("@@JAVA_LOCATION@@", java_location)
            .replace("@@JAR_LOCATION@@", jar_location)
            .replace("@@LAUNCH_LOCATION@@", launch_location)
            .quoteShell)

let javabin = find_java()
let jar = find_jar()

let java_location = javabin.parentDir
let jar_location = jar.parentDir
let launch_location = getAppFilename().parentDir()

var vmargs: seq[string]
var postArgs: seq[string]
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
