#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#ifdef __linux__ 
    #include <linux/limits.h>
#else
    #include <limits.h>
#endif

char* getExecPath() {
    char* path = malloc(PATH_MAX);
    memset(path, 0, PATH_MAX);
    size_t size = readlink("/proc/self/exe", path, PATH_MAX-1);
    if (size<1) {
        free(path);
        return NULL;
    } else {
        return path;
    }
}

int file_exists(const char* fname) {
    FILE * exec = fopen(fname, "r");
    if (exec != NULL) {
        fclose(exec);
        return 1;
    }
    return 0;
}
