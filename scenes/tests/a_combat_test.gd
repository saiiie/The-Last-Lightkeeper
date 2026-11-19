extends Node2D

class Dummy extends Area2D:
	var damage_received: int = 0
	var readout := Label.new()

	func _ready() -> void:
		collision_layer = 4
		collision_mask = 0
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 12
		shape.shape = circle
		add_child(shape)
		readout.position = Vector2(-18, -36)
		add_child(readout)
		take_damage(0)

	func _draw() -> void:
		draw_circle(Vector2.ZERO, 12, Color.SALMON)

	func take_damage(amount: int) -> void:
		damage_received += amount
		readout.text = str(damage_received)


func _ready() -> void:
	for location in [Vector2(55, 0), Vector2(0, -60), Vector2(-175, 100)]:
		var dummy := Dummy.new()
		dummy.position = location
		add_child(dummy)
	if "--verify-a2" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _verify() -> void:
	var east: Dummy = get_child(2)
	var north: Dummy = get_child(3)
	var far: Dummy = get_child(4)
	await _wait(4)
	await _click("melee_attack", east.position)
	await _click("ranged_attack", far.position)
	await _click("melee_attack", north.position)
	await _click("ranged_attack", east.position)
	await _wait(17)
	var passed := east.damage_received == 20 and north.damage_received == 0
	await _click("melee_attack", north.position)
	await _wait(18)
	passed = passed and north.damage_received == 20 and far.damage_received == 12
	await _click("ranged_attack", east.position)
	await _wait(12)
	passed = passed and east.damage_received == 32 and $Player.current_health == 100
	await _wait(25)
	await _click("ranged_attack", Vector2(0, 150))
	passed = passed and get_child_count() == 6
	await _wait(92)
	passed = passed and get_child_count() == 5
	if passed:
		print("A2 combat checks passed")
	else:
		push_error("A2 combat check failed. East %d, north %d, far %d" % [east.damage_received, north.damage_received, far.damage_received])
	get_tree().quit(0 if passed else 1)


func _click(action: StringName, target: Vector2) -> void:
	var aim := Vector2($Player.position).direction_to(target)
	$Player._try_attacks(aim, action == &"melee_attack", action == &"ranged_attack")
	await _wait(3)


func _wait(frames: int) -> void:
	for frame in frames:
		await get_tree().physics_frame
