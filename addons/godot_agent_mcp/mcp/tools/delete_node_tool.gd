@tool
extends MCPTool
class_name DeleteNodeTool

## Returns the unique identifier for this tool
func get_name() -> String:
	return "delete_node"

## Returns a description of what this tool does
func get_description() -> String:
	return "Deletes a node from the scene"

## Returns the input schema defining required parameters for this tool
## Returns: z_schema with node_path field
func get_input_schema() -> z_schema:
	return Z.schema({
		"node_path": Z.string().describe("Path to the node to delete")
	})

## Deletes a node from the currently edited scene
## Parameters:
##   - params: Dictionary containing node_path
## Returns: Dictionary with success data including deleted node path, or error message
func run(params: Dictionary) -> Dictionary:
	var node_path: String = params.get("node_path", "")
	
	var scene_root = EditorInterface.get_edited_scene_root()
	if not scene_root:
		return err("No scene is currently open in the Godot editor. Please create or open a scene first.")
	
	var target_node: Node
	if node_path == "/root":
		return err("Cannot delete the root node")
	else:
		target_node = scene_root.get_node_or_null(node_path)
		if not target_node:
			return err("Node not found at path: " + node_path)
	
	if target_node == scene_root:
		return err("Cannot delete the root node")
	
	var parent_node = target_node.get_parent()
	if not parent_node:
		return err("Node has no parent: " + node_path)
	
	var node_name = target_node.name
	parent_node.remove_child(target_node)
	target_node.queue_free()
	
	return ok("Node %s deleted from path: %s" % [node_name, node_path]) 