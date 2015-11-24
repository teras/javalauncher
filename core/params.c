#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "params.h"
#include "arrays.h"
#include "jsmn.h"
#include "debug.h"
#include "xstring.h"

char** get_params(char* json) {
    int json_size = strlen(json);
    jsmn_parser parser;
    jsmn_init(&parser);
    int token_size = jsmn_parse(&parser, json, json_size, NULL, 0);
    if (token_size<=0)
        return NULL;

    jsmntok_t tokens[token_size];
    jsmn_init(&parser);
    jsmn_parse(&parser, json, json_size, tokens, token_size);

    if (tokens[0].type != JSMN_OBJECT) {
        debug("Top JSON sould be object\n");
        return NULL;
    }

    char** params = NULL;
    for(int i = 0 ; i < token_size; i++) {
        if (tokens[i].parent == 0) {
            if (memcmp("arguments", json+tokens[i].start, tokens[i].end - tokens[i].start)==0) {
                i++;
                if (tokens[i].type!=JSMN_ARRAY)
                    continue;
                int argsize = tokens[i].size;
                if (argsize <= 0)
                    continue;
                params = malloc(sizeof(char*) * argsize+1);
                for(int ai = 1 ; ai <= argsize ; ai++) {
                    char* arg = string_unescape(json + tokens[i+ai].start, tokens[i+ai].end -tokens[i+ai].start);
                    params[ai-1] = arg;
                }
                params[argsize] = NULL;
            }
        }
    }
    return params;
}

