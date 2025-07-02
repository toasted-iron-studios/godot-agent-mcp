@tool
extends Control

func _init():
	var label = Label.new()
	label.text = "MCP Server Tool"
	add_child(label)