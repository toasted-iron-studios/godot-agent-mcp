@tool
extends BaseTool
class_name CreateNodeTool

const TOOL_NAME: String = "create_node"
const TOOL_DESCRIPTION: String = "Creates a new node in the scene under a specified parent"

static func get_input_schema() -> z_schema:
	return Z.schema({
		"parent_path": Z.string(),
		"node_type": Z.string(),
		"node_name": Z.string()
	})

static func get_schema() -> Dictionary:
	return {
		"name": TOOL_NAME,
		"description": TOOL_DESCRIPTION,
		"inputSchema": {
			"type": "object",
			"properties": {
				"parent_path": {
					"type": "string",
					"description": "Path to the parent node"
				},
				"node_type": {
					"type": "string", 
					"description": "Type of node to create"
				},
				"node_name": {
					"type": "string",
					"description": "Name for the new node"
				}
			},
			"required": ["parent_path", "node_type", "node_name"]
		}
	}

static func run(params: Dictionary) -> Dictionary:
	# Input validation with Zodot
	var validation_result: ZodotResult = get_input_schema().parse(params)
	if not validation_result.ok():
		return error_response("Invalid parameters: " + validation_result.error)
	
	# Extract parameters
	var parent_path: String = params.get("parent_path", "")
	var node_type: String = params.get("node_type", "")
	var node_name: String = params.get("node_name", "")
	
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotAgentMCPPlugin")
	if not plugin:
		return error_response("GodotAgentMCPPlugin not found in Engine metadata")
	
	var editor_interface = plugin.get_editor_interface()
	var scene_root: Node = editor_interface.get_edited_scene_root()
	if not scene_root:
		return error_response("No scene is currently open")
	
	# Find the parent node
	var parent_node: Node
	if parent_path == "/root":
		parent_node = scene_root
	else:
		parent_node = scene_root.get_node_or_null(parent_path)
		if not parent_node:
			return error_response("Parent node not found at path: " + parent_path)
	
	# Check if the node type exists
	if not ClassDB.class_exists(node_type):
		return error_response("Node type does not exist: " + node_type)
	
	# Create the new node
	var new_node := ClassDB.instantiate(node_type) as Node
	if not new_node:
		return error_response("Failed to create node of type: " + node_type)
	
	# Set the node name
	new_node.name = node_name
	
	# Add to parent
	parent_node.add_child(new_node)
	new_node.owner = scene_root
	
	# Get the full path of the created node
	var full_path: String = new_node.get_path()
	
	return ok_response({
		"success": true,
		"node_path": str(full_path),
		"node_type": node_type,
		"node_name": node_name,
		"parent_path": parent_path
	})