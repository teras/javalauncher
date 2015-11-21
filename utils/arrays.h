#ifndef ARRAYS_UTILS_H
#define ARRAYS_UTILS_H

void array_free(char** array);
int array_size(char** array);
char** array_copy(char** array);
char** array_convert(char** argv, int argc);
void array_print(char** array);
char** array_concat(char** first, char** second);

#endif
