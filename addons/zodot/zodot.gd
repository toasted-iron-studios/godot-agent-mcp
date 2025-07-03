class_name Zodot

var _coerce = false
var _nullable = false
var _description = ""

func _valid_type(_value: Variant) -> bool:
	# Implemented in subclass
	return false

func parse(_value: Variant, _field: Variant = "") -> ZodotResult:
	# Implemented in subclass
	return null
	
func coerce() -> Zodot:
	_coerce = true
	return self

func nullable() -> Zodot:
	_nullable = true
	return self

func describe(description: String) -> Zodot:
	_description = description
	return self

func get_mcp_type() -> String:
	push_error("get_mcp_type() must be implemented by subclass")
	return ""

func to_mcp_property() -> Dictionary:
	var property = {
		"type": get_mcp_type()
	}
	if _description != "":
		property["description"] = _description
	return property
