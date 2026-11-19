extends Node2D

const LIGHT_SHARD := preload("res://scenes/pickups/light_shard.tscn")
const WISP := preload("res://scenes/enemies/cinder_wisp.tscn")
const BRUTE := preload("res://scenes/enemies/hush_brute.tscn")

@onready var player = $Player
@onready var pickups: Node2D = $Pickups

var _enemies: Array[Node2D] = []
var _counts: Array[int] = []
var _failures: int = 0


func _ready() -> void:
	_track_enemy($Thornbound)
	_add_enemy(WISP, Vector2(0, -140))
	_add_enemy(BRUTE, Vector2(-160, 0))
	player.shards_changed.connect(_on_shards_changed)
	if "--verify-a7" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _add_enemy(scene: PackedScene, location: Vector2) -> void:
	var enemy := scene.instantiate() as Node2D
	enemy.position = location
	add_child(enemy)
	_track_enemy(enemy)


func _track_enemy(enemy: Node2D) -> void:
	_enemies.append(enemy)
	enemy.connect("died", _drop_light_shard)


func _drop_light_shard(world_position: Vector2) -> void:
	var shard := LIGHT_SHARD.instantiate() as Area2D
	shard.position = pickups.to_local(world_position)
	pickups.call_deferred("add_child", shard)


func _on_shards_changed(count: int) -> void:
	_counts.append(count)
	$HUD/Status.text = "Shards: %d" % count


func _verify() -> void:
	for enemy in _enemies:
		var death_position := enemy.global_position
		enemy.take_damage(1000)
		enemy.take_damage(1000)
		await _wait()
		_check(pickups.get_child_count() == 1, "one shard per death")
		var shard := pickups.get_child(0) as Area2D
		if shard != null:
			_check(shard.global_position.is_equal_approx(death_position), "shard at death position")
			var collected_before: int = player.shards
			player.global_position = death_position + Vector2(0, 34)
			await _wait()
			_check(player.shards == collected_before + 1 and pickups.get_child_count() == 0, "nearby pickup adds one and disappears")
	_check(_counts == [1, 2, 3], "three pickups emit three total updates")
	if _failures == 0:
		print("A7 light shard checks passed")
	get_tree().quit(0 if _failures == 0 else 1)


func _wait() -> void:
	for frame in 5:
		await get_tree().physics_frame


func _check(passed: bool, description: String) -> void:
	if not passed:
		_failures += 1
		push_error("A7 check failed: " + description)
