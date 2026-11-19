extends Node2D

const WORLD_MASK := 1
const BEACON_HIT_RADIUS := 24.0

@export var speed: float = 560.0
@export var lifetime: float = 1.5
@export var damage: int = 12
@export_flags_2d_physics var target_mask: int = 1 << 2

var _direction: Vector2
var _source: RID
var _beacon_target: Node2D
var _time_left: float


func launch(origin: Vector2, direction: Vector2, source: RID, beacon_target: Node2D = null) -> void:
	global_position = origin
	_direction = direction
	_source = source
	_beacon_target = beacon_target
	_time_left = lifetime
	global_rotation = direction.angle()


func _physics_process(delta: float) -> void:
	var end := global_position + _direction * speed * minf(delta, _time_left)
	var query := PhysicsRayQueryParameters2D.create(global_position, end, WORLD_MASK | target_mask, [_source])
	query.collide_with_areas = true
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	var unobstructed_end: Vector2 = end if hit.is_empty() else hit.position
	if _hits_beacon(unobstructed_end, hit.get("collider")):
		_beacon_target.take_damage(damage)
		queue_free()
		return
	if not hit.is_empty():
		if hit.collider.collision_layer & target_mask and hit.collider.has_method("take_damage"):
			hit.collider.take_damage(damage)
		queue_free()
		return
	global_position = end
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()


func _hits_beacon(end: Vector2, collider: Node) -> bool:
	if not is_instance_valid(_beacon_target) or _beacon_target.is_queued_for_deletion():
		return false
	if collider != null and (collider == _beacon_target or _beacon_target.is_ancestor_of(collider)):
		return true
	# The beacon API also supports a plain Node2D without a physics shape.
	var closest := Geometry2D.get_closest_point_to_segment(_beacon_target.global_position, global_position, end)
	return closest.distance_squared_to(_beacon_target.global_position) <= BEACON_HIT_RADIUS ** 2
