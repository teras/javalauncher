import os, strutils

const APPVERSION {.strdefine.} = "1.0"
const LONGVERSION {.strdefine.} = "1.0.0.0"

const COMPANY {.strdefine.} = "Company Name"
const DESCRIPTION {.strdefine.} = "Application description"
const COPYRIGHT {.strdefine.} = COMPANY
const APPNAME {.strdefine.} = "app"
const APPFILE {.strdefine.} = APPNAME & ".exe"

const ICON {.strdefine.} = "frame.ico"


const ICONRC = 
    if ICON != "" and ICON.fileExists:
        writeFile("target/appicon.ico", readFile(ICON))
        "101 ICON \"appicon.ico\"\n"
    else :
        ""

const BINVERSION = LONGVERSION.replace('.', ',')
const INTERNALNAME = if APPFILE.endsWith(".exe"): APPFILE.substr(0,APPFILE.len-5) else:APPFILE

const VERSIONRC = """
1 VERSIONINFO
FILEVERSION     """ & BINVERSION  & """

PRODUCTVERSION  1,0,0,0
BEGIN
  BLOCK "StringFileInfo"
  BEGIN
    BLOCK "040904E4"
    BEGIN
      VALUE "CompanyName", """" & COMPANY & """"
      VALUE "FileDescription", """" & DESCRIPTION & """"
      VALUE "FileVersion", """" & APPVERSION & """"
      VALUE "InternalName", """" & INTERNALNAME & """"
      VALUE "LegalCopyright", """" & COPYRIGHT & """"
      VALUE "OriginalFilename", """" & APPFILE & """"
      VALUE "ProductName", """" & APPNAME & """"
      VALUE "ProductVersion", """" & APPVERSION & """"
    END
  END
  BLOCK "VarFileInfo"
  BEGIN
    VALUE "Translation", 0x409, 1252
  END
END"""


when defined(gcc) and defined(windows):
    static:
        when ICONRC != "":
            writeFile("target/icon.rc", ICONRC)
            when defined(x86):
                echo staticExec("i686-w64-mingw32-windres target/icon.rc -O coff -o target/icon.res")
            else:
                echo staticExec("x86_64-w64-mingw32-windres target/icon.rc -O coff -o target/icon.res")
            {.link: "target/icon.res".}
        writeFile("target/version.rc", VERSIONRC)
        when defined(x86):
            echo staticExec("i686-w64-mingw32-windres target/version.rc -O coff -o target/version.res")
        else:
            echo staticExec("x86_64-w64-mingw32-windres target/version.rc -O coff -o target/version.res")
        {.link: "target/version.res".}
