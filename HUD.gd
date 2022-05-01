extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	print(get_parent().get_viewport().get_final_transform().x)
	transform.x.x = 1.0/get_parent().get_viewport().get_final_transform().x.x
	transform.y.y = 1.0/get_parent().get_viewport().get_final_transform().y.y
#	pass
