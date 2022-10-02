extends RigidBody

const sense: float = 0.01
const movement_force: float = 40.0

var health: float = 1.0
onready var _torso = $Torso
onready var _camera: Camera = $Torso/Camera
onready var _pickup: RayCast = $Torso/Camera/PickCast
onready var _right: Hand = $Torso/Camera/RightHand
onready var _left: Hand = $Torso/Camera/LeftHand
onready var _aimcast: RayCast = $Torso/Camera/AimCast

func _hand_pickup(is_left_hand: bool, object: RigidBody):
	var target_hand: Spatial = _right
	if is_left_hand:
		target_hand = _left
	
	
	var aiming_target: Vector3 = _camera.global_transform.origin + _camera.global_transform.basis.z*-100.0
	if _aimcast.is_colliding():
		aiming_target = _aimcast.get_collision_point()
	target_hand.throw_if_holding_something(aiming_target)
	
	if object != null:
		target_hand.hold(object)

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_torso.rotation.y -= event.relative.x*sense
		_camera.rotation.x -= event.relative.y*sense
		_camera.rotation.x = clamp(_camera.rotation.x, -PI/2.0+0.001, PI/2.0-0.001)
	if event.is_action_pressed("capture_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("left_hand"):
		_hand_pickup(true, _pickup.pickup())
	if event.is_action_pressed("right_hand"):
		_hand_pickup(false, _pickup.pickup())

func _flatten(v: Vector3) -> Vector3:
	v.y = 0.0
	return v.normalized()

func _process(delta):
	if (_left.holding() != null and _left.holding().is_in_group("medkits")) or \
	   (_right.holding() != null and _right.holding().is_in_group("medkits")):
		health += delta/8.0
	
	if health <= 0.0:
		var _err = get_tree().reload_current_scene()
	health = clamp(health, 0.0, 1.0)
	$Overlay/DamageVignette.modulate = Color(
		1, 0, 0,
		(1.0 - health)*0.6
	)
	if _pickup.is_colliding():
		$Overlay/CenterContainer/Reticle.rect_scale = Vector2(1.5, 1.5)
	else:
		$Overlay/CenterContainer/Reticle.rect_scale = Vector2(1.0, 1.0)

func hit_by_snake(snake: Spatial):
	apply_central_impulse((global_transform.origin - snake.global_transform.origin).normalized()*100.0)
	health -= 0.4

func _ready():
	_aimcast.add_exception(self)

func _integrate_forces(state: PhysicsDirectBodyState):
	# only movement damping, done like in bullet source code
	var before_vertical_vel: float = state.linear_velocity.y
	state.linear_velocity *= pow(0.05, state.step)
	state.linear_velocity.y = before_vertical_vel

func _physics_process(_delta):
	var movement_input: Vector2 = Input.get_vector("left", "right", "backward", "forward")
	
	var forward: Vector3 = _flatten(-_camera.global_transform.basis.z)
	var lateral: Vector3 = _flatten(_camera.global_transform.basis.x)
	
	
	
	add_central_force((forward*movement_input.y + lateral*movement_input.x).normalized()*movement_force)
