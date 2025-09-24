extends Area2D
signal enemy_hit(points: int, extra_time: int)

var speed = 150.0
var direction = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	position += direction * speed * delta
	if global_position.distance_to(target_position) < 10.0:
			queue_free()

func on_shot():
	emit_signal("enemy_hit", -25, -10) 
	queue_free()
