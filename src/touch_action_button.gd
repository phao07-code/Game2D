class_name TouchActionButton
extends Button

## Button's built-in GUI input can be tied to the emulated mouse pointer on mobile.
## Tracking a screen-touch index here lets every action button work independently.
var active_touch := -1

func _ready() -> void:
	# Receive raw touch events without the GUI system claiming the first finger.
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or disabled:
		cancel_touch()
		return
	if event is InputEventScreenTouch:
		if event.pressed and active_touch == -1 and get_global_rect().has_point(event.position):
			active_touch = event.index
			set_pressed_no_signal(true)
			button_down.emit()
		elif not event.pressed and event.index == active_touch:
			active_touch = -1
			set_pressed_no_signal(false)
			button_up.emit()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and active_touch == -1 and get_global_rect().has_point(event.position):
			active_touch = -2
			set_pressed_no_signal(true)
			button_down.emit()
		elif not event.pressed and active_touch == -2:
			active_touch = -1
			set_pressed_no_signal(false)
			button_up.emit()

func cancel_touch() -> void:
	if active_touch == -1:
		return
	active_touch = -1
	set_pressed_no_signal(false)
	button_up.emit()
