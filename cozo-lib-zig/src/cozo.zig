const std = @import("std");

const c = struct {
    extern fn cozo_open_db(engine: [*:0]const u8, path: [*:0]const u8, options: [*:0]const u8, db_id: *i32) callconv(.c) ?[*:0]u8;
    extern fn cozo_close_db(db_id: i32) callconv(.c) bool;
    extern fn cozo_run_query(db_id: i32, script: [*:0]const u8, params: [*:0]const u8, immutable: bool) callconv(.c) [*:0]u8;
    extern fn cozo_import_relations(db_id: i32, payload: [*:0]const u8) callconv(.c) [*:0]u8;
    extern fn cozo_export_relations(db_id: i32, payload: [*:0]const u8) callconv(.c) [*:0]u8;
    extern fn cozo_backup(db_id: i32, path: [*:0]const u8) callconv(.c) [*:0]u8;
    extern fn cozo_restore(db_id: i32, path: [*:0]const u8) callconv(.c) [*:0]u8;
    extern fn cozo_import_from_backup(db_id: i32, payload: [*:0]const u8) callconv(.c) [*:0]u8;
    extern fn cozo_free_str(value: [*:0]u8) callconv(.c) void;
};

pub const Error = error{DatabaseClosed};

/// Result of opening a database. The caller owns `failure` and must free it
/// with the same allocator passed to `Database.open`.
pub const OpenResult = union(enum) {
    database: Database,
    failure: []u8,
};

/// An embedded CozoDB client backed by `libcozo_c`.
///
/// This type owns the database handle and is intentionally used through a
/// pointer. Do not copy an open `Database`; call `close` exactly once.
pub const Database = struct {
    allocator: std.mem.Allocator,
    id: ?i32,

    pub fn open(allocator: std.mem.Allocator, engine: []const u8, path: []const u8, options_json: []const u8) !OpenResult {
        const engine_z = try allocator.dupeZ(u8, engine);
        defer allocator.free(engine_z);
        const path_z = try allocator.dupeZ(u8, path);
        defer allocator.free(path_z);
        const options_z = try allocator.dupeZ(u8, options_json);
        defer allocator.free(options_z);

        var id: i32 = undefined;
        if (c.cozo_open_db(engine_z, path_z, options_z, &id)) |message| {
            defer c.cozo_free_str(message);
            return .{ .failure = try allocator.dupe(u8, std.mem.span(message)) };
        }
        return .{ .database = .{ .allocator = allocator, .id = id } };
    }

    pub fn close(self: *Database) bool {
        const id = self.id orelse return false;
        self.id = null;
        return c.cozo_close_db(id);
    }

    pub fn run(self: *Database, script: []const u8, params_json: []const u8, immutable: bool) ![]u8 {
        const script_z = try self.allocator.dupeZ(u8, script);
        defer self.allocator.free(script_z);
        const params_z = try self.allocator.dupeZ(u8, params_json);
        defer self.allocator.free(params_z);
        return self.copyResult(c.cozo_run_query(try self.requireId(), script_z, params_z, immutable));
    }

    pub fn importRelations(self: *Database, payload_json: []const u8) ![]u8 {
        return self.callWithString(payload_json, c.cozo_import_relations);
    }

    pub fn exportRelations(self: *Database, payload_json: []const u8) ![]u8 {
        return self.callWithString(payload_json, c.cozo_export_relations);
    }

    pub fn backup(self: *Database, path: []const u8) ![]u8 {
        return self.callWithString(path, c.cozo_backup);
    }

    pub fn restore(self: *Database, path: []const u8) ![]u8 {
        return self.callWithString(path, c.cozo_restore);
    }

    pub fn importFromBackup(self: *Database, payload_json: []const u8) ![]u8 {
        return self.callWithString(payload_json, c.cozo_import_from_backup);
    }

    fn requireId(self: *const Database) Error!i32 {
        return self.id orelse error.DatabaseClosed;
    }

    fn callWithString(self: *Database, value: []const u8, function: *const fn (i32, [*:0]const u8) callconv(.c) [*:0]u8) ![]u8 {
        const value_z = try self.allocator.dupeZ(u8, value);
        defer self.allocator.free(value_z);
        return self.copyResult(function(try self.requireId(), value_z));
    }

    fn copyResult(self: *Database, result: [*:0]u8) ![]u8 {
        defer c.cozo_free_str(result);
        return self.allocator.dupe(u8, std.mem.span(result));
    }
};

test "database lifecycle and query ownership" {
    const allocator = std.testing.allocator;
    const opened = try Database.open(allocator, "mem", "", "{}");
    var db = switch (opened) {
        .database => |database| database,
        .failure => |message| {
            defer allocator.free(message);
            return error.UnexpectedOpenFailure;
        },
    };

    const result = try db.run("?[answer] := answer = $value", "{\"value\": 42}", true);
    defer allocator.free(result);
    try std.testing.expectEqualStrings("{\"ok\":true,\"rows\":[[42]]}", result);
    try std.testing.expect(db.close());
    try std.testing.expect(!db.close());
    try std.testing.expectError(error.DatabaseClosed, db.run("?[] <- [[]]", "{}", true));
}

test "open preserves native error message" {
    const allocator = std.testing.allocator;
    const opened = try Database.open(allocator, "invalid", "", "{}");
    switch (opened) {
        .database => return error.ExpectedOpenFailure,
        .failure => |message| {
            defer allocator.free(message);
            try std.testing.expectEqualStrings("unsupported engine", message);
        },
    }
}
