#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "arrays.h"

#define MAXSTRSIZE 10000
#define MAXARRAYSIZE MAXSTRSIZE

void array_free(char** array) {
    char** walker = array;
    while(*walker != 0) {
        free(*walker);
        walker++;
    }
    free(array);
}

int array_size(char** array) {
    int size = 0;
    while(*array != 0 && size < MAXARRAYSIZE) {
        size++;
        array++;
    }
    return size;
}

void array_rawcopy(char** from, char** to, int size) {
    for(int i = 0 ; i < size ; i++) {
        int length = strnlen(from[i], MAXSTRSIZE);
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

char** array_convert(int size, char** array) {
    char** data = malloc(sizeof(char*)*(size+1));
    array_rawcopy(array, data, size);
    return data;
}

char** array_copy(char** array) {
    return array_convert(array_size(array), array);
}

char** array_split(char* input, char delimeter) {
    int parts = 0;
    int size = strnlen(input, MAXSTRSIZE);
    int notFinalized = size>0 && *(input+size-1)!=delimeter;
    for (int i = 0 ; i < size; i++)
        if (*(input+i)==delimeter)
            parts++;
    if (notFinalized)
        parts++;

    int start = 0;
    int idx = 0;
    char** data = malloc(sizeof(char*)*(parts+1));
    for (int i = 0 ; i < size; i++)
        if (*(input+i)==delimeter) {
            int entrysize = i - start;
            char* entry = malloc(entrysize+1);
            strncpy(entry, input+start, entrysize);
            entry[entrysize] = 0;
            data[idx] = entry;
            idx++;
            start = i+1;
        }
    if (notFinalized) {
        int entrysize = size - start;
        char* entry = malloc(entrysize+1);
        strncpy(entry, input+start, entrysize);
        entry[entrysize] = 0;
        data[idx] = entry;
    }
    data[parts] = 0;
    return data;
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

char** array_replace(char** older, char** newer) {
    array_free(older);
    return newer;
}
