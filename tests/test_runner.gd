extends SceneTree

var tests_passed: int = 0
var tests_failed: int = 0

func _ready() -> void:
	print("Running MCP Middleware Tests...")
	
	run_test_class(load("res://tests/test_zodot_describe.gd").new())
	run_test_class(load("res://tests/test_zodot_mcp_types.gd").new())
	run_test_class(load("res://tests/test_zodot_schema_conversion.gd").new())
	run_test_class(load("res://tests/test_zodot_array_items.gd").new())
	run_test_class(load("res://tests/test_zodot_recursive_schemas.gd").new())
	run_test_class(load("res://tests/test_mcp_tool_integration.gd").new())
	
	print("\n=== TEST RESULTS ===")
	print("Tests passed: ", tests_passed)
	print("Tests failed: ", tests_failed)
	
	if tests_failed > 0:
		print("Some tests failed!")
		quit(1)
	else:
		print("All tests passed!")
		quit(0)

func run_test_class(test_instance: RefCounted) -> void:
	var klass: String = test_instance.get_class()
	if klass == "RefCounted":
		klass = test_instance.get_script().resource_path.get_file().get_basename()
	
	print("\n--- Running ", klass, " ---")
	
	var methods: Array = test_instance.get_method_list()
	for method: Dictionary in methods:
		if method.name.begins_with("test_"):
			print("About to run test: ", method.name)
			run_test(test_instance, method.name)
			print("Finished test: ", method.name)

func run_test(test_instance: RefCounted, method_name: String) -> void:
	print("  Running ", method_name, "...")
	test_instance.call(method_name)
	print("    ✓ PASSED")
	tests_passed += 1