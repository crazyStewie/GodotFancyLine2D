extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_1:
			get_tree().set_input_as_handled()
			$Lights.visible = not $Lights.visible
		elif event.scancode == KEY_2:
			get_tree().set_input_as_handled()
			$FollowLight.visible = not $FollowLight.visible
		elif event.scancode == KEY_3:
			get_tree().set_input_as_handled()
			$HUD/MarginContainer.visible = not $HUD/MarginContainer.visible
		elif event.scancode == KEY_4:
			get_tree().set_input_as_handled()
			$Lines.visible = not $Lines.visible
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
