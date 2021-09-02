extends VehicleBody

export var MAX_ENGINE_FORCE = 700.0
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

export (Array) var gear_ratios = [ 2.69, 2.01, 1.59, 1.32, 1.13, 1.0]
export (float) var reverse_ratio = -2.5
export (float) var final_drive_ratio =3.38
export (float) var max_engine_rpm = 8000
export (Curve) var power_curve = null


var current_gear = 0
var clutch_position : float = 1.0
var current_speed_mps = 0.0
onready var last_pos = translation

var gear_shift_time = 0.3
var gear_timer = 0.0

func get_speed_kph():
	return current_speed_mps * 3600 / 1000.0


func _process_gear_inputs():
	if Input.is_action_just_pressed("gear_down") and current_gear > -1:
		current_gear = current_gear - 1
	elif Input.is_action_just_pressed("gear_up") and current_gear < gear_ratios.size():
		current_gear = current_gear + 1

func calculate_rpm():
	if current_gear == 0:
		return 0.0
		
	var wheel_circumference : float = 2.0 * PI * $right_rear.wheel_radius
	var wheel_rotation_speed : float = 60.0 * current_speed_mps / wheel_circumference
	var drive_shaft_rotation_speed : float = wheel_rotation_speed * final_drive_ratio
	if current_gear == -1:
		return drive_shaft_rotation_speed * -reverse_ratio
	elif current_gear <= gear_ratios.size():
		return drive_shaft_rotation_speed * gear_ratios[current_gear -1]
	else:
		return 0


func _ready():
	pass
	
	
func _process(delta):
	_process_gear_inputs()
	var rpm = calculate_rpm()	
	print(rpm)


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
		
		
	var rpm = calculate_rpm()
	var rpm_factor = clamp(rpm / max_engine_rpm, 0.0, 1.0)
	var power_factor = power_curve.interpolate_baked(rpm_factor)
	
	
	if current_gear == -1:
		engine_force = throttle_val * power_factor * reverse_ratio * final_drive_ratio * MAX_ENGINE_FORCE
	elif current_gear > 0 and current_gear <= gear_ratios.size():
		engine_force = throttle_val * power_factor * gear_ratios[current_gear - 1] * reverse_ratio * final_drive_ratio * MAX_ENGINE_FORCE
	else:
		engine_force = 0.0
	
	engine_force = throttle_val
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
