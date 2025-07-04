# Godot Agent MCP

A Godot MCP (Model Context Protocol) server that enables AI assistants like Claude, Cursor, and Zed to interact with Godot Engine through standardized tools and commands.

## Overview

This plugin transforms your Godot editor into an MCP server, allowing AI coding assistants to:
- Create and manipulate scene nodes
- Inspect and modify project structure
- Execute Godot-specific operations remotely

The server implements the [MCP specification](https://modelcontextprotocol.io/introduction) and provides a robust foundation for building AI-assisted Godot development workflows.

Notably, the MCP runs _in_ Godot, which reduces installation complexity and improves maintainability.

## Features

- **MCP-compliant HTTP server** - Runs on localhost:8080
- **Schema validation** - Uses Zodot for type-safe parameter validation
- **Extensible tool system** - Easy to add new tools and capabilities
- **JSON-RPC 2.0 support** - Standard protocol implementation
- **CORS protection** - Restricted to localhost connections

## Installation

### Prerequisites
- Godot 4.x
- Git (for cloning the repository)

### Setup

1. **Clone the repository into your Godot project:**
   ```bash
   cd your-godot-project
   git clone https://github.com/toasted-iron-studios/godot-agent-mcp.git
   # Or add as submodule
   git submodule add https://github.com/toasted-iron-studios/godot-agent-mcp.git addons/godot_agent_mcp
   ```

2. **Enable the plugin:**
   - Open your project in Godot
   - Go to `Project → Project Settings → Plugins`
   - Find "Godot Agent MCP" and enable it
   - The server will automatically start on port 8080

3. **Verify installation:**
   - Check the Output panel for "Godot Agent MCP plugin started"
   - The server should be accessible at `http://127.0.0.1:8080`

## Usage

### With AI Assistants

Configure your AI assistant to use the MCP server:

**For Cursor/VSCode:**
```json
{
  "mcp": {
    "servers": {
      "godot-agent": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-fetch", "http://127.0.0.1:8080"]
      }
    }
  }
}
```

**For Claude Desktop:**
```json
{
  "mcpServers": {
    "godot-agent": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch", "http://127.0.0.1:8080"]
    }
  }
}
```

### Available Tools

#### `create_node`
Creates a new node in the currently edited scene.

**Parameters:**
- `parent_path` (string): Path to the parent node (use "/root" for scene root)
- `node_type` (string): Godot node class name (e.g., "Node2D", "RigidBody3D")
- `node_name` (string): Name for the new node

**Example:**
```json
{
  "parent_path": "/root",
  "node_type": "Node2D",
  "node_name": "Player"
}
```

### Direct HTTP Usage

You can also interact with the server directly via HTTP:

```bash
curl -X POST http://127.0.0.1:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "create_node",
      "arguments": {
        "parent_path": "/root",
        "node_type": "Node2D", 
        "node_name": "MyNode"
      }
    },
    "id": 1
  }'
```

## Architecture

### Core Components

- **`plugin.gd`** - Main plugin entry point, manages server lifecycle
- **`HttpServer`** - HTTP server handling MCP requests
- **`MCPRouter`** - Routes MCP method calls to appropriate handlers
- **`MCPTool`** - Abstract base class for all tools
- **`Zodot`** - Schema validation library for type safety

### Request Flow

```
AI Assistant → HTTP Request → HttpServer → MCPRouter → MCPTool → Godot API
```

1. AI assistant sends JSON-RPC 2.0 request
2. HttpServer validates and parses the request
3. MCPRouter routes to the appropriate tool
4. Tool validates parameters using Zodot schemas
5. Tool executes Godot operations and returns results

### Tool Architecture

Tools inherit from `MCPTool` and implement:
- `get_name()` - Unique tool identifier
- `get_description()` - Human-readable description
- `get_input_schema()` - Zodot schema for parameter validation
- `run(params)` - Tool execution logic

## Contributing

### Code Quality Standards

We maintain strict code quality standards to ensure a professional, maintainable codebase:

#### **NO INLINE COMMENTS**
- **NEVER** use inline comments (single `#` comments within function bodies)
- Inline comments indicate poor code quality and lack of experience
- If code needs explanation, refactor it into a well-named function with a docblock
- Code should be self-documenting through clear variable and function names

#### **MANDATORY DOCBLOCKS**
- **ALL** public functions MUST have descriptive docblocks (`##` comments)
- Docblocks must explain the function's purpose, parameters, return values, and side effects
- Include parameter types and return types in the description when helpful
- Document any exceptions or error conditions the function might encounter

#### **Function Naming**
- Use descriptive verb phrases: `validate_input()`, `parse_json_request()`, `handle_authentication()`
- Use descriptive nouns for variables: `user_credentials`, `parsed_data`, `validation_result`
- Avoid abbreviations and single-letter variables (except for short loop counters)

#### **Refactoring Guidelines**
- If you find yourself wanting to add an inline comment, **stop and refactor instead**
- Extract the code block into a function with a descriptive name
- The function name should explain what the inline comment would have said

### Examples

**❌ BAD - Inline comments:**
```gdscript
# Parse the request data
var data = parse_request(request)

# Check if user is valid
if user.is_valid():
    # Process the user
    process_user(user)
```

**✅ GOOD - Self-documenting code with docblocks:**
```gdscript
## Validates user credentials and processes authentication request
## Returns true if authentication succeeds, false otherwise
func authenticate_user(credentials: Dictionary) -> bool:
    var user = find_user_by_credentials(credentials)
    if not user or not user.is_valid():
        return false
    
    return process_authentication(user)

## Converts raw HTTP request data into a structured request object
## Parameters:
##   - raw_data: The complete HTTP request as a string
## Returns: Dictionary containing parsed headers, body, and method
## Throws: Returns error dictionary if request format is invalid
func parse_http_request(raw_data: String) -> Dictionary:
    # Implementation here
```

### Adding New Tools

1. **Create your tool class:**
   ```gdscript
   @tool
   extends MCPTool
   class_name YourTool

   ## Returns the unique identifier for this tool
   func get_name() -> String:
       return "your_tool_name"

   ## Returns a description of what this tool does
   func get_description() -> String:
       return "Clear description of tool functionality"

   ## Returns the input schema defining required parameters
   func get_input_schema() -> z_schema:
       return Z.schema({
           "param1": Z.string().describe("Parameter description"),
           "param2": Z.integer().nullable().describe("Optional parameter")
       })

   ## Executes the tool with validated parameters
   ## Parameters:
   ##   - params: Dictionary containing validated tool input
   ## Returns: Dictionary with success data or error message
   func run(params: Dictionary) -> Dictionary:
       # Tool implementation
       return ok("Success message")
   ```

2. **Register your tool:**
   ```gdscript
   # In plugin.gd
   http_server.start(MCPRouter.new([
       CreateNodeTool.new(),
       YourTool.new()  # Add your tool here
   ]), 8080)
   ```

3. **Add tests:**
   ```gdscript
   # In tests/test_your_tool.gd
   extends RefCounted
   class_name TestYourTool

   func test_your_tool_functionality() -> void:
       var tool = YourTool.new()
       var result = tool.run({"param1": "test_value"})
       assert(result.has("content"), "Tool should return content")
   ```

### Schema Validation with Zodot

Use Zodot for robust parameter validation:

```gdscript
# Basic types
Z.string()                    # String parameter
Z.integer()                   # Integer parameter  
Z.boolean()                   # Boolean parameter
Z.dictionary()                # Dictionary parameter

# Modifiers
Z.string().nullable()         # Optional string
Z.integer().describe("desc")  # With description

# Complex schemas
Z.schema({
    "user": Z.schema({
        "name": Z.string(),
        "age": Z.integer()
    }),
    "tags": Z.array().items(Z.string())
})
```

### Development Workflow

1. **Fork and clone** the repository
2. **Create a feature branch:** `git checkout -b feature/new-tool`
3. **Follow code standards** outlined above
4. **Add comprehensive tests** for your changes
5. **Submit a pull request** with clear description

### Testing

WIP: it don't work.

### GDScript Specific Guidelines

- Follow GDScript naming conventions (snake_case for variables/functions, PascalCase for classes)
- Use type hints wherever possible
- Prefer `match` statements over long `if/elif` chains
- Use `const` for compile-time constants, `var` for variables
- Favor composition over inheritance
- Use dependency injection for better testability
- Keep classes focused on a single responsibility

## Troubleshooting

### Common Issues

**Server won't start:**
- Check if port 8080 is already in use
- Ensure the plugin is properly enabled
- Check Godot's Output panel for error messages

**Tools not found:**
- Verify tools are properly registered in `plugin.gd`
- Check tool names match exactly (case-sensitive)
- Ensure tools inherit from `MCPTool`

**Schema validation errors:**
- Verify parameter types match schema definitions
- Check for missing required parameters
- Ensure Zodot schemas are properly defined

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

We welcome contributions! Please read our contributing guidelines above and ensure your code follows our quality standards.

## Support

- **Issues:** [GitHub Issues](https://github.com/toasted-iron-studios/godot-agent-mcp/issues)
- **Discussions:** [GitHub Discussions](https://github.com/toasted-iron-studios/godot-agent-mcp/discussions)
- **Documentation:** [MCP Specification](https://modelcontextprotocol.io/introduction) 