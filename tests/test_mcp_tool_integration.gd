extends RefCounted
class_name TestMCPToolIntegration

# Mock tool class for testing
class MockTool extends MCPTool:
	func get_name() -> String:
		return "mock_tool"
	
	func get_description() -> String:
		return "A mock tool for testing"
	
	func get_input_schema() -> z_schema:
		return Z.schema({
			"text": Z.string().describe("Input text"),
			"count": Z.integer().describe("Number count"),
			"enabled": Z.boolean().describe("Enable flag")
		})
	
	func run(_params: Dictionary) -> Dictionary:
		return ok("Mock tool executed")

func test_mcp_tool_get_schema_structure() -> void:
	var router: MCPRouter = MCPRouter.new([MockTool.new()])
	var schema: Dictionary = router.format_tool_schema(MockTool.new())
	
	assert(schema.has("name"), "Schema should have name field")
	assert(schema.has("description"), "Schema should have description field")
	assert(schema.has("inputSchema"), "Schema should have inputSchema field")
	
	assert(schema["name"] == "mock_tool", "Schema name should match tool name")
	assert(schema["description"] == "A mock tool for testing", "Schema description should match tool description")

func test_mcp_tool_input_schema_conversion() -> void:
	var router: MCPRouter = MCPRouter.new([MockTool.new()])
	var schema: Dictionary = router.format_tool_schema(MockTool.new())
	var input_schema: Dictionary = schema["inputSchema"]
	
	assert(input_schema["type"] == "object", "Input schema should be object type")
	assert(input_schema.has("properties"), "Input schema should have properties")
	assert(input_schema.has("required"), "Input schema should have required array")

func test_mcp_tool_properties_conversion() -> void:
	var router: MCPRouter = MCPRouter.new([MockTool.new()])
	var schema: Dictionary = router.format_tool_schema(MockTool.new())
	var properties: Dictionary = schema["inputSchema"]["properties"]
	
	assert(properties.has("text"), "Properties should have text field")
	assert(properties["text"]["type"] == "string", "Text field should be string type")
	assert(properties["text"]["description"] == "Input text", "Text field should have description")
	
	assert(properties.has("count"), "Properties should have count field")
	assert(properties["count"]["type"] == "number", "Count field should be number type")
	assert(properties["count"]["description"] == "Number count", "Count field should have description")
	
	assert(properties.has("enabled"), "Properties should have enabled field")
	assert(properties["enabled"]["type"] == "boolean", "Enabled field should be boolean type")
	assert(properties["enabled"]["description"] == "Enable flag", "Enabled field should have description")

func test_mcp_tool_required_fields() -> void:
	var router: MCPRouter = MCPRouter.new([MockTool.new()])
	var schema: Dictionary = router.format_tool_schema(MockTool.new())
	var required: Array = schema["inputSchema"]["required"]
	
	assert(required is Array, "Required should be an Array")
	assert("text" in required, "Text should be required")
	assert("count" in required, "Count should be required")
	assert("enabled" in required, "Enabled should be required")


# Test tool with nested schemas
class NestedMockTool extends MCPTool:
	func get_name() -> String:
		return "nested_tool"
	
	func get_description() -> String:
		return "A tool with nested schemas"
	
	func get_input_schema() -> z_schema:
		return Z.schema({
			"user": Z.schema({
				"name": Z.string().describe("User name"),
				"profile": Z.schema({
					"age": Z.integer().describe("User age"),
					"preferences": Z.array().items(Z.string()).describe("User preferences")
				}).describe("User profile")
			}).describe("User information"),
			"metadata": Z.dictionary().nullable().describe("Optional metadata")
		})
	
	func run(_params: Dictionary) -> Dictionary:
		return ok("Nested tool executed")

func test_nested_tool_schema_conversion() -> void:
	var router: MCPRouter = MCPRouter.new([NestedMockTool.new()])
	var schema: Dictionary = router.format_tool_schema(NestedMockTool.new())
	var input_schema: Dictionary = schema["inputSchema"]
	var properties: Dictionary = input_schema["properties"]
	
	# Test nested user schema
	var user_property: Dictionary = properties["user"]
	assert(user_property["type"] == "object", "User should be object type")
	assert(user_property.has("properties"), "User should have properties")
	assert(user_property["description"] == "User information", "User should have description")
	
	# Test deeply nested profile
	var profile_property: Dictionary = user_property["properties"]["profile"]
	assert(profile_property["type"] == "object", "Profile should be object type")
	assert(profile_property["description"] == "User profile", "Profile should have description")
	
	# Test array in nested schema
	var preferences_property: Dictionary = profile_property["properties"]["preferences"]
	assert(preferences_property["type"] == "array", "Preferences should be array type")
	assert(preferences_property["items"]["type"] == "string", "Preferences items should be string type")
	assert(preferences_property["description"] == "User preferences", "Preferences should have description")

func test_nested_tool_required_fields() -> void:
	var router: MCPRouter = MCPRouter.new([NestedMockTool.new()])
	var schema: Dictionary = router.format_tool_schema(NestedMockTool.new())
	var input_schema: Dictionary = schema["inputSchema"]
	var required: Array = input_schema["required"]
	
	assert("user" in required, "User should be required")
	assert(not ("metadata" in required), "Metadata should not be required")
	
	# Test nested required fields
	var user_property: Dictionary = input_schema["properties"]["user"]
	var user_required: Array = user_property["required"]
	assert("name" in user_required, "User name should be required")
	assert("profile" in user_required, "User profile should be required")

# Test tool with array items
class ArrayMockTool extends MCPTool:
	func get_name() -> String:
		return "array_tool"
	
	func get_description() -> String:
		return "A tool with array schemas"
	
	func get_input_schema() -> z_schema:
		return Z.schema({
			"tags": Z.array().items(Z.string().describe("Tag value")).describe("List of tags"),
			"items": Z.array().items(Z.schema({
				"id": Z.integer().describe("Item ID"),
				"name": Z.string().describe("Item name")
			})).describe("List of items")
		})
	
	func run(_params: Dictionary) -> Dictionary:
		return ok("Array tool executed")

func test_array_tool_schema_conversion() -> void:
	var router: MCPRouter = MCPRouter.new([ArrayMockTool.new()])
	var schema: Dictionary = router.format_tool_schema(ArrayMockTool.new())
	var properties: Dictionary = schema["inputSchema"]["properties"]
	
	# Test string array
	var tags_property: Dictionary = properties["tags"]
	assert(tags_property["type"] == "array", "Tags should be array type")
	assert(tags_property["items"]["type"] == "string", "Tags items should be string type")
	assert(tags_property["items"]["description"] == "Tag value", "Tags items should have description")
	
	# Test object array
	var items_property: Dictionary = properties["items"]
	assert(items_property["type"] == "array", "Items should be array type")
	assert(items_property["items"]["type"] == "object", "Items elements should be object type")
	assert(items_property["items"]["properties"]["id"]["type"] == "number", "Item ID should be number type")
	assert(items_property["items"]["properties"]["name"]["type"] == "string", "Item name should be string type")

func test_create_node_tool_integration() -> void:
	# Test our actual CreateNodeTool uses the new system correctly
	var router: MCPRouter = MCPRouter.new([CreateNodeTool.new()])
	var schema: Dictionary = router.format_tool_schema(CreateNodeTool.new())
	
	assert(schema.has("name"), "CreateNodeTool should have name")
	assert(schema.has("description"), "CreateNodeTool should have description")
	assert(schema.has("inputSchema"), "CreateNodeTool should have inputSchema")
	
	assert(schema["name"] == "create_node", "CreateNodeTool name should be correct")
	
	var properties: Dictionary = schema["inputSchema"]["properties"]
	assert(properties.has("parent_path"), "Should have parent_path property")
	assert(properties.has("node_type"), "Should have node_type property")
	assert(properties.has("node_name"), "Should have node_name property")
	
	assert(properties["parent_path"]["description"] == "Path to the parent node", "parent_path should have description")
	assert(properties["node_type"]["description"] == "Type of node to create", "node_type should have description")
	assert(properties["node_name"]["description"] == "Name for the new node", "node_name should have description")

func test_tool_schema_matches_mcp_spec() -> void:
	var router: MCPRouter = MCPRouter.new([MockTool.new()])
	var schema: Dictionary = router.format_tool_schema(MockTool.new())
	
	# Verify it matches MCP specification structure
	assert(schema is Dictionary, "Schema should be Dictionary")
	assert(schema.has("name") and schema["name"] is String, "Name should be String")
	assert(schema.has("description") and schema["description"] is String, "Description should be String")
	assert(schema.has("inputSchema") and schema["inputSchema"] is Dictionary, "InputSchema should be Dictionary")
	
	var input_schema: Dictionary = schema["inputSchema"]
	assert(input_schema.has("type") and input_schema["type"] == "object", "InputSchema type should be object")
	assert(input_schema.has("properties") and input_schema["properties"] is Dictionary, "Properties should be Dictionary")
	assert(input_schema.has("required") and input_schema["required"] is Array, "Required should be Array")