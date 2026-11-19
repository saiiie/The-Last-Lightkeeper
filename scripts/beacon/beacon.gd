@tool
extends Node2D

signal health_changed(current: int, maximum: int)
signal destroyed
signal witness_rite_completed

const WHITE := Color("#fff9eb")
const AMBER := Color("#ffb34d")
const EXTINGUISHED := Color("#45545a")
const RITE_DURATION := 1.2
const max_health: int = 200

var current_health: int = max_health
var rite_completed: bool = false
var light_color: Color = WHITE:
	set(value):
		light_color = value
		queue_redraw()
var _rite_tween: Tween


func take_damage(amount: int) -> void:
	if amount <= 0 or current_health == 0:
		return
	current_health = maxi(0, current_health - amount)
	var extinguished := current_health == 0
	if extinguished:
		if _rite_tween != null:
			_rite_tween.kill()
			_rite_tween = null
		light_color = EXTINGUISHED
	health_changed.emit(current_health, max_health)
	if extinguished:
		destroyed.emit()


func repair(amount: int) -> void:
	if amount <= 0 or current_health == 0 or current_health == max_health:
		return
	current_health += mini(amount, max_health - current_health)
	health_changed.emit(current_health, max_health)


func perform_witness_rite() -> void:
	if rite_completed or _rite_tween != null or current_health == 0:
		return
	_rite_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_rite_tween.tween_property(self, "light_color", AMBER, RITE_DURATION)
	_rite_tween.tween_callback(_finish_witness_rite)


func _finish_witness_rite() -> void:
	_rite_tween = null
	rite_completed = true
	witness_rite_completed.emit()


func _draw() -> void:
	if current_health > 0:
		draw_circle(Vector2.ZERO, 50.0, Color(light_color, 0.06))
		draw_circle(Vector2.ZERO, 38.0, Color(light_color, 0.1))
		draw_circle(Vector2.ZERO, 28.0, Color(light_color, 0.17))
	draw_circle(Vector2.ZERO, 22.0, Color("#26313a"))
	draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 48, Color("#82918c"), 2.0, true)
	draw_colored_polygon(
		PackedVector2Array([Vector2(0, -19), Vector2(11, -3), Vector2(7, 11), Vector2(-7, 11), Vector2(-11, -3)]),
		light_color
	)
