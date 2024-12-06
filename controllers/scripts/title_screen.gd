extends Control

@export var WORLDENVIRONMENT : WorldEnvironment

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_demo.tscn")

func _on_change_graphics_pressed() -> void:
	WORLDENVIRONMENT.environment.sdfgi_enabled = !WORLDENVIRONMENT.environment.sdfgi_enabled
