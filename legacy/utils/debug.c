#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "debug.h"

int __debug = 0;

void init_env() {
    __debug = getenv(LAUNCHER_DEBUG) != NULL;
}

void debug(const char* format, ...) {
    if (__debug) {
        va_list argptr;
        va_start(argptr, format);
        fprintf(stderr, "Debug: ");
        vfprintf(stderr, format, argptr);
        va_end(argptr);
    }
}

int is_debug() {
    return __debug;
}
