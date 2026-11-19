extends CanvasLayer

signal replay_requested
signal menu_requested

@onready var _replay: Button = $Shade/Center/Card/Content/Replay


func _ready() -> void:
	_replay.pressed.connect(replay_requested.emit)
	$Shade/Center/Card/Content/Menu.pressed.connect(menu_requested.emit)


func show_victory() -> void:
	show()
	_replay.grab_focus()
