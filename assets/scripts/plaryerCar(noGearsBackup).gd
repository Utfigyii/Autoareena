extends VehicleBody

export var MAX_ENGINE_FORCE = 200.0
export var MAX_BRAKE_FORCE = 5.0
export var MAX_STEERING_ANGLE = 0.5

export var steer_speed = 5.0

var steer_target = 0.0
var steer_angle = 0.0

export var joy_steering = JOY_ANALOG_LX
export var joy_throttle = JOY_ANALOG_R2
export var joy_brake = JOY_ANALOG_L2
export var steering_mult = -1.0
export var throttle_mult = 1.0
export var brake_mult = 1.0

func _ready():
	pass
	
func _physics_process(delta):
	var steer_val = steering_mult * Input.get_joy_axis(0, joy_steering)
	var throttle_val = throttle_mult * Input.get_joy_axis(0, joy_throttle)
	var brake_val = brake_mult * Input.get_joy_axis(0, joy_brake)
	
	if Input.is_action_pressed("accelerate"):
		throttle_val = 1.0
	if Input.is_action_pressed("brake"):
		brake_val = 1.0
	if Input.is_action_pressed("steer_left"):
		steer_val = 1.0
	if Input.is_action_pressed("steer_right"):
		steer_val = -1.0
		
	engine_force = throttle_val * MAX_ENGINE_FORCE
	brake = brake_val * MAX_BRAKE_FORCE
	
	steer_target = steer_val * MAX_STEERING_ANGLE
	if (steer_target < steer_angle):
		steer_angle -= steer_speed * delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += steer_speed * delta
		if (steer_target < steer_angle):
			steer_angle = steer_target
	
	steering = steer_angle
