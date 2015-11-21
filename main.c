#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include <unistd.h>
#include "debug.h"
#include "javahound.h"
#include "launcher.h"
#include "arrays.h"

int main(int argc, char** argv) {
    init_args(argc, argv);
    char* dir = dirname(argv[0]);
    char* file = basename(argv[0]);
    if (chdir(dir) == 0 ) {
        char* java = find_java();
        if (java) {
            strarray args = array_convert(argv+1, argc-1);
            strarray launchargs = launcher(java, file, args);
            array_print(launchargs);
            execvp(java, launchargs);
            // The code below this line is not expected to be called
            array_free(launchargs);
            array_free(args);
            free(java);
            return (EXIT_SUCCESS);
        }
    } else {
        fprintf(stderr, "Error: unable to update current directory to `%s`\n", dir);
        return (EXIT_FAILURE);
    }
}


