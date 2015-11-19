#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "messages.h"
#include "paths.h"
#include "utils.h"

char * get_from_JAVA_HOME() {
    char * jhome = getenv("JAVA_HOME");
    if (jhome != NULL) {
        char * path = malloc(strlen(jhome) + 10);
        sprintf(path, "%s/bin/java", jhome);
        if (file_exists(path)) {
            debug("Debug: Found JAVA_HOME: \"%s\".\n", jhome);
            return path;
        }
        debug("Debug: Invalid JAVA_HOME: \"%s\".\n", jhome);
    } else {
        debug("Debug: Unset JAVA_HOME.\n");
    }
    return NULL;
}

char * check_java_in_path(char * path) {
    char * buffer = malloc(strlen(path)+6);
    sprintf(buffer, "%s/java", path);
    if (file_exists(buffer)) {
        return buffer;
    } else {
        free(buffer);
        return NULL;
    }
}

char * find_java() {
    char * path;
    int i = 0;

    if ((path = get_from_JAVA_HOME()) != NULL) {
        return path;
    }
    while (paths[i] != NULL) {
        if ((path = check_java_in_path(paths[i])) != NULL) {
            return path;
        }
        i++;
    }
    debug("Warning: Unable to locate Java executable; just try anyhow and hope for the best.\n");
    path = malloc(5);
    sprintf(path, "java");
    return path;
}

int main(const int argc, const char** argv) {
    init_args(argc, argv);
    char* jarpath = get_jar(argv[0]);
    char* dirname = get_dir(argv[0]);
    char* filename = get_file(argv[0]);
    if (jarpath!=NULL && chdir(dirname) == 0 ) {
        char* cd = getcwd(NULL,0);
        debug("Debug: Working directory is \"%s\".\n", cd);
        free(cd);

        char * java = find_java();
        char* jargs[] = {java, "-jar", jarpath, 0};
        execvp(java, jargs);
        free(java);
        fprintf(stderr, "Error: Unable to execute Java Runtime.\n\n%s", NO_JRE);
    } else {
        char* anoext = remove_ext(argv[0]);
        char* fnoext = remove_ext(filename);
        fprintf(stderr, "Error: unable to find JAR file under:\n  %s.jar\n  %s/lib/%s.jar\n  %s.jar\n  %s/lib/%s.jar\n", argv[0], dirname, filename, anoext, dirname, fnoext);
        free(anoext);
        free(fnoext);
    }
    free(jarpath);
    free(dirname);
    free(filename);
    return (EXIT_FAILURE);
}


