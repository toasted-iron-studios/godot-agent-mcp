extends RefCounted
class_name MCPTool

## Abstract base class for MCP tools
## All tools must implement get_name(), get_schema(), get_input_schema(), and run()

## Returns the unique name identifier for this tool
## Must be implemented by subclasses
func get_name() -> String:
	push_error("MCPTool.get_name() must be implemented by subclass")
	return ""

## Returns a human-readable description of what this tool does
## Must be implemented by subclasses
func get_description() -> String:
	push_error("MCPTool.get_description() must be implemented by subclass")
	return ""

## Returns the input schema for validating tool parameters
## Must be implemented by subclasses
## Returns: z_schema instance defining the expected input structure
func get_input_schema() -> z_schema:
	push_error("MCPTool.get_input_schema() must be implemented by subclass")
	return Z.schema({})

## Executes the tool with the provided parameters
## Parameters:
##   - params: Dictionary containing tool input parameters
## Returns: Dictionary containing tool result or error information
## Must be implemented by subclasses
func run(params: Dictionary) -> Dictionary:
	push_error("MCPTool.run() must be implemented by subclass")
	return err("Tool not implemented")

## Utility function for common error responses
## Parameters:
##   - message: Error message to return
## Returns: Dictionary formatted as an error response
func err(message: String) -> Dictionary:
	return {"error": MCPError.MCPToolError.new(message)}

## Utility function for success responses
## Parameters:
##   - data: Success data to return
## Returns: Dictionary formatted as a success response
func ok(text: String) -> Dictionary:
	return {
		"content": [
			{
				"type": "text",
				"text": text
			}
		]
	}