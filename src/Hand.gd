extends Spatial

class_name Hand

var _holding: RigidBody = null

func _physics_process(delta):
	if _holding != null:
		
#		var target_position: Vector3 = lerp(_holding.global_transform.origin, global_transform.origin, delta*0.5)
#		var to_travel: Vector3 = target_position - _holding.global_transform.origin
		
		_holding.add_central_force((global_transform.origin - _holding.global_transform.origin)*1500.0)
		_holding.linear_velocity = lerp(_holding.linear_velocity, Vector3(), delta*0.01)
#		_holding.add_central_force((to_travel/(delta*delta)) * _holding.mass)
		var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
		_holding.add_central_force(Vector3(0, gravity, 0))

func throw_if_holding_something(aiming_at: Vector3):
	if _holding != null and not _holding.is_in_group("ends"):
		_holding.apply_central_impulse((aiming_at - _holding.global_transform.origin).normalized()*70.0)
		_holding.set_collision_mask_bit(0, true)
		_holding.set_collision_layer_bit(0, true)
		_holding = null

func holding() -> RigidBody:
	return _holding

func hold(h: RigidBody):
	if _holding != null and _holding.is_in_group("ends"):
		return
	assert(_holding == null)
	assert(h != null)
	if h.is_in_group("ends"):
		h.held = true
	_holding = h
	_holding.set_collision_mask_bit(0, false)
	_holding.set_collision_layer_bit(0, false)
