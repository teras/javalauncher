#ifndef DEBUG_UTILS_H
#define DEBUG_UTILS_H

#define LAUNCHER_DEBUG "LAUNCHER_DEBUG"

void init_env();
void debug(const char* format, ...);
int is_debug();

#endif
