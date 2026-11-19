extends Area2D

var _collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.has_method("add_shards"):
		return
	_collected = true
	body.add_shards(1)
	queue_free()
