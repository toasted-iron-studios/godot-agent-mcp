extends RefCounted
class_name MCPTool

## Abstract base class for MCP tools
## All tools must implement get_name(), get_schema(), get_input_schema(), and run()

func get_name() -> String:
	push_error("MCPTool.get_name() must be implemented by subclass")
	return ""


func get_description() -> String:
	push_error("MCPTool.get_description() must be implemented by subclass")
	return ""

func get_input_schema() -> z_schema:
	push_error("MCPTool.get_input_schema() must be implemented by subclass")
	return Z.schema({})

func run(params: Dictionary) -> Dictionary:
	push_error("MCPTool.run() must be implemented by subclass")
	return {"error": "Tool not implemented"}

## Utility function for common error responses
func err(message: String) -> Dictionary:
	return {"error": message}

## Utility function for success responses
func ok(data: Dictionary) -> Dictionary:
	return {"result": data}

## Get the GodotAgentMCPPlugin instance
func _get_plugin() -> Variant:
	var plugin = Engine.get_meta("GodotAgentMCPPlugin")
	if not plugin:
		push_error("GodotAgentMCPPlugin not found in Engine metadata")
		return null
	return plugin

## Get the editor interface from the plugin
func get_editor_interface() -> EditorInterface:
	var plugin = _get_plugin()
	if not plugin:
		return null
	return plugin.get_editor_interface()

## Get the currently edited scene root
func get_scene_root() -> Node:
	var editor_interface = get_editor_interface()
	if not editor_interface:
		return null
	
	return editor_interface.get_edited_scene_root()