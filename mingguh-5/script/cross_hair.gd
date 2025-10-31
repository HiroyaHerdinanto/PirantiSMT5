extends Node2D

@onready var hit_zone: Area2D = $Area2D
@export var harpoon:PackedScene

var use_mouse_movement: bool = true
var ftime:bool 
var velocity: Vector2 = Vector2.ZERO
var is_moving_with_wasd: bool = false
var is_moving_with_stick: bool = false
var last_mouse_position: Vector2

# Property untuk mendapatkan kecepatan dari SensitivityManager
var move_speed: float:
	get:
		return SensitivityManager.get_sensitivity()
var serial = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	last_mouse_position = get_global_mouse_position()
	Input.warp_mouse(Vector2(500,500))
	global_position = Vector2(500,500)
	
	# Connect ke sensitivity manager
	SensitivityManager.sensitivity_changed.connect(_on_sensitivity_changed)
	serial = GdSerial.new()
	serial.set_port("COM3") # ubah sesuai port Arduino lo
	serial.set_baud_rate(9600)
	
	if serial.open():
		print("✅ Terhubung ke Arduino!")
		serial.writeline("1") # kirim sinyal awal ke Arduino
	else:
		print("❌ Gagal membuka port serial!")

func _on_sensitivity_changed(new_value: float):
	print("Sensitivity changed to: ", new_value)

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	global_position += velocity * delta

func handle_movement(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if use_mouse_movement:
		if ftime:
			var viewport = get_viewport()
			var viewport_pos = viewport.get_screen_transform() * global_position
			Input.warp_mouse(viewport_pos)
			ftime = false
		global_position = get_global_mouse_position()
	
	elif is_moving_with_wasd:
		ftime = true
		var input_vector = Vector2.ZERO
		
		if Input.is_action_pressed("right"):
			input_vector.x += 1
		if Input.is_action_pressed("left"):
			input_vector.x -= 1
		if Input.is_action_pressed("down"):
			input_vector.y += 1
		if Input.is_action_pressed("up"):
			input_vector.y -= 1
		
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()
			velocity = input_vector * move_speed
			is_moving_with_wasd = true
			last_mouse_position = global_position
		else:
			is_moving_with_wasd = false
			last_mouse_position = global_position
		
	elif is_moving_with_stick:
		ftime = true
		var input_vector = Vector2.ZERO
		if Input.is_action_pressed("right"):
			input_vector.x += 1
		if Input.is_action_pressed("left"):
			input_vector.x -= 1
		if Input.is_action_pressed("down"):
			input_vector.y += 1
		if Input.is_action_pressed("up"):
			input_vector.y -= 1
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()
			velocity = input_vector * move_speed
			is_moving_with_stick = true
			last_mouse_position = global_position
		else:
			is_moving_with_stick = false
			last_mouse_position = global_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		is_moving_with_wasd = false
		use_mouse_movement = true
		is_moving_with_stick = false
	elif event is InputEventKey:
		is_moving_with_wasd = true
		use_mouse_movement = false
		is_moving_with_stick = false
	elif event is InputEventJoypadMotion:
		is_moving_with_wasd = false
		use_mouse_movement = false
		is_moving_with_stick = true
	
	if Input.is_action_just_pressed("increase_sensitivity"):
		SensitivityManager.increase_sensitivity()
	if Input.is_action_just_pressed("decrease_sensitivity"):
		SensitivityManager.decrease_sensitivity()
	
	if Input.is_action_just_pressed("Shoot"):
		shoot()

func shoot() -> void:
	var scene = harpoon.instantiate()
	var result = hit_zone.get_overlapping_areas()
	if !result or result.size() == 0:
		get_parent().missed_shot()
		scene.is_hit = false
	for hitted in result:
		if hitted.has_method("on_shot"):
			hitted.on_shot()
		scene.is_hit = true
	print("Tembakan kena: " + str(result.size()))
	scene.global_position = global_position
	get_tree().current_scene.add_child(scene)
	if !doned:
		ping_arduino()

var doned:bool
func ping_arduino():
	doned = true
	serial.writeline("1")
	await  get_tree().create_timer(0.5).timeout
	serial.writeline("0")
	doned = false
