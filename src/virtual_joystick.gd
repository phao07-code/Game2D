extends Control

var output := Vector2.ZERO
var center := Vector2(130, 130)
var knob := center
var radius := 88.0
var activation_radius := 116.0
var deadzone := 0.14
var active_touch := -1
var pressed_scale := 1.0

func _ready() -> void:
	custom_minimum_size = Vector2(260, 260)
	# Đọc touch toàn viewport để luôn nhận release kể cả khi kéo ra ngoài vòng.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()
	resized.connect(_on_resized)
	_on_resized()

func _on_resized() -> void:
	center = size * 0.5
	if active_touch == -1:
		knob = center
	queue_redraw()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		reset()
		return
	if event is InputEventScreenTouch:
		var local_pos: Vector2 = event.position - global_position
		if event.pressed and active_touch == -1 and local_pos.distance_to(center) <= activation_radius:
			active_touch = event.index
			set_knob(local_pos)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == active_touch:
			active_touch = -1
			reset()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == active_touch:
		set_knob(event.position - global_position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var local_mouse: Vector2 = event.position - global_position
		if event.pressed and active_touch == -1 and local_mouse.distance_to(center) <= activation_radius:
			active_touch = -2
			set_knob(local_mouse)
			get_viewport().set_input_as_handled()
		elif not event.pressed and active_touch == -2:
			active_touch = -1
			reset()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and active_touch == -2:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			set_knob(event.position - global_position)
		else:
			active_touch = -1
			reset()
		get_viewport().set_input_as_handled()

func set_knob(pos: Vector2) -> void:
	var delta := pos - center
	if delta.length() > radius: delta = delta.normalized() * radius
	knob = center + delta
	var strength := delta.length() / radius
	output = Vector2.ZERO if strength < deadzone else delta.normalized() * inverse_lerp(deadzone, 1.0, strength)
	pressed_scale = 0.9
	queue_redraw()

func reset() -> void:
	if output == Vector2.ZERO and knob == center and pressed_scale == 1.0: return
	output = Vector2.ZERO
	knob = center
	pressed_scale = 1.0
	queue_redraw()

func _process(delta: float) -> void:
	pressed_scale = move_toward(pressed_scale, 1.0, delta * 5.0)
	queue_redraw()

func _draw() -> void:
	# Bóng lệch và nhiều vòng sáng tạo cảm giác nút nổi 2.5D.
	draw_circle(center + Vector2(7, 10), 112, Color(0.01, 0.02, 0.06, 0.55))
	draw_circle(center, 108, Color("17223dcc"))
	draw_arc(center, 106, 0, TAU, 64, Color("56dbea"), 5)
	draw_arc(center, 86, 0, TAU, 64, Color("45618a99"), 3)
	for angle in [0.0, PI * 0.5, PI, PI * 1.5]:
		var a := center + Vector2.from_angle(angle) * 76
		var b := center + Vector2.from_angle(angle) * 96
		draw_line(a, b, Color("b8f7ff88"), 4)
	draw_circle(knob + Vector2(5, 7), 39 * pressed_scale, Color(0, 0, 0, 0.5))
	draw_circle(knob, 38 * pressed_scale, Color("38527e"))
	draw_circle(knob - Vector2(5, 7), 24 * pressed_scale, Color("668db8"))
	draw_arc(knob, 37 * pressed_scale, 0, TAU, 48, Color("a3f5ff"), 4)
