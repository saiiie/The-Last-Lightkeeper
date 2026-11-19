extends Node

signal wave_started(current: int, total: int)
signal wave_cleared(current: int)
signal all_waves_cleared
signal boss_spawned(boss: Node2D)

const REGULARS := [
	preload("res://scenes/enemies/thornbound.tscn"),
	preload("res://scenes/enemies/cinder_wisp.tscn"),
	preload("res://scenes/enemies/hush_brute.tscn"),
]
const SHARD := preload("res://scenes/pickups/light_shard.tscn")
# Thornbound, Wisp, Brute, Warden.
const WAVES := [
	[3, 0, 0, 0], [4, 1, 0, 0], [4, 2, 0, 0], [5, 2, 1, 0],
	[5, 3, 1, 0], [5, 3, 2, 0], [6, 3, 2, 0], [6, 4, 2, 0],
	[7, 4, 3, 0], [3, 2, 1, 1],
]
const LIVE_CAP := 10
const INTERMISSION := 7.0

@export var spawn_markers: Array[Marker2D] = []
@export var boss_scene: PackedScene = preload("res://scenes/enemies/hush_warden.tscn")

var _player: Node2D
var _beacon: Node2D
var _actors: Node2D
var _wave := 0
var _queue: Array[int] = []
var _alive: Dictionary = {}
var _delay := 0.0
var _between_waves := false


func start_run(player: Node2D, beacon: Node2D, spawn_parent: Node2D) -> void:
	stop_run()
	_player = player
	_beacon = beacon
	_actors = Node2D.new()
	spawn_parent.add_child(_actors)
	set_physics_process(true)
	_begin_wave(1)


func stop_run() -> void:
	set_physics_process(false)
	_queue.clear()
	_alive.clear()
	if is_instance_valid(_actors):
		_actors.process_mode = Node.PROCESS_MODE_DISABLED
		_actors.queue_free()
	_actors = null
	_between_waves = false
	_delay = 0.0


func _begin_wave(number: int) -> void:
	_wave = number
	_between_waves = false
	_delay = 0.0
	_queue.clear()
	for kind in WAVES[number - 1].size():
		for count in WAVES[number - 1][kind]:
			_queue.append(kind)
	_queue.shuffle()
	wave_started.emit(number, WAVES.size())


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_actors):
		return
	_delay = maxf(0.0, _delay - delta)
	if _delay > 0.0:
		return
	if _between_waves:
		_begin_wave(_wave + 1)
		return
	if _queue.is_empty() or _alive.size() >= LIVE_CAP:
		return
	var kind := _queue[0]
	var scene: PackedScene = REGULARS[kind] if kind < REGULARS.size() else boss_scene
	if scene == null:
		return
	_queue.pop_front()
	var enemy = scene.instantiate()
	enemy.position = _actors.to_local(_spawn_position())
	_actors.add_child(enemy)
	enemy.set_targets(_player, _beacon)
	var id: int = enemy.get_instance_id()
	_alive[id] = kind
	enemy.died.connect(_on_death.bind(id), CONNECT_ONE_SHOT)
	_delay = randf_range(1.2, 2.0)
	if kind == REGULARS.size():
		boss_spawned.emit(enemy)


func _spawn_position() -> Vector2:
	if not spawn_markers.is_empty():
		return spawn_markers.pick_random().global_position
	# Default arena is 1800 x 1100, centered on the beacon.
	var edge := Vector2(randf_range(-860, 860), randf_range(-510, 510))
	match randi_range(0, 3):
		0: edge.x = -860
		1: edge.x = 860
		2: edge.y = -510
		3: edge.y = 510
	return _beacon.global_position + edge


func _on_death(world_position: Vector2, id: int) -> void:
	if not _alive.has(id):
		return
	var regular: bool = _alive[id] < REGULARS.size()
	_alive.erase(id)
	if regular:
		var shard := SHARD.instantiate() as Area2D
		shard.position = _actors.to_local(world_position)
		_actors.add_child(shard)
	if not _alive.is_empty() or not _queue.is_empty():
		return
	var completed_run := _actors
	_between_waves = _wave < WAVES.size()
	_delay = INTERMISSION
	if not _between_waves:
		set_physics_process(false)
	wave_cleared.emit(_wave)
	if completed_run == _actors and _wave == WAVES.size():
		all_waves_cleared.emit()
