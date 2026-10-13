class_name CombatVFX
extends Node2D

const PETAL_TEXTURE = preload("res://assets/fx/flower_petals.png")

var age := 0.0
var duration := 0.45
var tint := Color.WHITE
var style := 0

func setup(vfx_style: int, color: Color, lifetime := 0.45) -> void:
	style = vfx_style
	tint = color
	duration = lifetime
	queue_redraw()

func _process(delta: float) -> void:
	age += delta
	if age >= duration:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var t := age / duration
	var alpha := 1.0 - t
	if style == 0:
		draw_arc(Vector2.ZERO, 35 + t * 75, -1.2, 1.2, 28, Color(tint, alpha), 13 * alpha + 2)
		draw_arc(Vector2.ZERO, 24 + t * 55, -1.0, 1.0, 24, Color.WHITE * Color(1,1,1,alpha), 4)
	elif style == 1:
		for i in range(8):
			var dir := Vector2.from_angle(i * TAU / 8.0 + t)
			draw_line(dir * (18 + t * 60), dir * (42 + t * 85), Color(tint, alpha), 6 * alpha + 1)
	elif style == 2:
		draw_circle(Vector2.ZERO, 25 + t * 150, Color(tint, 0.16 * alpha))
		draw_arc(Vector2.ZERO, 25 + t * 150, 0, TAU, 64, Color(tint, alpha), 9 * alpha + 2)
	elif style == 3:
		for i in range(3):
			var r := 35 + i * 28 + sin(t * TAU + i) * 8
			draw_arc(Vector2.ZERO, r, t * 3 + i, t * 3 + i + 4.5, 38, Color(tint, alpha), 8 - i)
	elif style == 4:
		for i in range(10):
			var x := -140 + i * 30
			draw_line(Vector2(x, -170 + t * 210), Vector2(x - 28, 35 + t * 80), Color(tint, alpha), 5)
	elif style == 5:
		for i in range(12):
			var dir := Vector2.from_angle(i * TAU / 12.0 + t * 2)
			draw_circle(dir * (30 + t * 160), 10 * alpha + 2, Color(tint, alpha))
	else:
		for i in range(16):
			var dir := Vector2.from_angle(i * 2.399)
			var pos := dir * (12 + t * (45 + (i % 5) * 9)) + Vector2(0, t * t * 55)
			draw_circle(pos, maxf(2.0, (7 - i % 4) * alpha), Color(tint, alpha * 0.9))
		draw_circle(Vector2.ZERO, 28 + t * 20, Color(tint, 0.18 * alpha))
	# Dấu ấn Làng Hoa: mỗi đòn bung cánh hoa asset CC0, skill tạo vòng sen kép.
	var petal_count := 8 if style <= 1 else 16
	for i in range(petal_count):
		var angle := i * TAU / float(petal_count) + t * (2.8 if i % 2 == 0 else -2.1)
		var petal_distance := (18.0 if style <= 1 else 30.0) + t * (68.0 + float(i % 4) * 14.0)
		var petal_pos := Vector2.from_angle(angle) * petal_distance
		var petal_frame := (i + int(t * 18.0)) % 9
		draw_set_transform(petal_pos, angle + PI * 0.5, Vector2.ONE)
		draw_texture_rect_region(PETAL_TEXTURE, Rect2(-13, -10, 26, 20), Rect2(petal_frame * 8, 0, 8, 7), Color(1.0, 0.68, 0.9, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if style >= 2 and style <= 5:
		for ring in range(2):
			var flower_radius := 18.0 + ring * 14.0 + t * 38.0
			for petal in range(6):
				var a := petal * TAU / 6.0 + ring * 0.52 - t * 1.5
				draw_circle(Vector2.from_angle(a) * flower_radius, (11.0 - ring * 2.0) * alpha + 2.0, Color(1.0, 0.42 + ring * 0.18, 0.78, alpha * 0.72))
		draw_circle(Vector2.ZERO, 14.0 + sin(t * PI) * 8.0, Color(1.0, 0.86, 0.32, alpha))
