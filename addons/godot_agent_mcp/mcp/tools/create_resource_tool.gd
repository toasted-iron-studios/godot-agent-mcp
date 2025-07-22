@tool
extends MCPTool
class_name CreateResourceTool

## Returns the unique identifier for this tool
func get_name() -> String:
	return "create_resource"

## Returns a description of what this tool does
func get_description() -> String:
	return "Creates a new resource with specified type, path, and properties"

## Returns the input schema defining required parameters for this tool
## Returns: z_schema with resource_type, resource_path, and optional properties
func get_input_schema() -> z_schema:
	return Z.schema({
		"resource_type": Z.string().non_empty().describe("Type of resource to create (e.g., 'PackedScene', 'Script', 'Material')"),
		"resource_path": Z.string().non_empty().describe("Path where the resource should be saved (relative to res://)"),
		"properties": Z.dictionary().nullable().describe("Optional dictionary of properties to set on the resource")
	})

## Creates a new resource with the specified parameters
## Parameters:
##   - params: Dictionary containing resource_type, resource_path, and optional properties
## Returns: Dictionary with success data including resource path, or error message
func run(params: Dictionary) -> Dictionary:
	var resource_type: String = params.get("resource_type", "")
	var resource_path: String = params.get("resource_path", "")
	var properties: Dictionary = params.get("properties", {})
	
	var normalized_path = normalize_resource_path(resource_path)
	var resource = create_resource_instance(resource_type)
	
	if resource == null:
		return err("Failed to create resource of type: " + resource_type)
	
	apply_resource_properties(resource, properties)
	
	var save_result = save_resource_to_path(resource, normalized_path)
	if save_result.has("error"):
		return save_result
	
	refresh_filesystem()
	
	return ok("Resource created successfully:\n- Type: " + resource_type + "\n- Path: " + normalized_path)

## Normalizes the resource path to ensure it starts with res://
## Parameters:
##   - path: Raw path string
## Returns: Normalized path string starting with res://
func normalize_resource_path(path: String) -> String:
	if not path.begins_with("res://"):
		return "res://" + path
	return path

## Creates a new resource instance of the specified type
## Parameters:
##   - resource_type: String name of the resource class
## Returns: Resource instance or null if creation failed
func create_resource_instance(resource_type: String) -> Resource:
	if not ClassDB.class_exists(resource_type):
		return null
	
	if not ClassDB.is_parent_class(resource_type, "Resource"):
		return null
	
	return ClassDB.instantiate(resource_type)

## Applies properties to a resource instance
## Parameters:
##   - resource: Resource instance to modify
##   - properties: Dictionary of property names and values
func apply_resource_properties(resource: Resource, properties: Dictionary) -> void:
	for property_name in properties:
		var property_value = properties[property_name]
		if resource.has_method("set_" + property_name):
			resource.call("set_" + property_name, property_value)
		else:
			resource.set(property_name, property_value)

## Saves a resource to the specified path
## Parameters:
##   - resource: Resource instance to save
##   - path: Full path where to save the resource
## Returns: Dictionary with success or error information
func save_resource_to_path(resource: Resource, path: String) -> Dictionary:
	var directory_result = ensure_directory_exists(path)
	if directory_result.has("error"):
		return directory_result
	
	var save_result = ResourceSaver.save(resource, path)
	if save_result != OK:
		return err("Failed to save resource to path '" + path + "' (Error code: " + str(save_result) + ")")
	
	return {"success": true}

## Ensures the directory for the resource path exists
## Parameters:
##   - resource_path: Full path to the resource file
## Returns: Dictionary with success or error information
func ensure_directory_exists(resource_path: String) -> Dictionary:
	var directory_path = resource_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(directory_path):
		var creation_result = DirAccess.make_dir_recursive_absolute(directory_path)
		if creation_result != OK:
			return err("Failed to create directory '" + directory_path + "' (Error code: " + str(creation_result) + ")")
	
	return {"success": true}

## Refreshes the filesystem to show the new resource in the editor
func refresh_filesystem() -> void:
	var editor_interface = EditorInterface
	if editor_interface:
		editor_interface.get_resource_filesystem().scan() 