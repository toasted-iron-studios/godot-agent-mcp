class_name Z

## Dictionary objects with specific properties
##
## Usage:
## [codeblock]
## var MySchema = Z.schema({
##     "name": Z.string(),
##     "age": Z.integer()
## })
## [/codeblock]
static func schema(dict: Dictionary) -> z_schema:
	return z_schema.new(dict)
	
static func boolean(kind: z_boolean.Kind = z_boolean.Kind.BOTH) -> z_boolean:
	return z_boolean.new(kind)
	
static func integer() -> z_integer:
	return z_integer.new()
	
static func float() -> z_float:
	return z_float.new()

static func string() -> z_string:
	return z_string.new()
	
static func dictionary(schema: Zodot = null) -> z_dictionary:
	return z_dictionary.new(schema)
	
static func array(schema: Zodot = null) -> z_array:
	return z_array.new(schema)
	
