extends RigidBody

var speed = 15
var velocity = Vector3()
var gravity = Vector3.DOWN * 15

onready var timer = get_node("Timer")

func _ready():
	timer.set_wait_time(1)
	timer.start()

func start(xform):
	transform = xform
	velocity = -transform.basis.z * speed

func _process(delta):
	transform.origin += velocity * delta
	
func _physics_process(delta):
	velocity += gravity * delta

func _on_Bullet_body_entered(body):
	if body is RigidBody:
		queue_free()

func _on_Timer_timeout():
	queue_free()


