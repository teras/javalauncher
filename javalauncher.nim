import hound, os, proclauncher, producer
import carver
from strutils import replace, startsWith

var args: seq[string]
var vmargs: seq[string]
var postArgs: seq[string]

if isInProducerMode():
    produce()
    echo "producer"

let selfbin = findSelf()
let json = loadJson(selfbin)
let selfname = findArgs(json, vmargs, postArgs)
# let jarname = findJar(json, selfbin)


let javabin = find_java()
let jar = find_jar("")
let java_location = javabin.parentDir
let jar_location = jar.parentDir
let launch_location = selfbin.parentDir()

proc asArg(item: string): string {.inline} =
    return item
        .replace("@@JAVA_LOCATION@@", java_location)
        .replace("@@JAR_LOCATION@@", jar_location)
        .replace("@@LAUNCH_LOCATION@@", launch_location)
proc addArgs(args: var seq[string], list: seq[string]) {.inline} =
    for item in list:
        args.add(item.asArg)

var still_starting = true
for arg in commandLineParams():
    if still_starting and arg.startsWith("-D"):
        vmargs.add(arg)
    else:
        still_starting = false
        postArgs.add(arg)

# let json = extractData(selfbin)
args.addArgs(vmargs)
args.add("-Dself.exec=" & selfbin)
args.add("-jar")
args.add(jar)
args.addArgs(postArgs)

launch(javabin, args)
