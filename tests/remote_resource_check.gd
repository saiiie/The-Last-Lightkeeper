# CI only: never invoke Godot locally to execute this script.
extends SceneTree

func _initialize() -> void:
	if OS.get_environment("GITHUB_ACTIONS") != "true" or OS.get_environment("RUNNER_ENVIRONMENT") != "github-hosted":
		push_error("This validation is restricted to GitHub-hosted runners.")
		quit(1)
		return
	var frames = load("res://assets/characters/player/aren/aren_idle_frames.tres")
	var tiles = load("res://assets/environments/forest/terrain/forest_visual_tileset.tres")
	var scene = load("res://scenes/main.tscn")
	if not frames is SpriteFrames or not tiles is TileSet or not scene is PackedScene:
		push_error("Prepared resources failed to load with expected types.")
		quit(1)
		return
	for direction in ["down", "up", "left", "right"]:
		var animation = "idle_" + direction
		if not frames.has_animation(animation) or frames.get_frame_count(animation) != 1:
			push_error("Missing idle direction or unexpected frame count: " + direction)
			quit(1)
			return
	if tiles.get_source_count() != 64 or tiles.tile_size != Vector2i(32, 32):
		push_error("Unexpected forest TileSet layout.")
		quit(1)
		return
	var instance = scene.instantiate()
	if not instance is Node2D:
		push_error("Main scene must have a Node2D root.")
		quit(1)
		return
	instance.free()
	print("Remote resource checks passed.")
	quit(0)
