extends Node2D

@onready var hit_zone: Area2D = $Area2D
@export var move_speed: float = 300.0
@export var use_mouse_movement: bool = true
@export var use_wasd_movement: bool = true

var ftime:bool 
var velocity: Vector2 = Vector2.ZERO
var is_moving_with_wasd: bool = false
var last_mouse_position: Vector2

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	last_mouse_position = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	
	global_position += velocity * delta
	#print("global posisi sekarang = " + str(global_position))
	#print("lmouse posisi sekarang = " + str(last_mouse_position))


func handle_movement(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if use_mouse_movement:
		if ftime:
			var viewport = get_viewport()
			var camera:Camera2D = viewport.get_camera_2d()
			
			if camera:
				var viewport_pos = camera.get_global_transform() * global_position
				Input.warp_mouse(viewport_pos)
			else:
				var viewport_pos = viewport.get_screen_transform() * global_position
				Input.warp_mouse(viewport_pos)
			ftime = false
		global_position = get_global_mouse_position()
	
	elif use_wasd_movement:
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
		
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		is_moving_with_wasd = false
		use_mouse_movement = true
	elif event is InputEventKey:
		is_moving_with_wasd = true
		use_mouse_movement = false
	
	if Input.is_action_just_pressed("Shoot"):
		shoot()

func shoot() -> void:
	print("dor")
	var result = hit_zone.get_overlapping_areas()
	if !result or result.size() == 0:
		return
	for hitted in result:
		if hitted.has_method("on_shot"):
			hitted.on_shot()
	print("dor kena " + str(result.size()))
