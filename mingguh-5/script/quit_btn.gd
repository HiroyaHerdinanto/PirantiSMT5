extends Button
@export var interaction_area: Area2D

func _ready():
	if not interaction_area:
		create_interaction_area()
	

func create_interaction_area():
	interaction_area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size  
	
	collision.shape = shape
	interaction_area.add_child(collision)
	add_child(interaction_area)
	
	interaction_area.position = size / 2


func _on_pressed() -> void:
	get_tree().quit(1)
