extends RayCast

var last_outlining: Spatial = null

func _outline(collider: Node) -> Spatial:
	return collider.get_node("Outline") as Spatial

func _physics_process(_delta):
	var new_outlining: Spatial = null
	if is_colliding():
		new_outlining = _outline(get_collider())
	
	if new_outlining != last_outlining:
		if last_outlining != null:
			last_outlining.visible = false
		last_outlining = new_outlining
		if last_outlining != null:
			last_outlining.visible = true

func pickup() -> RigidBody:
	if last_outlining == null:
		return null
	return last_outlining.get_parent() as RigidBody
