extends Node2D

const MockBeacon := preload("res://scenes/tests/a_thornbound_test.gd").MockBeacon
const BOSS_STAND_IN := preload("res://scenes/enemies/hush_brute.tscn")

@onready var manager = $WaveManager
var beacon := MockBeacon.new()
var clears: Array[int] = []
var finishes := 0
var failures := 0


func _ready() -> void:
	add_child(beacon)
	manager.boss_scene = BOSS_STAND_IN
	manager.wave_started.connect(_show_wave)
	manager.wave_cleared.connect(func(number: int): clears.append(number))
	manager.all_waves_cleared.connect(func(): finishes += 1)
	manager.start_run($Player, beacon, self)
	if "--verify-a8" in OS.get_cmdline_user_args():
		_verify()


func _show_wave(number: int, total: int) -> void:
	$HUD/Status.text = "Wave %d/%d | Test only: F9/F10 jump | Brute stands in for Warden" % [number, total]


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_F9, KEY_F10]:
			manager.start_run($Player, beacon, self)
			manager._begin_wave(9 if event.keycode == KEY_F9 else 10)


func _kill_one() -> void:
	var enemy = instance_from_id(manager._alive.keys()[0])
	enemy.take_damage(10000)


func _verify() -> void:
	manager._physics_process(0.1)
	manager._physics_process(1.0)
	_check(manager._alive.size() == 1, "staggered spawns")
	_kill_one()
	_check(clears.is_empty(), "pending queue prevents clear")
	for i in 2:
		manager._physics_process(2.1)
	_check(clears.is_empty(), "living enemies prevent clear")
	for i in 2:
		_kill_one()
	_check(clears == [1], "single wave 1 clear")
	var shards := 0
	for actor in manager._actors.get_children():
		if actor.scene_file_path == "res://scenes/pickups/light_shard.tscn":
			shards += 1
	_check(shards == 3, "one shard per standard death")
	manager._physics_process(6.9)
	_check(manager._wave == 1, "intermission")
	manager._physics_process(0.2)
	_check(manager._wave == 2 and manager._queue.size() == 5, "wave 2 begins")
	manager.stop_run()
	manager._physics_process(100)
	_check(manager._actors == null and manager._queue.is_empty(), "stopped spawns")
	manager.start_run($Player, beacon, self)
	manager._begin_wave(9)
	_check(_counts() == [7, 4, 3, 0], "wave 9 mix")
	for i in 14:
		manager._physics_process(2.1)
	_check(manager._alive.size() == 10 and manager._queue.size() == 4, "live cap")
	while not manager._alive.is_empty():
		_kill_one()
		manager._physics_process(2.1)
	manager._physics_process(7.1)
	_check(manager._wave == 10 and _counts() == [3, 2, 1, 1], "final wave mix")
	for i in 7:
		manager._physics_process(2.1)
	for i in 6:
		_kill_one()
	_check(finishes == 0, "last enemy blocks completion")
	_kill_one()
	_check(clears == [1, 9, 10] and finishes == 1, "single final clear")
	if failures == 0:
		print("A8 wave checks passed")
	get_tree().quit(0 if failures == 0 else 1)


func _counts() -> Array:
	var counts := [0, 0, 0, 0]
	for kind in manager._queue:
		counts[kind] += 1
	return counts


func _check(passed: bool, description: String) -> void:
	if not passed:
		failures += 1
		push_error("A8 check failed: " + description)
