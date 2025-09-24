extends Node2D

@onready var spawner_top = $Spawner_Top
@onready var spawner_bot = $Spawner_Bottom
@onready var spawner_left = $Spawner_Left
@onready var spawner_right = $Spawner_Right

# preload scene musuh
var enemy_scenes: Array[PackedScene] = [
	preload("res://Enemies/fish_easy.tscn"),
	preload("res://Enemies/fish_fast.tscn"),
	preload("res://Enemies/fish_golden.tscn"),
	preload("res://Enemies/fish_Fake1.tscn")
]

# bobot spawn (semakin besar makin sering muncul)
var enemy_weights: Array = [70, 25, 5, 50]

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
	print("spawm")
	if randf() < spawn_chance:
		var idx = pick_weighted_index(enemy_weights)
		var enemy = enemy_scenes[idx].instantiate()
		

		var spawners = [spawner_top, spawner_bot, spawner_left, spawner_right]
		var spawner_index = randi() % spawners.size()
		var selected_spawner = spawners[spawner_index]
		
		# Tentukan target berdasarkan spawner yang dipilih
		var target_spawner
		match spawner_index:
			0: # Top -> target Bottom
				target_spawner = spawner_bot
			1: # Bottom -> target Top
				target_spawner = spawner_top
			2: # Left -> target Right
				target_spawner = spawner_right
			3: # Right -> target Left
				target_spawner = spawner_left
		
		enemy.global_position = selected_spawner.global_position + select_random(selected_spawner)
		
		enemy.target_position = target_spawner.global_position + select_random(target_spawner)
		
		var direction = (target_spawner.global_position - selected_spawner.global_position).normalized()
		enemy.direction = direction
		
		if enemy.has_signal("enemy_hit"):
			enemy.connect("enemy_hit", Callable(get_parent(), "add_score"))
		
		add_child(enemy)

func select_random(col:Area2D) -> Vector2:
	var collision = col.get_node("CollisionShape2D")
	var collision_shape = collision.shape
	var extents = collision_shape.size / 2
	var random_x = randf_range(-extents.x, extents.x)
	var random_y = randf_range(-extents.y, extents.y)
	return Vector2(random_x,random_y)
