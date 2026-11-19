extends Node2D

@onready var hud = $HUD


func _ready() -> void:
	hud.set_player_health(76, 100)
	hud.set_beacon_health(145, 200)
	hud.set_wave(4, 10)
	hud.set_shards(5)
	hud.set_pulse_cooldown(2.4, 6.0)
	hud.set_prompt("E  Repair beacon (3 shards)")
	if "--verify-b3" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _process(delta: float) -> void:
	$Camera2D.position.x += 85.0 * delta
	if $Camera2D.position.x > 400.0:
		$Camera2D.position.x = -400.0


func _verify() -> void:
	await get_tree().process_frame
	var readouts: Control = hud.get_node("Status/Inset/Readouts")
	var passed: bool = readouts.get_node("Player").text == "Player HP  76 / 100"
	passed = passed and readouts.get_node("Beacon").text == "Beacon HP  145 / 200"
	passed = passed and readouts.get_node("Wave").text == "Wave  4 / 10"
	passed = passed and readouts.get_node("Shards").text == "Shards  5"
	passed = passed and readouts.get_node("Pulse").text == "Pulse  2.4 / 6.0 s"
	var charge: ProgressBar = readouts.get_node("Pulse/Charge")
	passed = passed and is_equal_approx(charge.value, 0.6)
	var prompt: Label = hud.get_node("Prompt/Message")
	passed = passed and prompt.is_visible_in_tree() and prompt.text == "E  Repair beacon (3 shards)"
	var hud_transform: Transform2D = readouts.get_global_transform_with_canvas()
	var world_transform := get_canvas_transform()
	$Camera2D.position.x += 250.0
	$Camera2D.force_update_scroll()
	passed = passed and get_canvas_transform() != world_transform
	passed = passed and readouts.get_global_transform_with_canvas() == hud_transform
	hud.set_prompt("")
	hud.set_pulse_cooldown(0.0, 6.0)
	passed = passed and not prompt.is_visible_in_tree() and readouts.get_node("Pulse").text == "Pulse  Ready"
	passed = passed and charge.value == 1.0
	if passed:
		print("B3 HUD checks passed")
	else:
		push_error("B3 HUD values or camera independence failed")
	get_tree().quit(0 if passed else 1)
