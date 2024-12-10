extends Camera3D

# Borrows Ideas from Apocalyptic Phosphorus (https://www.youtube.com/watch?v=QitqbSHEYas) with added damping and smoother flying.

@export var acceleration = 25.0
@export var baseFlySpeed = 5.0
@export var fastFlyModifier = 3.0
@export var mouseSpeed = 300.0
@export var damping = 15.0

var velocity = Vector3.ZERO
var lookAngles = Vector2.ZERO
var flycamEnabled = true
var flySpeed = baseFlySpeed

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta):
	if not flycamEnabled:
		return
	lookAngles.y = clamp(lookAngles.y, PI / -2, PI / 2)
	set_rotation(Vector3(lookAngles.y, lookAngles.x, 0))
	var direction = updateDirection()
	
	# If there is input direction, accelerate in that direction
	if direction.length_squared() > 0:
		velocity += direction * acceleration * delta
	else:
		# If no input, apply damping to slow down gradually
		velocity = velocity.move_toward(Vector3.ZERO, damping * delta)
	
	# Cap the velocity if it exceeds the maximum speed
	if velocity.length() > flySpeed:
		velocity = velocity.normalized() * flySpeed
		
	translate(velocity * delta)
	
func _input(event):
	if event is InputEventMouseMotion:
		lookAngles -= event.relative / mouseSpeed
		
	if Input.is_action_just_pressed("TOGGLE_FLYCAM"):
		flycamEnabled = !flycamEnabled
		if flycamEnabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("MOD_FASTER"):
		flySpeed *= fastFlyModifier
		acceleration *= fastFlyModifier
	if Input.is_action_just_released("MOD_FASTER"):
		flySpeed = baseFlySpeed
		acceleration /= fastFlyModifier


func updateDirection():
	var dir = Vector3()
	if Input.is_action_pressed("FOWARD"):
		dir += Vector3.FORWARD
	if Input.is_action_pressed("BACK"):
		dir += Vector3.BACK
	if Input.is_action_pressed("LEFT"):
		dir += Vector3.LEFT
	if Input.is_action_pressed("RIGHT"):
		dir += Vector3.RIGHT
	if Input.is_action_pressed("UP"):
		dir += Vector3.UP
	if Input.is_action_pressed("DOWN"):
		dir += Vector3.DOWN
	if Input.is_action_just_pressed("ESCAPE"):
		get_tree().quit()
		
	return dir.normalized()
