import hound, os, proclauncher
import carver
from strutils import replace, startsWith


{.compile: "launchjvm.c".}
proc launchjvm (jvmlib:cstring, jvmopts:cstringArray, c_jvmopts:int, args:cstringArray, c_args:int, mainclass:cstring ) {.importc.}

launchjvm "/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/jre/lib/server/libjsig.dylib", nil, 0, nil, 0, "noclass"


var args: seq[string]
var vmArgs: seq[string]
var postArgs: seq[string]
let launcherPath = findSelf()
let launcherDir = launcherPath.parentDir()
let launcherBase = stripName(launcherPath.extractFilename())

var json = loadJsonFromFile(launcherDir)
if json == "":
   json = loadJsonFromZip(findFile(launcherDir, launcherBase & ".jar"))

let jarPath = findJar(launcherDir, parseJson(json, launcherBase, vmArgs, postArgs))
let javabin = findJava()
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
