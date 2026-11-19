extends CanvasLayer

signal restart_requested
signal menu_requested

@onready var _content := $Shade/Center/Card/Content


func _ready() -> void:
	$Shade/Center/Card/Content/Restart.pressed.connect(restart_requested.emit)
	$Shade/Center/Card/Content/Menu.pressed.connect(menu_requested.emit)


func show_defeat(reason: String) -> void:
	_content.get_node("Reason").text = reason
	show()
	_content.get_node("Restart").grab_focus()
