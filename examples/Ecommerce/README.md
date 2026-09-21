# Ecommerce fixture for CozoDB

The integration test uses the same domain shape as the AllasCode example:
5 users, 20 consumers, 10 categories and 30 products.

The complete fixture is intentionally deterministic. The first integration
test inserts a compact subset to keep CI fast; the seed generator below emits
the complete CozoScript/JSON import payload for local and integration tests.
