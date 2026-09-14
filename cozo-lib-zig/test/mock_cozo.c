#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static char *copy(const char *value) {
    size_t size = strlen(value) + 1;
    char *result = malloc(size);
    memcpy(result, value, size);
    return result;
}

char *cozo_open_db(const char *engine, const char *path, const char *options, int32_t *id) {
    (void)path; (void)options;
    if (strcmp(engine, "mem") != 0) return copy("unsupported engine");
    *id = 1;
    return NULL;
}
bool cozo_close_db(int32_t id) { return id == 1; }
char *cozo_run_query(int32_t id, const char *script, const char *params, bool immutable) {
    (void)id; (void)script; (void)params; (void)immutable;
    return copy("{\"ok\":true,\"rows\":[[42]]}");
}
char *cozo_import_relations(int32_t id, const char *p) { (void)id; (void)p; return copy("{\"ok\":true}"); }
char *cozo_export_relations(int32_t id, const char *p) { (void)id; (void)p; return copy("{\"ok\":true}"); }
char *cozo_backup(int32_t id, const char *p) { (void)id; (void)p; return copy("{\"ok\":true}"); }
char *cozo_restore(int32_t id, const char *p) { (void)id; (void)p; return copy("{\"ok\":true}"); }
char *cozo_import_from_backup(int32_t id, const char *p) { (void)id; (void)p; return copy("{\"ok\":true}"); }
void cozo_free_str(char *value) { free(value); }
