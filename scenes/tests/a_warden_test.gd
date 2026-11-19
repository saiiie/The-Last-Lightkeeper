extends Node2D

const MockBeacon := preload("res://scenes/tests/a_thornbound_test.gd").MockBeacon
var beacon := MockBeacon.new()
var deaths := 0
var health_updates: Array[int] = []
var failures := 0
@onready var boss = $Warden
@onready var player = $Player
@onready var warning: Polygon2D = $Warden/SlamWarning


func _ready() -> void:
	add_child(beacon)
	boss.set_targets(player, beacon)
	boss.died.connect(func(_pos): deaths += 1)
	boss.health_changed.connect(_show_health)
	_show_health(boss.current_health, boss.max_health)
	if "--verify-a9" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _show_health(current: int, maximum: int) -> void:
	health_updates.append(current)
	$HUD/Status.text = "Hush Warden %d / %d | Dodge the bolts and leave the marked circle." % [current, maximum]


func _verify() -> void:
	await _wait(42)
	var bolts := 0
	for child in boss.get_children():
		if child.scene_file_path == "res://scenes/projectiles/cinder_bolt.tscn":
			bolts += 1
	_check(bolts == 3, "three bolts launched")
	await _wait(94)
	_check(player.current_health == 95 and beacon.health == 200, "intercepted center shot, side shots miss")
	_check(warning.visible and warning.global_position == beacon.global_position, "visible warning at beacon")
	player.position = Vector2.ZERO
	await _wait(30)
	_check(beacon.health == 200 and player.current_health == 95, "warning precedes damage")
	player.position = Vector2(0, 120)
	await _wait(35)
	_check(beacon.health == 182 and player.current_health == 95, "slam hits beacon and player dodges")
	await _wait(210)
	_check(warning.visible and beacon.health == 177, "unblocked volley reaches beacon")
	player.position = warning.global_position
	beacon.position = Vector2(0, 110)
	await _wait(60)
	_check(player.current_health == 77 and beacon.health == 177, "slam hits player at locked position")
	for frame in 400:
		if warning.visible:
			break
		await _wait(1)
	_check(warning.visible, "final slam armed")
	var hp_before_death := beacon.health
	boss.take_damage(25)
	boss.take_damage(1000)
	boss.take_damage(5)
	await _wait(200)
	_check(health_updates == [450, 425, 0] and deaths == 1, "boss health and death signals")
	_check(not is_instance_valid(boss) and beacon.health == hp_before_death, "death cancels pending slam")
	if failures == 0:
		print("A9 Warden checks passed")
	get_tree().quit(0 if failures == 0 else 1)


func _wait(frames: int) -> void:
	for frame in frames:
		await get_tree().physics_frame


func _check(passed: bool, description: String) -> void:
	if not passed:
		failures += 1
		push_error("A9 check failed: " + description)
