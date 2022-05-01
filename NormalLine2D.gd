tool
extends Line2D

export var corner_radius : float = 8.0 setget set_corner_radius

var length_until : PoolRealArray = PoolRealArray()
func _init():
	if not is_connected("draw", self, "on_draw"):
		connect("draw", self, "on_draw")

func set_corner_radius(value : float):
	corner_radius = max(value, 0.0)

func on_draw():
	if not Engine.editor_hint:
		return
#	print("updating")
	if points.size() < 2:
		return
	var length = calculate_length()
	var new_gradient = Gradient.new()
	var tg : Vector2 = (points[1] - points[0]).normalized()
	var bn : Vector2 = tg.rotated(PI*0.5)
	new_gradient.set_color(0, Color(tg.x*0.5 + 0.5, tg.y*0.5 + 0.5, bn.x*0.5 + 0.5, bn.y*0.5 + 0.5))
	tg = (points[-1] - points[-2]).normalized()
	bn = tg.rotated(PI*0.5)
	new_gradient.set_color(1, Color(tg.x*0.5 + 0.5, tg.y*0.5 + 0.5, bn.x*0.5 + 0.5, bn.y*0.5 + 0.5));
#	for i in points.size() - 1:
#		var idx = i + 1;
#		tg = (points[idx] - points[idx - 1]).normalized()
#		bn = tg.rotated(PI*0.5)
#		var color_value = Color(tg.x*0.5 + 0.5, tg.y*0.5 + 0.5, bn.x*0.5 + 0.5, bn.y*0.5 + 0.5)
#		var seg_length = length_until[idx] - length_until[idx - 1]
#		if seg_length <= 2.0*corner_radius:
#			new_gradient.add_point((length_until[idx] - seg_length*0.5)/length, color_value)
#		else:
#			new_gradient.add_point((length_until[idx - 1] + corner_radius)/length, color_value)
#			new_gradient.add_point((length_until[idx] - corner_radius)/length, color_value)
	for i in points.size() - 2:
		var idx = i + 1;
		var tg_a = (points[idx] - points[idx - 1]).normalized()
		var tg_b = (points[idx + 1] - points[idx]).normalized()
		tg = (tg_a + tg_b).normalized()
		bn = tg.rotated(PI*0.5)
		var offset = length_until[idx]/length
		var color_value = Color(tg.x*0.5 + 0.5, tg.y*0.5 + 0.5, bn.x*0.5 + 0.5, bn.y*0.5 + 0.5)
		new_gradient.add_point(offset, color_value)
	gradient = new_gradient
	(material as ShaderMaterial).set_shader_param("UVX_SCALE", round(length/(width*PI*0.5)))
	pass


func calculate_length() -> float:
	var result : float = 0.0
	length_until.resize(points.size())
	length_until[0] = 0.0
	for i in points.size() - 1:
		result += points[i].distance_to(points[i + 1])
		length_until[i + 1] = result
	return result
