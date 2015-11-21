#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "arrays.h"

void array_free(char** array) {
    char** this_array = array;
    while(array != 0) {
        free(array);
        array++;
    }
    free(this_array);
}

int array_size(char** array) {
    int size = 0;
    while(*array != 0 && size<10) {
        size++;
        array++;
    }
    return size;
}

void array_rawcopy(char** from, char** to, int size) {
    for(int i = 0 ; i < size ; i++) {
        int length = strlen(from[i]);
        char* entry = malloc(length + 1);
        strncpy(entry, from[i], length);
        entry[length] = 0;
        to[i] = entry;
    }
    to[size] = 0;
}



char** array_concat(char** first, char** second) {
    int sizeF = array_size(first);
    int sizeS = array_size(second);
    if (sizeF==0)
        return array_copy(second);
    if (sizeS==0)
        return array_copy(first);
    char** data = malloc(sizeof(char*)*(sizeF+sizeS+1));
    array_rawcopy(first, data, sizeF);
    array_rawcopy(second, data+sizeF, sizeS); 
    return data;
}

char** array_convert(char** array, int size) {
    char** data = malloc(sizeof(char*)*(size+1));
    array_rawcopy(array, data, size);
    return data;
}

char** array_copy(char** array) {
    return array_convert(array, array_size(array));
}

void array_print(char** array) {
    int size = array_size(array);
    printf("[");
    for (int i = 0 ; i < size ; i++) {
        if (i>0)
            printf(", ");
        printf("%s", array[i]);
    }
    printf("]\n");
}
