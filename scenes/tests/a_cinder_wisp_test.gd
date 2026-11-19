extends Node2D

const MockBeacon := preload("res://scenes/tests/a_thornbound_test.gd").MockBeacon

@onready var player = $Player
@onready var wisp = $CinderWisp

var _beacon := MockBeacon.new()
var _failures: int = 0


func _ready() -> void:
	add_child(_beacon)
	wisp.set_targets(player, _beacon)
	if "--verify-a5" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _process(_delta: float) -> void:
	$HUD/Status.text = "Beacon HP %d | Player HP %d" % [_beacon.health, player.current_health]


func _verify() -> void:
	_check(wisp.current_health == 25, "starting HP")
	await _wait(55)
	_check(is_equal_approx(wisp.position.x, 220.0), "stops within firing range")
	_check(_beacon.hits == 0 and _bolt_count() == 1, "shot travels before doing damage")
	await _wait(50)
	_check(_beacon.health == 195 and _beacon.hits == 1 and _bolt_count() == 0, "bolt hits beacon once and is removed")
	player.position = Vector2(110, 0)
	await _wait(95)
	_check(player.current_health == 95 and _beacon.hits == 1 and _bolt_count() == 0, "player intercepts bolt")

	player.position = Vector2(110, 80)
	var wall := StaticBody2D.new()
	wall.position = Vector2(100, 0)
	var hitbox := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(10, 40)
	hitbox.shape = box
	wall.add_child(hitbox)
	add_child(wall)
	await _wait(95)
	_check(_beacon.hits == 1 and _bolt_count() == 0, "wall absorbs bolt")

	wall.queue_free()
	await _wait(2)
	wisp.position = Vector2(100, 0)
	await _wait(42)
	_check(is_equal_approx(wisp.position.x, 170.0), "retreats when too close")
	wisp.set_physics_process(false)
	await _wait(60)
	var miss = preload("res://scenes/projectiles/cinder_bolt.tscn").instantiate()
	add_child(miss)
	miss.launch(Vector2(220, 0), Vector2.UP, wisp.get_rid(), _beacon)
	await _wait(94)
	_check(not is_instance_valid(miss) and _beacon.hits == 1, "miss expires without damaging beacon")
	if _failures == 0:
		print("A5 Cinder Wisp checks passed")
	get_tree().quit(0 if _failures == 0 else 1)


func _bolt_count() -> int:
	var count := 0
	for child in get_children():
		if child.scene_file_path == "res://scenes/projectiles/cinder_bolt.tscn":
			count += 1
	return count


func _wait(frames: int) -> void:
	for frame in frames:
		await get_tree().physics_frame


func _check(passed: bool, description: String) -> void:
	if not passed:
		_failures += 1
		push_error("A5 check failed: " + description)
