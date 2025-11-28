extends Node2D

var score: int = 0
var time_left: int = 1000
@export var magic_hand:PackedScene
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var game_timer: Timer = $GameTimer
@onready var game_over_label: Label = $CanvasLayer/GameOver
@onready var r_but:Button = $Retry_button
@onready var spawner = $EnemySpawner

func _ready() -> void:
	update_ui()
	game_over_label.hide()
	r_but.hide()
	if get_tree().paused == true:
		get_tree().paused = false
	game_timer.wait_time = 1.0
	game_timer.start()

func add_score(points: int, extra_time: int = 0) -> void:
	score += points
	time_left += extra_time
	update_ui()

func missed_shot() -> void:
	time_left -= 1
	update_ui()

func update_ui() -> void:
	score_label.text = "Score: %d" % score
	time_label.text = "Time: %d" % time_left

func game_over() -> void:
	r_but.get_child(0).monitorable = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_timer.stop()
	print("Game Over! Final Score:", score)
	game_over_label.visible = true
	var cursor = magic_hand.instantiate()
	get_tree().current_scene.add_child(cursor)
	$Cross_Hair.queue_free()
	$Timer.stop()
	for kid in spawner.get_children():
		kid.set_process(false)
	await get_tree().create_timer(5).timeout
	r_but.show()
	r_but.get_child(0).monitorable = true


func _on_game_timer_timeout() -> void:
	time_left -= 1
	if time_left <= 0:
		time_left = 0
		game_over()
	update_ui()# Replace with function body.
