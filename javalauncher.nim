import hound, carver, debug, ospaths, os, proclauncher
from strutils import replace

let javabin = find_java()
let jar = find_jar()
let java_location = javabin.parentDir
let jar_location = jar.parentDir
let launch_location = getAppFilename().parentDir()

proc asArg(item:string) : string =
    return item
        .replace("@@JAVA_LOCATION@@", java_location)
        .replace("@@JAR_LOCATION@@", jar_location)
        .replace("@@LAUNCH_LOCATION@@", launch_location)
proc addArgs(args: var seq[string], list:seq[string]) =
    for item in list:
        args.add(item.asArg)

var args: seq[string]
var vmargs: seq[string]
var postArgs: seq[string]

let json = extractData(jar)
if json != "":
    findArgs(json, vmargs, postArgs)
args.addArgs(vmargs)
args.add("-jar")
args.add(jar)
args.addArgs(postArgs)
args.addArgs(commandLineParams())

launch(javabin, args)
