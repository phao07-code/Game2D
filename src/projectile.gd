class_name HoaProjectile
extends Area2D

const PETAL_TEXTURE = preload("res://assets/fx/flower_petals.png")

var direction := Vector2.RIGHT
var speed := 620.0
var damage := 20.0
var friendly := true
var life := 1.4
var tint := Color.CYAN
var kind := 2
var visual: Sprite2D

func setup(dir: Vector2, hit_damage: float, is_friendly: bool, color: Color, projectile_kind := 2) -> void:
	direction = dir.normalized()
	damage = hit_damage
	friendly = is_friendly
	tint = color
	kind = projectile_kind
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 7.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)
	if friendly and kind == 2:
		visual = Sprite2D.new()
		visual.texture = load("res://assets/items/shuriken.svg")
		visual.scale = Vector2(0.42, 0.42)
		add_child(visual)
	queue_redraw()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if is_instance_valid(visual): visual.rotation += delta * 18.0
	life -= delta
	if life <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body is HoaActor and body.hostile == friendly:
		body.take_damage(damage)
		queue_free()

func _draw() -> void:
	if is_instance_valid(visual):
		for i in range(1, 5):
			var trail_pos := -direction * i * 11 + direction.orthogonal() * sin(life * 14.0 + i) * 6.0
			draw_texture_rect_region(PETAL_TEXTURE, Rect2(trail_pos - Vector2(7,6), Vector2(14,12)), Rect2((i * 2) % 9 * 8, 0, 8, 7), Color(1,0.66,0.9,0.75 / i))
	else:
		for i in range(1, 5): draw_circle(-direction * i * 8, 6 - i, Color(tint, 0.22))
		draw_circle(Vector2.ZERO, 9, Color(tint, 0.25))
		draw_circle(Vector2.ZERO, 5, tint)
