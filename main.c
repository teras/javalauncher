#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include <unistd.h>
#include "debug.h"
#include "javahound.h"
#include "arrays.h"
#include "ziputils.h"
#include "params.h"

#define LAUNCHER_ENTRY "META-INF/LAUNCHER.INF"
#define MANIFEST_ENTRY "META-INF/MANIFEST.MF"

int main(int argc, char** argv) {
    init_env();
    char* java = find_java();
    if (java) {
        char* javabin[] = {java, 0};
        char* javajar[] = {"-jar", 0, 0};
        char** givenargs = array_convert(argc - 1, argv + 1);

        char** args = array_copy(javabin);

        int isvalid = 0;
        void* manifest = getEntry(argv[0], MANIFEST_ENTRY, &isvalid);
        char* jar = find_jar(argv[0], isvalid);
        free(manifest);
        if (jar == NULL)
            return EXIT_FAILURE;
        javajar[1] = jar;

        char* jsondata = getEntry(argv[0], LAUNCHER_ENTRY, NULL);
        if (jsondata != NULL) {
            char** prefixparam = get_params(jsondata);
            free(jsondata);
            if (prefixparam != NULL) {
                args = array_replace(args, array_concat(args, prefixparam));
                array_free(prefixparam);
            }
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
        free(jar);
        free(java);
        return EXIT_SUCCESS;
    } else
        return EXIT_FAILURE;
}


