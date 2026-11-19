@tool
extends Node2D

const BOUNDS := Rect2(-900, -550, 1800, 1100)
const WALL_THICKNESS := 24.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var half := BOUNDS.size * 0.5
	var outer := half + Vector2.ONE * WALL_THICKNESS * 0.5
	var horizontal := Vector2(BOUNDS.size.x + 2.0 * WALL_THICKNESS, WALL_THICKNESS)
	var vertical := Vector2(WALL_THICKNESS, BOUNDS.size.y)
	_add_wall(Vector2(0, -outer.y), horizontal)
	_add_wall(Vector2(0, outer.y), horizontal)
	_add_wall(Vector2(-outer.x, 0), vertical)
	_add_wall(Vector2(outer.x, 0), vertical)


func get_spawn_markers() -> Array[Marker2D]:
	var markers: Array[Marker2D] = []
	markers.assign($SpawnMarkers.get_children())
	return markers


func _add_wall(center: Vector2, size: Vector2) -> void:
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	var collision := CollisionShape2D.new()
	collision.position = center
	collision.shape = rectangle
	$Boundary.add_child(collision)


func _draw() -> void:
	draw_rect(BOUNDS.grow(WALL_THICKNESS), Color("#304846"))
	draw_rect(BOUNDS, Color("#223530"))
	for x in range(-800, 900, 100):
		draw_line(Vector2(x, -550), Vector2(x, 550), Color("#2b4138"))
	for y in range(-500, 550, 100):
		draw_line(Vector2(-900, y), Vector2(900, y), Color("#2b4138"))
	draw_rect(BOUNDS.grow(-4), Color("#b1c6ab"), false, 8.0)
	draw_circle(Vector2.ZERO, 35.0, Color("#2e443b"))
	draw_arc(Vector2.ZERO, 35.0, 0.0, TAU, 48, Color("#e0c789"), 3.0, true)
	for marker in get_spawn_markers():
		draw_arc(marker.position, 12.0, 0.0, TAU, 24, Color("#a98068"), 2.0, true)
