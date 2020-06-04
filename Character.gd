extends KinematicBody

var gravity = Vector3.DOWN * 25
var speed = 3
var jump_speed = 8
var jetpack_speed = 10
const MOUSE_SENSITIVITY = 0.002

var velocity = Vector3()
var jump = false
var jetpack = false
var shooting = false
var settings_loaded = false

const BULLET = preload("res://Bullet.tscn")

func _ready():
	if settings_loaded == false:
		load_settings()

func _physics_process(delta):
	velocity += gravity * delta
	get_input()
	velocity = move_and_slide(velocity, Vector3.UP)
	process_jump_movement()
	process_jetpack_movement()
	process_shooting()
	
func get_input():	
	var vy = velocity.y
	velocity = Vector3()
	
	process_movement()
	process_jump_input()
	process_jetpack_input()
	process_shooting_input()
	switch_camera()		
	toggle_mouse_capture()
	toggle_fullscreen()

	velocity.y = vy
	
func _unhandled_input(event):
	# Horizontal mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * MOUSE_SENSITIVITY

	# Vertical mouse look, clamped to -90..90 degrees
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.x = clamp(rotation.x - event.relative.y * MOUSE_SENSITIVITY, deg2rad(-90), deg2rad(90))
		
func process_jump_input():
	jump = false
	if Input.is_action_just_pressed("jump") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		jump = true
		
func process_jump_movement():
	if jump and is_on_floor():
		velocity.y = jump_speed
		
func process_shooting_input():
	shooting = false
	if Input.is_action_just_pressed("shoot") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		shooting = true
		
func process_shooting():
	var bullet_count = get_tree().get_nodes_in_group("bullets").size()
	if shooting && bullet_count < 4:
		var bullet = BULLET.instance()
		bullet.add_to_group("bullets")
		bullet.start($Position3D.global_transform)
		get_parent().add_child(bullet)
		
func process_jetpack_input():
	jetpack = false
	if !is_on_floor():
		if Input.is_action_just_pressed("jump") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			jetpack = true
			
func process_jetpack_movement():
	if jetpack:
		velocity.y = jetpack_speed
		
func process_movement():
	if Input.is_action_pressed("move_forward") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		velocity += -transform.basis.z * speed
	if Input.is_action_pressed("move_back") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		velocity += transform.basis.z * speed
	if Input.is_action_pressed("strafe_left") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		velocity += -transform.basis.x * speed
	if Input.is_action_pressed("strafe_right") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		velocity += transform.basis.x * speed
		
func switch_camera():
	if Input.is_action_just_pressed("camera_switch") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:		
		if $FirstPerson.is_current():
			$ThirdPerson.make_current()
		elif $ThirdPerson.is_current():
			$FirstPerson.make_current()
		
func toggle_mouse_capture():
	if Input.is_action_just_pressed("capture_mouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pass
		
func toggle_fullscreen():
	if Input.is_action_just_pressed("go_fullscreen") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		OS.window_fullscreen = !OS.window_fullscreen
		pass
	
func load_settings():
	$ThirdPerson.make_current()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.window_fullscreen = false
	settings_loaded = true
	pass
	
func _exit_tree():
	# Restore the mouse cursor upon quitting
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
