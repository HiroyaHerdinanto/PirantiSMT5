extends Node2D

# Signal untuk feedback interaksi
signal button_hovered(button_name)
signal button_pressed(button_name)

# Referensi ke area deteksi
@onready var interaction_area: Area2D = $Area2D
@onready var cursor_sprite: Sprite2D = $Sprite2D

var move_speed: float:
	get:
		return SensitivityManager.get_sensitivity()
var velocity: Vector2 = Vector2.ZERO

# State variables
var current_hovered_button: Control = null
var is_moving: bool = false
var use_mouse_movement: bool = false
var is_moving_with_wasd: bool = false
var is_moving_with_stick: bool = false
var ftime: bool = false
var last_mouse_position: Vector2

# Controller deadzone
var deadzone: float = 0.2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	last_mouse_position = get_global_mouse_position()
	# Connect signal dari area interaksi
	interaction_area.area_entered.connect(_on_button_entered)
	interaction_area.area_exited.connect(_on_button_exited)
	SensitivityManager.sensitivity_changed.connect(_on_sensitivity_changed)

func _physics_process(delta):
	handle_movement(delta)
	global_position += velocity * delta
	
	# Update visual cursor
	update_cursor_visual()

func handle_movement(delta):
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
		
		# Gunakan analog stick untuk controller
		var stick_x = Input.get_axis("controller_left", "controller_right")
		var stick_y = Input.get_axis("controller_up", "controller_down")
		
		# Terapkan deadzone
		if abs(stick_x) > 0.2:
			input_vector.x = stick_x
		if abs(stick_y) > 0.2:
			input_vector.y = stick_y
		
		# Fallback ke button presses jika analog stick tidak aktif
		if input_vector.length() == 0:
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

func _on_sensitivity_changed(new_value: float):
	print("Sensitivity changed to: ", new_value)

func _input(event):
	# Deteksi perubahan input method
	if event is InputEventMouseMotion:
		is_moving_with_wasd = false
		use_mouse_movement = true
		is_moving_with_stick = false
	elif event is InputEventKey:
		is_moving_with_wasd = true
		use_mouse_movement = false
		is_moving_with_stick = false
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		is_moving_with_wasd = false
		use_mouse_movement = false
		is_moving_with_stick = true
	
	if Input.is_action_just_pressed("increase_sensitivity"):
		SensitivityManager.increase_sensitivity()
	if Input.is_action_just_pressed("decrease_sensitivity"):
		SensitivityManager.decrease_sensitivity()
	
	if event.is_action_pressed("Shoot") or event.is_action_pressed("controller_confirm"):
		print("mencoba input")
		press_current_button()

func _on_button_entered(area: Area2D):
	print("ini area " + area.name)
	var button = area.get_parent()
	current_hovered_button = button
	button.grab_focus()
	button.modulate = Color(1.2, 1.2, 1.2)  # Highlight

func _on_button_exited(area: Area2D):
	var button = area.get_parent()
	button.release_focus()
	button.modulate = Color.WHITE
	current_hovered_button = null

func press_current_button():
	
	if !current_hovered_button or current_hovered_button.disabled:
		return
		
	
	var tween = create_tween()
	tween.tween_property(current_hovered_button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(current_hovered_button, "scale", Vector2(1.0, 1.0), 0.1)
	current_hovered_button.emit_signal("pressed")


func update_cursor_visual():
	# Update visual cursor berdasarkan state
	if current_hovered_button:
		cursor_sprite.modulate = Color(1, 0.8, 0)  # Orange ketika hover
	else:
		cursor_sprite.modulate = Color.WHITE

# Public function untuk mengontrol dari luar
func set_interaction_enabled(enabled: bool):
	set_process_input(enabled)
	set_physics_process(enabled)
	visible = enabled
	
	if enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func move_to_button(button: Control):
	if button:
		global_position = button.global_position
