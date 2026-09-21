const std = @import("std");

const c = @cImport({
    @cInclude("cozo_c.h");
});

pub const Error = error{ CozoOpenFailed, CozoQueryFailed, CozoImportFailed };

pub const Database = struct {
    id: c_int,

    pub fn open(engine: [:0]const u8, path: [:0]const u8, options: [:0]const u8) !Database {
        var id: c_int = 0;
        if (c.cozo_open_db(engine.ptr, path.ptr, options.ptr, &id) != null) return Error.CozoOpenFailed;
        return .{ .id = id };
    }

    pub fn close(self: Database) void {
        _ = c.cozo_close_db(self.id);
    }

    pub fn run(self: Database, allocator: std.mem.Allocator, script: [:0]const u8, params: [:0]const u8, immutable: bool) ![]u8 {
        const result = c.cozo_run_query(self.id, script.ptr, params.ptr, immutable);
        if (result == null) return Error.CozoQueryFailed;
        defer c.cozo_free_str(result);
        return allocator.dupe(u8, std.mem.span(result));
    }

    pub fn importRelations(self: Database, allocator: std.mem.Allocator, payload: [:0]const u8) ![]u8 {
        const result = c.cozo_import_relations(self.id, payload.ptr);
        if (result == null) return Error.CozoImportFailed;
        defer c.cozo_free_str(result);
        return allocator.dupe(u8, std.mem.span(result));
    }
};

pub const ecommerce = @import("ecommerce.zig");
