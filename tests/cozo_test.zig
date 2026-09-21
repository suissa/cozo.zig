const std = @import("std");
const cozo = @import("cozo");
const ecommerce = cozo.ecommerce;

test "fixture has ten categories and thirty products" {
    const counts = ecommerce.seedCounts();
    try std.testing.expectEqual(@as(usize, 10), counts.categories);
    try std.testing.expectEqual(@as(usize, 30), counts.products);
}

test "CozoDB populates ecommerce relations and queries products" {
    var db = try cozo.Database.open("mem", "", "");
    defer db.close();

    const schema = ":create user {id: String => username: String, role: String}\n:create consumer {id: String => display_name: String, phone_e164: String, city: String}\n:create category {id: String => slug: String, name: String}\n:create product {id: String => category_id: String, sku: String, name: String, price_cents: Int, stock_quantity: Int}";
    const schema_result = try db.run(std.testing.allocator, schema, "{}", false);
    defer std.testing.allocator.free(schema_result);

    const payload = "{\"relations\":[{\"relation\":\"user\",\"columns\":[\"id\",\"username\",\"role\"],\"rows\":[[\"usr-01\",\"store-1\",\"admin\"],[\"usr-02\",\"store-2\",\"operator\"],[\"usr-03\",\"store-3\",\"support\"],[\"usr-04\",\"store-4\",\"operator\"],[\"usr-05\",\"store-5\",\"support\"]]},{\"relation\":\"consumer\",\"columns\":[\"id\",\"display_name\",\"phone_e164\",\"city\"],\"rows\":[[\"con-01\",\"Consumidor 1\",\"+5515999000001\",\"Itarare-SP\"],[\"con-02\",\"Consumidor 2\",\"+5515999000002\",\"Itarare-SP\"],[\"con-03\",\"Consumidor 3\",\"+5515999000003\",\"Itarare-SP\"],[\"con-04\",\"Consumidor 4\",\"+5515999000004\",\"Itarare-SP\"],[\"con-05\",\"Consumidor 5\",\"+5515999000005\",\"Itarare-SP\"]]},{\"relation\":\"category\",\"columns\":[\"id\",\"slug\",\"name\"],\"rows\":[[\"cat-01\",\"eletronicos\",\"Eletronicos\"],[\"cat-02\",\"informatica\",\"Informatica\"],[\"cat-03\",\"casa\",\"Casa\"],[\"cat-04\",\"cozinha\",\"Cozinha\"],[\"cat-05\",\"moda\",\"Moda\"],[\"cat-06\",\"beleza\",\"Beleza\"],[\"cat-07\",\"esportes\",\"Esportes\"],[\"cat-08\",\"livros\",\"Livros\"],[\"cat-09\",\"brinquedos\",\"Brinquedos\"],[\"cat-10\",\"pet\",\"Pet\"]]},{\"relation\":\"product\",\"columns\":[\"id\",\"category_id\",\"sku\",\"name\",\"price_cents\",\"stock_quantity\"],\"rows\":[[\"prd-01\",\"cat-01\",\"EC-001\",\"Fone Bluetooth\",6365,11],[\"prd-02\",\"cat-01\",\"EC-002\",\"Caixa de Som\",7740,12],[\"prd-03\",\"cat-01\",\"EC-003\",\"Teclado\",9115,13]]}]}{"relation":"user","columns":["id","username","role"],"rows":[["usr-01","store-1","admin"],["usr-02","store-2","operator"],["usr-03","store-3","support"],["usr-04","store-4","operator"],["usr-05","store-5","support"]]},{"relation":"consumer","columns":["id","display_name","phone_e164","city"],"rows":[["con-01","Consumidor 1","+5515999000001","Itarare-SP"],["con-02","Consumidor 2","+5515999000002","Itarare-SP"],["con-03","Consumidor 3","+5515999000003","Itarare-SP"],["con-04","Consumidor 4","+5515999000004","Itarare-SP"],["con-05","Consumidor 5","+5515999000005","Itarare-SP"]]},{"relation":"category","columns":["id","slug","name"],"rows":[["cat-01","eletronicos","Eletronicos"],["cat-02","informatica","Informatica"],["cat-03","casa","Casa"],["cat-04","cozinha","Cozinha"],["cat-05","moda","Moda"],["cat-06","beleza","Beleza"],["cat-07","esportes","Esportes"],["cat-08","livros","Livros"],["cat-09","brinquedos","Brinquedos"],["cat-10","pet","Pet"]]},{"relation":"product","columns":["id","category_id","sku","name","price_cents","stock_quantity"],"rows":[["prd-01","cat-01","EC-001","Fone Bluetooth",6365,11],["prd-02","cat-01","EC-002","Caixa de Som",7740,12],["prd-03","cat-01","EC-003","Teclado",9115,13]]}]}";
    const imported = try db.importRelations(std.testing.allocator, payload);
    defer std.testing.allocator.free(imported);
    try std.testing.expect(imported.len > 0);

    const result = try db.run(std.testing.allocator, "?[count(id)] := *product {id}", "{}", true);
    defer std.testing.allocator.free(result);
    try std.testing.expect(std.mem.indexOf(u8, result, "3") != null);
}
