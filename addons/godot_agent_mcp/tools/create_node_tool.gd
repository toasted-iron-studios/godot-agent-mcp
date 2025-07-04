@tool
extends MCPTool
class_name CreateNodeTool

func get_name() -> String:
	return "create_node"

func get_description() -> String:
	return "Creates a new node in the scene under a specified parent"

func get_input_schema() -> z_schema:
	return Z.schema({
		"parent_path": Z.string().describe("Path to the parent node"),
		"node_type": Z.string().describe("Type of node to create"),
		"node_name": Z.string().describe("Name for the new node")
	})


func run(params: Dictionary) -> Dictionary:
	# Extract parameters
	var parent_path: String = params.get("parent_path", "")
	var node_type: String = params.get("node_type", "")
	var node_name: String = params.get("node_name", "")

	# Get scene root using base class method
	var scene_root = get_scene_root()
	if not scene_root:
		return err("No scene is currently open in the Godot editor. Please create or open a scene first.")
	
	# Find the parent node
	var parent_node: Node
	if parent_path == "/root":
		parent_node = scene_root
	else:
		parent_node = scene_root.get_node_or_null(parent_path)
		if not parent_node:
			return err("Parent node not found at path: " + parent_path)
	
	# Check if the node type exists
	if not ClassDB.class_exists(node_type):
		return err("Node type does not exist: " + node_type)
	
	# Create the new node
	var new_node := ClassDB.instantiate(node_type) as Node
	if not new_node:
		return err("Failed to create node of type: " + node_type)
	
	# Set the node name
	new_node.name = node_name
	
	# Add to parent
	parent_node.add_child(new_node)
	new_node.owner = scene_root
	
	# Get the full path of the created node
	var full_path: String = new_node.get_path()
	
	return ok({
		"success": true,
		"node_path": str(full_path),
		"node_type": node_type,
		"node_name": node_name,
		"parent_path": parent_path
	})