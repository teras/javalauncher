import osproc, strutils

proc getHiDpi*():float=
    when system.hostOS != "linux" :
        return -1.0
    else:
        let (output,code) = execCmdEx("xrdb -q")
        if code == 0:
            for line in output.splitLines:
                if line.startsWith("Xft.dpi:"):
                    try:
                        return line.substr(line.find(":")+1).strip.parseFloat
                    except:
                        discard
        return -1.0

proc hasDpiArg*(args:seq[string]):bool =
    for arg in args:
        if arg.startsWith("-Dsun.java2d.uiScale="):
            return true
    return false