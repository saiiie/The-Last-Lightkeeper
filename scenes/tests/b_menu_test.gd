extends Node

@onready var menu = $MainMenu
@onready var card: PanelContainer = $MainMenu/Backdrop/Center/Card
var starts := 0
var quits := 0


func _ready() -> void:
	menu.start_requested.connect(func(): starts += 1)
	if "--verify-b4" in OS.get_cmdline_user_args():
		menu.quit_requested.connect(func(): quits += 1)
		_verify.call_deferred()
	else:
		menu.quit_requested.connect(func(): get_tree().quit())


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not menu.visible:
		menu.show_menu()


func _verify() -> void:
	var menu_panel: Control = card.get_node("Menu")
	var intro: Control = card.get_node("Intro")
	var play: Button = menu_panel.get_node("Play")
	var begin: Button = intro.get_node("Begin")
	var controls: Label = menu_panel.get_node("Controls")
	var opening: Label = intro.get_node("Opening")
	var passed := menu_panel.is_visible_in_tree() and play.has_focus() and controls.text.contains("WASD")
	play.pressed.emit()
	passed = passed and intro.is_visible_in_tree() and begin.has_focus() and opening.text.contains("Aren Vale") and starts == 0
	intro.get_node("Back").pressed.emit()
	passed = passed and menu_panel.is_visible_in_tree() and play.has_focus()
	play.pressed.emit()
	begin.pressed.emit()
	passed = passed and starts == 1 and not menu.visible
	menu.show_menu()
	menu_panel.get_node("Quit").pressed.emit()
	passed = passed and quits == 1
	if passed:
		print("B4 menu checks passed")
	else:
		push_error("B4 menu navigation, text, or button wiring failed")
	get_tree().quit(0 if passed else 1)
