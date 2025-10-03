extends Node2D
@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var hit_label_1 = $Hit_Label1
@onready var hit_label_2 = $Hit_Label2
@onready var hit_label_3 = $Hit_Label3
@onready var miss_label_1 = $Miss_Label1
@onready var miss_label_2 = $Miss_Label2
var is_hit:bool

func _ready() -> void:
	hit_label_1.visible = false
	hit_label_2.visible = false
	hit_label_3.visible = false
	miss_label_1.visible = false
	miss_label_2.visible = false
	anim.play("drop")

func check_hit() -> void:
	if is_hit:
		hit_label_1.visible = true
		hit_label_2.visible = true
		hit_label_3.visible = true
	else :
		miss_label_1.visible = true
		miss_label_2.visible = true
	await get_tree().create_timer(2).timeout
	queue_free()
