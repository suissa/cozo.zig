const std = @import("std");

pub fn main() !void {
    var out = std.io.getStdOut().writer();
    try out.writeAll("{\"relations\":[\n");
    try out.writeAll("{\"relation\":\"user\",\"columns\":[\"id\",\"username\",\"role\"],\"rows\":[");
    for (0..5) |i| {
        if (i != 0) try out.writeByte(',');
        try out.print("[\"usr-{d:0>2}\",\"store-{d}\",\"{s}\"]", .{ i + 1, i + 1, if (i == 0) "admin" else if (i == 2 or i == 4) "support" else "operator" });
    }
    try out.writeAll("]},\n{\"relation\":\"consumer\",\"columns\":[\"id\",\"display_name\",\"phone_e164\",\"city\"],\"rows\":[");
    for (0..20) |i| {
        if (i != 0) try out.writeByte(',');
        try out.print("[\"con-{d:0>2}\",\"Consumidor {d}\",\"+55159990{d:0>4}\",\"Itarare-SP\"]", .{ i + 1, i + 1, i + 1 });
    }
    try out.writeAll("]},\n{\"relation\":\"category\",\"columns\":[\"id\",\"slug\",\"name\"],\"rows\":[");
    const names = [_][]const u8{ "eletronicos", "informatica", "casa", "cozinha", "moda", "beleza", "esportes", "livros", "brinquedos", "pet" };
    for (names, 0..) |name, i| {
        if (i != 0) try out.writeByte(',');
        try out.print("[\"cat-{d:0>2}\",\"{s}\",\"{s}\"]", .{ i + 1, name, name });
    }
    try out.writeAll("]},\n{\"relation\":\"product\",\"columns\":[\"id\",\"category_id\",\"sku\",\"name\",\"price_cents\",\"stock_quantity\"],\"rows\":[");
    for (0..30) |i| {
        if (i != 0) try out.writeByte(',');
        try out.print("[\"prd-{d:0>2}\",\"cat-{d:0>2}\",\"EC-{d:0>3}\",\"Produto {d}\",{d},{d}]", .{ i + 1, i / 3 + 1, i + 1, i + 1, 4990 + (i + 1) * 1375, 10 + i + 1 });
    }
    try out.writeAll("]}]}\n");
}
