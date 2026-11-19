extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died
signal shards_changed(count: int)
signal pulse_cooldown_changed(remaining: float, total: float)

@export var move_speed: float = 230.0
@export_range(1, 1000) var max_health: int = 100

@onready var current_health: int = max_health

var shards: int = 0
var pulse_cooldown_remaining: float = 0.0
var pulse_cooldown_total: float = 0.0
var _controls_enabled: bool = true


func _physics_process(_delta: float) -> void:
	if not _controls_enabled or current_health <= 0:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()


func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = maxi(0, current_health - amount)
	var lethal := current_health == 0
	if lethal:
		set_controls_enabled(false)
		$Visual.modulate = Color(0.45, 0.45, 0.45)
	health_changed.emit(current_health, max_health)
	if lethal:
		died.emit()


func add_shards(amount: int) -> void:
	if amount <= 0:
		return
	shards += amount
	shards_changed.emit(shards)


func spend_shards(amount: int) -> bool:
	if amount <= 0 or amount > shards:
		return false
	shards -= amount
	shards_changed.emit(shards)
	return true


func set_controls_enabled(enabled: bool) -> void:
	_controls_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO
