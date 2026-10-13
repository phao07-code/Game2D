extends Node2D

const Actor = preload("res://src/actor.gd")
const Projectile = preload("res://src/projectile.gd")
const Joystick = preload("res://src/virtual_joystick.gd")
const TouchButton = preload("res://src/touch_action_button.gd")
const VFX = preload("res://src/combat_vfx.gd")
const SAVE_PATH := "user://hoa_save.json"
const WORLD_SIZE := Vector2(1500, 820)
const PRISON_POSITIONS := [Vector2(470, 250), Vector2(790, 570), Vector2(1120, 275)]
const FLOOR_TEXTURE = preload("res://assets/tiles/floor.png")
const BOOK_TEXTURE = preload("res://assets/items/skill_book.png")
const VILLAGE_TEXTURE = preload("res://assets/tiles/village.png")
const RPG_TEXTURE = preload("res://assets/tiles/kenney_rpg.png")
const DUNGEON_TEXTURE = preload("res://assets/tiles/kenney_dungeon.png")
const PARTICLE_TEXTURE = preload("res://assets/fx/leaf.png")
const PRISON_TEXTURE = preload("res://assets/world/prison_cage.svg")
const VILLAGER_TEXTURE = preload("res://assets/characters/villager.svg")
const PORTAL_TEXTURE = preload("res://assets/world/portal.svg")
const PANORAMA_TEXTURE = preload("res://assets/backgrounds/intro_panorama.svg")
const FLOWER_TEXTURE = preload("res://assets/tiles/flowers_animated.png")
const PETAL_TEXTURE = preload("res://assets/fx/flower_petals.png")
const CLOUD_TEXTURE = preload("res://assets/fx/cloud_layer.png")
const SUN_RAYS_TEXTURE = preload("res://assets/fx/sun_rays.png")
const RAIN_SPLASH_TEXTURE = preload("res://assets/fx/rain_splash.png")

const HEROES := [
	{"name":"Kai", "role":"Công nghệ", "color":Color("42dff5"), "hp":110.0, "speed":265.0, "damage":22.0, "skill":"Drone Xung Kích"},
	{"name":"Lira", "role":"Chiến binh", "color":Color("ff9b54"), "hp":165.0, "speed":225.0, "damage":32.0, "skill":"Kiếm Lốc"},
	{"name":"Thorn", "role":"Y sư", "color":Color("70e080"), "hp":125.0, "speed":220.0, "damage":16.0, "skill":"Mạch Sống"},
	{"name":"Ryn", "role":"Cung thủ", "color":Color("ffd866"), "hp":100.0, "speed":250.0, "damage":25.0, "skill":"Mưa Tên"},
	{"name":"Vex", "role":"Vey'Rith cải tạo", "color":Color("bd72ff"), "hp":140.0, "speed":245.0, "damage":29.0, "skill":"Bẻ Cong Năng Lượng"}
]
## Chỉ 3 cấp độ — mục tiêu WIN: hoàn thành cấp 3 (hạ Zorath + chọn Ending)
const ZONES := [
	{"name":"Đèo Samurai", "color":Color("284d3b"), "accent":Color("c98552"), "goal":4, "story":"Kai tỉnh dậy tại đèo làng. Thanh kiếm cùn là thứ duy nhất còn lại. Hạ lính canh Samurai, mở 3 nhà tù và tiến về phía Đông.", "reward":"Katana Hoa Thép + Bí Kíp Kiếm Lốc"},
	{"name":"Rừng Ninja", "color":Color("183c37"), "accent":Color("68a67d"), "goal":5, "story":"Ninja Kage phục kích bên kia sông. Vượt cầu, né phi tiêu, cứu tù nhân và lấy Phi Tiêu Gió.", "reward":"Phi Tiêu Gió + Ryn gia nhập"},
	{"name":"Nhà Tù Tinh Vân", "color":Color("210f35"), "accent":Color("ed4cff"), "goal":1, "story":"Trận chiến cuối. Hạ Zorath, mở nhà tù cuối và chọn số phận Làng Hoa để WIN.", "reward":"Giải cứu Làng Hoa + Ending (WIN)"}
]
const QUESTS := [
	"Cấp 1: Hạ 4 lính canh → mở 3 nhà tù → đi Cổng Đông",
	"Cấp 2: Hạ 5 Ninja → mở 3 nhà tù → đi Cổng Đông",
	"Cấp 3 (WIN): Hạ Zorath → mở nhà tù → chọn Ending"
]
## Index cấp cuối (WIN)
const FINAL_ZONE := 2

var player: HoaActor
var enemies: Array[HoaActor] = []
var active_hero := 0
var unlocked_heroes := 2
var zone := 0
var zone_kills := 0
var rescued := 0
var rescued_in_zone := 0
var prisons_opened := [false, false, false]
var materials := 0
var tech_fragments := 0
var level := 1
var xp := 0
var damage_bonus := 0.0
var weapon_unlocked := 1
var weapon_mode := 0
var manuals := 0
var dodge_cooldown := 0.0
var energy := 100.0
var last_direction := Vector2.RIGHT
var game_time := 0.0
var is_night := false
var playing := false
var paused := false
var boss_defeated := false
var can_exit := false
var spawn_timer := 0.0
var message_timer := 0.0

var ui: CanvasLayer
var title_label: Label
var stats_label: Label
var objective_label: Label
var hud_panel: Panel
var message_panel: Panel
var message_label: Label
var touch_root: Control
var joystick
var skill_button: Button
var choice_panel: Panel
var menu_panel: Panel
var stage_panel: Panel
var stage_text: Label
var stage_button: Button
var stage_action := "intro"
var replay_button: Button
var gameover_panel: Panel
var win_panel: Panel
var help_panel: Panel
var progress_panel: Panel
var night_overlay: ColorRect
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var world_tint: CanvasModulate
var world_lights: Array[PointLight2D] = []
var splash_panel: Control
var menu_backdrop: TextureRect
var rubric_enemy_b: HoaActor
# Âm thanh / nhạc (SoundOn/Off · MusicOn/Off)
var sound_enabled := true
var music_enabled := true
var sound_btn: Button
var music_btn: Button
# Phòng thủ + vật phẩm X/Y/Z
var armor := 0.0
var gold := 0
var shield_active := false
var shield_timer := 0.0
var freeze_timer := 0.0
var world_pickups: Array = []
const RESTRICTED_RADIUS := 160.0
var _zone_warn_cd := 0.0
var _zone_warn_left := 0

func _ready() -> void:
	create_ui()
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -1
	add_child(music_player)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = 4
	add_child(sfx_player)
	world_tint = CanvasModulate.new()
	world_tint.color = Color.WHITE
	add_child(world_tint)
	music_player.stream = load("res://assets/music/village.ogg")
	music_player.play()
	show_splash_screen()
	queue_redraw()

func show_splash_screen() -> void:
	playing = false
	touch_root.hide()
	hud_panel.hide()
	title_label.hide()
	stats_label.hide()
	objective_label.hide()
	splash_panel = Control.new()
	splash_panel.name = "SplashScreen"
	splash_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(splash_panel)
	var panorama := TextureRect.new()
	panorama.texture = PANORAMA_TEXTURE
	panorama.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panorama.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panorama.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	splash_panel.add_child(panorama)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.035, 0.09, 0.42)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	splash_panel.add_child(shade)
	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.anchor_left = 0.5
	icon.anchor_right = 0.5
	icon.position = Vector2(-65, 54)
	icon.size = Vector2(130, 130)
	icon.texture = load("res://icon.svg")
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.clip_contents = true
	splash_panel.add_child(icon)
	var intro := make_label(Vector2(240, 200), Vector2(800, 120), 38, Color("a8f5ff"))
	intro.anchor_left = 0.5
	intro.anchor_right = 0.5
	intro.position.x = -400
	intro.text = "❀  GIẢI CỨU NGÔI LÀNG HOA  ❀\n✦ HÀNH TRÌNH ARIA ✦"
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	splash_panel.add_child(intro)
	var loading_frame := TextureRect.new()
	loading_frame.texture = load("res://assets/ui/loading_frame.svg")
	loading_frame.anchor_left = 0.5
	loading_frame.anchor_right = 0.5
	loading_frame.position = Vector2(-300, 445)
	loading_frame.size = Vector2(600, 42)
	loading_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	splash_panel.add_child(loading_frame)
	var progress := ProgressBar.new()
	progress.name = "LoadingBar"
	progress.anchor_left = 0.5
	progress.anchor_right = 0.5
	progress.position = Vector2(-291, 454)
	progress.size = Vector2(582, 24)
	progress.show_percentage = true
	progress.add_theme_font_size_override("font_size", 13)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("50e4ee")
	fill.set_corner_radius_all(12)
	progress.add_theme_stylebox_override("fill", fill)
	splash_panel.add_child(progress)
	var loading_text := make_label(Vector2(390, 505), Vector2(500, 30), 16, Color("e9efff"))
	loading_text.anchor_left = 0.5
	loading_text.anchor_right = 0.5
	loading_text.position.x = -250
	loading_text.text = "✦ Đang nạp thế giới Làng Hoa · âm thanh · chiến đấu... ✦"
	loading_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	splash_panel.add_child(loading_text)
	var tween := create_tween()
	tween.tween_property(progress, "value", 100.0, 1.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	if is_instance_valid(splash_panel):
		splash_panel.queue_free()
		splash_panel = null
	if not playing: show_main_menu()

func create_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	night_overlay = ColorRect.new()
	night_overlay.color = Color(0.04, 0.05, 0.18, 0.0)
	night_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	night_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(night_overlay)

	hud_panel = Panel.new()
	hud_panel.position = Vector2(14, 10)
	hud_panel.size = Vector2(540, 108)
	hud_panel.add_theme_stylebox_override("panel", panel_style(Color("0e1628f2"), Color("5ad4e8"), 16))
	ui.add_child(hud_panel)
	# Viền accent trên HUD
	var hud_bar := ColorRect.new()
	hud_bar.position = Vector2(0, 0)
	hud_bar.size = Vector2(540, 4)
	hud_bar.color = Color("5ad4e8")
	hud_panel.add_child(hud_bar)
	title_label = make_label(Vector2(16, 10), Vector2(508, 28), 20, Color("7ef0ff"))
	hud_panel.add_child(title_label)
	stats_label = make_label(Vector2(16, 40), Vector2(508, 62), 15, Color("eef6ff"))
	hud_panel.add_child(stats_label)

	objective_label = make_label(Vector2(600, 14), Vector2(660, 90), 17, Color("ffe28a"))
	objective_label.anchor_left = 1.0
	objective_label.anchor_right = 1.0
	objective_label.offset_left = -680
	objective_label.offset_right = -20
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ui.add_child(objective_label)

	message_panel = Panel.new()
	message_panel.position = Vector2(250, 540)
	message_panel.size = Vector2(780, 128)
	message_panel.anchor_left = 0.5
	message_panel.anchor_right = 0.5
	message_panel.anchor_top = 1.0
	message_panel.anchor_bottom = 1.0
	message_panel.offset_left = -390
	message_panel.offset_right = 390
	message_panel.offset_top = -180
	message_panel.offset_bottom = -52
	ui.add_child(message_panel)
	message_panel.add_theme_stylebox_override("panel", panel_style(Color("120c22f5"), Color("e0a0ff"), 20))
	message_label = make_label(Vector2(24, 17), Vector2(732, 94), 20, Color.WHITE)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_panel.add_child(message_label)
	message_panel.hide()

	create_touch_controls()
	create_choice_panel()
	create_stage_panel()
	create_gameover_panel()
	create_win_panel()
	create_help_panel()
	create_progress_panel()
	create_audio_toggle_buttons()

func create_stage_panel() -> void:
	stage_panel = Panel.new()
	stage_panel.anchor_left = 0.5
	stage_panel.anchor_right = 0.5
	stage_panel.anchor_top = 0.5
	stage_panel.anchor_bottom = 0.5
	stage_panel.offset_left = -395
	stage_panel.offset_right = 395
	stage_panel.offset_top = -228
	stage_panel.offset_bottom = 227
	stage_panel.add_theme_stylebox_override("panel", panel_style(Color("0e1628f8"), Color("ffd866"), 24))
	ui.add_child(stage_panel)
	stage_text = make_label(Vector2(45, 38), Vector2(700, 275), 21, Color.WHITE)
	stage_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stage_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_panel.add_child(stage_text)
	stage_button = make_button("BẮT ĐẦU MÀN", Vector2(245, 340), Vector2(300, 66), handle_stage_action)
	stage_panel.add_child(stage_button)
	stage_panel.hide()

func show_stage_intro() -> void:
	hide_all_modals()
	paused = true
	stage_action = "intro"
	stage_button.text = "BẮT ĐẦU MÀN"
	stage_text.text = "CẤP %d/3 — %s\n\n%s\n\nNHIỆM VỤ\n%s\n\nPHẦN THƯỞNG: %s" % [zone + 1, ZONES[zone].name, ZONES[zone].story, QUESTS[zone], ZONES[zone].reward]
	stage_panel.show()

func close_stage_intro() -> void:
	stage_panel.hide()
	paused = false
	play_sfx("res://assets/sfx/ui_click.ogg")

func handle_stage_action() -> void:
	if stage_action == "retry": start_zone()
	else: close_stage_intro()

func hide_all_modals() -> void:
	message_panel.hide()
	choice_panel.hide()
	stage_panel.hide()
	if is_instance_valid(gameover_panel): gameover_panel.hide()
	if is_instance_valid(win_panel): win_panel.hide()
	if is_instance_valid(help_panel): help_panel.hide()
	if is_instance_valid(progress_panel): progress_panel.hide()
	if is_instance_valid(replay_button): replay_button.hide()

# ---------- GAME OVER (≥3 nút: Replay / Home / Help) ----------
func create_gameover_panel() -> void:
	gameover_panel = Panel.new()
	gameover_panel.anchor_left = 0.5
	gameover_panel.anchor_right = 0.5
	gameover_panel.anchor_top = 0.5
	gameover_panel.anchor_bottom = 0.5
	gameover_panel.offset_left = -360
	gameover_panel.offset_right = 360
	gameover_panel.offset_top = -260
	gameover_panel.offset_bottom = 260
	gameover_panel.add_theme_stylebox_override("panel", panel_style(Color("1a0a14f8"), Color("ff6b8a"), 24))
	ui.add_child(gameover_panel)
	gameover_panel.hide()

func show_gameover_screen() -> void:
	hide_all_modals()
	save_game()  # Lưu tiến độ hiện tại trước khi hiện Game Over
	play_sfx("res://assets/sfx/game_over.ogg")
	for c in gameover_panel.get_children():
		c.queue_free()

	# Nền nhấn
	var accent := ColorRect.new()
	accent.position = Vector2(20, 18)
	accent.size = Vector2(680, 8)
	accent.color = Color("ff6b7a")
	gameover_panel.add_child(accent)

	var title := make_label(Vector2(40, 36), Vector2(640, 70), 28, Color("ff6b7a"))
	title.text = "☠  GAME OVER  ☠\nKai đã gục ngã — Làng Hoa vẫn chìm trong bóng tối..."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gameover_panel.add_child(title)

	# Thẻ tóm tắt nhanh
	var card := Panel.new()
	card.position = Vector2(70, 120)
	card.size = Vector2(580, 56)
	card.add_theme_stylebox_override("panel", panel_style(Color("2a1520ee"), Color("ff8a9a"), 12))
	gameover_panel.add_child(card)
	var info := make_label(Vector2(16, 10), Vector2(548, 40), 16, Color("ffe8ec"))
	info.text = "Cấp %d/3 · Lv.%d · Cứu %d người · ⚔ %d · 📜 %d bí kíp" % [
		zone + 1, level, rescued, weapon_unlocked, manuals
	]
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(info)

	# 4 nút: Replay / Stats / Home / Help
	gameover_panel.add_child(make_button("↻  REPLAY — thử lại cấp này", Vector2(140, 195), Vector2(440, 50), func():
		hide_all_modals()
		start_zone()))
	gameover_panel.add_child(make_button("📊  THỐNG SỐ & TIẾN ĐỘ", Vector2(140, 255), Vector2(440, 50), func():
		_show_stats_from_gameover()))
	gameover_panel.add_child(make_button("⌂  HOME SCREEN", Vector2(140, 315), Vector2(440, 50), _go_home_from_modal))
	gameover_panel.add_child(make_button("?  HELP / HƯỚNG DẪN", Vector2(140, 375), Vector2(440, 50), show_help_screen))
	gameover_panel.show()

# ---------- WIN (≥3 nút: Replay / Home / Progress) ----------
func create_win_panel() -> void:
	win_panel = Panel.new()
	win_panel.anchor_left = 0.5
	win_panel.anchor_right = 0.5
	win_panel.anchor_top = 0.5
	win_panel.anchor_bottom = 0.5
	win_panel.offset_left = -380
	win_panel.offset_right = 380
	win_panel.offset_top = -250
	win_panel.offset_bottom = 250
	win_panel.add_theme_stylebox_override("panel", panel_style(Color("0a1a14f8"), Color("7dffba"), 24))
	ui.add_child(win_panel)
	win_panel.hide()

func show_win_screen(ending_text: String) -> void:
	hide_all_modals()
	# Âm thanh WIN riêng (khác pickup/sword_hit trong combat)
	play_sfx("res://assets/sfx/win_fanfare.ogg")
	for c in win_panel.get_children():
		c.queue_free()
	var title := make_label(Vector2(40, 24), Vector2(680, 50), 28, Color("7dffba"))
	title.text = "★  CHIẾN THẮNG  ★\nLàng Hoa được giải cứu — bình minh trở lại!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_panel.add_child(title)
	var body := make_label(Vector2(40, 90), Vector2(680, 160), 16, Color.WHITE)
	body.text = ending_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_panel.add_child(body)
	win_panel.add_child(make_button("REPLAY (chơi lại từ đầu)", Vector2(180, 270), Vector2(400, 52), new_game))
	win_panel.add_child(make_button("HOME SCREEN", Vector2(180, 340), Vector2(400, 52), _go_home_from_modal))
	win_panel.add_child(make_button("HIGH ACHIEVEMENTS / TIẾN ĐỘ", Vector2(180, 410), Vector2(400, 52), show_progress_screen))
	win_panel.show()

# ---------- HELP ----------
func create_help_panel() -> void:
	help_panel = Panel.new()
	help_panel.anchor_left = 0.5
	help_panel.anchor_right = 0.5
	help_panel.anchor_top = 0.5
	help_panel.anchor_bottom = 0.5
	help_panel.offset_left = -420
	help_panel.offset_right = 420
	help_panel.offset_top = -290
	help_panel.offset_bottom = 290
	help_panel.add_theme_stylebox_override("panel", panel_style(Color("0e1628f8"), Color("f0c76a"), 24))
	ui.add_child(help_panel)
	help_panel.hide()

func show_help_screen() -> void:
	hide_all_modals()
	# Không bị Home che: ẩn menu + đưa Help lên trên cùng
	if is_instance_valid(menu_panel):
		menu_panel.hide()
	if is_instance_valid(menu_backdrop):
		menu_backdrop.modulate.a = 0.35
	play_sfx("res://assets/sfx/book_open.ogg")
	for c in help_panel.get_children():
		c.queue_free()

	var banner := ColorRect.new()
	banner.position = Vector2(24, 20)
	banner.size = Vector2(792, 72)
	banner.color = Color(0.15, 0.22, 0.18, 0.95)
	help_panel.add_child(banner)

	var story_title := make_label(Vector2(36, 28), Vector2(768, 56), 22, Color("ffe28a"))
	story_title.text = "❀  NHẬT KÝ KAI — NĂM 2147  ❀\nXuyên không về ngày Làng Hoa thất thủ"
	story_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_panel.add_child(story_title)

	var body := make_label(Vector2(36, 108), Vector2(768, 340), 15, Color("e8f0ff"))
	body.text = "CỐT TRUYỆN\nKỹ sư Kai từ tương lai mang chip Aria trở về quá khứ. Nhiệm vụ: tập hợp kháng chiến, mở nhà tù, đánh bại Zorath và cứu dân làng.\n\n◆ 3 CẤP ĐỘ\n  ① Đèo Samurai — Hạ 4 lính canh, mở 3 nhà tù, đi Cổng Đông\n  ② Rừng Ninja — Hạ 5 Ninja, mở nhà tù, lấy Phi Tiêu\n  ③ Nhà Tù Tinh Vân — Hạ Zorath, chọn Ending → WIN\n\n◆ ĐIỀU KHIỂN\n  Joystick / WASD  di chuyển     ĐÁNH / Space  tấn công\n  NÉ  lướt tránh đòn              F  mở nhà tù / tương tác\n  CHIÊU  kỹ năng / khiên         Esc  tạm dừng\n  SoundOff/On · MusicOff/On     (giữa mép trên khi chơi)\n\n◆ ĐỊCH THÔNG MINH\n  patrol · chase(+né) · ranged\n\nMục tiêu WIN: hoàn thành cả 3 cấp và chọn Ending."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_panel.add_child(body)

	help_panel.add_child(make_button("❀ BẮT ĐẦU HÀNH TRÌNH", Vector2(120, 470), Vector2(280, 50), new_game))
	help_panel.add_child(make_button("VỀ HOME", Vector2(440, 470), Vector2(280, 50), _go_home_from_modal))
	help_panel.show()
	help_panel.z_index = 100
	ui.move_child(help_panel, -1)

# ---------- PROGRESS / ACHIEVEMENTS ----------
func create_progress_panel() -> void:
	progress_panel = Panel.new()
	progress_panel.anchor_left = 0.5
	progress_panel.anchor_right = 0.5
	progress_panel.anchor_top = 0.5
	progress_panel.anchor_bottom = 0.5
	progress_panel.offset_left = -400
	progress_panel.offset_right = 400
	progress_panel.offset_top = -290
	progress_panel.offset_bottom = 290
	progress_panel.add_theme_stylebox_override("panel", panel_style(Color("10182cf8"), Color("f0c76a"), 22))
	ui.add_child(progress_panel)
	progress_panel.hide()

var _stats_back_to_gameover := false

func _show_stats_from_gameover() -> void:
	_stats_back_to_gameover = true
	show_progress_screen()

func show_progress_screen() -> void:
	hide_all_modals()
	play_sfx("res://assets/sfx/ui_click.ogg")
	for c in progress_panel.get_children():
		c.queue_free()

	# Header vàng
	var header := ColorRect.new()
	header.position = Vector2(24, 18)
	header.size = Vector2(752, 56)
	header.color = Color(0.18, 0.14, 0.08, 0.95)
	progress_panel.add_child(header)
	var title := make_label(Vector2(24, 26), Vector2(752, 40), 24, Color("ffe28a"))
	title.text = "✦  NHẬT KÝ HÀNH TRÌNH — THỐNG SỐ ĐÃ LƯU  ✦"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_panel.add_child(title)

	# Thẻ nhân vật
	var hero_name: String = str(HEROES[active_hero].name)
	var hero_role: String = str(HEROES[active_hero].role)
	var weapon_names := ["Kiếm cũ", "Katana", "Phi tiêu", "Súng Aria"]
	var wname: String = weapon_names[mini(weapon_mode, weapon_names.size() - 1)]

	var card1 := Panel.new()
	card1.position = Vector2(28, 90)
	card1.size = Vector2(360, 150)
	card1.add_theme_stylebox_override("panel", panel_style(Color("1a2840ee"), Color("55dcec"), 14))
	progress_panel.add_child(card1)
	var c1 := make_label(Vector2(16, 12), Vector2(328, 130), 15, Color("e8f4ff"))
	c1.text = "NHÂN VẬT\n%s — %s\nCấp: %d   XP: %d\nHP gốc + buff cấp\nVũ khí: %s (%d/%d)\nHero mở khóa: %d/5" % [
		hero_name, hero_role, level, xp, wname, weapon_mode + 1, weapon_unlocked, unlocked_heroes
	]
	card1.add_child(c1)

	# Thẻ nhiệm vụ / cứu hộ
	var card2 := Panel.new()
	card2.position = Vector2(412, 90)
	card2.size = Vector2(360, 150)
	card2.add_theme_stylebox_override("panel", panel_style(Color("1a3040ee"), Color("7dffba"), 14))
	progress_panel.add_child(card2)
	var c2 := make_label(Vector2(16, 12), Vector2(328, 130), 15, Color("e8fff4"))
	c2.text = "NHIỆM VỤ & CỨU HỘ\nBản đồ: %s\nCấp chơi: %d / 3\nNgười đã cứu: %d\nMảnh công nghệ: %d\nBí kíp: %d\nVật liệu: %d" % [
		ZONES[zone].name, zone + 1, rescued, tech_fragments, manuals, materials
	]
	card2.add_child(c2)

	# 3 ô trạng thái cấp độ
	var zone_y := 260.0
	for i in range(ZONES.size()):
		var done := i < zone or (i == zone and can_exit) or (i == FINAL_ZONE and boss_defeated)
		var current := (i == zone and not done)
		var zcard := Panel.new()
		zcard.position = Vector2(28 + i * 255, zone_y)
		zcard.size = Vector2(240, 100)
		var border := Color("7dffba") if done else (Color("ffe28a") if current else Color("556688"))
		var bg := Color("143028ee") if done else (Color("2a2410ee") if current else Color("151a28ee"))
		zcard.add_theme_stylebox_override("panel", panel_style(bg, border, 12))
		progress_panel.add_child(zcard)
		var status := "✓ HOÀN THÀNH" if done else ("▶ ĐANG CHƠI" if current else "○ CHƯA MỞ")
		var zl := make_label(Vector2(12, 12), Vector2(216, 80), 14, Color.WHITE)
		zl.text = "Cấp %d\n%s\n%s" % [i + 1, ZONES[i].name, status]
		zl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		zcard.add_child(zl)

	var foot := make_label(Vector2(28, 380), Vector2(744, 40), 13, Color("c8d0e8"))
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_panel.add_child(foot)

	if _stats_back_to_gameover:
		progress_panel.add_child(make_button("← QUAY LẠI GAME OVER", Vector2(120, 430), Vector2(280, 48), func():
			_stats_back_to_gameover = false
			show_gameover_screen()))
		progress_panel.add_child(make_button("⌂  VỀ HOME", Vector2(420, 430), Vector2(280, 48), func():
			_stats_back_to_gameover = false
			_go_home_from_modal()))
	else:
		progress_panel.add_child(make_button("⌂  VỀ HOME", Vector2(250, 430), Vector2(300, 48), _go_home_from_modal))
	progress_panel.show()

func _go_home_from_modal() -> void:
	hide_all_modals()
	playing = false
	paused = false
	clear_world()
	touch_root.hide()
	hud_panel.hide()
	title_label.hide()
	stats_label.hide()
	objective_label.hide()
	_set_audio_buttons_visible(false)
	show_main_menu()


func make_label(pos: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func panel_style(bg: Color, border: Color, radius_value: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(radius_value)
	style.shadow_color = Color(border.r, border.g, border.b, 0.35)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 3)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func make_button(text_value: String, pos: Vector2, size: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = pos
	button.size = size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color("f5fbff"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("ffe28a"))
	button.add_theme_stylebox_override("normal", panel_style(Color("1a2a48f0"), Color("5ad4e8"), 14))
	button.add_theme_stylebox_override("hover", panel_style(Color("2a4570f5"), Color("a8f5ff"), 14))
	button.add_theme_stylebox_override("pressed", panel_style(Color("3d2460f5"), Color("ffd866"), 14))
	button.pressed.connect(func():
		play_sfx("res://assets/sfx/ui_click.ogg")
		callback.call())
	return button

func create_touch_controls() -> void:
	touch_root = Control.new()
	touch_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(touch_root)
	joystick = Joystick.new()
	joystick.anchor_top = 1.0
	joystick.anchor_bottom = 1.0
	joystick.offset_left = 18
	joystick.offset_right = 278
	joystick.offset_top = -278
	joystick.offset_bottom = -18
	touch_root.add_child(joystick)
	var controls := [
		["ĐÁNH", Vector2(1150, 592), Vector2(110, 110), "attack"],
		["CHIÊU", Vector2(1042, 484), Vector2(94, 94), "skill"],
		["VŨ KHÍ", Vector2(1048, 620), Vector2(82, 82), "switch_weapon"],
		["NÉ", Vector2(946, 610), Vector2(88, 88), "dodge"],
		["ĐỔI", Vector2(1158, 480), Vector2(84, 84), "switch_hero"],
		["TƯƠNG TÁC", Vector2(944, 506), Vector2(80, 80), "interact"]
	]
	for entry in controls:
		var b := TouchButton.new()
		b.name = "Action_%s" % String(entry[3])
		b.text = entry[0]
		b.focus_mode = Control.FOCUS_NONE
		b.clip_contents = true
		b.anchor_left = 1.0
		b.anchor_right = 1.0
		b.anchor_top = 1.0
		b.anchor_bottom = 1.0
		b.offset_left = entry[1].x - 1280
		b.offset_right = b.offset_left + entry[2].x
		b.offset_top = entry[1].y - 720
		b.offset_bottom = b.offset_top + entry[2].y
		b.modulate = Color(1, 1, 1, 0.90)
		b.add_theme_font_size_override("font_size", 14)
		var action_name := String(entry[3])
		var circle_radius := int(minf(b.size.x, b.size.y) * 0.5)
		var action_colors := {"attack":Color("a93646"), "skill":Color("6c3fa0"), "switch_weapon":Color("a87525"), "dodge":Color("247ca0"), "switch_hero":Color("328065"), "interact":Color("48556c")}
		var base_color: Color = action_colors[action_name]
		b.add_theme_stylebox_override("normal", panel_style(Color(base_color, 0.94), base_color.lightened(0.45), circle_radius))
		b.add_theme_stylebox_override("hover", panel_style(Color("385d83f2"), Color.WHITE, circle_radius))
		b.add_theme_stylebox_override("pressed", panel_style(Color("692e81f2"), Color("ff9df2"), circle_radius))
		if action_name == "skill": skill_button = b
		var icon_paths := {"attack":"res://assets/items/sword.png", "skill":"res://assets/tiles/flowers_animated.png", "switch_hero":"res://assets/ui/icon_switch.svg", "switch_weapon":"res://assets/items/shuriken.svg", "dodge":"res://assets/ui/icon_switch.svg", "interact":"res://assets/ui/icon_interact.svg"}
		if icon_paths.has(action_name):
			var button_size: Vector2 = entry[2]
			var icon_side := minf(48.0, minf(button_size.x, button_size.y) * 0.48)
			var icon := TextureRect.new()
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.position = Vector2((button_size.x - icon_side) * 0.5, maxf(5.0, button_size.y * 0.10))
			icon.size = Vector2(icon_side, icon_side)
			if action_name == "skill":
				var flower_icon := AtlasTexture.new()
				flower_icon.atlas = FLOWER_TEXTURE
				flower_icon.region = Rect2(0, 0, 16, 16)
				icon.texture = flower_icon
			else:
				icon.texture = load(icon_paths[action_name])
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			b.add_child(icon)
			var caption := Label.new()
			caption.text = b.text
			caption.position = Vector2(2, button_size.y - 25)
			caption.size = Vector2(button_size.x - 4, 21)
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			caption.add_theme_font_size_override("font_size", 12)
			caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
			b.add_child(caption)
			b.text = ""
		b.button_down.connect(_touch_button_down.bind(action_name, b))
		b.button_up.connect(_touch_button_up.bind(action_name, b))
		touch_root.add_child(b)
	touch_root.hide()

func _touch_down(action_name: String) -> void:
	Input.action_press(action_name)

func _touch_up(action_name: String) -> void:
	Input.action_release(action_name)

func _touch_button_down(action_name: String, button: Button) -> void:
	_touch_down(action_name)
	button.pivot_offset = button.size * 0.5
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.86, 0.86), 0.06)
	play_sfx("res://assets/sfx/ui_click.ogg")

func _touch_button_up(action_name: String, button: Button) -> void:
	_touch_up(action_name)
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)

func clear_touch_actions() -> void:
	for action_name in ["attack", "skill", "switch_weapon", "dodge", "switch_hero", "interact"]:
		Input.action_release(action_name)
	if is_instance_valid(joystick):
		joystick.active_touch = -1
		joystick.reset()
	if is_instance_valid(touch_root):
		for child in touch_root.get_children():
			if child.has_method("cancel_touch"):
				child.cancel_touch()

func create_choice_panel() -> void:
	choice_panel = Panel.new()
	choice_panel.anchor_left = 0.5
	choice_panel.anchor_right = 0.5
	choice_panel.anchor_top = 0.5
	choice_panel.anchor_bottom = 0.5
	choice_panel.offset_left = -380
	choice_panel.offset_right = 380
	choice_panel.offset_top = -200
	choice_panel.offset_bottom = 200
	ui.add_child(choice_panel)
	choice_panel.add_theme_stylebox_override("panel", panel_style(Color("16152af5"), Color("d45bff"), 22))
	var heading := make_label(Vector2(35, 30), Vector2(690, 90), 27, Color("eb8cff"))
	heading.text = "ZORATH ĐÃ BỊ ĐÁNH BẠI\nBạn sẽ định đoạt số phận Vera thế nào?"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	choice_panel.add_child(heading)
	choice_panel.add_child(make_button("TIÊU DIỆT VERA", Vector2(85, 155), Vector2(270, 65), func(): finish_game(0)))
	choice_panel.add_child(make_button("MỞ CỔNG ĐƯA HỌ VỀ", Vector2(405, 155), Vector2(270, 65), func(): finish_game(1)))
	choice_panel.add_child(make_button("DÙNG CHIP ARIA ĐÀM PHÁN", Vector2(185, 255), Vector2(390, 65), func(): finish_game(2)))
	choice_panel.hide()

func show_main_menu() -> void:
	playing = false
	paused = false
	touch_root.hide()
	clear_touch_actions()
	hud_panel.hide()
	title_label.hide()
	stats_label.hide()
	objective_label.hide()
	_set_audio_buttons_visible(false)
	hide_all_modals()
	if is_instance_valid(menu_panel):
		menu_panel.queue_free()
	if is_instance_valid(menu_backdrop):
		menu_backdrop.queue_free()

	menu_backdrop = TextureRect.new()
	menu_backdrop.texture = PANORAMA_TEXTURE
	menu_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	menu_backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	menu_backdrop.modulate = Color(0.72, 0.78, 0.92, 1.0)
	ui.add_child(menu_backdrop)
	ui.move_child(menu_backdrop, 1)

	menu_panel = Panel.new()
	menu_panel.anchor_left = 0.5
	menu_panel.anchor_right = 0.5
	menu_panel.anchor_top = 0.5
	menu_panel.anchor_bottom = 0.5
	menu_panel.offset_left = -380
	menu_panel.offset_right = 380
	menu_panel.offset_top = -300
	menu_panel.offset_bottom = 300
	ui.add_child(menu_panel)
	menu_panel.add_theme_stylebox_override("panel", panel_style(Color("0c1428f5"), Color("5ad4e8"), 28))

	var logo := make_label(Vector2(40, 16), Vector2(680, 90), 34, Color("7ef0ff"))
	logo.text = "❀  GIẢI CỨU\nNGÔI LÀNG HOA  ❀"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_panel.add_child(logo)
	# Hoa văn trang trí dưới logo
	var ornament := TextureRect.new()
	ornament.texture = load("res://assets/ui/menu_ornament.svg") if ResourceLoader.exists("res://assets/ui/menu_ornament.svg") else null
	ornament.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ornament.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ornament.position = Vector2(220, 100)
	ornament.size = Vector2(320, 24)
	if ornament.texture:
		menu_panel.add_child(ornament)

	var sub := make_label(Vector2(50, 120), Vector2(660, 56), 15, Color("d8d9ff"))
	sub.text = "Năm 2147 — Kỹ sư Kai xuyên không về ngày Làng Hoa thất thủ.\nTập hợp kháng chiến  ·  Tìm bí kíp  ·  Giải phóng dân làng."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_panel.add_child(sub)

	var route := make_label(Vector2(50, 185), Vector2(660, 28), 14, Color("ffe28a"))
	route.text = "⚔ Đèo Samurai  →  🥷 Rừng Ninja  →  🌌 Nhà Tù Tinh Vân  →  ★ WIN"
	route.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_panel.add_child(route)

	# Tóm tắt save nhanh trên Home
	var save_summary := _read_save_summary()
	var summary_card := Panel.new()
	summary_card.position = Vector2(90, 220)
	summary_card.size = Vector2(580, 48)
	summary_card.add_theme_stylebox_override("panel", panel_style(Color("1a2840ee"), Color("55dcec"), 12))
	menu_panel.add_child(summary_card)
	var sum_lbl := make_label(Vector2(12, 8), Vector2(556, 36), 14, Color("c8e8ff"))
	sum_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if save_summary.is_empty():
		sum_lbl.text = "Chưa có dữ liệu lưu — hãy bắt đầu hành trình mới"
	else:
		sum_lbl.text = "Đã lưu: Cấp %d/3 · Lv.%d · Cứu %d người · Màn cao nhất: %s" % [
			int(save_summary.get("zone", 0)) + 1,
			int(save_summary.get("level", 1)),
			int(save_summary.get("rescued", 0)),
			ZONES[clampi(int(save_summary.get("zone", 0)), 0, FINAL_ZONE)].name
		]
	summary_card.add_child(sum_lbl)

	var start_btn := make_button("▶  BẮT ĐẦU HÀNH TRÌNH", Vector2(180, 290), Vector2(400, 54), new_game)
	start_btn.add_theme_stylebox_override("normal", panel_style(Color("1a3040f5"), Color("ffe28a"), 16))
	start_btn.add_theme_stylebox_override("hover", panel_style(Color("2a5060f5"), Color("fff0a8"), 16))
	menu_panel.add_child(start_btn)
	var continue_button := make_button("↻  TIẾP TỤC (save)", Vector2(180, 350), Vector2(400, 48), load_game)
	continue_button.disabled = not FileAccess.file_exists(SAVE_PATH)
	menu_panel.add_child(continue_button)
	# Nút mở trang màn đã chơi
	menu_panel.add_child(make_button("🗺  MÀN ĐÃ CHƠI / CHỌN CẤP", Vector2(180, 408), Vector2(400, 48), show_chapter_select))
	menu_panel.add_child(make_button("THOÁT", Vector2(255, 470), Vector2(250, 48), func(): get_tree().quit()))


## Đọc tóm tắt file save (không start game)
func _read_save_summary() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary:
		return data
	return {}


## Màn hình chọn cấp — hiển thị màn đã chơi / đã mở khóa
func show_chapter_select() -> void:
	hide_all_modals()
	play_sfx("res://assets/sfx/book_open.ogg")
	if is_instance_valid(menu_panel):
		menu_panel.hide()

	# Dùng progress_panel làm khung chọn cấp
	for c in progress_panel.get_children():
		c.queue_free()
	progress_panel.offset_left = -420
	progress_panel.offset_right = 420
	progress_panel.offset_top = -300
	progress_panel.offset_bottom = 300
	progress_panel.add_theme_stylebox_override("panel", panel_style(Color("0e1628f8"), Color("52e4ee"), 24))

	var header := ColorRect.new()
	header.position = Vector2(24, 18)
	header.size = Vector2(792, 58)
	header.color = Color(0.08, 0.16, 0.22, 0.95)
	progress_panel.add_child(header)
	var title := make_label(Vector2(24, 26), Vector2(792, 42), 24, Color("72ecff"))
	title.text = "🗺  BẢN ĐỒ HÀNH TRÌNH — MÀN ĐÃ CHƠI"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_panel.add_child(title)

	var save_data := _read_save_summary()
	var max_zone: int = 0
	if not save_data.is_empty():
		max_zone = clampi(int(save_data.get("zone", 0)), 0, FINAL_ZONE)
		# Nếu đã can_exit ở cấp đó coi như đã mở cấp kế
		if bool(save_data.get("can_exit", false)) and max_zone < FINAL_ZONE:
			max_zone = mini(max_zone + 1, FINAL_ZONE)
		if bool(save_data.get("boss_defeated", false)):
			max_zone = FINAL_ZONE

	var desc := make_label(Vector2(40, 88), Vector2(760, 36), 14, Color("c8d8f0"))
	if save_data.is_empty():
		desc.text = "Chưa có save. Chỉ Cấp 1 mở. Chơi và hoàn thành cấp để mở khóa màn tiếp theo."
	else:
		desc.text = "Save: Lv.%d · Cứu %d · Bí kíp %d · Bấm màn đã mở để chơi lại / tiếp tục." % [
			int(save_data.get("level", 1)), int(save_data.get("rescued", 0)), int(save_data.get("manuals", 0))
		]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_panel.add_child(desc)

	var accents := [Color("c98552"), Color("68a67d"), Color("ed4cff")]
	var icons := ["⚔", "🥷", "🌌"]
	for i in range(ZONES.size()):
		var unlocked: bool = (i <= max_zone) or (i == 0)
		var completed: bool = i < max_zone or (i == FINAL_ZONE and bool(save_data.get("boss_defeated", false)))
		var card := Panel.new()
		card.position = Vector2(40, 140 + i * 115)
		card.size = Vector2(760, 100)
		var border: Color = accents[i]
		var bg := Color(0.12, 0.18, 0.14, 0.95) if completed else (Color(0.12, 0.16, 0.24, 0.95) if unlocked else Color(0.08, 0.08, 0.12, 0.9))
		if not unlocked:
			border = Color("445566")
		card.add_theme_stylebox_override("panel", panel_style(bg, border, 16))
		progress_panel.add_child(card)

		var status: String
		if completed:
			status = "✓ ĐÃ HOÀN THÀNH"
		elif unlocked:
			status = "▶ ĐÃ MỞ — bấm để chơi"
		else:
			status = "🔒 CHƯA MỞ KHÓA"

		var info := make_label(Vector2(20, 14), Vector2(500, 72), 16, Color.WHITE if unlocked else Color("8899aa"))
		info.text = "%s  CẤP %d — %s\n%s\n%s" % [icons[i], i + 1, ZONES[i].name, ZONES[i].reward, status]
		card.add_child(info)

		if unlocked:
			var zi := i
			var btn := make_button("CHƠI", Vector2(560, 26), Vector2(170, 48), func(): _start_from_chapter(zi))
			card.add_child(btn)
		else:
			var lock := make_label(Vector2(560, 30), Vector2(170, 40), 18, Color("667788"))
			lock.text = "🔒"
			lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			card.add_child(lock)

	progress_panel.add_child(make_button("← VỀ HOME", Vector2(270, 500), Vector2(300, 48), func():
		progress_panel.hide()
		show_main_menu()))
	progress_panel.show()


func _start_from_chapter(target_zone: int) -> void:
	# Load save nếu có, rồi nhảy tới cấp đã chọn (đã mở khóa)
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data is Dictionary:
				active_hero = int(data.get("hero", 0))
				unlocked_heroes = int(data.get("unlocked", 2))
				rescued = int(data.get("rescued", 0))
				materials = int(data.get("materials", 0))
				tech_fragments = int(data.get("tech", 0))
				level = int(data.get("level", 1))
				xp = int(data.get("xp", 0))
				damage_bonus = float(data.get("bonus", 0))
				weapon_unlocked = int(data.get("weapons", 1))
				weapon_mode = mini(int(data.get("weapon_mode", 0)), maxi(weapon_unlocked - 1, 0))
				manuals = int(data.get("manuals", 0))
	else:
		# Không save: chỉ cho cấp 1
		if target_zone > 0:
			show_message("Hãy hoàn thành cấp trước để mở khóa!", 2.0)
			return
		level = 1
		xp = 0
		weapon_unlocked = 1
		weapon_mode = 0
		manuals = 0
		rescued = target_zone * 3
	zone = clampi(target_zone, 0, FINAL_ZONE)
	can_exit = false
	boss_defeated = false
	if is_instance_valid(menu_backdrop):
		menu_backdrop.queue_free()
	if is_instance_valid(menu_panel):
		menu_panel.hide()
	progress_panel.hide()
	hide_all_modals()
	start_zone()

func new_game() -> void:
	if is_instance_valid(splash_panel): splash_panel.queue_free()
	if is_instance_valid(menu_backdrop): menu_backdrop.queue_free()
	if is_instance_valid(replay_button): replay_button.queue_free()
	message_panel.position = Vector2(250, 540)
	message_panel.size = Vector2(780, 128)
	message_label.size = Vector2(732, 94)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	message_panel.hide()
	zone = 0
	active_hero = 0
	unlocked_heroes = 2
	rescued = 0
	materials = 0
	tech_fragments = 0
	level = 1
	xp = 0
	damage_bonus = 0
	weapon_unlocked = 1
	weapon_mode = 0
	manuals = 0
	game_time = 0
	start_zone()

func start_zone() -> void:
	clear_world()
	playing = true
	paused = false
	boss_defeated = false
	zone_kills = 0
	rescued_in_zone = 0
	prisons_opened = [false, false, false]
	rescued = zone * 3
	can_exit = false
	energy = 100
	if is_instance_valid(menu_panel): menu_panel.queue_free()
	if is_instance_valid(menu_backdrop): menu_backdrop.queue_free()
	choice_panel.hide()
	touch_root.show()
	hud_panel.show()
	title_label.show()
	stats_label.show()
	objective_label.show()
	# A xuất hiện chính giữa biên trái; B đối diện chính giữa biên phải.
	spawn_player(Vector2(35, WORLD_SIZE.y * 0.5))
	create_zone_lights()
	if zone == FINAL_ZONE:
		spawn_enemy(Vector2(WORLD_SIZE.x - 35, WORLD_SIZE.y * 0.5), true, true)
	else:
		spawn_enemy(Vector2(WORLD_SIZE.x - 35, WORLD_SIZE.y * 0.5), false, true)
		for i in range(mini(2, int(ZONES[zone].goal) - 2)):
			spawn_enemy(random_spawn(), false)
	play_zone_music()
	_spawn_world_pickups()
	_set_audio_buttons_visible(true)
	_refresh_audio_button_labels()
	update_ui()
	show_stage_intro()
	save_game()
	queue_redraw()

func clear_world() -> void:
	for child in get_children():
		if child != ui and child != music_player and child != sfx_player and child != world_tint:
			child.queue_free()
	enemies.clear()
	world_lights.clear()
	world_pickups.clear()
	rubric_enemy_b = null
	player = null

func create_zone_lights() -> void:
	var light_color := Color("ffd27a") if zone < 2 else Color("62e9ff")
	if zone >= FINAL_ZONE: light_color = Color("cf6cff")
	for i in range(6):
		var light := PointLight2D.new()
		var gradient := Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 0.95))
		gradient.set_color(1, Color(1, 1, 1, 0.0))
		var texture := GradientTexture2D.new()
		texture.width = 256
		texture.height = 256
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.gradient = gradient
		light.texture = texture
		light.color = light_color
		light.energy = 0.75
		light.texture_scale = 2.0
		light.position = Vector2(270 + i * 225, 225 + (i % 2) * 350)
		world_lights.append(light)
		add_child(light)

func spawn_player(at: Vector2) -> void:
	var data: Dictionary = HEROES[active_hero]
	player = Actor.new()
	player.setup(data.name, data.role, data.color, data.hp + level * 5, data.speed, data.damage + damage_bonus)
	player.position = at
	player.died.connect(_on_player_died)
	add_child(player)
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(WORLD_SIZE.x)
	camera.limit_bottom = int(WORLD_SIZE.y)
	player.add_child(camera)
	player.equip_weapon(weapon_mode, last_direction)

func spawn_enemy(at: Vector2, elite := false, is_rubric_b := false) -> void:
	if not playing or zone_kills >= int(ZONES[zone].goal): return
	var enemy := Actor.new()
	var hp_value := 45.0 + zone * 16.0 + level * 4.0
	var normal_names := ["Samurai Ronin", "Ninja Bóng", "Zorath"]
	var boss_names := ["Tướng Goro", "Ninja Kage", "Zorath"]
	var enemy_name: String = boss_names[zone] if elite or zone == FINAL_ZONE else normal_names[zone]
	if elite: hp_value *= 2.4
	if zone == FINAL_ZONE: hp_value = 520.0 + level * 25.0
	enemy.setup(enemy_name, "Địch", Color("9b55dd") if zone != 4 else Color("f04c9b"), hp_value, 105.0 + zone * 10, 9.0 + zone * 3, true)
	enemy.elite = elite or zone == FINAL_ZONE
	enemy.radius = 25.0 if enemy.elite else 18.0
	if is_instance_valid(enemy.visual): enemy.visual.scale = Vector2(4.2, 4.2) if enemy.elite else Vector2(3.0, 3.0)
	enemy.wrap_on_left = is_rubric_b
	if is_rubric_b: rubric_enemy_b = enemy
	# Gán 3 loại AI thông minh luân phiên theo số quái đã spawn
	var ai_types := ["patrol", "chase", "ranged"]
	enemy.ai_type = ai_types[enemies.size() % 3]
	if elite or zone == FINAL_ZONE:
		enemy.ai_type = "chase"
	enemy.target = player
	enemy.position = at
	enemy.patrol_origin = at
	enemy.died.connect(_on_enemy_died)
	enemies.append(enemy)
	add_child(enemy)

func random_spawn() -> Vector2:
	var prison: Vector2 = PRISON_POSITIONS[randi() % PRISON_POSITIONS.size()]
	return prison + Vector2(randf_range(-105, 105), randf_range(-80, 80))

func _physics_process(delta: float) -> void:
	if not playing or paused or not is_instance_valid(player): return
	game_time += delta
	is_night = fmod(game_time, 100.0) > 58.0
	night_overlay.color.a = move_toward(night_overlay.color.a, 0.10 if is_night else 0.0, delta * 0.2)
	world_tint.color = world_tint.color.lerp(Color("56638a") if is_night else Color.WHITE, delta * 0.45)
	for light in world_lights:
		if is_instance_valid(light): light.energy = move_toward(light.energy, 1.35 if is_night else 0.48, delta)
	energy = minf(100.0, energy + delta * 9.0)
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if is_instance_valid(joystick) and joystick.output.length() > 0.05: direction = joystick.output
	if direction.length() > 0.1:
		last_direction = direction.normalized()
	player.velocity = direction * player.speed * get_terrain_speed()
	player.move_and_slide()
	player.position = player.position.clamp(Vector2(35, 125), WORLD_SIZE - Vector2(35, 35))
	# Nút hành động có touch index riêng, nên có thể đánh trong khi vẫn giữ joystick.
	if Input.is_action_just_pressed("attack"): attack()
	if Input.is_action_just_pressed("skill"): use_skill()
	if Input.is_action_just_pressed("switch_hero"): switch_hero()
	if Input.is_action_just_pressed("switch_weapon"): switch_weapon()
	if Input.is_action_just_pressed("dodge"): dodge()
	if Input.is_action_just_pressed("interact"): interact()
	if Input.is_action_just_pressed("pause_game"): toggle_pause()
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy):
			enemies.erase(enemy)
			continue
		enemy.target = player
		wrap_enemy_if_needed(enemy)
		if is_night:
			enemy.speed = 125.0 + zone * 12.0
		var dist_p: float = enemy.global_position.distance_to(player.global_position)
		# Ranged NPC: bắn khi trong tầm và shoot_cd vừa reset về sẵn sàng
		if enemy.ai_type == "ranged" and enemy.alerted and dist_p >= 140.0 and dist_p <= 300.0 and enemy.shoot_cd >= 1.55:
			shoot_enemy(enemy.position, enemy.position.direction_to(player.position), enemy.damage * 0.7)
			enemy.attack_cooldown = 1.6
		elif enemy.alerted and dist_p < 50.0 and enemy.attack_cooldown <= 0.0:
			_apply_damage_to_player(enemy.damage * (1.25 if is_night else 1.0))
			enemy.attack_cooldown = 0.85
		elif enemy.alerted and zone >= 1 and dist_p < 380.0 and enemy.attack_cooldown <= 0.0 and enemy.ai_type != "ranged":
			enemy_special_attack(enemy)
	spawn_timer -= delta
	if zone < FINAL_ZONE and not can_exit and enemies.size() < 4 and zone_kills < int(ZONES[zone].goal) and spawn_timer <= 0:
		spawn_enemy(random_spawn(), zone_kills == int(ZONES[zone].goal) - 1)
		spawn_timer = 2.0
	if can_exit and player.position.x > 1370:
		advance_zone()
	# Vùng cấm quanh A: NPC B vào → cảnh báo 3–6 tiếng
	_update_restricted_zone_warning(delta)
	_update_pickups()
	shield_timer = maxf(0.0, shield_timer - delta)
	freeze_timer = maxf(0.0, freeze_timer - delta)
	if shield_timer <= 0.0:
		shield_active = false
	_zone_warn_cd = maxf(0.0, _zone_warn_cd - delta)
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0: message_panel.hide()
	update_ui()
	queue_redraw()


func _update_restricted_zone_warning(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var any_inside := false
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(player.global_position) <= RESTRICTED_RADIUS:
			any_inside = true
			break
	if any_inside and _zone_warn_left <= 0 and _zone_warn_cd <= 0.0:
		_zone_warn_left = randi_range(3, 6)
		_zone_warn_cd = 0.35
	if _zone_warn_left > 0 and _zone_warn_cd <= 0.0:
		play_sfx("res://assets/sfx/hit.ogg")
		_zone_warn_left -= 1
		_zone_warn_cd = 0.28
		if _zone_warn_left == 0:
			_zone_warn_cd = 2.5  # nghỉ giữa các đợt cảnh báo

func wrap_enemy_if_needed(enemy: HoaActor) -> void:
	if not is_instance_valid(enemy) or not enemy.wrap_on_left or enemy.position.x > 20.0: return
	enemy.position = Vector2(WORLD_SIZE.x - 35.0, randf_range(145.0, WORLD_SIZE.y - 45.0))
	enemy.patrol_origin = enemy.position
	enemy.alerted = false

func get_terrain_speed() -> float:
	if zone == 1:
		var in_river := player.position.x > 590 and player.position.x < 845
		var on_bridge := player.position.y > 350 and player.position.y < 475
		if in_river and not on_bridge: return 0.48
	elif zone == 2:
		if player.position.y < 235: return 0.62
		if player.position.y > 650: return 0.72
	elif zone == 3 and last_direction.x < 0:
		return 0.72
	return 1.0

func attack() -> void:
	if player.attack_cooldown > 0: return
	player.attack_cooldown = 0.32
	var data: Dictionary = HEROES[active_hero]
	player.animate_weapon_attack(weapon_mode, last_direction)
	if weapon_mode <= 1:
		spawn_combat_vfx(player.position + last_direction * 35, 0, data.color)
		play_sfx("res://assets/sfx/sword_hit.ogg")
		for enemy in enemies:
			if is_instance_valid(enemy) and enemy.position.distance_to(player.position) < 82:
				enemy.take_damage(player.damage)
	else:
		spawn_combat_vfx(player.position + last_direction * 28, 1, data.color, 0.25)
		play_sfx("res://assets/sfx/shuriken.ogg")
		shoot(last_direction, player.damage * (0.78 if weapon_mode == 2 else 1.2), data.color)

## Phòng thủ 1: Né
func dodge() -> void:
	if dodge_cooldown > 0.0 or not is_instance_valid(player):
		return
	dodge_cooldown = 1.15
	player.invulnerable = 0.42
	player.position += last_direction * 115
	player.position = player.position.clamp(Vector2(35, 125), WORLD_SIZE - Vector2(35, 35))
	spawn_combat_vfx(player.position, 3, Color("a8f5ff"), 0.38)
	play_sfx("res://assets/sfx/ui_click.ogg")
	show_message("NÉ THÀNH CÔNG!", 1.0)


## Phòng thủ 2: Khiên năng lượng (chặn sát thương 4s)
func activate_shield() -> void:
	if not is_instance_valid(player) or shield_active:
		return
	if energy < 25:
		show_message("Cần 25 ⚡ để dựng khiên!", 1.5)
		return
	energy -= 25
	shield_active = true
	shield_timer = 4.0
	player.invulnerable = maxf(player.invulnerable, 0.3)
	spawn_combat_vfx(player.position, 3, Color("7dffba"), 0.6)
	play_sfx("res://assets/sfx/book_open.ogg")
	show_message("KHIÊN NĂNG LƯỢNG (4 giây)!", 1.8)

func switch_weapon() -> void:
	if weapon_unlocked <= 1:
		show_message("Bạn chưa tìm thấy vũ khí tầm xa. Hãy cứu các tù nhân đầu tiên.", 2.2)
		return
	weapon_mode = (weapon_mode + 1) % weapon_unlocked
	player.equip_weapon(weapon_mode, last_direction)
	play_sfx("res://assets/sfx/draw_weapon.ogg")
	var weapon_names := ["Kiếm Cũ", "Katana Hoa Thép", "Phi Tiêu Gió", "Súng Năng Lượng Aria"]
	show_message("Đã trang bị: %s" % weapon_names[weapon_mode], 1.8)

func shoot(dir: Vector2, amount: float, color: Color) -> void:
	var shot := Projectile.new()
	shot.setup(dir, amount, true, color, weapon_mode)
	shot.position = player.position + dir * 28
	add_child(shot)

func shoot_enemy(at: Vector2, dir: Vector2, amount: float) -> void:
	var shot := Projectile.new()
	shot.setup(dir, amount, false, Color("ff5bd7"), 2)
	shot.speed = 360 if zone < FINAL_ZONE else 470
	shot.position = at + dir * 28
	add_child(shot)

func enemy_special_attack(enemy: HoaActor) -> void:
	var aim := enemy.position.direction_to(player.position)
	if zone == 1:
		# Ninja: phi tiêu tỏa ba hướng.
		for angle in [-0.20, 0.0, 0.20]: shoot_enemy(enemy.position, aim.rotated(angle), enemy.damage * 0.65)
		enemy.attack_cooldown = 2.0
	elif zone == 2:
		# Linh thú: báo hiệu rồi lao thẳng, có thể né bằng nút NÉ.
		spawn_combat_vfx(enemy.position, 2, Color("70ffc4"), 0.45)
		enemy.position += aim * 125
		if enemy.position.distance_to(player.position) < 75: player.take_damage(enemy.damage * 1.4)
		enemy.attack_cooldown = 2.4
	elif zone == 3:
		# Titan: đạn chùm kèm vòng cảnh báo vùng nổ.
		spawn_combat_vfx(player.position, 2, Color("ff984f"), 0.65)
		for angle in [-0.32, 0.0, 0.32]: shoot_enemy(enemy.position, aim.rotated(angle), enemy.damage * 0.8)
		enemy.attack_cooldown = 1.75
	else:
		# Zorath: barrage năm hướng luân phiên.
		for i in range(5): shoot_enemy(enemy.position, aim.rotated((i - 2) * 0.24), enemy.damage * 0.72)
		spawn_combat_vfx(enemy.position, 5, Color("f25cff"), 0.7)
		enemy.attack_cooldown = 1.1

func use_skill() -> void:
	# Ưu tiên khiên nếu chưa bật và đủ 25 NL; không thì chiêu hero / vô hiệu hóa
	if not shield_active and energy >= 25 and manuals <= 0:
		activate_shield()
		return
	if manuals <= 0:
		if energy >= 25:
			activate_shield()
		else:
			show_message("Ô kỹ năng đang khóa. Tìm Bí Kíp hoặc dùng khiên (25⚡).", 2.4)
		return
	if not shield_active and energy >= 25 and Input.is_key_pressed(KEY_SHIFT) == false:
		# Lần 1 CHIÊU = khiên nếu chưa có
		activate_shield()
		return
	if energy < 40:
		show_message("Aria: Chưa đủ năng lượng cho chiêu (40⚡)!", 1.5)
		return
	energy -= 40
	spawn_combat_vfx(player.position, active_hero + 2, HEROES[active_hero].color, 0.8)
	play_sfx("res://assets/sfx/book_open.ogg")
	# Vô hiệu hóa ngắn NPC trong tầm (phòng thủ bổ sung)
	freeze_timer = 2.5
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.position.distance_to(player.position) < 220:
			enemy.slowed = 2.5
			enemy.alerted = false
	match active_hero:
		0:
			for enemy in enemies:
				if is_instance_valid(enemy) and enemy.position.distance_to(player.position) < 260: enemy.take_damage(player.damage * 1.6)
			show_message("Drone của Kai phát xung điện diện rộng!", 2)
		1:
			for enemy in enemies:
				if is_instance_valid(enemy) and enemy.position.distance_to(player.position) < 135: enemy.take_damage(player.damage * 2.0)
			show_message("Lira tung Kiếm Lốc!", 2)
		2:
			player.heal(player.max_hp * 0.45)
			for enemy in enemies:
				if is_instance_valid(enemy) and enemy.position.distance_to(player.position) < 230: enemy.slowed = 5
			show_message("Thorn hồi phục và làm chậm kẻ địch!", 2)
		3:
			for i in range(-2, 3): shoot(last_direction.rotated(i * 0.16), player.damage * 1.25, HEROES[3].color)
			show_message("Ryn bắn Mưa Tên!", 2)
		4:
			for enemy in enemies:
				if is_instance_valid(enemy):
					enemy.take_damage(player.damage * 1.25)
					enemy.slowed = 3
			show_message("Vex bẻ cong trường năng lượng!", 2)

func switch_hero() -> void:
	if unlocked_heroes <= 1: return
	var old_pos := player.position
	var hp_ratio := player.hp / player.max_hp
	player.queue_free()
	active_hero = (active_hero + 1) % unlocked_heroes
	spawn_player(old_pos)
	player.hp = player.max_hp * maxf(0.45, hp_ratio)
	show_message("Đang điều khiển %s — %s" % [HEROES[active_hero].name, HEROES[active_hero].skill], 2)

func interact() -> void:
	if zone_kills >= int(ZONES[zone].goal) and not can_exit:
		for i in range(PRISON_POSITIONS.size()):
			if not prisons_opened[i] and player.position.distance_to(PRISON_POSITIONS[i]) < 105:
				prisons_opened[i] = true
				rescued_in_zone += 1
				rescued = zone * 3 + rescued_in_zone
				play_sfx("res://assets/sfx/pickup.ogg")
				spawn_combat_vfx(PRISON_POSITIONS[i], 5, Color("79f5cc"), 0.8)
				show_message("ĐÃ MỞ NHÀ TÙ %d/3 — người dân đã an toàn!" % rescued_in_zone, 2.5)
				queue_redraw()
				if rescued_in_zone >= 3: complete_zone_rescue()
				return
		show_message("Lính canh đã bị hạ. Hãy đến gần từng lồng tù và nhấn F.", 2.5)
	elif materials >= 8:
		materials -= 8
		damage_bonus += 3
		player.damage += 3
		show_message("Đã chế tạo lõi tăng cường: sát thương +3!", 2.5)
	elif can_exit:
		show_message("Cổng đã mở ở phía Đông →", 2)
	else:
		show_message("Nhà tù còn khóa. Hạ hết lính canh trước!", 2)

func complete_zone_rescue() -> void:
	if zone == FINAL_ZONE:
		boss_defeated = true
		playing = false
		touch_root.hide()
		clear_touch_actions()
		hide_all_modals()
		save_game()  # Lưu trước khi chọn Ending
		choice_panel.show()
		return
	can_exit = true
	tech_fragments += 1
	manuals = maxi(manuals, zone + 1)
	if zone == 0: weapon_unlocked = maxi(weapon_unlocked, 2)
	elif zone == 1: weapon_unlocked = maxi(weapon_unlocked, 3)
	elif zone == 3: weapon_unlocked = maxi(weapon_unlocked, 4)
	weapon_mode = weapon_unlocked - 1
	player.equip_weapon(weapon_mode, last_direction)
	var manual_names := ["Kiếm Lốc", "Bước Chân Bóng Tối", "Hơi Thở Hồi Sinh", "Dư Âm Thời Gian"]
	var reward_text := "ĐÃ CỨU HẾT TÙ NHÂN! Nhận Bí Kíp %s." % manual_names[zone]
	if zone == 0: reward_text += " Trang bị Katana Hoa Thép."
	elif zone == 1: reward_text += " Ryn trao Phi Tiêu Gió."
	elif zone == 3: reward_text += " Aria khôi phục Súng Năng Lượng."
	show_message(reward_text + " Cổng phía Đông đã mở!", 5)
	save_game()  # Lưu trạng thái sau khi hoàn thành cấp / nhiệm vụ

func _on_enemy_died(enemy: HoaActor) -> void:
	spawn_combat_vfx(enemy.position, 6, Color("b91532"), 0.9)
	spawn_loot_fx(enemy.position, enemy.elite)
	play_sfx("res://assets/sfx/hit.ogg")
	enemies.erase(enemy)
	zone_kills += 1
	materials += 2 if enemy.elite else 1
	xp += 35 if enemy.elite else 15
	if zone < FINAL_ZONE and zone_kills % 3 == 0:
		show_message("Đã thu được dấu vết đoàn tù binh. Họ vẫn bị giữ sau lá chắn Nhà Tù Tinh Vân.", 2.8)
	if xp >= level * 70:
		xp -= level * 70
		level += 1
		player.max_hp += 12
		player.hp = player.max_hp
		player.damage += 2
		show_message("LÊN CẤP %d! Máu và sát thương tăng." % level, 2.8)
	if zone_kills >= int(ZONES[zone].goal):
		show_message("ĐÃ HẠ HẾT LÍNH CANH! Tìm và mở đủ 3 nhà tù bằng nút F.", 4)

func _on_player_died(_actor: HoaActor) -> void:
	playing = false
	paused = true
	touch_root.hide()
	clear_touch_actions()
	hide_all_modals()
	# SFX thua phát trong show_gameover_screen()
	show_gameover_screen()

func advance_zone() -> void:
	zone += 1
	if zone >= ZONES.size():
		zone = ZONES.size() - 1
	if zone == 1:
		unlocked_heroes = maxi(unlocked_heroes, 3)
	if zone == 2:
		unlocked_heroes = maxi(unlocked_heroes, 5)
	active_hero = mini(active_hero, unlocked_heroes - 1)
	save_game()  # Lưu khi chuyển bản đồ / cấp độ
	start_zone()

func finish_game(choice: int) -> void:
	hide_all_modals()
	playing = false
	paused = true
	touch_root.hide()
	clear_touch_actions()
	# SFX thắng phát trong show_win_screen()
	var ending := ""
	if rescued >= 6 and tech_fragments >= 2 and choice == 2:
		ending = "SECRET ENDING — DƯ ÂM THỜI GIAN\nAria tìm thấy dòng thời gian nơi hai giống loài cùng xây lại Trái Đất. Kai ở lại quá khứ, và Làng Hoa trở thành ngọn hải đăng của thiên hà.\n\n★ BẠN ĐÃ WIN — hoàn thành cả 3 cấp độ! ★"
	elif choice == 0:
		ending = "ENDING — TRO TÀN\nVera bị quét sạch. Dân làng tự do.\n\n★ BẠN ĐÃ WIN — hoàn thành cả 3 cấp độ! ★"
	elif choice == 1:
		ending = "ENDING — CÁNH CỔNG QUÊ NHÀ\nVex mở cổng đưa Vera trở về. Làng Hoa bắt đầu hồi sinh.\n\n★ BẠN ĐÃ WIN — hoàn thành cả 3 cấp độ! ★"
	else:
		ending = "ENDING — BÌNH MINH MỚI\nAria giúp Kai lập hiệp ước. Ngôi làng được gieo mùa hoa mới.\n\n★ BẠN ĐÃ WIN — hoàn thành cả 3 cấp độ! ★"
	show_win_screen(ending)
	DirAccess.remove_absolute(SAVE_PATH)

func spawn_loot_fx(at: Vector2, elite_drop: bool) -> void:
	var particles := CPUParticles2D.new()
	particles.position = at
	particles.texture = PARTICLE_TEXTURE
	particles.amount = 18 if elite_drop else 9
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.direction = Vector2(0, -1)
	particles.spread = 150
	particles.initial_velocity_min = 70
	particles.initial_velocity_max = 160
	particles.gravity = Vector2(0, 180)
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 3.2
	particles.color = Color("d9ff6b") if not elite_drop else Color("ff78e8")
	add_child(particles)
	particles.finished.connect(particles.queue_free)
	particles.emitting = true
	var loot := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = RPG_TEXTURE
	# Bình năng lượng và tinh thể trong sheet Kenney.
	atlas.region = Rect2(748 if elite_drop else 731, 255, 16, 16)
	loot.texture = atlas
	loot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	loot.scale = Vector2(2.2, 2.2)
	loot.position = at
	add_child(loot)
	var tween := create_tween()
	tween.tween_property(loot, "position:y", at.y - 28, 0.25).set_trans(Tween.TRANS_BACK)
	tween.tween_interval(0.8)
	tween.tween_property(loot, "modulate:a", 0.0, 0.35)
	tween.tween_callback(loot.queue_free)

func spawn_combat_vfx(at: Vector2, style: int, color: Color, lifetime := 0.45) -> void:
	var effect := VFX.new()
	effect.position = at
	effect.rotation = last_direction.angle()
	effect.setup(style, color, lifetime)
	add_child(effect)

func play_sfx(path: String) -> void:
	if not sound_enabled:
		return
	if not is_instance_valid(sfx_player):
		return
	if not ResourceLoader.exists(path):
		return
	sfx_player.stream = load(path)
	sfx_player.play()


## Nút SFX / Nhạc dạng icon khiên (cùng kích thước), giữa mép trên
func create_audio_toggle_buttons() -> void:
	var btn_size := Vector2(52, 52)
	sound_btn = Button.new()
	sound_btn.custom_minimum_size = btn_size
	sound_btn.size = btn_size
	sound_btn.anchor_left = 0.5
	sound_btn.anchor_right = 0.5
	sound_btn.anchor_top = 0.0
	sound_btn.anchor_bottom = 0.0
	sound_btn.offset_left = -60
	sound_btn.offset_right = -8
	sound_btn.offset_top = 8
	sound_btn.offset_bottom = 60
	sound_btn.flat = true
	sound_btn.pressed.connect(_on_sound_toggle)
	ui.add_child(sound_btn)

	music_btn = Button.new()
	music_btn.custom_minimum_size = btn_size
	music_btn.size = btn_size
	music_btn.anchor_left = 0.5
	music_btn.anchor_right = 0.5
	music_btn.anchor_top = 0.0
	music_btn.anchor_bottom = 0.0
	music_btn.offset_left = 8
	music_btn.offset_right = 60
	music_btn.offset_top = 8
	music_btn.offset_bottom = 60
	music_btn.flat = true
	music_btn.pressed.connect(_on_music_toggle)
	ui.add_child(music_btn)
	_refresh_audio_button_labels()
	_set_audio_buttons_visible(false)


func _refresh_audio_button_labels() -> void:
	# Bật → hiện icon Off (bấm để tắt); Tắt → hiện icon On
	if is_instance_valid(sound_btn):
		sound_btn.text = ""
		var sfx_path := "res://assets/ui/icon_sfx_off.svg" if sound_enabled else "res://assets/ui/icon_sfx_on.svg"
		if ResourceLoader.exists(sfx_path):
			sound_btn.icon = load(sfx_path)
		sound_btn.expand_icon = true
		sound_btn.tooltip_text = "SFX: TẮT" if sound_enabled else "SFX: BẬT"
	if is_instance_valid(music_btn):
		music_btn.text = ""
		var mus_path := "res://assets/ui/icon_music_off.svg" if music_enabled else "res://assets/ui/icon_music_on.svg"
		if ResourceLoader.exists(mus_path):
			music_btn.icon = load(mus_path)
		music_btn.expand_icon = true
		music_btn.tooltip_text = "Nhạc: TẮT" if music_enabled else "Nhạc: BẬT"


func _set_audio_buttons_visible(v: bool) -> void:
	if is_instance_valid(sound_btn):
		sound_btn.visible = v
	if is_instance_valid(music_btn):
		music_btn.visible = v


func _on_sound_toggle() -> void:
	sound_enabled = not sound_enabled
	_refresh_audio_button_labels()
	if sound_enabled:
		play_sfx("res://assets/sfx/ui_click.ogg")


func _on_music_toggle() -> void:
	music_enabled = not music_enabled
	_refresh_audio_button_labels()
	if is_instance_valid(music_player):
		if music_enabled:
			if not music_player.playing:
				music_player.play()
		else:
			music_player.stop()
	if sound_enabled:
		play_sfx("res://assets/sfx/ui_click.ogg")

func show_message(text_value: String, duration := 3.0) -> void:
	message_label.text = text_value
	message_panel.show()
	message_timer = duration

func update_ui() -> void:
	if not is_instance_valid(player):
		return
	title_label.text = "%s  •  %s" % [HEROES[active_hero].name, HEROES[active_hero].role]
	var weapon_names := ["Kiếm cũ", "Katana", "Phi tiêu", "Súng Aria"]
	var shield_txt := "ON(%.0fs)" % shield_timer if shield_active else "OFF"
	# HUD ≥3 chỉ số: HP, Giáp, Vàng, ⚡, vũ khí, khiên
	stats_label.text = "❤ HP %d/%d   🛡 Giáp %d   💰 %d\n⚡ %d   ⚔ %s   🛡 Khiên %s   Lv.%d" % [
		int(player.hp), int(player.max_hp), int(armor), gold,
		int(energy), weapon_names[mini(weapon_mode, 3)], shield_txt, level
	]
	var goal := int(ZONES[zone].goal)
	var progress_text := "Lính canh: %d/%d" % [zone_kills, goal]
	if zone_kills >= goal:
		progress_text = "Mở nhà tù: %d/3" % rescued_in_zone
	if can_exit:
		progress_text = "Hoàn tất — đi tới Cổng Đông →"
	objective_label.text = "%s  •  %s\n%s\n%s" % [ZONES[zone].name, "ĐÊM" if is_night else "NGÀY", QUESTS[zone], progress_text]
	if is_instance_valid(skill_button):
		skill_button.modulate = Color(1, 1, 1, 0.82) if energy >= 25 else Color(0.38, 0.42, 0.55, 0.65)
		skill_button.tooltip_text = "CHIÊU / Khiên — ⚡ %d" % int(energy)

func toggle_pause() -> void:
	paused = not paused
	show_message("TẠM DỪNG — nhấn Esc để tiếp tục" if paused else "Tiếp tục hành trình", 2)

func save_game() -> void:
	# Duy trì trạng thái sau mỗi cấp / nhiệm vụ / bản đồ (và khi Game Over)
	var data := {
		"zone": zone,
		"hero": active_hero,
		"unlocked": unlocked_heroes,
		"rescued": rescued,
		"materials": materials,
		"tech": tech_fragments,
		"level": level,
		"xp": xp,
		"bonus": damage_bonus,
		"time": game_time,
		"weapons": weapon_unlocked,
		"weapon_mode": weapon_mode,
		"manuals": manuals,
		"can_exit": can_exit,
		"boss_defeated": boss_defeated,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		new_game()
		return
	var data = JSON.parse_string(file.get_as_text())
	if not data is Dictionary:
		new_game()
		return
	zone = clampi(int(data.get("zone", 0)), 0, FINAL_ZONE)
	active_hero = int(data.get("hero", 0))
	unlocked_heroes = int(data.get("unlocked", 2))
	rescued = int(data.get("rescued", 0))
	materials = int(data.get("materials", 0))
	tech_fragments = int(data.get("tech", 0))
	level = int(data.get("level", 1))
	xp = int(data.get("xp", 0))
	damage_bonus = float(data.get("bonus", 0))
	game_time = float(data.get("time", 0))
	weapon_unlocked = int(data.get("weapons", 1))
	weapon_mode = mini(int(data.get("weapon_mode", 0)), maxi(weapon_unlocked - 1, 0))
	manuals = int(data.get("manuals", zone))
	can_exit = bool(data.get("can_exit", false))
	boss_defeated = bool(data.get("boss_defeated", false))
	start_zone()

func play_zone_music() -> void:
	var path := "res://assets/music/village.ogg"
	if zone in [1, 2]:
		path = "res://assets/music/adventure.ogg"
	elif zone >= FINAL_ZONE:
		path = "res://assets/music/danger.ogg"
	var stream = load(path)
	if music_player.stream != stream:
		music_player.stream = stream
	if music_enabled:
		if not music_player.playing:
			music_player.play()
	else:
		music_player.stop()


func _apply_damage_to_player(amount: float) -> void:
	if not is_instance_valid(player):
		return
	if player.invulnerable > 0.0:
		return
	if shield_active:
		spawn_combat_vfx(player.position, 3, Color("7dffba"), 0.3)
		show_message("Khiên chắn đòn!", 0.8)
		return
	if armor > 0.0:
		var absorbed: float = minf(armor, amount)
		armor -= absorbed
		amount -= absorbed
	if amount > 0.0:
		player.take_damage(amount)


## Vật phẩm theo từng màn (hình + công dụng phù hợp biome)
func _spawn_world_pickups() -> void:
	world_pickups.clear()
	# Mỗi cấp 3 vật phẩm: bẫy / thưởng / buff — texture khác nhau
	var trap_tex := "res://assets/items/pickup_trap.svg"
	var gold_tex := "res://assets/items/pickup_gold.svg"
	var buff_tex := "res://assets/items/pickup_buff.svg"
	# Ưu tiên asset theo màn nếu có
	if zone == 0:
		if ResourceLoader.exists("res://assets/items/skill_book.png"):
			buff_tex = "res://assets/items/skill_book.png"
		if ResourceLoader.exists("res://assets/items/sword.png"):
			gold_tex = "res://assets/items/sword.png"
	elif zone == 1:
		if ResourceLoader.exists("res://assets/items/shuriken.svg"):
			trap_tex = "res://assets/items/shuriken.svg"
		if ResourceLoader.exists("res://assets/items/katana.svg"):
			gold_tex = "res://assets/items/katana.svg"
	elif zone == FINAL_ZONE:
		if ResourceLoader.exists("res://assets/items/energy_gun.svg"):
			buff_tex = "res://assets/items/energy_gun.svg"
	var labels := [
		["Bẫy đinh", "Rương làng", "Bí kíp"],
		["Phi tiêu độc", "Katana rơi", "Lá thuốc"],
		["Bẫy năng lượng", "Tinh thể", "Súng Aria"],
	]
	var zone_labels: Array = labels[clampi(zone, 0, 2)]
	var specs := [
		{"id": "X", "pos": Vector2(300 + zone * 40, 260), "tex": trap_tex, "label": zone_labels[0], "color": Color("ff6b7a")},
		{"id": "Y", "pos": Vector2(700, 500 - zone * 20), "tex": gold_tex, "label": zone_labels[1], "color": Color("ffd866")},
		{"id": "Z", "pos": Vector2(1080 - zone * 30, 320), "tex": buff_tex, "label": zone_labels[2], "color": Color("55dcec")},
	]
	for s in specs:
		var tex = null
		if ResourceLoader.exists(str(s.tex)):
			tex = load(str(s.tex))
		world_pickups.append({
			"id": s.id,
			"pos": s.pos,
			"color": s.color,
			"label": s.label,
			"tex": tex,
			"alive": true,
		})


func _update_pickups() -> void:
	if not is_instance_valid(player):
		return
	for p in world_pickups:
		if not p.alive:
			continue
		if player.position.distance_to(p.pos) < 40.0:
			p.alive = false
			_apply_pickup_effect(str(p.id))


func _apply_pickup_effect(pid: String) -> void:
	play_sfx("res://assets/sfx/pickup.ogg")
	match pid:
		"X":
			# Bẫy theo màn: −HP + −Giáp
			_apply_damage_to_player(16.0 + zone * 4.0)
			armor = maxf(0.0, armor - 5.0)
			spawn_combat_vfx(player.position, 2, Color("ff6b7a"), 0.5)
			var xn: String = ["Bẫy đinh làng", "Phi tiêu độc", "Bẫy năng lượng"][clampi(zone, 0, 2)]
			show_message("%s: −HP và −Giáp!" % xn, 2.0)
		"Y":
			# Thưởng theo màn: +vàng + hồi máu
			gold += 20 + zone * 10
			if is_instance_valid(player):
				player.heal(18.0 + zone * 4.0)
			spawn_combat_vfx(player.position, 3, Color("ffd866"), 0.5)
			var yn: String = ["Rương làng", "Katana rơi", "Tinh thể Vera"][clampi(zone, 0, 2)]
			show_message("%s: +vàng & hồi máu!" % yn, 2.0)
		"Z":
			# Buff theo màn: +giáp +⚡ + tốc
			armor += 12.0 + zone * 3.0
			energy = minf(100.0, energy + 25.0 + zone * 5.0)
			if is_instance_valid(player):
				player.speed = minf(player.speed + 35.0, 340.0)
			spawn_combat_vfx(player.position, 4, Color("55dcec"), 0.5)
			var zn: String = ["Bí kíp cổ", "Lá thuốc rừng", "Mảnh súng Aria"][clampi(zone, 0, 2)]
			show_message("%s: +Giáp, +⚡, +Tốc độ!" % zn, 2.0)
		_:
			pass

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), ZONES[zone].color if zone < ZONES.size() else Color("182030"))
	# Hai bản panorama nối tiếp tạo ảnh nền chuyển động liên tục (parallax xa).
	var panorama_offset := fmod(game_time * (18.0 + zone * 4.0), 1280.0)
	var panorama_tint := Color(0.62, 0.72, 0.86, 0.28) if zone < 3 else Color(0.68, 0.48, 0.88, 0.24)
	draw_texture_rect(PANORAMA_TEXTURE, Rect2(-panorama_offset, 0, 1280, 720), false, panorama_tint)
	draw_texture_rect(PANORAMA_TEXTURE, Rect2(1280.0 - panorama_offset, 0, 1280, 720), false, panorama_tint)
	# Mỗi biome dùng đúng nhóm tile: đất làng, cỏ rừng, đá núi, đảo mây, tinh vân.
	var tile_source_y: int = [192, 160, 336][zone]
	for x in range(0, 1500, 64):
		for y in range(100, 820, 64):
			var variant := (int(x / 64.0) + int(y / 64.0)) % 4
			draw_texture_rect_region(FLOOR_TEXTURE, Rect2(x, y, 64, 64), Rect2(variant * 16, tile_source_y, 16, 16), Color(0.68, 0.68, 0.78, 0.78) if zone >= FINAL_ZONE else Color(1, 1, 1, 0.78))
	# Chỉ các khu công nghệ mới có panel neon; biome tự nhiên không bị pha asset.
	if zone >= FINAL_ZONE:
		for i in range(8):
			var p := Vector2(250 + i * 155, 210 + (i % 3) * 175)
			draw_rect(Rect2(p, Vector2(60, 45)), Color(ZONES[zone].accent, 0.22), true)
			draw_line(p, p + Vector2(60, 45), Color(ZONES[zone].accent, 0.4), 3)
	draw_geography()
	draw_zone_decor()
	draw_flower_fields()
	draw_prisons()
	# Chỉ vẽ khiên khi đang bật (không vẽ vòng cam vùng cấm)
	if playing and is_instance_valid(player) and shield_active:
		var pulse := 36.0 + sin(game_time * 6.0) * 3.0
		draw_arc(player.position, pulse, 0, TAU, 48, Color(0.45, 1.0, 0.75, 0.7), 3.0)
	# Vật phẩm theo màn (texture + nhãn)
	for p in world_pickups:
		if not p.get("alive", false):
			continue
		var pos: Vector2 = p.pos
		if p.get("tex") != null:
			var tex: Texture2D = p.tex
			var sz := Vector2(40, 40)
			draw_texture_rect(tex, Rect2(pos - sz * 0.5, sz), false)
		else:
			draw_circle(pos, 16.0, p.color)
		draw_string(ThemeDB.fallback_font, pos + Vector2(-28, -28), str(p.label), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	if can_exit:
		var pulse := 1.0 + sin(game_time * 4.0) * 0.06
		draw_circle(Vector2(1430, 430), 72 * pulse, Color(ZONES[zone].accent, 0.16))
		draw_texture_rect(PORTAL_TEXTURE, Rect2(Vector2(1362, 330) - Vector2.ONE * 6 * pulse, Vector2(136, 166) * pulse), false)
		draw_string(ThemeDB.fallback_font, Vector2(1365, 515), "CỔNG SANG MÀN", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)

func draw_geography() -> void:
	if zone == 0:
		# Tia nắng ấm xuyên qua Làng Hoa.
		for x in [80.0, 520.0, 1030.0]:
			draw_texture_rect(SUN_RAYS_TEXTURE, Rect2(x, 95, 325, 154), false, Color(1, 0.92, 0.58, 0.34))
		draw_colored_polygon(PackedVector2Array([Vector2(0,360),Vector2(1500,300),Vector2(1500,510),Vector2(0,470)]), Color("8b6546"))
		for x in range(40, 1500, 95): draw_circle(Vector2(x, 410 + sin(x) * 25), 8, Color("b48a5d"))
	elif zone == 1:
		# Sông chia rừng và cầu gỗ là điểm nhận diện màn.
		draw_colored_polygon(PackedVector2Array([Vector2(650,100),Vector2(845,100),Vector2(790,820),Vector2(590,820)]), Color("184d73"))
		for y in range(120, 820, 42): draw_line(Vector2(625, y), Vector2(810, y + 15), Color("54b9cf88"), 4)
		draw_rect(Rect2(590, 350, 255, 125), Color("4a2f27"), true)
		for x in range(600, 845, 28):
			draw_rect(Rect2(x, 360, 23, 105), Color("b87943"), true)
			draw_line(Vector2(x,360), Vector2(x,465), Color("55362a"), 2)
	elif zone == 2:
		# Vách núi và khe dung nham trong mỏ.
		for x in range(0, 1500, 110):
			draw_colored_polygon(PackedVector2Array([Vector2(x,180),Vector2(x+55,105),Vector2(x+110,180)]), Color("48415e"))
		draw_colored_polygon(PackedVector2Array([Vector2(0,700),Vector2(420,620),Vector2(760,735),Vector2(1120,650),Vector2(1500,720),Vector2(1500,820),Vector2(0,820)]), Color("7d352b"))
		for x in range(20, 1500, 75): draw_circle(Vector2(x, 730 + sin(x) * 22), 9, Color("ff7b39aa"))
	elif zone == 3:
		# Đảo nổi và mây trôi quanh pháo đài.
		for p in [Vector2(180,220),Vector2(720,170),Vector2(1180,260),Vector2(470,670),Vector2(1030,650)]:
			draw_circle(p, 95, Color("b7d9ec2f"))
			draw_circle(p + Vector2(65,10), 60, Color("d9eff544"))
	else:
		# Sàn nhà tù tinh vân với các mạch năng lượng.
		for x in range(0, 1500, 120):
			draw_line(Vector2(x,100), Vector2(x+180,820), Color("ba54e855"), 3)
		for y in range(140, 820, 110): draw_line(Vector2(0,y), Vector2(1500,y), Color("4bdaee44"), 2)
	# Thời tiết có chuyển động, khác nhau theo từng biome.
	if zone == 1:
		for i in range(40):
			var p := Vector2(fmod(i * 97.0 + game_time * 170.0, 1500.0), fmod(i * 53.0 + game_time * 260.0, 720.0) + 100)
			draw_line(p, p + Vector2(-10, 24), Color("b5e8ff77"), 2)
		for i in range(12):
			var splash_pos := Vector2(fmod(i * 131.0 + 35.0, 1500.0), 135 + fmod(i * 83.0, 650.0))
			var splash_frame := int(game_time * 9.0 + i) % 3
			draw_texture_rect_region(RAIN_SPLASH_TEXTURE, Rect2(splash_pos, Vector2(48, 16)), Rect2(splash_frame * 8, 0, 8, 8), Color(0.72, 0.92, 1, 0.8))
		for i in range(5):
			var cloud_x := fmod(i * 330.0 + game_time * 24.0, 1740.0) - 120.0
			draw_texture_rect(CLOUD_TEXTURE, Rect2(cloud_x, 115 + (i % 2) * 170, 200, 90), false, Color(0.62, 0.78, 0.82, 0.24))
	elif zone >= FINAL_ZONE:
		for i in range(24):
			var p := Vector2(fmod(i * 137.0 + game_time * 35.0, 1500.0), 120 + fmod(i * 71.0, 680.0))
			draw_circle(p, 3 + (i % 3), Color("dc83ff88"))

func draw_zone_decor() -> void:
	if zone == 0:
		# Nhà được crop riêng, không kéo cả atlas thành mảng lộn xộn.
		for p in [Vector2(265, 185), Vector2(905, 555), Vector2(1190, 190)]:
			draw_ellipse_at(p + Vector2(55, 103), Vector2(58, 15), Color(0, 0, 0, 0.35))
			draw_texture_rect_region(VILLAGE_TEXTURE, Rect2(p, Vector2(112, 128)), Rect2(164, 104, 70, 80))
		for p in [Vector2(45, 130), Vector2(610, 655), Vector2(1010, 125), Vector2(1340, 610)]:
			draw_texture_rect_region(VILLAGE_TEXTURE, Rect2(p, Vector2(108, 96)), Rect2(0, 96, 72, 64))
	elif zone == 1:
		# Rừng Ninja dùng tán cây dày, bụi thấp và giữ lòng sông thoáng.
		for p in [Vector2(15, 125),Vector2(160, 155),Vector2(360, 120),Vector2(875, 125),Vector2(1060, 155),Vector2(1290, 120),Vector2(85, 650),Vector2(940, 640),Vector2(1260, 650)]:
			draw_texture_rect_region(VILLAGE_TEXTURE, Rect2(p, Vector2(108, 96)), Rect2(0, 96, 72, 64), Color(0.62, 0.88, 0.68))
		for p in [Vector2(410, 660), Vector2(1120, 590)]:
			draw_texture_rect_region(VILLAGE_TEXTURE, Rect2(p, Vector2(96, 82)), Rect2(96, 0, 64, 55), Color(0.65, 0.84, 0.68))
	elif zone == 2:
		# Đá núi thật từ atlas Caves & Dungeons, nhiều silhouette khác nhau.
		for i in range(10):
			var p := Vector2(35 + i * 148, 125 + (i % 3) * 245)
			var source_x := float((i % 4) * 32)
			draw_ellipse_at(p + Vector2(40, 70), Vector2(48, 13), Color(0, 0, 0, 0.38))
			draw_texture_rect_region(DUNGEON_TEXTURE, Rect2(p, Vector2(82, 82)), Rect2(source_x, 0, 32, 32), Color(0.78, 0.83, 0.9))
	else:
		for p in [Vector2(70,145),Vector2(410,620),Vector2(720,140),Vector2(1090,610),Vector2(1320,180)]:
			draw_texture_rect_region(RPG_TEXTURE, Rect2(p, Vector2(92, 92)), Rect2(765, 288, 48, 48), Color(0.68, 0.78, 1.0))
		for p in [Vector2(330,250),Vector2(820,390),Vector2(1160,230)]:
			draw_rect(Rect2(p, Vector2(100,70)), Color("151833"), true)
			draw_texture_rect_region(RPG_TEXTURE, Rect2(p, Vector2(100,70)), Rect2(816,68,48,34), Color("8af7ff"))

func draw_flower_fields() -> void:
	# Hoa là nhận diện xuyên suốt: dày đặc ở làng, thưa dần khi tiến vào vùng địch.
	var flower_count: int = [42, 22, 12][zone]
	var flower_frame := int(game_time * 7.0) % 4
	var flower_colors := [Color.WHITE, Color("ffd0e8"), Color("c9e8ff"), Color("e6d0ff")]
	for i in range(flower_count):
		var x := fmod(73.0 + i * 173.0 + (i % 5) * 41.0, 1460.0)
		var y := 135.0 + fmod(i * 97.0 + (i % 4) * 33.0, 630.0)
		# Không đặt hoa giữa lòng sông; ven bờ tạo thành dải hoa tự nhiên.
		if zone == 1 and x > 570 and x < 865: x = 535 if i % 2 == 0 else 885
		var size := 18.0 + float(i % 3) * 3.0
		draw_ellipse_at(Vector2(x + size * 0.5, y + size * 0.82), Vector2(size * 0.36, size * 0.10), Color(0,0,0,0.24))
		var flower_color: Color = flower_colors[i % flower_colors.size()] if zone < 3 else Color(0.88,0.72,1.0,0.9)
		draw_texture_rect_region(FLOWER_TEXTURE, Rect2(x, y, size, size), Rect2(flower_frame * 16, 0, 16, 16), flower_color)
	# Cánh hoa bay tạo chiều sâu và liên hệ trực tiếp với hệ skill.
	if zone in [0, 1, FINAL_ZONE]:
		for i in range(16):
			var petal_pos := Vector2(fmod(i * 113.0 + game_time * 42.0, 1500.0), 120 + fmod(i * 67.0 + game_time * 18.0, 680.0))
			var petal_frame := (i + int(game_time * 10.0)) % 9
			draw_texture_rect_region(PETAL_TEXTURE, Rect2(petal_pos, Vector2(18, 16)), Rect2(petal_frame * 8, 0, 8, 7), Color(1,0.76,0.9,0.82))

func draw_prisons() -> void:
	for i in range(PRISON_POSITIONS.size()):
		var p: Vector2 = PRISON_POSITIONS[i]
		# Bóng tiếp xúc lớn, lệch xuống tạo chiều sâu 2.5D.
		draw_ellipse_at(p + Vector2(8, 47), Vector2(70, 18), Color(0.01, 0.02, 0.05, 0.52))
		if prisons_opened[i]:
			for villager_index in range(2):
				var vp := p + Vector2(-32 + villager_index * 62, 14 + sin(game_time * 3 + villager_index) * 4)
				draw_texture_rect(VILLAGER_TEXTURE, Rect2(vp - Vector2(24, 50), Vector2(48, 64)), false, Color.WHITE)
			draw_string(ThemeDB.fallback_font, p + Vector2(-39, -52), "ĐÃ CỨU", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("7dffba"))
		else:
			draw_texture_rect(VILLAGER_TEXTURE, Rect2(p - Vector2(20, 34), Vector2(40, 54)), false, Color("d8e5ec"))
			draw_texture_rect(PRISON_TEXTURE, Rect2(p - Vector2(64, 56), Vector2(128, 112)), false)
			draw_circle(p, 72, Color(ZONES[zone].accent, 0.07), false, 3)

func draw_ellipse_at(center: Vector2, ellipse_size: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, Vector2(ellipse_size.x / ellipse_size.y, 1.0))
	draw_circle(Vector2.ZERO, ellipse_size.y, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
