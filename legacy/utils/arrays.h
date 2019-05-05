#ifndef ARRAYS_UTILS_H
#define ARRAYS_UTILS_H

void array_free(char** array);
int array_size(char** array);
char** array_copy(char** array);
char** array_convert(int size, char** array);
void array_print(char** array);
char** array_concat(char** first, char** second);
char** array_split(char* input, char delimeter);
char** array_replace(char** older, char** newer);

#endif
