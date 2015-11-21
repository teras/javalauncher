#include <stdio.h>
#include <stdlib.h>
#include "ziputils.h"
#include "launcher.h"
#include "arrays.h"

char** launcher(char* java, char* jar, char** args) {
   // const char* found = getEntry(jar, LAUNCHER_ENTRY);
    char* jargs[] = {java, "-jar", jar, 0};
    return array_concat(jargs, args);
}

