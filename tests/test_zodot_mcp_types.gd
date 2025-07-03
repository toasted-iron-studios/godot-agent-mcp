extends RefCounted
class_name TestZodotMCPTypes

func test_string_mcp_type() -> void:
	var schema: Zodot = Z.string()
	assert(schema.get_mcp_type() == "string", "String should map to MCP type 'string'")

func test_integer_mcp_type() -> void:
	var schema: Zodot = Z.integer()
	assert(schema.get_mcp_type() == "number", "Integer should map to MCP type 'number'")

func test_boolean_mcp_type() -> void:
	var schema: Zodot = Z.boolean()
	assert(schema.get_mcp_type() == "boolean", "Boolean should map to MCP type 'boolean'")

func test_array_mcp_type() -> void:
	var schema: Zodot = Z.array()
	assert(schema.get_mcp_type() == "array", "Array should map to MCP type 'array'")

func test_dictionary_mcp_type() -> void:
	var schema: Zodot = Z.dictionary()
	assert(schema.get_mcp_type() == "object", "Dictionary should map to MCP type 'object'")

func test_schema_mcp_type() -> void:
	var schema: Zodot = Z.schema({})
	assert(schema.get_mcp_type() == "object", "Schema should map to MCP type 'object'")

func test_float_mcp_type() -> void:
	var schema: Zodot = Z.float()
	assert(schema.get_mcp_type() == "number", "Float should map to MCP type 'number'")

func test_string_to_mcp_property() -> void:
	var schema: Zodot = Z.string()
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type field")
	assert(property["type"] == "string", "Property type should be 'string'")
	assert(property.size() == 1, "Property should only have type field when no description")

func test_integer_to_mcp_property() -> void:
	var schema: Zodot = Z.integer()
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type field")
	assert(property["type"] == "number", "Property type should be 'number'")

func test_boolean_to_mcp_property() -> void:
	var schema: Zodot = Z.boolean()
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type field")
	assert(property["type"] == "boolean", "Property type should be 'boolean'")

func test_array_to_mcp_property() -> void:
	var schema: Zodot = Z.array()
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type field")
	assert(property["type"] == "array", "Property type should be 'array'")

func test_dictionary_to_mcp_property() -> void:
	var schema: Zodot = Z.dictionary()
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type field")
	assert(property["type"] == "object", "Property type should be 'object'")

func test_mcp_property_with_description() -> void:
	var schema: Zodot = Z.string().describe("Test description")
	var property: Dictionary = schema.to_mcp_property()
	
	assert(property.has("type"), "Property should have type field")
	assert(property["type"] == "string", "Property type should be 'string'")
	assert(property.has("description"), "Property should have description field")
	assert(property["description"] == "Test description", "Property description should match")
	assert(property.size() == 2, "Property should have exactly 2 fields")

func test_mcp_property_structure() -> void:
	var schema: Zodot = Z.integer().describe("A number field")
	var property: Dictionary = schema.to_mcp_property()
	
	# Verify it's a valid MCP property structure
	assert(property is Dictionary, "Property should be a Dictionary")
	assert(property.has("type"), "Property must have 'type' field")
	assert(property["type"] is String, "Property type must be a String")
	assert(property.has("description"), "Property should have 'description' field")
	assert(property["description"] is String, "Property description must be a String")

func test_all_zodot_types_have_mcp_mapping() -> void:
	var types_to_test: Array[Zodot] = [
		Z.string(),
		Z.integer(),
		Z.boolean(),
		Z.array(),
		Z.dictionary(),
		Z.schema({}),
		Z.float()
	]
	
	for schema in types_to_test:
		var mcp_type: String = schema.get_mcp_type()
		assert(mcp_type != "", "All zodot types should have non-empty MCP type mapping")
		assert(mcp_type in ["string", "number", "boolean", "array", "object"], 
			"MCP type should be one of the valid JSON Schema types: " + mcp_type)