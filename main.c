#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include <unistd.h>
#include "utils.h"
#include "javahound.h"

int main(int argc, char** argv) {
    init_args(argc, argv);
    char* dir = dirname(argv[0]);
    char* file = basename(argv[0]);
    if (chdir(dir) == 0 ) {
        char* java = find_java();
        if (java) {
            char* jargs[] = {java, "-jar", file, 0};
            debug("Will try to launch java.\n");
            execvp(java, jargs);

            // The code below this line is not expected to be called
            free(java);
            return (EXIT_SUCCESS);
        }
    } else {
        fprintf(stderr, "Error: unable to update current directory to `%s`\n", dir);
        return (EXIT_FAILURE);
    }
}


