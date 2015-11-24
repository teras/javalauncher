#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "debug.h"
#include "file.h"
#include "errormessages.h"
#include "paths.h"

char * check_java_in_path(char * binpath) {
    char * path = malloc(strlen(binpath)+6);
    sprintf(path, "%s" SEPARATOR "java", binpath);
    if (file_exists(path)) {
        return path;
    } else {
        free(path);
        return NULL;
    }
}

char * get_from_JAVA_HOME() {
    char * jhome = getenv("JAVA_HOME");
    if (jhome==NULL)
        return NULL;
    char * binpath = malloc(strlen(jhome) + 5);
    sprintf(binpath, "%s" SEPARATOR "bin", jhome);
    char * path = check_java_in_path(binpath);
    free(binpath);
    return path;
}

char * find_java() {
    char * path;
    int i = 0;
    if ((path = get_from_JAVA_HOME()) != NULL) {
        debug("Java found using JAVA_HOME under `%s`\n", path);
       return path;
    }
    while (PATHS[i] != NULL) {
        if ((path = check_java_in_path(PATHS[i])) != NULL) {
            debug("Java found under `%s`\n", path);
            return path;
        }
        i++;
    }
    fprintf(stderr, NO_JRE);
    return NULL;
}

