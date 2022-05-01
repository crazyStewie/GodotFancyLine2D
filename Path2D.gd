tool
extends Path2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var closed_path : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Path2D_draw():
	var points = curve.get_baked_points()
	if closed_path:
		var last = curve.get_point_count() - 1
		if last > 2:
			curve.set_point_in(last, -curve.get_point_out(0))
			curve.set_point_position(last, curve.get_point_position(0))
		points[-2] = points[-1] + curve.get_point_in(last).normalized()*points[-1].distance_to(points[-2])
		points.insert(1, points[0] + curve.get_point_out(0).normalized()*points[1].distance_to(points[0])*0.5)
	$Line2D.points = points
	pass # Replace with function body.
