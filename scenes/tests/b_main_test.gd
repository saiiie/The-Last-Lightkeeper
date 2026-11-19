extends Node


func _ready() -> void:
	if "--verify-b5" in OS.get_cmdline_user_args():
		_verify.call_deferred()


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
