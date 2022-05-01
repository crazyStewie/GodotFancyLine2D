extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Values/FPS.text = "%.2f" % Performance.get_monitor(Performance.TIME_FPS)
	$Values/FrameTime.text = "%.2f ms" % (1000.0*Performance.get_monitor(Performance.TIME_PROCESS))
	$Values/ObjectsDrawn.text = "%d" % Performance.get_monitor(Performance.RENDER_2D_ITEMS_IN_FRAME)
	$Values/DrawCalls.text = "%d" % Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME)
#	pass
