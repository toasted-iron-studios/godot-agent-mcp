extends RefCounted
class_name TestZodotDescribe

func test_string_describe() -> void:
	var schema: Zodot = Z.string().describe("A test string")
	assert(schema._description == "A test string", "String description should be set")

func test_integer_describe() -> void:
	var schema: Zodot = Z.integer().describe("A test integer")
	assert(schema._description == "A test integer", "Integer description should be set")

func test_boolean_describe() -> void:
	var schema: Zodot = Z.boolean().describe("A test boolean")
	assert(schema._description == "A test boolean", "Boolean description should be set")

func test_array_describe() -> void:
	var schema: Zodot = Z.array().describe("A test array")
	assert(schema._description == "A test array", "Array description should be set")

func test_schema_describe() -> void:
	var schema: Zodot = Z.schema({}).describe("A test schema")
	assert(schema._description == "A test schema", "Schema description should be set")

func test_describe_chaining() -> void:
	var schema: Zodot = Z.string().describe("First").describe("Second")
	assert(schema._description == "Second", "Description should be overwritten by chaining")

func test_describe_with_nullable() -> void:
	var schema: Zodot = Z.string().nullable().describe("Nullable string")
	assert(schema._description == "Nullable string", "Description should work with nullable")
	assert(schema._nullable == true, "Nullable should still be set")

func test_describe_with_constraints() -> void:
	var schema: Zodot = Z.string().minimum(5).describe("Constrained string")
	assert(schema._description == "Constrained string", "Description should work with constraints")
	assert(schema._min == 5, "Constraints should still be set")

func test_empty_description() -> void:
	var schema: Zodot = Z.string().describe("")
	assert(schema._description == "", "Empty description should be allowed")

func test_to_mcp_property_with_description() -> void:
	var schema: Zodot = Z.string().describe("Test description")
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type")
	assert(property["type"] == "string", "Property type should be string")
	assert(property.has("description"), "Property should have description")
	assert(property["description"] == "Test description", "Property description should match")

func test_to_mcp_property_without_description() -> void:
	var schema: Zodot = Z.string()
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type")
	assert(property["type"] == "string", "Property type should be string")
	assert(not property.has("description"), "Property should not have description when not set")