@tool
extends MCPTool
class_name CreateNodeTool

## Returns the unique identifier for this tool
func get_name() -> String:
	return "create_node"

## Returns a description of what this tool does
func get_description() -> String:
	return "Creates a new node in the scene under a specified parent"

## Returns the input schema defining required parameters for this tool
## Returns: z_schema with parent_path, node_type, and node_name fields
func get_input_schema() -> z_schema:
	return Z.schema({
		"parent_path": Z.string().describe("Path to the parent node"),
		"node_type": Z.string().describe("Type of node to create"),
		"node_name": Z.string().describe("Name for the new node")
	})

## Creates a new node in the currently edited scene
## Parameters:
##   - params: Dictionary containing parent_path, node_type, and node_name
## Returns: Dictionary with success data including node path, or error message
func run(params: Dictionary) -> Dictionary:
	var parent_path: String = params.get("parent_path", "")
	var node_type: String = params.get("node_type", "")
	var node_name: String = params.get("node_name", "")

	var scene_root = EditorInterface.get_edited_scene_root()
	if not scene_root:
		return err("No scene is currently open in the Godot editor. Please create or open a scene first.")
	
	var parent_node: Node
	if parent_path == "/root":
		parent_node = scene_root
	else:
		parent_node = scene_root.get_node_or_null(parent_path)
		if not parent_node:
			return err("Parent node not found at path: " + parent_path)
	
	if not ClassDB.class_exists(node_type):
		return err("Node type does not exist: " + node_type)
	
	var new_node := ClassDB.instantiate(node_type) as Node
	if not new_node:
		return err("Failed to create node of type: " + node_type)
	
	new_node.name = node_name
	parent_node.add_child(new_node)
	new_node.owner = scene_root
	
	var full_path: String = new_node.get_path()
	
	return ok("Node %s created at path: %s" % [node_name, full_path])