extends Node

@onready var main = $Main
var starts: Array[int] = []
var clears: Array[int] = []
var roster := {}
var seen := {}
var volley := false
var warning := false
var slam := false
var repaired := false
var completions := 0


func _ready() -> void:
	if "--verify-b11" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _interact() -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	get_viewport().push_input(event)


func _verify() -> void:
	main.waves.wave_started.connect(func(wave, _total): starts.append(wave))
	main.waves.wave_cleared.connect(func(wave): clears.append(wave))
	main.waves.all_waves_cleared.connect(func(): completions += 1)
	var menu := $Main/Overlays/MainMenu/Backdrop/Center/Card
	menu.get_node("Menu/Play").pressed.emit()
	menu.get_node("Intro/Begin").pressed.emit()
	var last_drop := Vector2.ZERO
	var pickup_frames := 0
	for frame in 48000:
		await get_tree().physics_frame
		if completions > 0 or main.defeat.visible:
			break
		var target: Node2D
		for id in main.waves._alive:
			var enemy = instance_from_id(id)
			var kind := enemy.scene_file_path.get_file().get_basename() as String
			if starts.back() == 10 and not seen.has(id):
				seen[id] = true
				roster[kind] = roster.get(kind, 0) + 1
			if kind == "hush_warden":
				var bolts := 0
				for child in enemy.get_children():
					if child.scene_file_path.ends_with("cinder_bolt.tscn"):
						bolts += 1
				volley = volley or bolts == 3
				if enemy.get_node("SlamWarning").visible:
					warning = true
				elif warning:
					slam = true
				if not slam or main.waves._alive.size() > 1 or not main.waves._queue.is_empty():
					continue
			target = enemy
		if pickup_frames > 0:
			main.player.global_position = last_drop
			pickup_frames -= 1
		elif not repaired and main.player.shards >= 3 and main.beacon.current_health < 200:
			main.player.global_position = main.beacon.global_position
			var before: int = main.beacon.current_health
			var cost_before: int = main.player.shards
			_interact()
			repaired = main.beacon.current_health == mini(200, before + 30) and main.player.shards == cost_before - 3
		elif target != null:
			if starts.back() == 1 and main.beacon.current_health == 200:
				continue
			main.player.global_position = target.global_position + Vector2(38, 0)
			last_drop = target.global_position
			main.player._try_attacks(Vector2.LEFT, true, true)
			if target.is_queued_for_deletion():
				pickup_frames = 4
		else:
			main.player.global_position = Vector2(70, 110)

	var passed := starts == [1,2,3,4,5,6,7,8,9,10] and clears == starts and completions == 1
	passed = passed and roster == {"thornbound":3,"cinder_wisp":2,"hush_brute":1,"hush_warden":1}
	passed = passed and repaired and volley and slam and not main.victory.visible
	main.player.global_position = main.beacon.global_position + Vector2(120, 0)
	_interact()
	passed = passed and not main.beacon.rite_completed
	main.player.global_position = main.beacon.global_position
	_interact()
	await get_tree().create_timer(1.5).timeout
	passed = passed and main.victory.visible and main.beacon.rite_completed
	if passed:
		print("B11 integrated ten-wave finale passed")
	else:
		push_error("B11 failed: waves %s, clears %s, roster %s, repair %s, volley %s, slam %s" % [starts, clears, roster, repaired, volley, slam])
	get_tree().quit(0 if passed else 1)
