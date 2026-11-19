extends CanvasLayer

signal start_requested
signal quit_requested

@onready var _menu: VBoxContainer = $Backdrop/Center/Card/Menu
@onready var _intro: VBoxContainer = $Backdrop/Center/Card/Intro


func _ready() -> void:
	$Backdrop/Center/Card/Menu/Play.pressed.connect(_show_intro)
	$Backdrop/Center/Card/Menu/Quit.pressed.connect(quit_requested.emit)
	$Backdrop/Center/Card/Intro/Begin.pressed.connect(_begin)
	$Backdrop/Center/Card/Intro/Back.pressed.connect(show_menu)
	show_menu()


func show_menu() -> void:
	show()
	_intro.hide()
	_menu.show()
	$Backdrop/Center/Card/Menu/Play.grab_focus()


func _show_intro() -> void:
	_menu.hide()
	_intro.show()
	$Backdrop/Center/Card/Intro/Begin.grab_focus()


func _begin() -> void:
	hide()
	start_requested.emit()
