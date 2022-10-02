extends RigidBody

onready var _skele: Skeleton = $"snake/Snake/Skeleton"
onready var _mat: ShaderMaterial = $snake/Snake/Skeleton/SnakeMesh.get_active_material(0)
onready var _eye: Spatial = $snakeye

var _dead: bool = false

func _physics_process(delta):
	
	var target: Spatial = null
	for b in $SpottingArea.get_overlapping_bodies():
		if b.is_in_group("snake_targeted"):
			target = b
			break
	
	var target_wigglespeed: float = 1.0
	var target_eyescale := Vector3(2.5, 2.5, 2.5)
	if _dead:
		target_wigglespeed = 0.0
		target_eyescale = Vector3(2.5, 0.0, 2.5)
		$CollisionShape.disabled = true
		mode = RigidBody.MODE_STATIC
	elif target != null:
		target_wigglespeed = 5.0
		target_eyescale = Vector3(2.5, 1.0, 1.0)
		var to_target: Vector3 = target.global_transform.origin - global_transform.origin
#		var target_basis := Basis(
#			Vector3.UP.cross(-to_target.normalized()),
#			Vector3.UP,
#			-to_target.normalized()
#		).orthonormalized()
#		global_transform.basis = global_transform.basis.slerp(target_basis, delta*1.5)
#		var to_look_at = target.global_transform.origin
#		look_at(, Vector3(0, 1, 0))
#		rotation.y = lerp_angle()
#		add_central_force(to_target.normalized()*30.0)
		sleeping = false
		add_central_force(-global_transform.basis.z*35.0)
		add_torque(Vector3(0.0, global_transform.basis.z.rotated(Vector3.UP, -PI/2.0).dot(to_target.normalized())*19.0,0.0))

	_eye.scale = lerp(_eye.scale, target_eyescale, delta*2.0)
	_mat.set_shader_param("time", _mat.get_shader_param("time") + delta*target_wigglespeed)

func _on_SnakeCreature_body_entered(body):
	if body.is_in_group("snake_harmed"):
		body.hit_by_snake(self)

func die():
	_dead = true

func _on_Heart_body_entered(body):
	if body.is_in_group("rocks"):
		$Heart.visible = false
		$SnakeDeathParticles.emitting = true
		die()
