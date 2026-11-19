extends CanvasLayer

@onready var _readouts := $Status/Inset/Readouts
@onready var _prompt: Label = $Prompt/Message
@onready var _pulse_charge: ProgressBar = $Status/Inset/Readouts/Pulse/Charge
@onready var _boss_health: ProgressBar = $Boss/Readout/Health
@onready var _boss_label: Label = $Boss/Readout/Name


func set_player_health(current: int, maximum: int) -> void:
	_readouts.get_node("Player").text = "Player HP  %d / %d" % [current, maximum]


func set_beacon_health(current: int, maximum: int) -> void:
	_readouts.get_node("Beacon").text = "Beacon HP  %d / %d" % [current, maximum]


func set_wave(current: int, total: int) -> void:
	_readouts.get_node("Wave").text = "Wave  %d / %d" % [current, total]


func set_shards(count: int) -> void:
	_readouts.get_node("Shards").text = "Shards  %d" % count


func set_pulse_cooldown(remaining: float, total: float) -> void:
	_pulse_charge.value = clampf(1.0 - remaining / total, 0.0, 1.0) if total > 0.0 else 1.0
	_readouts.get_node("Pulse").text = (
		"Pulse  Ready" if remaining <= 0.0 else "Pulse  %.1f / %.1f s" % [remaining, total]
	)


func set_prompt(message: String) -> void:
	_prompt.text = message
	$Prompt.visible = not message.is_empty()


func set_boss_health(current: int, maximum: int) -> void:
	_boss_health.max_value = maximum
	_boss_health.value = current
	_boss_label.text = "Hush Warden  %d / %d" % [current, maximum]
	$Boss.visible = current > 0


func hide_boss_health() -> void:
	$Boss.hide()
