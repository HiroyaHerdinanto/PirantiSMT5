extends Node2D

@onready var hit_zone: Area2D = $Area2D
@export var harpoon:PackedScene
@onready var serial := GdSerial.new()
@onready var label: Label = $"../CanvasLayer/Label"
@onready var label_2: Label = $"../CanvasLayer/Label2"
var use_mouse_movement: bool = true
var ftime:bool 
var velocity: Vector2 = Vector2.ZERO
var is_moving_with_wasd: bool = false
var is_moving_with_stick: bool = false
var use_arduino_movement: bool = false
var last_mouse_position: Vector2
var tilt_deadzone := 5.0  
var tilt_sensitivity := 0.1
var move_X := 0.0
var move_y := 0.0
# Property untuk mendapatkan kecepatan dari SensitivityManager
var move_speed: float:
	get:
		return SensitivityManager.get_sensitivity()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	last_mouse_position = get_global_mouse_position()
	Input.warp_mouse(Vector2(500,500))
	global_position = Vector2(500,500)
	if SerialManager.serial.is_open():
		serial = SerialManager.serial
		print("berhasil menimpa serial")

func _on_sensitivity_changed(new_value: float):
	print("Sensitivity changed to: ", new_value)

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	global_position += velocity * delta

func _parse_data(data: String):
	var parts = data.split(",")
	if parts.size() != 2:
		return

	var roll  = parts[0].to_float()
	var pitch = parts[1].to_float()

	move_X = roll 
	move_y = pitch  
	var mv = Vector2(move_X,move_y)
	print("parse terbaru:", mv)


func handle_movement(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if use_arduino_movement:  # atau bikin flag khusus misal use_arduino = true
		var ax = move_X
		var ay = -move_y

		# Terapin deadzone biar ga jitter
		#if ax > 5:
			#ax = 1
		#elif ax < 5:
			#ax = -1
		#else:
			#ax = 0
		#if ay > 5:
			#ay = 1
		#elif ay < 5:
			#ay = -1
		#else:
			#ay = 0

		# Normalisasi dan scaling
		var input_vector = Vector2(ax, ay) * tilt_sensitivity
		label.text = str(input_vector)
		if input_vector.length() > 0.01:
			velocity = input_vector * move_speed
			last_mouse_position = global_position
		else:
			velocity = Vector2.ZERO
		return
	
	elif use_mouse_movement:
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
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F:   # Tekan F untuk ON/OFF Arduino
			use_arduino_movement = !use_arduino_movement
			is_moving_with_wasd = false
			use_mouse_movement = false
			is_moving_with_stick = false
			print("Arduino movement:", use_arduino_movement)
			return  # Penting: biar event lain tidak override
	elif event is InputEventMouseMotion:
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
	

var serial_buffer := ""

func _on_SerialTimer_timeout():
	if not serial.is_open():
		return
	var available := serial.bytes_available()
	if available <= 0:
		print("lah")
		return

	var raw: PackedByteArray = serial.read(available)
	var chunk := raw.get_string_from_utf8()

	
	serial_buffer += chunk

	var lines = serial_buffer.split("\n")
	var latest_line = lines[lines.size() - 2]  # ambil line terakhir lengkap
	serial_buffer = ""  # reset buffer

	# Parse SATU data paling baru
	_parse_data(latest_line)
	print("data terbaru:", latest_line)
	#label_2.text = latest_line

#if use_arduino_movement:  # atau bikin flag khusus misal use_arduino = true
		#var ax = move_X
		#var ay = move_y
#
		## Terapin deadzone biar ga jitter
		#if abs(ax) < tilt_deadzone:
			#ax = 0
		#if abs(ay) < tilt_deadzone:
			#ay = 0
#
		## Normalisasi dan scaling
		#var input_vector = Vector2(ax, ay) * tilt_sensitivity
		#print(input_vector)
		#if input_vector.length() > 0.01:
			#velocity = input_vector * move_speed
			#last_mouse_position = global_position
		#else:
			#velocity = Vector2.ZERO
#
		#return
#func _parse_data(data: String):
	#var parts = data.split(",")
	#if parts.size() != 2:
		#return
#
	#var roll  = parts[0].to_float()
	#var pitch = parts[1].to_float()
#
	#move_X = pitch / 30.0
	#move_y = roll  / 30.0
#
	#print("OK:", roll, pitch)
