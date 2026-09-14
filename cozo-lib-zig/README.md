# Cozo client for Zig 0.16

An allocator-aware Zig client for embedding CozoDB through its stable C API.
The client supports opening and closing databases, queries, relation
import/export, backup, restore, and import from backup.

## Requirements

- Zig 0.16 or a compatible development build;
- `libcozo_c` available to the linker (build it with
  `cargo build --release -p cozo_c -F compact`).

Add this package as a dependency, import its `cozo` module, and link the Cozo C
library and libc in your executable's build:

```zig
exe.root_module.addImport("cozo", cozo_dependency.module("cozo"));
exe.root_module.linkSystemLibrary("cozo_c", .{});
exe.root_module.link_libc = true;
```

## Example

```zig
const std = @import("std");
const cozo = @import("cozo");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const opened = try cozo.Database.open(allocator, "mem", "", "{}");
    var db = switch (opened) {
        .database => |database| database,
        .failure => |message| {
            defer allocator.free(message);
            std.debug.print("could not open CozoDB: {s}\n", .{message});
            return;
        },
    };
    defer _ = db.close();

    const json = try db.run(
        "?[name] := *person{name}, name == $name",
        "{\"name\": \"Ada\"}",
        true,
    );
    defer allocator.free(json);
    std.debug.print("{s}\n", .{json});
}
```

All returned strings are owned by the caller and must be released with the
allocator used to open the database. `run` accepts parameters as JSON so query
values never need to be interpolated into CozoScript.

Run the unit tests with `zig build test` from this directory. Tests use a small
mock C implementation and do not require a built Cozo library.
