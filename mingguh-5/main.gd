extends Node2D

var score: int = 0
var time_left: int = 30   # durasi awal 30 detik

@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var game_timer: Timer = $GameTimer
@onready var game_over_label: Label = $CanvasLayer/GameOver

# --- Crosshair ---
@onready var crosshair_tex: Texture2D = preload("res://crosshair-removebg-preview.png")
var crosshair: Sprite2D

func _ready() -> void:
	update_ui()
	game_over_label.hide()

	# Timer countdown
	game_timer.wait_time = 1.0
	game_timer.start()

	# Buat crosshair custom
	crosshair = Sprite2D.new()
	crosshair.texture = crosshair_tex
	crosshair.centered = true
	add_child(crosshair)

	# Sembunyikan cursor default
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta: float) -> void:
	# Crosshair ikutin mouse
	if crosshair:
		crosshair.global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			shoot()

func shoot() -> void:
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state

	var query := PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_point(query, 1)

	if result.size() > 0:
		var collider = result[0].collider
		if collider.has_method("on_shot"):
			collider.on_shot()
	

func add_score(points: int, extra_time: int = 0) -> void:
	score += points
	time_left += extra_time
	update_ui()

func update_ui() -> void:
	score_label.text = "Score: %d" % score
	time_label.text = "Time: %d" % time_left

func game_over() -> void:
	game_timer.stop()
	print("Game Over! Final Score:", score)
	game_over_label.show()


func _on_game_timer_timeout() -> void:
	time_left -= 1
	if time_left <= 0:
		time_left = 0
		game_over()
	update_ui()# Replace with function body.
