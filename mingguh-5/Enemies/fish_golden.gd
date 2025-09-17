extends Area2D
signal enemy_hit(points: int, extra_time: int)

var speed = 200.0
var direction = Vector2(0, -1)

func _process(delta: float) -> void:
	position += direction * speed * delta
	if global_position.y < -150 or global_position.y > 700 or global_position.x < -200 or global_position.x > 1000:
		queue_free()

func on_shot():
	emit_signal("enemy_hit", 100, 10)  # +100 poin, +10 detik
	queue_free()
