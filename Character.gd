extends KinematicBody

var gravity = Vector3.DOWN * 12
var speed = 3
var jump_speed = 6
var spin = 0.060

var velocity = Vector3()
var jump = false

func _physics_process(delta):
	velocity += gravity * delta
	get_input()
	velocity = move_and_slide(velocity, Vector3.UP)
	if jump and is_on_floor():
		velocity.y = jump_speed
	
func get_input():	
	var vy = velocity.y
	velocity = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		velocity += -transform.basis.z * speed
	if Input.is_action_pressed("move_back"):
		velocity += transform.basis.z * speed
	if Input.is_action_pressed("strafe_left"):
		velocity += -transform.basis.x * speed
	if Input.is_action_pressed("strafe_right"):
		velocity += transform.basis.x * speed

	velocity.y = vy
	jump = false
	if Input.is_action_just_pressed("jump"):
		jump = true
		
	if Input.is_action_just_pressed("camera_switch"):		
		if $FirstPerson.is_current():
	    	$ThirdPerson.make_current()
		elif $ThirdPerson.is_current():
	    	$FirstPerson.make_current()
			
	capture_mouse()
	go_fullscreen()
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-lerp(0, spin, event.relative.x/20))
		
func capture_mouse():
	if Input.is_action_just_pressed("capture_mouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pass
		
func go_fullscreen():
	if Input.is_action_just_pressed("go_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		pass