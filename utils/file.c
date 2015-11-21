#include <stdio.h>

int file_exists(const char* fname) {
    FILE * exec = fopen(fname, "r");
    if (exec != NULL) {
        fclose(exec);
        return 1;
    }
    return 0;
}
