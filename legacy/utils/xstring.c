#include <stdlib.h>
#include <string.h>
#include "xstring.h"

char* string_extract(char* buffer, int length) {
    char* result = malloc(length+1);
    memcpy(result, buffer, length);
    result[length] = 0;
    return result;
}

char* string_unescape(char* buffer, int length) {
    if (buffer==NULL)
        return NULL;

    int count = 0;
    for (int i = 0 ; i < length - 1; i++) {
        if (buffer[i]=='\\') {
            i++;
            count++;
        }
    }
    char* result = malloc(length-count+1);
    int idx = 0;
    for(int i =0 ; i < length; i++, idx++) {
        if (buffer[i]=='\\') {
            i++;
            switch(buffer[i]) {
            case 'n':
                result[idx] = '\n';
                break;
            case 'r':
                result[idx] = '\r';
                break;
            case 't':
                result[idx] = '\t';
                break;
            case 'b':
                result[idx] = '\b';
                break;
            case 'f':
                result[idx] = '\f';
                break;
            default:
                result[idx] = buffer[i];
                break;
            }
        } else {
            result[idx] = buffer[i];
        }
    }
    result[length-count] = 0;
    return result;
}
