extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var scene: Node = load("res://src/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.new_game()
	print("SMOKE_STATE: playing=", scene.playing, " player=", scene.player)
	await process_frame
	assert(scene.player != null, "Không tạo được người chơi")
	assert(scene.enemies.size() > 0, "Không tạo được kẻ địch")
	assert(scene.world_lights.size() == 6, "Hệ thống ánh sáng chưa hoạt động")
	for asset_path in ["res://assets/tiles/flowers_animated.png", "res://assets/fx/flower_petals.png", "res://assets/fx/sun_rays.png", "res://assets/fx/cloud_layer.png", "res://assets/fx/rain_splash.png"]:
		assert(ResourceLoader.exists(asset_path), "Thiếu asset biome/VFX: %s" % asset_path)
	assert(scene.music_player.playing, "Nhạc nền chưa phát")
	assert(scene.joystick != null, "Joystick chưa được tạo")
	assert(scene.hud_panel.visible and scene.title_label.text != "" and scene.stats_label.text != "", "HUD đang hiện khung rỗng")
	# Chạm ngoài vòng không được kích hoạt; thả ngoài vòng vẫn phải reset.
	var outside_touch := InputEventScreenTouch.new()
	outside_touch.index = 7
	outside_touch.pressed = true
	outside_touch.position = scene.joystick.global_position + Vector2(225, 225)
	scene.joystick._input(outside_touch)
	assert(scene.joystick.output == Vector2.ZERO and scene.joystick.active_touch == -1, "Joystick nhận chạm ngoài vùng")
	var inside_touch := InputEventScreenTouch.new()
	inside_touch.index = 8
	inside_touch.pressed = true
	inside_touch.position = scene.joystick.global_position + scene.joystick.center + Vector2(60, 0)
	scene.joystick._input(inside_touch)
	assert(scene.joystick.output.x > 0.5, "Joystick không nhận chạm hợp lệ")
	inside_touch.pressed = false
	inside_touch.position = Vector2(1200, 100)
	scene.joystick._input(inside_touch)
	assert(scene.joystick.output == Vector2.ZERO and scene.joystick.active_touch == -1, "Joystick bị kẹt sau khi thả ngoài vùng")
	var action_buttons: Array[Control] = []
	for action_name in ["attack", "skill", "switch_weapon", "dodge", "switch_hero", "interact"]:
		var button: Button = scene.touch_root.get_node("Action_%s" % action_name)
		action_buttons.append(button)
		var icon_rect: TextureRect = null
		for node in button.get_children():
			if node is TextureRect: icon_rect = node
		assert(icon_rect != null, "Nút %s thiếu icon" % action_name)
		assert(absf(icon_rect.position.x + icon_rect.size.x * 0.5 - button.size.x * 0.5) < 0.1, "Icon %s lệch tâm" % action_name)
		assert(icon_rect.position.x >= 0 and icon_rect.position.x + icon_rect.size.x <= button.size.x, "Icon %s tràn nút" % action_name)
	for i in range(action_buttons.size()):
		for j in range(i + 1, action_buttons.size()):
			assert(not action_buttons[i].get_global_rect().intersects(action_buttons[j].get_global_rect()), "Hai nút kỹ năng bị đè lên nhau")
	# Hai ngón tay phải hoạt động độc lập: giữ joystick vẫn bấm được chiêu.
	inside_touch.pressed = true
	inside_touch.position = scene.joystick.global_position + scene.joystick.center + Vector2(60, 0)
	scene.joystick._input(inside_touch)
	var skill_touch := InputEventScreenTouch.new()
	skill_touch.index = 9
	skill_touch.pressed = true
	skill_touch.position = scene.skill_button.get_global_rect().get_center()
	scene.skill_button._input(skill_touch)
	assert(scene.joystick.output.x > 0.5, "Joystick dừng khi bấm chiêu bằng ngón thứ hai")
	assert(Input.is_action_pressed("skill"), "Nút chiêu không nhận đa điểm chạm")
	skill_touch.pressed = false
	scene.skill_button._input(skill_touch)
	inside_touch.pressed = false
	scene.joystick._input(inside_touch)
	# Tấn công cũng không được khóa khi joystick đang được giữ.
	inside_touch.pressed = true
	inside_touch.position = scene.joystick.global_position + scene.joystick.center + Vector2(60, 0)
	scene.joystick._input(inside_touch)
	var attack_button: Button = scene.touch_root.get_node("Action_attack")
	var attack_touch := InputEventScreenTouch.new()
	attack_touch.index = 10
	attack_touch.pressed = true
	attack_touch.position = attack_button.get_global_rect().get_center()
	attack_button._input(attack_touch)
	assert(Input.is_action_pressed("attack") and scene.joystick.output.x > 0.5, "Không thể vừa di chuyển vừa tấn công")
	attack_touch.pressed = false
	attack_button._input(attack_touch)
	inside_touch.pressed = false
	scene.joystick._input(inside_touch)
	assert(scene.player.position.is_equal_approx(Vector2(35, scene.WORLD_SIZE.y * 0.5)), "A chưa xuất hiện giữa biên trái")
	var enemy_b = scene.rubric_enemy_b
	assert(enemy_b != null, "Chưa tạo đối tượng B")
	assert(enemy_b.position.is_equal_approx(Vector2(scene.WORLD_SIZE.x - 35, scene.WORLD_SIZE.y * 0.5)), "B chưa xuất hiện ở biên đối diện A")
	assert(is_equal_approx(enemy_b.radius, scene.player.radius), "A và B không cùng kích thước va chạm")
	assert(enemy_b.visual.scale.is_equal_approx(scene.player.visual.scale), "A và B không cùng kích thước hiển thị")
	enemy_b.position.x = 10
	scene.wrap_enemy_if_needed(enemy_b)
	assert(enemy_b.position.x == scene.WORLD_SIZE.x - 35 and enemy_b.position.y >= 145, "B chưa quấn về biên phải với vị trí ngẫu nhiên")
	# C là phi tiêu, sinh từ A và được kích hoạt cùng action attack (click/chạm).
	scene.weapon_mode = 2
	scene.player.attack_cooldown = 0
	scene.attack()
	var projectile_found := false
	for child in scene.get_children():
		if child is HoaProjectile:
			projectile_found = child.position.distance_to(scene.player.position) <= 35
	assert(projectile_found, "C chưa xuất phát từ A khi tấn công")
	scene.use_skill()
	for enemy in scene.enemies:
		assert(enemy.patrol_origin != Vector2.ZERO, "Enemy chưa có tâm tuần tra")
	scene.zone_kills = int(scene.ZONES[scene.zone].goal)
	for prison in scene.PRISON_POSITIONS:
		scene.player.position = prison
		scene.interact()
	assert(scene.rescued_in_zone == 3 and scene.can_exit, "Cổng mở trước khi cứu đủ tù nhân hoặc không mở sau 3/3")
	scene._on_player_died(scene.player)
	assert(scene.stage_panel.visible and not scene.message_panel.visible and not scene.choice_panel.visible, "Modal thua đang chồng nhau")
	print("SMOKE_GAME_PASS: player, enemies, lighting, combat, locked skill")
	scene.queue_free()
	await process_frame
	await process_frame
	quit(0)
