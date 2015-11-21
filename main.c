#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include <unistd.h>
#include "debug.h"
#include "javahound.h"
#include "launcher.h"
#include "arrays.h"

int main(int argc, char** argv) {
    init_env();
    char* java = find_java();
    if (java) {
        char** args = array_convert(argv+1, argc-1);
        char** launchargs = launcher(java, argv[0], args);
        if (is_debug()) {
            printf("Launch arguments: ");
            array_print(launchargs);
        }
        execvp(java, launchargs);
        // The code below this line is not expected to be called
        array_free(launchargs);
        array_free(args);
        free(java);
        return EXIT_SUCCESS;
    } else
        return EXIT_FAILURE;
}


