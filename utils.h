#ifndef UTILS_H
#define UTILS_H

#define PATHSEPARATOR ":"
#define SEPARATOR "/"

void debug(const char* format, ...);
void init_args(int argc, char** argv);

int file_exists(const char* fname);
extern int __debug;

#endif
