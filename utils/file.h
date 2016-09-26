#ifndef FILE_UTILS_H
#define FILE_UTILS_H

#if (!defined(_WIN32)) && (!defined(WIN32))
#  define PATHSEPARATOR ":"
#  define SEPARATOR "/"
#else
#  define PATHSEPARATOR ";"
#  define SEPARATOR "\\"
#endif

int file_exists(const char* fname);

#endif
