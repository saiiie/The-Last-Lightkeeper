extends Node2D

class Dummy extends Area2D:
	var damage_received: int = 0
	var readout := Label.new()
	var pulse_hits: int = 0
	var stun_remaining: float = 0.0
	var knockback_velocity := Vector2.ZERO

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

	func apply_lantern_pulse(stun_seconds: float, knockback: Vector2) -> void:
		pulse_hits += 1
		stun_remaining = stun_seconds
		knockback_velocity = knockback
		modulate = Color.LIGHT_SKY_BLUE

	func _physics_process(delta: float) -> void:
		if stun_remaining <= 0.0:
			return
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1200.0 * delta)
		stun_remaining = maxf(0.0, stun_remaining - delta)
		if stun_remaining == 0.0:
			modulate = Color.WHITE


func _ready() -> void:
	for location in [Vector2(55, 0), Vector2(0, -60), Vector2(-175, 100)]:
		var dummy := Dummy.new()
		dummy.position = location
		add_child(dummy)
	if "--verify-a2" in OS.get_cmdline_user_args():
		_verify.call_deferred()
	if "--verify-a3" in OS.get_cmdline_user_args():
		_verify_pulse.call_deferred()
	$Player.pulse_cooldown_changed.connect(_show_pulse_cooldown)


func _show_pulse_cooldown(remaining: float, _total: float) -> void:
	$HUD/PulseStatus.text = "Pulse ready" if remaining <= 0.0 else "Pulse cooldown: %.1f s" % remaining


func _verify_pulse() -> void:
	var east: Dummy = get_child(2)
	var north: Dummy = get_child(3)
	var far: Dummy = get_child(4)
	await _wait(4)
	await _press_pulse()
	var passed := east.pulse_hits == 1 and north.pulse_hits == 1 and far.pulse_hits == 0
	passed = passed and east.stun_remaining > 0.0 and north.stun_remaining > 0.0
	passed = passed and east.position.x > 55.0 and north.position.y < -60.0
	passed = passed and $Player/PulseRing.visible and $Player.pulse_cooldown_remaining > 5.9
	passed = passed and $HUD/PulseStatus.text.begins_with("Pulse cooldown")
	await _press_pulse()
	passed = passed and east.pulse_hits == 1 and north.pulse_hits == 1
	await _wait(30)
	passed = passed and not $Player/PulseRing.visible
	await _wait(340)
	passed = passed and $Player.pulse_cooldown_remaining == 0.0 and $HUD/PulseStatus.text == "Pulse ready"
	await _press_pulse()
	passed = passed and east.pulse_hits == 2 and north.pulse_hits == 2 and far.pulse_hits == 0
	if passed:
		print("A3 pulse checks passed")
	else:
		push_error("A3 pulse checks failed")
	get_tree().quit(0 if passed else 1)


func _press_pulse() -> void:
	Input.action_press("lantern_pulse")
	await _wait(3)
	Input.action_release("lantern_pulse")
	await _wait(1)


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
