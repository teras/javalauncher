#ifndef ARRAYS_UTILS_H
#define ARRAYS_UTILS_H

typedef char** strarray;

void array_free(strarray array);
int array_size(strarray array);
strarray array_copy(strarray array);
strarray array_convert(char** argv, int argc);
void array_print(strarray array);

#endif
