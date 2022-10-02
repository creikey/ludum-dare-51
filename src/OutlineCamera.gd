extends Camera

func _process(_delta):
	global_transform = get_parent().get_parent().get_viewport().get_camera().global_transform
