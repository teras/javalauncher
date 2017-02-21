#include <stdio.h>
#include "unzip.h"

char* getEntry(const char *zipfile, const char* zipentryname, int* const isvalid) {
    unzFile * file = unzOpen(zipfile);
    if (file != NULL) {
        char * data = NULL;
        if (unzLocateFile(file, zipentryname, NULL) == UNZ_OK) {
            if (isvalid)
                *isvalid = 1;
            unz_file_info info;
            unzGetCurrentFileInfo(file, &info, NULL, 0, NULL, 0, NULL, 0);
            if (info.uncompressed_size > 0 && unzOpenCurrentFile(file) == UNZ_OK) {
                data = malloc(info.uncompressed_size + 1);
                unzReadCurrentFile(file, data, info.uncompressed_size);
                data[info.uncompressed_size] = 0;
                if (unzCloseCurrentFile(file) == UNZ_CRCERROR)
                    fprintf(stderr, "Data was read correctly but the CRC does not match");
            }
        }
        unzClose(file);
        return data;
    }
    if (isvalid)
        *isvalid = 0;
    return NULL;
}
