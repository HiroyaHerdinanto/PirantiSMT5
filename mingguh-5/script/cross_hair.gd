extends Node2D

@onready var hit_zone: Area2D = $Area2D

# Pengaturan kecepatan
@export var move_speed: float = 300.0
@export var use_mouse_movement: bool = true
@export var use_wasd_movement: bool = true

var velocity: Vector2 = Vector2.ZERO
var is_moving_with_wasd: bool = false
var last_mouse_position: Vector2

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	last_mouse_position = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	
	# Update posisi berdasarkan velocity
	global_position += velocity * delta
	
	# Simpan posisi mouse terakhir
	last_mouse_position = get_global_mouse_position()

func handle_movement(delta: float) -> void:
	velocity = Vector2.ZERO
	
	# Gerakan dengan WASD (jika diaktifkan)
	if use_wasd_movement:
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
		else:
			# Jika tidak ada input WASD, kembali ke mode mouse
			is_moving_with_wasd = false
	
	# Gerakan dengan mouse (jika diaktifkan dan tidak sedang menggunakan WASD)
	if use_mouse_movement and not is_moving_with_wasd:
		global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	# Deteksi pergerakan mouse
	if event is InputEventMouseMotion:
		is_moving_with_wasd = false
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			shoot()

func shoot() -> void:
	# Pastikan kita menggunakan posisi mouse yang benar
	# Jika sedang bergerak dengan WASD, gunakan posisi mouse terakhir yang disimpan
	# Jika tidak, gunakan posisi mouse saat ini
	var shoot_position
	if is_moving_with_wasd:
		shoot_position = last_mouse_position
	else:
		shoot_position = get_global_mouse_position()
	
	# Pindah ke posisi shoot yang ditentukan
	global_position = shoot_position
	
	# Lakukan pengecekan hit zone
	var result = hit_zone.get_overlapping_areas()
	if !result or result.size() == 0:
		return
	for hitted in result:
		if hitted.has_method("on_shot"):
			hitted.on_shot()
