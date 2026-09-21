pub const Category = struct { id: []const u8, slug: []const u8, name: []const u8 };
pub const Product = struct {
    id: []const u8,
    category_id: []const u8,
    sku: []const u8,
    name: []const u8,
    price_cents: i64,
    stock_quantity: i64,
};

pub const categories = [_]Category{
    .{ .id = "cat-01", .slug = "eletronicos", .name = "Eletronicos" },
    .{ .id = "cat-02", .slug = "informatica", .name = "Informatica" },
    .{ .id = "cat-03", .slug = "casa", .name = "Casa" },
    .{ .id = "cat-04", .slug = "cozinha", .name = "Cozinha" },
    .{ .id = "cat-05", .slug = "moda", .name = "Moda" },
    .{ .id = "cat-06", .slug = "beleza", .name = "Beleza" },
    .{ .id = "cat-07", .slug = "esportes", .name = "Esportes" },
    .{ .id = "cat-08", .slug = "livros", .name = "Livros" },
    .{ .id = "cat-09", .slug = "brinquedos", .name = "Brinquedos" },
    .{ .id = "cat-10", .slug = "pet", .name = "Pet" },
};

pub fn products(comptime count: usize) [count]Product {
    var result: [count]Product = undefined;
    for (&result, 0..) |*product, i| {
        const category_index = i / 3;
        product.* = .{
            .id = "",
            .category_id = categories[category_index].id,
            .sku = "",
            .name = "",
            .price_cents = 4990 + @as(i64, @intCast((i + 1) * 1375)),
            .stock_quantity = 10 + @as(i64, @intCast(i + 1)),
        };
    }
    return result;
}

pub fn seedCounts() struct { categories: usize, products: usize } {
    return .{ .categories = categories.len, .products = 30 };
}
