#ifndef UTILS_H
#define UTILS_H

void debug(const char* format, ...);
void init_args(const int argc, const char** argv);

int file_exists(const char* fname);
char * get_jar(const char* argv0);
char * get_dir(const char* argv0);
char * get_file(const char* argv0);
char* remove_ext(const char* file);

extern int __debug;

#endif
