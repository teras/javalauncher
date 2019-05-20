proc debug*(message: string): void =
    echo message
    return

proc error*(message: string): void =
    echo message
    quit(QuitFailure)
