extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died
signal shards_changed(count: int)
signal pulse_cooldown_changed(remaining: float, total: float)

const LIGHT_PROJECTILE := preload("res://scenes/projectiles/light_projectile.tscn")
const ATTACK_MASK := (1 << 0) | (1 << 2)
const MELEE_REACH := 65.0
const MELEE_COOLDOWN := 0.35
const RANGED_COOLDOWN := 0.55

@export var move_speed: float = 230.0
@export_range(1, 1000) var max_health: int = 100

@onready var current_health: int = max_health

var shards: int = 0
var pulse_cooldown_remaining: float = 0.0
var pulse_cooldown_total: float = 0.0
var _controls_enabled: bool = true
var _melee_remaining: float = 0.0
var _ranged_remaining: float = 0.0
var _melee_flash_remaining: float = 0.0

@onready var _melee_flash: Line2D = $MeleeFlash


func _physics_process(delta: float) -> void:
	_melee_remaining = maxf(0.0, _melee_remaining - delta)
	_ranged_remaining = maxf(0.0, _ranged_remaining - delta)
	_melee_flash_remaining = maxf(0.0, _melee_flash_remaining - delta)
	_melee_flash.visible = _melee_flash_remaining > 0.0
	if not _controls_enabled or current_health <= 0:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()
	var aim := global_position.direction_to(get_global_mouse_position())
	_try_attacks(aim, Input.is_action_just_pressed("melee_attack"), Input.is_action_just_pressed("ranged_attack"))


func _try_attacks(aim: Vector2, melee_pressed: bool, ranged_pressed: bool) -> void:
	if aim.is_zero_approx():
		return
	if melee_pressed and _melee_remaining <= 0.0:
		_melee_remaining = MELEE_COOLDOWN
		_melee_attack(aim)
	if ranged_pressed and _ranged_remaining <= 0.0:
		_ranged_remaining = RANGED_COOLDOWN
		var projectile := LIGHT_PROJECTILE.instantiate()
		get_parent().add_child(projectile)
		projectile.launch(global_position, aim, get_rid())


func _melee_attack(aim: Vector2) -> void:
	var end := global_position + aim * MELEE_REACH
	var query := PhysicsRayQueryParameters2D.create(global_position, end, ATTACK_MASK, [get_rid()])
	query.collide_with_areas = true
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		end = hit.position
		if hit.collider.get_collision_layer_value(3) and hit.collider.has_method("take_damage"):
			hit.collider.take_damage(20)
	_melee_flash.points = PackedVector2Array([Vector2.ZERO, to_local(end)])
	_melee_flash_remaining = 0.09
	_melee_flash.show()


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
