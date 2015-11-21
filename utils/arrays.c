#include <stdlib.h>
#include <string.h>
#include <stdio.h>

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


char** array_convert(char** array, int size) {
    char** data = malloc(sizeof(char*)*(size+1));
    for(int i = 0 ; i < size ; i++) {
        int length = strlen(array[i]);
        char* entry = malloc(length + 1);
        strncpy(entry, array[i], length);
        entry[length] = 0;
        data[i] = entry;
    }
    data[size] = 0;
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
