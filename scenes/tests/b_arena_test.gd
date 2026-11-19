extends Node2D


func _ready() -> void:
	if "--verify-b1" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _verify() -> void:
	var bounds: Rect2 = $Arena.BOUNDS
	var markers: Array[Marker2D] = $Arena.get_spawn_markers()
	var passed := bounds.size == Vector2(1800, 1100) and markers.size() == 8
	passed = passed and $Arena/BeaconMarker.position == bounds.get_center()
	for marker in markers:
		var edge_gap := minf(900.0 - absf(marker.position.x), 550.0 - absf(marker.position.y))
		passed = passed and is_equal_approx(edge_gap, 50.0)
	var directions := {
		"move_left": Vector2.LEFT, "move_right": Vector2.RIGHT,
		"move_up": Vector2.UP, "move_down": Vector2.DOWN,
	}
	for action in directions:
		var direction: Vector2 = directions[action]
		var edge := bounds.size.abs().dot(direction.abs()) * 0.5
		$Player.position = direction * (edge - 60.0)
		Input.action_press(action)
		for frame in 35:
			await get_tree().physics_frame
		Input.action_release(action)
		var distance: float = $Player.position.dot(direction)
		passed = passed and absf(distance - (edge - 16.0)) < 0.5
	if passed:
		print("B1 arena checks passed")
	else:
		push_error("B1 arena bounds, markers, or wall collision failed")
	get_tree().quit(0 if passed else 1)
