extends CharacterBody2D

signal died(world_position: Vector2)

@export var max_health: int = 35

@onready var current_health: int = max_health

var _player: Node2D
var _beacon: Node2D
var _stun_remaining: float = 0.0
var _knockback_velocity := Vector2.ZERO


func set_targets(player: Node2D, beacon: Node2D) -> void:
	_player = player
	_beacon = beacon


func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = maxi(0, current_health - amount)
	if current_health == 0:
		set_physics_process(false)
		var death_position := global_position
		queue_free()
		died.emit(death_position)


func apply_lantern_pulse(stun_seconds: float, knockback: Vector2) -> void:
	if current_health <= 0 or stun_seconds <= 0.0:
		return
	_stun_remaining = maxf(_stun_remaining, stun_seconds)
	_knockback_velocity = knockback


func _physics_process(delta: float) -> void:
	if _stun_remaining > 0.0:
		velocity = _knockback_velocity
		move_and_slide()
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 1200.0 * delta)
		_stun_remaining = maxf(0.0, _stun_remaining - delta)
		return
	_update_behavior(delta)


func _update_behavior(_delta: float) -> void:
	pass
