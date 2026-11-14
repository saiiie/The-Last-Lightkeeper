extends TileMapLayer
## Deterministic visual cells only; no adjacency rules or gameplay.
@export var map_size: Vector2i = Vector2i(48, 32)
@export var source_ids: PackedInt32Array = PackedInt32Array()

func _ready() -> void:
	assert(source_ids.size() == map_size.x * map_size.y)
	for y in range(map_size.y):
		for x in range(map_size.x):
			set_cell(Vector2i(x, y), source_ids[y * map_size.x + x], Vector2i.ZERO, 0)
