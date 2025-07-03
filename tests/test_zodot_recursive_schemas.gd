extends RefCounted
class_name TestZodotRecursiveSchemas

func test_simple_nested_schema() -> void:
	var schema: Zodot = Z.schema({
		"user": Z.schema({
			"name": Z.string().describe("User name"),
			"age": Z.integer().describe("User age")
		}).describe("User information")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	var user_property: Dictionary = mcp_schema["properties"]["user"]
	
	assert(user_property["type"] == "object", "Nested schema should be object type")
	assert(user_property.has("properties"), "Nested schema should have properties")
	assert(user_property["properties"].has("name"), "Nested schema should have name property")
	assert(user_property["properties"].has("age"), "Nested schema should have age property")
	assert(user_property.has("description"), "Nested schema should have description")

func test_deeply_nested_schema() -> void:
	var schema: Zodot = Z.schema({
		"company": Z.schema({
			"name": Z.string().describe("Company name"),
			"address": Z.schema({
				"street": Z.string().describe("Street address"),
				"city": Z.string().describe("City name"),
				"country": Z.string().describe("Country name")
			}).describe("Company address")
		}).describe("Company information")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	var company_property: Dictionary = mcp_schema["properties"]["company"]
	var address_property: Dictionary = company_property["properties"]["address"]
	
	assert(address_property["type"] == "object", "Deeply nested schema should be object type")
	assert(address_property.has("properties"), "Deeply nested schema should have properties")
	assert(address_property["properties"].has("street"), "Deeply nested schema should have street")
	assert(address_property["properties"].has("city"), "Deeply nested schema should have city")
	assert(address_property["properties"].has("country"), "Deeply nested schema should have country")

func test_array_of_objects() -> void:
	var schema: Zodot = Z.schema({
		"users": Z.array().items(Z.schema({
			"id": Z.integer().describe("User ID"),
			"name": Z.string().describe("User name"),
			"email": Z.string().describe("User email")
		})).describe("List of users")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	var users_property: Dictionary = mcp_schema["properties"]["users"]
	
	assert(users_property["type"] == "array", "Array property should be array type")
	assert(users_property.has("items"), "Array property should have items")
	assert(users_property["items"]["type"] == "object", "Array items should be object type")
	assert(users_property["items"].has("properties"), "Array items should have properties")
	assert(users_property["items"]["properties"].has("id"), "Array items should have id property")
	assert(users_property["items"]["properties"].has("name"), "Array items should have name property")
	assert(users_property["items"]["properties"].has("email"), "Array items should have email property")

func test_mixed_recursive_structures() -> void:
	var schema: Zodot = Z.schema({
		"data": Z.schema({
			"metadata": Z.schema({
				"version": Z.string().describe("Version info"),
				"tags": Z.array().items(Z.string()).describe("Tags array")
			}).describe("Metadata object"),
			"items": Z.array().items(Z.schema({
				"name": Z.string().describe("Item name"),
				"properties": Z.dictionary().describe("Item properties")
			})).describe("Items array")
		}).describe("Data container")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	var data_property: Dictionary = mcp_schema["properties"]["data"]
	var metadata_property: Dictionary = data_property["properties"]["metadata"]
	var items_property: Dictionary = data_property["properties"]["items"]
	
	# Test metadata nested object
	assert(metadata_property["type"] == "object", "Metadata should be object type")
	assert(metadata_property["properties"]["tags"]["type"] == "array", "Tags should be array type")
	assert(metadata_property["properties"]["tags"]["items"]["type"] == "string", "Tags items should be string type")
	
	# Test items array of objects
	assert(items_property["type"] == "array", "Items should be array type")
	assert(items_property["items"]["type"] == "object", "Items elements should be object type")
	assert(items_property["items"]["properties"]["name"]["type"] == "string", "Item name should be string type")
	assert(items_property["items"]["properties"]["properties"]["type"] == "object", "Item properties should be object type")

func test_recursive_required_fields() -> void:
	var schema: Zodot = Z.schema({
		"required_parent": Z.schema({
			"required_child": Z.string().describe("Required child field"),
			"optional_child": Z.string().nullable().describe("Optional child field")
		}).describe("Required parent object"),
		"optional_parent": Z.schema({
			"child": Z.string().describe("Child in optional parent")
		}).nullable().describe("Optional parent object")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	
	# Test top-level required fields
	var required: Array = mcp_schema["required"]
	assert("required_parent" in required, "Required parent should be in required array")
	assert(not ("optional_parent" in required), "Optional parent should not be in required array")
	
	# Test nested required fields
	var required_parent: Dictionary = mcp_schema["properties"]["required_parent"]
	var nested_required: Array = required_parent["required"]
	assert("required_child" in nested_required, "Required child should be in nested required array")
	assert(not ("optional_child" in nested_required), "Optional child should not be in nested required array")

func test_recursive_validation_still_works() -> void:
	var schema: Zodot = Z.schema({
		"user": Z.schema({
			"name": Z.string().describe("User name"),
			"profile": Z.schema({
				"age": Z.integer().describe("User age"),
				"email": Z.string().describe("User email")
			}).describe("User profile")
		}).describe("User data")
	})
	
	# Test that validation still works after adding MCP conversion
	var valid_data: Dictionary = {
		"user": {
			"name": "John Doe",
			"profile": {
				"age": 30,
				"email": "john@example.com"
			}
		}
	}
	
	var result: ZodotResult = schema.parse(valid_data)
	assert(result.ok(), "Valid nested data should pass validation")
	
	# Test invalid data
	var invalid_data: Dictionary = {
		"user": {
			"name": "John Doe",
			"profile": {
				"age": "thirty",  # Invalid type
				"email": "john@example.com"
			}
		}
	}
	
	var invalid_result: ZodotResult = schema.parse(invalid_data)
	assert(not invalid_result.ok(), "Invalid nested data should fail validation")

func test_array_nested_in_object_nested_in_array() -> void:
	var schema: Zodot = Z.schema({
		"departments": Z.array().items(Z.schema({
			"name": Z.string().describe("Department name"),
			"employees": Z.array().items(Z.schema({
				"id": Z.integer().describe("Employee ID"),
				"name": Z.string().describe("Employee name")
			})).describe("Department employees")
		})).describe("Company departments")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	var departments_property: Dictionary = mcp_schema["properties"]["departments"]
	
	# Navigate the nested structure
	var dept_schema: Dictionary = departments_property["items"]
	var employees_property: Dictionary = dept_schema["properties"]["employees"]
	var employee_schema: Dictionary = employees_property["items"]
	
	assert(departments_property["type"] == "array", "Departments should be array")
	assert(dept_schema["type"] == "object", "Department should be object")
	assert(employees_property["type"] == "array", "Employees should be array")
	assert(employee_schema["type"] == "object", "Employee should be object")
	assert(employee_schema["properties"]["id"]["type"] == "number", "Employee ID should be number")
	assert(employee_schema["properties"]["name"]["type"] == "string", "Employee name should be string")

func test_recursive_descriptions_preserved() -> void:
	var schema: Zodot = Z.schema({
		"level1": Z.schema({
			"level2": Z.schema({
				"level3": Z.string().describe("Deeply nested string")
			}).describe("Second level object")
		}).describe("First level object")
	})
	
	var mcp_schema: Dictionary = schema.to_mcp_schema()
	
	# Check that all descriptions are preserved through recursion
	var level1: Dictionary = mcp_schema["properties"]["level1"]
	var level2: Dictionary = level1["properties"]["level2"]
	var level3: Dictionary = level2["properties"]["level3"]
	
	assert(level1["description"] == "First level object", "Level 1 description should be preserved")
	assert(level2["description"] == "Second level object", "Level 2 description should be preserved")
	assert(level3["description"] == "Deeply nested string", "Level 3 description should be preserved")