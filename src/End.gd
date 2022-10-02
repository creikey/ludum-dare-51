extends RigidBody

var held: bool = false

func _process(_delta):
	if Input.is_action_pressed("left_hand") and held:
		var new_rock = preload("res://Rock.tscn").instance()
		get_node("/root/Main/EndRocks").add_child(new_rock)
		new_rock.global_transform = global_transform
		var cam: Camera = get_viewport().get_camera()
		new_rock.add_central_force(-cam.global_transform.basis.z*10000.0)
		get_node("/root/Main/CanvasLayer/Finished").visible = true
