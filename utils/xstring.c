#include <stdlib.h>
#include <string.h>
#include "xstring.h"

char* string_extract(char* buffer, int length) {
    char* result = malloc(length+1);
    memcpy(result, buffer, length);
    result[length] = 0;
    return result;
}
