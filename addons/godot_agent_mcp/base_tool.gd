@tool
extends RefCounted
class_name BaseTool

## Abstract base class for MCP tools
## All tools must implement get_schema(), get_input_schema(), and run()

static func get_schema() -> Dictionary:
	push_error("BaseTool.get_schema() must be implemented by subclass")
	return {}

static func get_input_schema() -> z_schema:
	push_error("BaseTool.get_input_schema() must be implemented by subclass")
	return Z.schema({})

static func run(params: Dictionary) -> Dictionary:
	push_error("BaseTool.run() must be implemented by subclass")
	return {"error": "Tool not implemented"}

## Utility function for common error responses
static func error_response(message: String) -> Dictionary:
	return {"error": message}

## Utility function for success responses
static func ok_response(data: Dictionary) -> Dictionary:
	return {"result": data}