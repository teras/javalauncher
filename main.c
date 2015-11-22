#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include <unistd.h>
#include "debug.h"
#include "javahound.h"
#include "arrays.h"
#include "ziputils.h"

#define LAUNCHER_ENTRY "META-INF/launcher"

int main(int argc, char** argv) {
    init_env();
    char* java = find_java();
    if (java) {
        char* javabin[] = {java, 0};
        char* javajar[] = {"-jar", argv[0], 0};
        char** givenargs = array_convert(argc - 1, argv + 1);

        char** args = array_copy(javabin);

        char* found = getEntry(argv[0], LAUNCHER_ENTRY);
        if (found!=NULL) {
            char** embedparams = array_split(found, '\n');
            free(found);
            args = array_replace(args, array_concat(args, embedparams));
            array_free(embedparams);
        }

        args = array_replace(args, array_concat(args, javajar));
        args = array_replace(args, array_concat(args, givenargs));
        array_free(givenargs);

        if (is_debug()) {
            printf("Launch arguments: ");
            array_print(args);
        }
        execvp(java, args);

        // The code below this line is not expected to be called
        array_free(givenargs);
        array_free(args);
        free(java);
        return EXIT_SUCCESS;
    } else
        return EXIT_FAILURE;
}


