#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <libgen.h>
#include <unistd.h>
#include "utils.h"

int __debug = 0;

void init_args(int argc, char** argv) {
    for(int i = 1 ; i < argc ; i++)
        if (!memcmp(argv[i],"--debug",8)) {
            __debug = 1;
            return;
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

int file_exists(const char* fname) {
    FILE * exec = fopen(fname, "r");
    if (exec != NULL) {
        debug("File `%s` exists\n", fname);
        fclose(exec);
        return 1;
    } else {
        debug("File `%s` does not exist\n", fname);
        return 0;
    }
}
