@tool
extends MCPTool
class_name ListNodesTool

## Returns the unique identifier for this tool
func get_name() -> String:
	return "list_nodes"

## Returns a description of what this tool does
func get_description() -> String:
	return "Lists all child nodes under a specified parent node"

## Returns the input schema defining required parameters for this tool
## Returns: z_schema with parent_path field
func get_input_schema() -> z_schema:
	return Z.schema({
		"parent_path": Z.string().describe("Path to the parent node to list children from")
	})

## Lists all child nodes under a specified parent node
## Parameters:
##   - params: Dictionary containing parent_path
## Returns: Dictionary with success data including child node information, or error message
func run(params: Dictionary) -> Dictionary:
	var parent_path: String = params.get("parent_path", "")
	
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
	
	var children = []
	for child in parent_node.get_children():
		children.append({
			"name": child.name,
			"type": child.get_class(),
			"path": str(child.get_path())
		})
	
	var children_text = format_children_as_text(children, parent_path)
	return ok("Children of node at path %s:\n%s" % [parent_path, children_text])

## Formats children array as readable text
## Parameters:
##   - children: Array of child node information
##   - parent_path: Path of the parent node
## Returns: Formatted string representation
func format_children_as_text(children: Array, parent_path: String) -> String:
	if children.is_empty():
		return "  No children found"
	
	var lines = []
	for child in children:
		lines.append("  %s (%s) - %s" % [child["name"], child["type"], child["path"]])
	return "\n".join(lines) 