import hound, os, proclauncher
import carver
from strutils import startsWith
import sequtils

let jlilib = findJliLib()
let launcherPath = findSelf()
if jlilib.len > 0 and isalreadyParsed():
    launchJli(jlilib, concat(@[launcherPath], commandLineParams()))
    # will quit here

var vmArgs: seq[string]
var appArgs: seq[string]
var mainclass: string
var splashscreen: string
var classpath: string

# launcher
let launcherDir = launcherPath.parentDir()
let launcherBase = stripName(launcherPath.extractFilename())

# JSON
let filejson = loadJsonFromFile(launcherDir)
let jarName = findJarName(launcherBase, filejson)
let jarPath = findJar(launcherDir, jarName)
let jarDir = jarPath.parentDir
let json = updateJsonFromJar(jarPath, filejson)
populateArguments(json, vmArgs, appArgs, mainclass, splashscreen, classpath, jarDir, launcherDir)
vmArgs.add("-Dself.exec=" & launcherPath)

var still_starting = true
for arg in commandLineParams():
    if still_starting and arg.startsWith("-D"):
        vmArgs.add(arg)
    else:
        still_starting = false
        appArgs.add(arg)

# Call Java
let args = concat(@[launcherPath], vmArgs, @["-jar", jarPath], appArgs)
if jlilib != "":
    launchJli(jlilib, args)
else:
    let javalib = findJvmLib()
    if javalib != "":
        launchjvm(javalib, vmArgs, jarPath, appArgs, mainclass, splashscreen, classpath)
    else:
        let javabin = findJava()
        launchJre(javabin, args)
