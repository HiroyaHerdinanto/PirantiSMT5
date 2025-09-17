extends Node2D

# preload scene musuh
var enemy_scenes: Array[PackedScene] = [
	preload("res://Enemies/fish_easy.tscn"),
	preload("res://Enemies/fish_fast.tscn"),
	preload("res://Enemies/fish_golden.tscn")
]

# bobot spawn (semakin besar makin sering muncul)
var enemy_weights: Array = [70, 25, 5]

# area spawn
var screen_width: float = 800
var margin: float = 100
var spawn_x_range: Vector2 = Vector2(-screen_width/2 + margin, screen_width/2 - margin)

# posisi spawn Y
var spawn_y_bottom: float = 600
var spawn_y_top: float = -100

var spawn_chance: float = 0.6   # 60% kemungkinan spawn tiap tick

@onready var timer: Timer = $"../Timer"

func _ready() -> void:
	randomize()
	timer.wait_time = 0.5
	timer.start()
	

func pick_weighted_index(weights: Array) -> int:
	var total: float = 0.0
	for w in weights:
		total += float(w)

	var r = randf() * total
	var cuml = 0.0
	for i in range(weights.size()):
		cuml += float(weights[i])
		if r <= cuml:
			return i
	
	return weights.size() - 1


func _on_timer_timeout() -> void:
	if randf() < spawn_chance:
		var idx = pick_weighted_index(enemy_weights)
		var enemy = enemy_scenes[idx].instantiate()

		# posisi random
		var rand_x = randf_range(spawn_x_range.x, spawn_x_range.y)
		var spawn_from_top = randf() < 0.5

		if spawn_from_top:
			enemy.global_position = Vector2(rand_x, spawn_y_top)
			enemy.direction = Vector2(randf_range(-0.3, 0.3), 1).normalized()
		else:
			enemy.global_position = Vector2(rand_x, spawn_y_bottom)
			enemy.direction = Vector2(randf_range(-0.3, 0.3), -1).normalized()

		# connect signal ke Main.gd
		enemy.connect("enemy_hit", Callable(get_parent(), "add_score"))

		add_child(enemy) # Replace with function body.
