#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h>
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
        debug("Searching for JRE under `%s` %s\n", PATHS[i], SEPARATOR);
        if ((path = check_java_in_path(PATHS[i])) != NULL) {
            debug("Java found under `%s`\n", path);
            return path;
        }
        i++;
    }
    fprintf(stderr, NO_JRE);
    return NULL;
}

void append_jar_ext(char* jar) {
    jar[0] = '.';
    jar[1] = 'j';
    jar[2] = 'a';
    jar[3] = 'r';
    jar[4] = 0;
}

int find_jar_by_exec(char* jar, int size) {
    char*fname = basename(jar);
    int fsize = strlen(fname);
    append_jar_ext(jar+size);
    debug("Guessing JAR file under %s\n", jar);
    if (file_exists(jar))
        return 1;
    size=strnlen(dirname(jar), size);
    jar[size+1] = 'l';
    jar[size+2] = 'i';
    jar[size+3] = 'b';
    jar[size+4] = SEPARATOR[0];
    memcpy(jar+size+5,fname, fsize);
    append_jar_ext(jar+size+fsize+5);
    debug("Guessing JAR file under %s\n", jar);
    if (file_exists(jar))
        return 1;
    return 0;
}

char * find_jar(const char* argv0, int isvalid) {
    char* jar;
    int size = strlen(argv0);
    jar = malloc(size + 9); // lib/.jar + '0'
    memcpy(jar, argv0, size);
    if (isvalid) {
        jar[size] = 0;
        return jar;
    } else {
        if (find_jar_by_exec(jar, size))
            return jar;
        memcpy(jar, argv0, size);
        if ((jar[size-2]=='3' && jar[size-1]=='2') || (jar[size-2]=='6' && jar[size-1]=='4')) {
            jar[size-2] = 0;
            if (find_jar_by_exec(jar, size-2))
                return jar;
        }
       free(jar);
        return NULL;
    }
}

