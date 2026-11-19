extends Node2D

@onready var player = $Player
@onready var health: Label = $HUD/Health

var _deaths: int = 0
var _failures: int = 0


func _ready() -> void:
	player.health_changed.connect(_show_health)
	player.died.connect(_record_death)
	_show_health(player.current_health, player.max_health)
	if "--verify-a1" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_T:
		player.take_damage(25)


func _show_health(current: int, maximum: int) -> void:
	health.text = "HP %d / %d" % [current, maximum]


func _record_death() -> void:
	_deaths += 1
	health.text += " | Player died"


func _verify() -> void:
	_check(player.current_health == 100 and player.max_health == 100, "initial health")
	var directions := {
		"move_up": Vector2.UP,
		"move_down": Vector2.DOWN,
		"move_left": Vector2.LEFT,
		"move_right": Vector2.RIGHT,
	}
	for action in directions:
		var start: Vector2 = player.position
		await _hold(action, 6)
		var displacement: Vector2 = player.position - start
		_check(displacement.dot(directions[action]) > 10, action)
		var camera := get_viewport().get_camera_2d()
		_check(camera != null and camera.get_screen_center_position().is_equal_approx(player.global_position), "camera tracks " + action)

	await _hold("move_right", 90)
	_check(absf(player.position.x - 188.0) < 0.5, "player stops against world wall")
	player.set_controls_enabled(false)
	var stopped: Vector2 = player.position
	await _hold("move_left", 6)
	_check(player.position.is_equal_approx(stopped), "disabled controls")
	player.set_controls_enabled(true)
	await _hold("move_left", 6)
	_check(player.position.x < stopped.x, "re-enabled controls")

	player.add_shards(3)
	_check(not player.spend_shards(4) and player.shards == 3, "insufficient shards")
	_check(player.spend_shards(3) and player.shards == 0, "spend shards")
	player.take_damage(25)
	_check(player.current_health == 75 and health.text == "HP 75 / 100", "damage and health signal")
	player.take_damage(100)
	player.take_damage(25)
	_check(player.current_health == 0 and _deaths == 1, "lethal damage clamps HP and emits death once")
	stopped = player.position
	await _hold("move_left", 6)
	_check(player.position.is_equal_approx(stopped), "dead player cannot move")
	if _failures == 0:
		print("A1 player checks passed")
	get_tree().quit(1 if _failures > 0 else 0)


func _hold(action: StringName, frames: int) -> void:
	Input.action_press(action)
	for frame in frames:
		await get_tree().physics_frame
	Input.action_release(action)


func _check(passed: bool, description: String) -> void:
	if not passed:
		_failures += 1
		push_error("A1 check failed: " + description)
