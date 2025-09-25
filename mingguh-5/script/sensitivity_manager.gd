extends Control

signal sensitivity_changed(new_value)

@export_category("Sensitivity Settings")
@export var min_sensitivity: float = 100.0
@export var max_sensitivity: float = 600.0
@export var sensitivity_step: float = 50.0
@export var default_sensitivity: float = 300.0

@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar

var current_sensitivity: float = 300.0
var is_visible: bool = false

func _ready():
	setup_ui()

func setup_ui():
	
	if progress_bar:
		progress_bar.min_value = 0
		progress_bar.max_value = 100
		progress_bar.value = get_sensitivity_normalized() * 100
	

func increase_sensitivity():
	current_sensitivity = min(current_sensitivity + sensitivity_step, max_sensitivity)
	on_sensitivity_changed()

func decrease_sensitivity():
	current_sensitivity = max(current_sensitivity - sensitivity_step, min_sensitivity)
	on_sensitivity_changed()

func set_sensitivity(value: float):
	current_sensitivity = clamp(value, min_sensitivity, max_sensitivity)
	on_sensitivity_changed()

func get_sensitivity() -> float:
	return current_sensitivity

func get_sensitivity_normalized() -> float:
	return (current_sensitivity - min_sensitivity) / (max_sensitivity - min_sensitivity)

func on_sensitivity_changed():
	update_ui()
	
	# Emit signal
	sensitivity_changed.emit(current_sensitivity)

func update_ui():
	if progress_bar:
		progress_bar.value = get_sensitivity_normalized() * 100
