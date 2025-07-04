@tool
extends MCPTool
class_name GetNodePropertiesTool

## Returns the unique identifier for this tool
func get_name() -> String:
	return "get_node_properties"

## Returns a description of what this tool does
func get_description() -> String:
	return "Gets all properties of a node in the scene"

## Returns the input schema defining required parameters for this tool
## Returns: z_schema with node_path field
func get_input_schema() -> z_schema:
	return Z.schema({
		"node_path": Z.string().describe("Path to the node to get properties from")
	})

## Gets all properties of a node in the currently edited scene
## Parameters:
##   - params: Dictionary containing node_path
## Returns: Dictionary with success data including all node properties, or error message
func run(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	
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
	
	var properties = {}
	var property_list = target_node.get_property_list()
	
	for prop in property_list:
		var name = prop["name"]
		if not name.begins_with("_"):
			var value = target_node.get(name)
			properties[name] = serialize_property_value(value)
	
	var properties_text = format_properties_as_text(properties)
	return ok("Properties for node at path %s:\n%s" % [node_path, properties_text])

## Serializes property value to string representation
## Parameters:
##   - value: Property value to serialize
## Returns: String representation of the value
func serialize_property_value(value) -> String:
	if value == null:
		return "null"
	elif value is Vector2:
		return "Vector2(%s, %s)" % [value.x, value.y]
	elif value is Vector3:
		return "Vector3(%s, %s, %s)" % [value.x, value.y, value.z]
	elif value is Color:
		return "Color(%s, %s, %s, %s)" % [value.r, value.g, value.b, value.a]
	else:
		return str(value)

## Formats properties dictionary as readable text
## Parameters:
##   - properties: Dictionary of property names and values
## Returns: Formatted string representation
func format_properties_as_text(properties: Dictionary) -> String:
	var lines = []
	for prop_name in properties.keys():
		var value = properties[prop_name]
		lines.append("  %s: %s" % [prop_name, value])
	return "\n".join(lines) 