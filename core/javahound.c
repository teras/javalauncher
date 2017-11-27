#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h>
#include <unistd.h>
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
        } else {
            debug("Unable to find Java under `%s`\n", PATHS[i]);
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

int find_jar_by_exec_impl(char* jar) {
    if (file_exists(jar)) {
        debug("Found JAR file under %s\n", jar);
        return 1;
    } else {
        debug("Unable to find JAR file under %s\n", jar);
        return 0;
    }
}

int find_jar_by_exec(char* jar, int size) {
    char*basen = basename(jar);
    int fsize = strlen(basen);
    char* fname = malloc(fsize+1);
    memcpy(fname, basen, fsize);
    fname[size] = '\0';

    append_jar_ext(jar+size);
    if (find_jar_by_exec_impl(jar)) {
        free(fname);
        return 1;
    }
    char* dir = dirname(jar);
    size=strnlen(dir, size);
    if ( size==1 && strncmp(".", dir,1)==0) {
        size=-1;
    } else {
        jar[size] = SEPARATOR[0];
    }
    jar[size+1] = 'l';
    jar[size+2] = 'i';
    jar[size+3] = 'b';
    jar[size+4] = SEPARATOR[0];
    memcpy(jar+size+5,fname, fsize);
    append_jar_ext(jar+size+fsize+5);
    if (find_jar_by_exec_impl(jar)) {
        free(fname);
        return 1;
    }

    jar[size+1] = '.';
    jar[size+2] = '.';
    jar[size+3] = '/';
    jar[size+4] = 'l';
    jar[size+5] = 'i';
    jar[size+6] = 'b';
    jar[size+7] = SEPARATOR[0];
    memcpy(jar+size+8,fname, fsize);
    append_jar_ext(jar+size+fsize+8);
    free(fname);
    return find_jar_by_exec_impl(jar);
}

char * find_jar(const char* argv0, int isvalid) {
    char* jar;
    int size = strlen(argv0);
    jar = malloc(size + 12); // ../lib/.jar + \0
    memcpy(jar, argv0, size);
    jar[size] = 0;
    if (isvalid) {
        return jar;
    } else {
        if (find_jar_by_exec(jar, size))
            return jar;
        memcpy(jar, argv0, size+1);
        if ((jar[size-2]=='3' && jar[size-1]=='2') || (jar[size-2]=='6' && jar[size-1]=='4')) {
            size-=2;
            jar[size] = 0;
            if (find_jar_by_exec(jar, size))
                return jar;
            size+=4;
        }
        append_jar_ext(jar+size);
        fprintf(stderr, "Unable to locate JAR `%s`\n", basename(jar));
        free(jar);
        return NULL;
    }
}

