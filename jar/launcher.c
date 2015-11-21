#include <stdio.h>
#include <stdlib.h>
#include "ziputils.h"
#include "launcher.h"
#include "arrays.h"

strarray launcher(char* java, char* jar, strarray args) {
   // const char* found = getEntry(jar, LAUNCHER_ENTRY);
    char* jargs[] = {java, "-jar", jar, "1", "2", "3", "4", 0};
    return array_copy(jargs);
}

