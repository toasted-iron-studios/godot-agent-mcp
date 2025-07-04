extends RefCounted
class_name TestZodotArrayItems

func test_array_items_method() -> void:
	var schema: Zodot = Z.array().items(Z.string())
	assert(schema._schema != null, "Array items schema should be set")
	assert(schema._schema is z_string, "Array items schema should be z_string")

func test_array_items_chaining() -> void:
	var schema: Zodot = Z.array().items(Z.string()).describe("Array of strings")
	assert(schema._schema != null, "Array items schema should be set")
	assert(schema._description == "Array of strings", "Description should be set")

func test_array_items_with_integer() -> void:
	var schema: Zodot = Z.array().items(Z.integer())
	assert(schema._schema is z_integer, "Array items schema should be z_integer")

func test_array_items_with_boolean() -> void:
	var schema: Zodot = Z.array().items(Z.boolean())
	assert(schema._schema is z_boolean, "Array items schema should be z_boolean")

func test_array_items_overwrite() -> void:
	var schema: Zodot = Z.array().items(Z.string()).items(Z.integer())
	assert(schema._schema is z_integer, "Second items() call should overwrite first")

func test_array_to_mcp_property_without_items() -> void:
	var schema: Zodot = Z.array()
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type")
	assert(property["type"] == "array", "Property type should be array")
	assert(not property.has("items"), "Property should not have items when none specified")

func test_array_to_mcp_property_with_string_items() -> void:
	var schema: Zodot = Z.array().items(Z.string())
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type")
	assert(property["type"] == "array", "Property type should be array")
	assert(property.has("items"), "Property should have items")
	assert(property["items"]["type"] == "string", "Items type should be string")

func test_array_to_mcp_property_with_integer_items() -> void:
	var schema: Zodot = Z.array().items(Z.integer())
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("items"), "Property should have items")
	assert(property["items"]["type"] == "number", "Items type should be number")

func test_array_to_mcp_property_with_boolean_items() -> void:
	var schema: Zodot = Z.array().items(Z.boolean())
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("items"), "Property should have items")
	assert(property["items"]["type"] == "boolean", "Items type should be boolean")

func test_array_to_mcp_property_with_described_items() -> void:
	var schema: Zodot = Z.array().items(Z.string().describe("String item"))
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("items"), "Property should have items")
	assert(property["items"]["type"] == "string", "Items type should be string")
	assert(property["items"]["description"] == "String item", "Items should have description")

func test_array_to_mcp_property_with_array_description() -> void:
	var schema: Zodot = Z.array().items(Z.string()).describe("Array of strings")
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("description"), "Property should have description")
	assert(property["description"] == "Array of strings", "Property description should match")
	assert(property.has("items"), "Property should have items")
	assert(property["items"]["type"] == "string", "Items type should be string")

func test_array_to_mcp_property_with_object_items() -> void:
	var item_schema: Zodot = Z.schema({
		"name": Z.string().describe("Item name"),
		"value": Z.integer().describe("Item value")
	})
	var schema: Zodot = Z.array().items(item_schema)
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("items"), "Property should have items")
	assert(property["items"]["type"] == "object", "Items type should be object")
	assert(property["items"].has("properties"), "Items should have properties")
	assert(property["items"]["properties"].has("name"), "Items properties should have name")
	assert(property["items"]["properties"].has("value"), "Items properties should have value")

func test_array_validation_with_items() -> void:
	var schema: Zodot = Z.array().items(Z.string())
	
	# Test valid array
	var valid_result: ZodotResult = schema.parse(["hello", "world"])
	assert(valid_result.ok(), "Valid string array should pass validation")
	
	# Test invalid array (wrong item type)
	var invalid_result: ZodotResult = schema.parse(["hello", 123])
	assert(not invalid_result.ok(), "Array with wrong item type should fail validation")

func test_array_validation_without_items() -> void:
	var schema: Zodot = Z.array()
	
	# Should accept any array when no items constraint
	var result1: ZodotResult = schema.parse(["hello", 123, true])
	assert(result1.ok(), "Array without items constraint should accept mixed types")
	
	var result2: ZodotResult = schema.parse([])
	assert(result2.ok(), "Array without items constraint should accept empty array")

func test_array_non_empty_with_items() -> void:
	var schema: Zodot = Z.array().items(Z.string()).non_empty()
	
	# Test non-empty array
	var valid_result: ZodotResult = schema.parse(["hello"])
	assert(valid_result.ok(), "Non-empty array should pass validation")
	
	# Test empty array
	var invalid_result: ZodotResult = schema.parse([])
	assert(not invalid_result.ok(), "Empty array should fail non_empty validation")

func test_array_mcp_property_structure() -> void:
	var schema: Zodot = Z.array().items(Z.string().describe("String item")).describe("String array")
	var property: Dictionary = schema.to_mcp_property()
	
	# Verify complete MCP property structure
	assert(property is Dictionary, "Property should be Dictionary")
	assert(property.has("type"), "Property should have type")
	assert(property["type"] == "array", "Property type should be array")
	assert(property.has("items"), "Property should have items")
	assert(property["items"] is Dictionary, "Items should be Dictionary")
	assert(property["items"].has("type"), "Items should have type")
	assert(property["items"]["type"] == "string", "Items type should be string")
	assert(property["items"].has("description"), "Items should have description")
	assert(property.has("description"), "Property should have description")

func test_nested_array_items() -> void:
	var schema: Zodot = Z.array().items(Z.array().items(Z.string()))
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property["items"]["type"] == "array", "Nested array items should be array type")
	assert(property["items"]["items"]["type"] == "string", "Nested array items should have string items")