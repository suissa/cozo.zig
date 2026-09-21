/* Generated-compatible CozoDB C API header. See upstream cozo-lib-c/cozo_c.h. */
#include <stdbool.h>
#include <stdint.h>
char *cozo_open_db(const char *engine, const char *path, const char *options, int32_t *db_id);
bool cozo_close_db(int32_t db_id);
char *cozo_run_query(int32_t db_id, const char *script_raw, const char *params_raw, bool immutable_query);
char *cozo_import_relations(int32_t db_id, const char *json_payload);
void cozo_free_str(char *s);
