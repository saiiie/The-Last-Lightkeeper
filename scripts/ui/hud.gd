extends CanvasLayer

@onready var _readouts := $Status/Inset/Readouts
@onready var _prompt: Label = $Prompt/Message


func set_player_health(current: int, maximum: int) -> void:
	_readouts.get_node("Player").text = "Player HP  %d / %d" % [current, maximum]


func set_beacon_health(current: int, maximum: int) -> void:
	_readouts.get_node("Beacon").text = "Beacon HP  %d / %d" % [current, maximum]


func set_wave(current: int, total: int) -> void:
	_readouts.get_node("Wave").text = "Wave  %d / %d" % [current, total]


func set_shards(count: int) -> void:
	_readouts.get_node("Shards").text = "Shards  %d" % count


func set_pulse_cooldown(remaining: float, total: float) -> void:
	_readouts.get_node("Pulse").text = (
		"Pulse  Ready" if remaining <= 0.0 else "Pulse  %.1f / %.1f s" % [remaining, total]
	)


func set_prompt(message: String) -> void:
	_prompt.text = message
	$Prompt.visible = not message.is_empty()
