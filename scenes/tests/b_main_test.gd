extends Node


func _ready() -> void:
	if "--verify-b5" in OS.get_cmdline_user_args():
		_verify.call_deferred()
	elif "--verify-b6" in OS.get_cmdline_user_args():
		_verify_repair.call_deferred()
	elif "--verify-b7" in OS.get_cmdline_user_args():
		_verify_defeat.call_deferred()


func _verify() -> void:
	var main = $Main
	var card := $Main/Overlays/MainMenu/Backdrop/Center/Card
	var passed: bool = not main.hud.visible and not main.get_node("World").visible
	card.get_node("Menu/Play").pressed.emit()
	passed = passed and card.get_node("Intro").is_visible_in_tree() and main.waves._actors == null
	card.get_node("Intro/Begin").pressed.emit()
	for frame in 4:
		await get_tree().physics_frame
	var labels := $Main/HUD/Status/Inset/Readouts
	passed = passed and main.beacon.is_visible_in_tree() and main.arena.is_visible_in_tree() and main.hud.visible
	passed = passed and labels.get_node("Player").text == "Player HP  100 / 100"
	passed = passed and labels.get_node("Beacon").text == "Beacon HP  200 / 200"
	passed = passed and labels.get_node("Wave").text == "Wave  1 / 10"
	passed = passed and labels.get_node("Shards").text == "Shards  0" and labels.get_node("Pulse").text == "Pulse  Ready"
	passed = passed and main.waves._alive.size() == 1 and main.waves.spawn_markers.size() == 8
	main.player.take_damage(8)
	main.player.add_shards(1)
	main.beacon.take_damage(20)
	passed = passed and labels.get_node("Player").text == "Player HP  92 / 100"
	passed = passed and labels.get_node("Beacon").text == "Beacon HP  180 / 200" and labels.get_node("Shards").text == "Shards  1"
	if passed:
		print("B5 main scene checks passed")
	else:
		push_error("B5 menu, world, spawning, or live HUD check failed")
	get_tree().quit(0 if passed else 1)


func _verify_repair() -> void:
	var main = $Main
	var card := $Main/Overlays/MainMenu/Backdrop/Center/Card
	var prompt: Label = $Main/HUD/Prompt/Message
	main.player.add_shards(2)
	main.beacon.take_damage(45)
	_press_interact()
	var passed: bool = main.beacon.current_health == 155 and main.player.shards == 2
	card.get_node("Menu/Play").pressed.emit()
	card.get_node("Intro/Begin").pressed.emit()
	passed = passed and prompt.text == "Need 3 shards to repair the beacon"
	_press_interact()
	passed = passed and main.beacon.current_health == 155 and main.player.shards == 2

	main.player.add_shards(1)
	main.player.global_position = main.beacon.global_position + Vector2(91.0, 0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	passed = passed and not prompt.is_visible_in_tree()
	_press_interact()
	passed = passed and main.beacon.current_health == 155 and main.player.shards == 3

	main.player.global_position = main.beacon.global_position + Vector2(90.0, 0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	passed = passed and prompt.text == "E  Repair beacon (3 shards)"
	_press_interact()
	passed = passed and main.beacon.current_health == 185 and main.player.shards == 0
	main.player.add_shards(6)
	_press_interact()
	passed = passed and main.beacon.current_health == 200 and main.player.shards == 3
	passed = passed and prompt.text == "Beacon at full health"
	_press_interact()
	passed = passed and main.beacon.current_health == 200 and main.player.shards == 3
	passed = passed and $Main/HUD/Status/Inset/Readouts/Beacon.text == "Beacon HP  200 / 200"
	passed = passed and $Main/HUD/Status/Inset/Readouts/Shards.text == "Shards  3"

	if passed:
		print("B6 beacon repair checks passed")
	else:
		push_error("B6 repair cost, range, healing cap, or HUD check failed")
	get_tree().quit(0 if passed else 1)


func _press_interact() -> void:
	var press := InputEventAction.new()
	press.action = "interact"
	press.pressed = true
	get_viewport().push_input(press)


func _verify_defeat() -> void:
	var main = $Main
	var card := $Main/Overlays/MainMenu/Backdrop/Center/Card
	var content := $Main/Overlays/Defeat/Shade/Center/Card/Content
	var labels := $Main/HUD/Status/Inset/Readouts
	card.get_node("Menu/Play").pressed.emit()
	card.get_node("Intro/Begin").pressed.emit()
	await get_tree().physics_frame
	await get_tree().physics_frame
	var passed: bool = main.waves._alive.size() == 1
	main.player.add_shards(4)
	main.beacon.take_damage(25)
	main.player.take_damage(100)
	passed = passed and main.defeat.visible and content.get_node("Reason").text == "The Lightkeeper has fallen."
	passed = passed and not main.waves.is_physics_processing() and main.waves._actors == null
	passed = passed and main.world.process_mode == Node.PROCESS_MODE_DISABLED
	_press_interact()
	passed = passed and main.beacon.current_health == 175 and main.player.shards == 4
	content.get_node("Restart").pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	passed = passed and main.world.visible and not main.defeat.visible and not main.menu.visible
	passed = passed and main.player.current_health == 100 and main.beacon.current_health == 200 and main.player.shards == 0
	passed = passed and labels.get_node("Wave").text == "Wave  1 / 10" and labels.get_node("Shards").text == "Shards  0"
	passed = passed and main.waves.is_physics_processing()

	main.beacon.take_damage(200)
	passed = passed and main.defeat.visible and content.get_node("Reason").text == "The beacon has gone dark."
	passed = passed and not main.waves.is_physics_processing() and not main.player._controls_enabled
	content.get_node("Menu").pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	passed = passed and main.menu.visible and not main.world.visible and not main.hud.visible and not main.defeat.visible
	card.get_node("Menu/Play").pressed.emit()
	card.get_node("Intro/Begin").pressed.emit()
	passed = passed and main.world.visible and main.hud.visible and main.beacon.current_health == 200
	if passed:
		print("B7 defeat and reset checks passed")
	else:
		push_error("B7 defeat, restart, or menu check failed")
	get_tree().quit(0 if passed else 1)
