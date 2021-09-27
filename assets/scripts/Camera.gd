extends Camera

export var cameralookX = JOY_ANALOG_RX
export var cameralookY = JOY_ANALOG_RY
export var maxAngleDeg = 90

func _process(delta):
	rotation_degrees(JOY_ANALOG_RX, 0, 0)
