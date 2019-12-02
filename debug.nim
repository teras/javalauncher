import os

let shouldDebug* = existsEnv("DEBUG")

proc debug*(message: string): void =
    if shouldDebug:
        echo message
    return

proc error*(message: string): void =
    stderr.writeLine message
    quit(QuitFailure)
