import osproc, streams

var exec:Process = nil

proc hook() {.noconv.} =
    if exec!=nil:
        exec.terminate()
    quit 0

proc launch*(cmd:string, args:seq[string]) =
    setControlCHook(hook)
    exec = startProcess(cmd, args=args, options={poEchoCmd})
    let outS = exec.outputStream()
    let errS = exec.errorStream()
    var line = newStringOfCap(120).TaintedString
    while true:
        if  outS.readLine(line):
            echo line.string
        elif errS.readLine(line):
            stderr.writeLine line
        elif not exec.running():
            break
    exec.close()
    exec = nil