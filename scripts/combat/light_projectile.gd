extends Node2D

const SPEED := 560.0
const LIFETIME := 1.5
const DAMAGE := 12
const HIT_MASK := (1 << 0) | (1 << 2)

var _direction: Vector2
var _source: RID
var _time_left: float = LIFETIME


func launch(origin: Vector2, direction: Vector2, source: RID) -> void:
	global_position = origin
	_direction = direction
	_source = source
	global_rotation = direction.angle()


func _physics_process(delta: float) -> void:
	var end := global_position + _direction * SPEED * minf(delta, _time_left)
	var query := PhysicsRayQueryParameters2D.create(global_position, end, HIT_MASK, [_source])
	query.collide_with_areas = true
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		if hit.collider.get_collision_layer_value(3) and hit.collider.has_method("take_damage"):
			hit.collider.take_damage(DAMAGE)
		queue_free()
		return
	global_position = end
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
