@tool
extends MCPTool
class_name UpdateNodePropertyTool

## Returns the unique identifier for this tool
func get_name() -> String:
	return "update_node_property"

## Returns a description of what this tool does
func get_description() -> String:
	return "Updates a property on a node in the scene"

## Returns the input schema defining required parameters for this tool
## Returns: z_schema with node_path, property, and value fields
func get_input_schema() -> z_schema:
	return Z.schema({
		"node_path": Z.string().describe("Path to the node to update"),
		"property": Z.string().describe("Name of the property to update"),
		"value": Z.string().describe("New value for the property")
	})

## Updates a property on a node in the currently edited scene
## Parameters:
##   - params: Dictionary containing node_path, property, and value
## Returns: Dictionary with success data including updated property info, or error message
func run(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	var property_name: String = params.get("property", "")
	var property_value = params.get("value")
	
	var scene_root = EditorInterface.get_edited_scene_root()
	if not scene_root:
		return err("No scene is currently open in the Godot editor. Please create or open a scene first.")
	
	var target_node: Node
	if node_path == "/root":
		target_node = scene_root
	else:
		target_node = scene_root.get_node_or_null(node_path)
		if not target_node:
			return err("Node not found at path: " + node_path)
	
	if not property_name in target_node:
		return err("Property %s does not exist on node %s" % [property_name, node_path])
	
	var parsed_value = parse_property_value(property_value)
	target_node.set(property_name, parsed_value)
	
	return ok("Property %s updated to %s on node at path: %s" % [property_name, str(parsed_value), node_path])

## Parses property value to appropriate Godot type
## Parameters:
##   - value: Raw property value to parse
## Returns: Parsed value in appropriate type
func parse_property_value(value):
	if value is String:
		var str_value = value as String
		if str_value.is_valid_int():
			return str_value.to_int()
		elif str_value.is_valid_float():
			return str_value.to_float()
		elif str_value.to_lower() == "true":
			return true
		elif str_value.to_lower() == "false":
			return false
		else:
			return str_value
	else:
		return value 