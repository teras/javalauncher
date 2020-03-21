import os

let shouldDebug* = existsEnv("JAVALAUNCHER_DEBUG")

proc debug*(message: string): void =
    if shouldDebug:
        echo " [DEBUG] " & message
    return

proc error*(message: string): void =
    stderr.writeLine message
    quit(QuitFailure)
