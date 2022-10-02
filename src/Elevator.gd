extends KinematicBody

const speed: float = 5.0
const height: float = 15.0

func _physics_process(delta):
	var going_up: bool = false
	for b in $Detector.get_overlapping_bodies():
		if b.is_in_group("triggers_elevator"):
			going_up = true
			break
	
	if going_up and translation.y < height:
		var _collision = move_and_collide(Vector3(0,speed*delta,0))
	elif not going_up and translation.y > 0.0:
		var _collision = move_and_collide(Vector3(0,-speed*delta,0))
