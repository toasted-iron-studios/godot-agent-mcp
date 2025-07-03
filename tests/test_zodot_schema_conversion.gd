extends RefCounted
class_name TestZodotSchemaConversion

func test_simple_schema_conversion() -> void:
	var schema: Zodot = Z.schema({
		"name": Z.string(),
		"age": Z.integer()
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	
	assert(mcp_schema.has("type"), "Schema should have type field")
	assert(mcp_schema["type"] == "object", "Schema type should be 'object'")
	assert(mcp_schema.has("properties"), "Schema should have properties field")
	assert(mcp_schema.has("required"), "Schema should have required field")

func test_schema_properties_conversion() -> void:
	var schema: Zodot = Z.schema({
		"username": Z.string(),
		"score": Z.integer(),
		"active": Z.boolean()
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	var properties: Dictionary = mcp_schema["properties"]
	
	assert(properties.has("username"), "Properties should have username field")
	assert(properties["username"]["type"] == "string", "Username should be string type")
	
	assert(properties.has("score"), "Properties should have score field")
	assert(properties["score"]["type"] == "number", "Score should be number type")
	
	assert(properties.has("active"), "Properties should have active field")
	assert(properties["active"]["type"] == "boolean", "Active should be boolean type")

func test_schema_required_fields() -> void:
	var schema: Zodot = Z.schema({
		"required_field": Z.string(),
		"optional_field": Z.string().nullable()
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	var required: Array = mcp_schema["required"]
	
	assert(required is Array, "Required should be an Array")
	assert("required_field" in required, "Required field should be in required array")
	assert(not ("optional_field" in required), "Optional field should not be in required array")

func test_schema_with_descriptions() -> void:
	var schema: Zodot = Z.schema({
		"name": Z.string().describe("User's full name"),
		"email": Z.string().describe("User's email address")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	var properties: Dictionary = mcp_schema["properties"]
	
	assert(properties["name"].has("description"), "Name property should have description")
	assert(properties["name"]["description"] == "User's full name", "Name description should match")
	
	assert(properties["email"].has("description"), "Email property should have description")
	assert(properties["email"]["description"] == "User's email address", "Email description should match")

func test_empty_schema() -> void:
	var schema: Zodot = Z.schema({})
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	
	assert(mcp_schema["type"] == "object", "Empty schema should still be object type")
	assert(mcp_schema["properties"] is Dictionary, "Empty schema should have properties dict")
	assert(mcp_schema["properties"].size() == 0, "Empty schema should have no properties")
	assert(mcp_schema["required"] is Array, "Empty schema should have required array")
	assert(mcp_schema["required"].size() == 0, "Empty schema should have no required fields")

func test_complex_schema_structure() -> void:
	var schema: Zodot = Z.schema({
		"user_id": Z.integer().describe("Unique user identifier"),
		"profile": Z.schema({
			"first_name": Z.string().describe("User's first name"),
			"last_name": Z.string().describe("User's last name"),
			"bio": Z.string().nullable().describe("User's biography")
		}).describe("User profile information"),
		"tags": Z.array().items(Z.string()).describe("User tags"),
		"metadata": Z.dictionary().nullable().describe("Additional metadata")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	
	# Test top-level structure
	assert(mcp_schema["type"] == "object", "Root should be object type")
	assert(mcp_schema["properties"].has("user_id"), "Should have user_id property")
	assert(mcp_schema["properties"].has("profile"), "Should have profile property")
	assert(mcp_schema["properties"].has("tags"), "Should have tags property")
	assert(mcp_schema["properties"].has("metadata"), "Should have metadata property")
	
	# Test required fields
	var required: Array = mcp_schema["required"]
	assert("user_id" in required, "user_id should be required")
	assert("profile" in required, "profile should be required")
	assert("tags" in required, "tags should be required")
	assert(not ("metadata" in required), "metadata should not be required")

func test_schema_conversion_preserves_validation() -> void:
	var original_schema: Zodot = Z.schema({
		"name": Z.string().describe("Test name"),
		"age": Z.integer().describe("Test age")
	})
	
	# Test that original schema still works for validation
	var valid_data: Dictionary = {"name": "John", "age": 30}
	var result: ZodotResult = original_schema.parse(valid_data)
	assert(result.ok(), "Original schema should still validate correctly")
	
	# Test MCP conversion
	var mcp_schema: Dictionary = original_schema.to_mcp_schema()
	assert(mcp_schema["properties"]["name"]["type"] == "string", "MCP schema should have correct types")
	assert(mcp_schema["properties"]["age"]["type"] == "number", "MCP schema should have correct types")

func test_schema_with_mixed_nullable_fields() -> void:
	var schema: Zodot = Z.schema({
		"required_string": Z.string().describe("This is required"),
		"optional_string": Z.string().nullable().describe("This is optional"),
		"required_number": Z.integer().describe("This number is required"),
		"optional_number": Z.integer().nullable().describe("This number is optional")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	var required: Array = mcp_schema["required"]
	
	assert(required.size() == 2, "Should have exactly 2 required fields")
	assert("required_string" in required, "required_string should be required")
	assert("required_number" in required, "required_number should be required")
	assert(not ("optional_string" in required), "optional_string should not be required")
	assert(not ("optional_number" in required), "optional_number should not be required")

func test_schema_conversion_idempotent() -> void:
	var schema: Zodot = Z.schema({
		"field1": Z.string().describe("First field"),
		"field2": Z.integer().describe("Second field")
	})
	
	var mcp_schema1: Dictionary = schema.to_mcp_schema()
	var mcp_schema2: Dictionary = schema.to_mcp_schema()
	
	# Should produce identical results
	assert(mcp_schema1.hash() == mcp_schema2.hash(), "Multiple conversions should produce identical results")