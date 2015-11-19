#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <libgen.h>
#include <unistd.h>
#include "utils.h"

int __debug = 0;

void init_args(const int argc, const char** argv) {
    __debug = argc>1 && !memcmp(argv[1],"--debug",8);
}

void debug(const char* format, ...) {
    if (__debug) {
        va_list argptr;
        va_start(argptr, format);
        vfprintf(stderr, format, argptr);
        va_end(argptr);
    }
}

int file_exists(const char* fname) {
    FILE * exec = fopen(fname, "r");
    if (exec != NULL) {
        debug("Debug: File \"%s\" exists.\n", fname);
        fclose(exec);
        return 1;
    } else {
        debug("Debug: File \"%s\" does not exist.\n", fname);
        return 0;
    }
}

char * get_self(const char* argv0) {
    char *buffer = malloc(strlen(argv0)+1);
    sprintf(buffer, "%s", argv0);
    debug("Debug: Executable path: \"%s\".\n", buffer);
    return buffer;
}


char* construct_path(const char* base, const char*ext) {
    char* buffer = malloc(strlen(base) + strlen(ext) + 1);
    sprintf(buffer, "%s%s", base, ext);
    return buffer;
}

char* get_jar_impl(const char* argv0) {
    char *selfpath = get_self(argv0);
    
    char* jarpath = construct_path(selfpath, ".jar");
    if (file_exists(jarpath)) {
        free(selfpath);
        return jarpath;
    }
    free(jarpath);

    char* dirname = get_dir(selfpath);
    char* filename= get_file(selfpath);
    free(selfpath);

    char* p1 = construct_path(dirname, "/lib/");
    char* p2 = construct_path(filename, ".jar");
    free(dirname);
    free(filename);
    jarpath = construct_path(p1, p2);
    free(p1);
    free(p2);

    if (file_exists(jarpath)) {
        return jarpath;
    }

    free(jarpath);
    return NULL;
}

char* get_jar (const char* argv0) {
    if (argv0==NULL)
        return NULL;
    char* found = get_jar_impl(argv0);
    if (found)
        return found;
    char* noext = remove_ext(argv0);
    if (strlen(noext)<1) {
        free(noext);
        return NULL;
    }
    found = get_jar_impl(noext);
    free(noext);
    return found;
}

char * get_dir(const char* argv0) {
    char* path = construct_path(argv0, "");
    char* res = construct_path(dirname(path), "");
    free(path);
    return res;
}

char * get_file(const char* argv0) {
    char* path = construct_path(argv0, "");
    char* res = construct_path(basename(path), "");
    free(path);
    return res;
}

char * remove_ext(const char* file) {
    if (file==NULL)
        return NULL;
    char* buffer = malloc(strlen(file)+1);
    strcpy(buffer, file);
    char *dot = strrchr(buffer, '.');
    if (dot)
        *dot='\0';
    return buffer;
}
