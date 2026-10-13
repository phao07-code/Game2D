class_name HoaActor
extends CharacterBody2D

signal died(actor)

var actor_name := ""
var role := ""
var tint := Color.WHITE
var max_hp := 100.0
var hp := 100.0
var speed := 230.0
var damage := 20.0
var radius := 18.0
var hostile := false
var target: Node2D
var attack_cooldown := 0.0
var hurt_flash := 0.0
var elite := false
var slowed := 0.0
var visual: Sprite2D
var weapon_visual: Sprite2D
var anim_clock := 0.0
var invulnerable := 0.0
var patrol_origin := Vector2.ZERO
var aggro_radius := 245.0
var alerted := false
## Đối tượng B của rubric: khi vượt biên trái sẽ tái xuất ở biên phải.
var wrap_on_left := false
## AI thông minh: "patrol" | "chase" | "ranged"
var ai_type := "patrol"
var shoot_cd := 0.0
## NPC "chase" có thể né khi bị player tấn công
var dodge_cd := 0.0

func setup(n: String, r: String, color: Color, health: float, move_speed: float, hit_damage: float, is_hostile := false) -> void:
	actor_name = n
	role = r
	tint = color
	max_hp = health
	hp = health
	speed = move_speed
	damage = hit_damage
	hostile = is_hostile
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	add_child(shape)
	create_visual()
	queue_redraw()

func create_visual() -> void:
	var path := "res://assets/characters/kai.png"
	var beast_visual := false
	if actor_name == "Lira": path = "res://assets/characters/lira.png"
	elif actor_name == "Thorn": path = "res://assets/characters/thorn.png"
	elif hostile:
		if actor_name in ["Sói Nhiễm", "Linh Thú Fenrir"]:
			path = "res://assets/characters/beast.png"
			beast_visual = true
		elif actor_name in ["Vệ Binh Máy", "Hộ Vệ Titan", "Zorath"]: path = "res://assets/characters/samurai_green_enemy.png"
		elif actor_name in ["Ninja Bóng", "Ninja Kage"]: path = "res://assets/characters/ninja_enemy.png"
		else: path = "res://assets/characters/samurai_enemy.png"
	visual = Sprite2D.new()
	visual.texture = load(path)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if hostile:
		visual.hframes = 4
		visual.vframes = 2 if beast_visual else 7
		visual.scale = Vector2(4.2, 4.2) if elite else Vector2(3.0, 3.0)
		visual.modulate = tint.lightened(0.2)
	else:
		visual.hframes = 4
		visual.vframes = 7
		visual.scale = Vector2(3.0, 3.0)
		if actor_name in ["Ryn", "Vex"]: visual.modulate = tint
	visual.position.y = -8
	add_child(visual)
	if not hostile:
		weapon_visual = Sprite2D.new()
		weapon_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		weapon_visual.position = Vector2(18, -4)
		weapon_visual.z_index = 2
		add_child(weapon_visual)
		equip_weapon(0)

func equip_weapon(mode: int, facing := Vector2.RIGHT) -> void:
	if not is_instance_valid(weapon_visual): return
	var paths := ["res://assets/items/sword.png", "res://assets/items/katana.svg", "res://assets/items/shuriken.svg", "res://assets/items/energy_gun.svg"]
	weapon_visual.texture = load(paths[clampi(mode, 0, 3)])
	weapon_visual.scale = Vector2(2.7, 2.7) if mode == 0 else (Vector2(0.42, 0.42) if mode == 1 else Vector2(0.48, 0.48))
	weapon_visual.rotation = facing.angle()
	weapon_visual.position = facing.normalized() * 22 + Vector2(0, -7)
	weapon_visual.flip_v = facing.x < 0

func animate_weapon_attack(mode: int, facing: Vector2) -> void:
	equip_weapon(mode, facing)
	if not is_instance_valid(weapon_visual): return
	var base_angle := facing.angle()
	weapon_visual.rotation = base_angle - 0.9
	weapon_visual.scale *= 1.18
	var tween := create_tween()
	tween.tween_property(weapon_visual, "rotation", base_angle + 1.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(weapon_visual, "rotation", base_angle, 0.10)
	tween.tween_callback(func(): equip_weapon(mode, facing))

func _physics_process(delta: float) -> void:
	anim_clock += delta
	invulnerable = maxf(0.0, invulnerable - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	hurt_flash = maxf(0.0, hurt_flash - delta)
	slowed = maxf(0.0, slowed - delta)
	shoot_cd = maxf(0.0, shoot_cd - delta)
	dodge_cd = maxf(0.0, dodge_cd - delta)
	if hostile and is_instance_valid(target):
		var distance := global_position.distance_to(target.global_position)
		var move_spd := speed * (0.55 if slowed > 0 else 1.0)
		match ai_type:
			"chase":
				# NPC 2: luôn đuổi theo player
				if distance < aggro_radius + 80.0:
					alerted = true
				if alerted and distance > 42.0:
					velocity = global_position.direction_to(target.global_position) * move_spd
					move_and_slide()
				else:
					velocity = Vector2.ZERO
			"ranged":
				# NPC 3: giữ khoảng cách + tấn công tầm xa (đánh dấu sẵn sàng bắn)
				if distance < aggro_radius:
					alerted = true
				if alerted:
					if distance < 140.0:
						velocity = -global_position.direction_to(target.global_position) * move_spd
						move_and_slide()
					elif distance > 280.0:
						velocity = global_position.direction_to(target.global_position) * move_spd * 0.7
						move_and_slide()
					else:
						velocity = Vector2.ZERO
						# Sẵn sàng bắn khi trong tầm (main.gd xử lý damage)
						if shoot_cd <= 0.0:
							shoot_cd = 1.6
				else:
					var t: Vector2 = patrol_origin + Vector2(sin(anim_clock * 0.5) * 60.0, cos(anim_clock * 0.7) * 40.0)
					velocity = global_position.direction_to(t) * move_spd * 0.35
					if global_position.distance_to(t) > 8.0:
						move_and_slide()
			_:
				# NPC 1: tuần tra hình số 8; chỉ đuổi khi player xâm nhập
				if distance < aggro_radius:
					alerted = true
				if alerted and distance > 42.0:
					velocity = global_position.direction_to(target.global_position) * move_spd
					move_and_slide()
				elif alerted:
					velocity = Vector2.ZERO
				else:
					var patrol_target: Vector2 = patrol_origin + Vector2(sin(anim_clock * 0.75) * 85.0, sin(anim_clock * 1.5) * 42.0)
					velocity = global_position.direction_to(patrol_target) * move_spd * 0.42
					if global_position.distance_to(patrol_target) > 8.0:
						move_and_slide()
	else:
		velocity = Vector2.ZERO
	update_animation()
	queue_redraw()

func update_animation() -> void:
	if not is_instance_valid(visual): return
	var moving := velocity.length() > 4.0
	var frame_column := int(anim_clock * 8.0) % 4 if moving else 0
	if hostile:
		visual.frame_coords = Vector2i(frame_column, 0)
	else:
		var row := 0
		if absf(velocity.x) > absf(velocity.y):
			row = 1 if velocity.x > 0 else 2
		elif velocity.y != 0:
			row = 0 if velocity.y > 0 else 3
		visual.frame_coords = Vector2i(frame_column, row)
		if velocity.length() > 2 and is_instance_valid(weapon_visual): equip_weapon(_weapon_index(), velocity.normalized())
	visual.modulate.a = 0.55 if hurt_flash > 0 else 1.0

func _weapon_index() -> int:
	if not is_instance_valid(weapon_visual) or not weapon_visual.texture: return 0
	var path := weapon_visual.texture.resource_path
	if "katana" in path: return 1
	if "shuriken" in path: return 2
	if "energy_gun" in path: return 3
	return 0

func take_damage(amount: float) -> void:
	if invulnerable > 0.0:
		return
	# NPC chase: ~55% né được đòn cận chiến của player
	if hostile and ai_type == "chase" and try_dodge_attack():
		return
	hp -= amount
	hurt_flash = 0.12
	if hp <= 0.0:
		died.emit(self)
		queue_free()


## Né đòn: nhảy ngang vuông góc với hướng từ player, bất tử ngắn
func try_dodge_attack() -> bool:
	if dodge_cd > 0.0:
		return false
	if not is_instance_valid(target):
		return false
	# Xác suất né 55%
	if randf() > 0.55:
		return false
	dodge_cd = 1.4
	invulnerable = 0.35
	hurt_flash = 0.08
	var away: Vector2 = global_position - target.global_position
	if away.length() < 0.01:
		away = Vector2.RIGHT
	# Nhảy sang bên (vuông góc) + lùi nhẹ
	var side: Vector2 = Vector2(-away.y, away.x).normalized()
	if randf() < 0.5:
		side = -side
	var dodge_dir: Vector2 = (side * 0.85 + away.normalized() * 0.35).normalized()
	global_position += dodge_dir * 95.0
	velocity = dodge_dir * speed * 1.2
	return true

func heal(amount: float) -> void:
	hp = minf(max_hp, hp + amount)

func _draw() -> void:
	var c := Color.WHITE if hurt_flash > 0 else tint
	draw_ellipse_shadow()
	if not is_instance_valid(visual): draw_circle(Vector2.ZERO, radius, c)
	var ratio := clampf(hp / max_hp, 0.0, 1.0)
	draw_rect(Rect2(-22, -31, 44, 5), Color(0.12, 0.08, 0.12))
	draw_rect(Rect2(-21, -30, 42 * ratio, 3), Color(0.25, 0.95, 0.48) if not hostile else Color(1.0, 0.24, 0.3))

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 11), 0.0, Vector2(1.5, 0.55))
	draw_circle(Vector2.ZERO, radius, Color(0.02, 0.03, 0.06, 0.42))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
