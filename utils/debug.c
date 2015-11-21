#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include "arrays.h"

int __debug = 0;

void init_args(int argc, char** argv) {
    for(int i = 1 ; i < argc ; i++)
        if (!memcmp(argv[i],"--debug",8)) {
            __debug = 1;
            break;
        }
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
