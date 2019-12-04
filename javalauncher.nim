import hound, os, proclauncher
import carver
from strutils import replace, startsWith

var args: seq[string]
var vmArgs: seq[string]
var postArgs: seq[string]
let launcherPath = findSelf()
let launcherDir = launcherPath.parentDir()

let javabin = findJava()
let json = loadJson(launcherDir)

let jarFilename = parseJson(json, launcherPath.extractFilename(), vmArgs, postArgs)
let jarPath = findJar(launcherDir, jarFilename)
let javaDir = javabin.parentDir
let jarDir = jarPath.parentDir

proc asArg(item: string): string {.inline} =
    return item
        .replace("@@JAVA_LOCATION@@", javaDir)
        .replace("@@JAR_LOCATION@@", jarDir)
        .replace("@@LAUNCH_LOCATION@@", launcherDir)
proc addArgs(args: var seq[string], list: seq[string]) {.inline} =
    for item in list:
        args.add(item.asArg)

var still_starting = true
for arg in commandLineParams():
    if still_starting and arg.startsWith("-D"):
        vmArgs.add(arg)
    else:
        still_starting = false
        postArgs.add(arg)

# let json = extractData(launcherPath)
args.addArgs(vmArgs)
args.add("-Dself.exec=" & launcherPath)
args.add("-jar")
args.add(jarPath)
args.addArgs(postArgs)

launch(javabin, args)
