#ifndef LAUNCHERINFO_H
#define LAUNCHERINFO_H
#include "arrays.h"

#define LAUNCHER_ENTRY "META-INF/launcher"

char** launcher(char* java, char* jar, char** args);

#endif
