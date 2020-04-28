import os, strutils

# START: User configuration
const APPVERSION {.strdefine.} = "1.0"
const LONGVERSION {.strdefine.} = "1.0.0.0"

const COMPANY {.strdefine.} = "Company Name"
const DESCRIPTION {.strdefine.} = "Application description"
const COPYRIGHT {.strdefine.} = COMPANY
const APPNAME {.strdefine.} = "app"
# END: User configuration

const BINVERSION = LONGVERSION.replace('.', ',')
const INTERNALNAME = APPNAME.toLowerAscii
const FILENAME = INTERNALNAME & ".exe"

const ICONRC = if "target/appicon.ico".fileExists: "101 ICON \"appicon.ico\"\n" else:""
const VERSIONRC = """
1 VERSIONINFO
FILEVERSION     """ & BINVERSION  & """

PRODUCTVERSION  """ & BINVERSION  & """

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
      VALUE "OriginalFilename", """" & FILENAME & """"
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
