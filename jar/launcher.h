#ifndef LAUNCHERINFO_H
#define LAUNCHERINFO_H
#include "arrays.h"

#define LAUNCHER_ENTRY "META-INF/launcher"

strarray launcher(char* java, char* jar, strarray args);

#endif
