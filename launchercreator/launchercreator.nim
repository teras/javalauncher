import argparse, os

proc safeSP(input:string): string=
    if input == "": return ""
    result = input.replace("'", "\\'")
    if result.contains(" "): result = "'" & result & "'"
    result = " " & result

let p = newParser("launchercreator"):
    help("Create windows javalauncher executables with specific resources")
    option("-n", "--name", help="name of the application")
    option("-c", "--company", help="company name")
    option("-d", "--description", help="description of the application, defaults to application name")
    option("-v", "--version", help="version of the application, defaults to 1.0")
    option("-l", "--longversion", help="long version of the application in the form a.b.c.d, defaults to 1.0.0.0")
    option("-r", "--copyright", help="copyright info, defaults to company name")
    option("-i", "--icon", help="")

let o = p.parse(commandLineParams())
if o.name == "": quit("Please provide the name of the application")
if o.company == "": quit("Please provide the company name")

let basename = o.name.replace(' ', '_').toLowerAscii

let target = "target".absolutePath
target.createDir
assert target.existsDir

let hasIcon = if o.icon != "":
    if not o.icon.fileExists or not o.icon.endsWith(".ico"):
        quit("Invalid icon file: "&o.icon)
    copyFile(o.icon, joinPath(target, "appicon.ico"))
    true
else:
    false

template docker(bits32:bool) =
    let exec = if bits32: basename & ".32.exe" else: basename & ".64.exe"
    let cpu = if bits32: "i386" else: "amd64"
    let strip = if bits32: "i686-w64-mingw32-strip" else: "x86_64-w64-mingw32-strip"
    let cmd = "docker run --rm -v " & (target & ":/root/target").quoteShell &
        " teras/javalauncher bash -c \"nim c -d:release --opt:size --passC:-Iinclude --passC:-Iinclude/windows -d:mingw" &
        (if o.name != "": safeSP("-d:APPNAME=" & o.name) else: "") &
        (if o.company != "": safeSP("-d:COMPANY=" & o.company) else: "") &
        (if o.description != "": safeSP("-d:DESCRIPTION=" & o.description) else: "") &
        (if o.version != "": safeSP("-d:APPVERSION=" & o.version) else: "") &
        (if o.longversion != "": safeSP("-d:LONGVERSION=" & o.longversion) else: "") &
        (if o.copyright != "": safeSP("-d:COPYRIGHT=" & o.copyright) else: "") &
        (if hasIcon: safeSP("-d:ICON=target/app.ico") else: "") &
        " --app:gui --cpu:" & cpu & " -o:target/" & exec & " javalauncher ; " &
        strip & " target/" & exec & "\""
    echo "▶️ " & cmd 
    if cmd.execShellCmd != 0: quit("Unable to create application "&o.name&" for architecture "&cpu)
docker(true)
docker(false)


