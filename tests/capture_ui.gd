extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene = load("res://src/main.tscn").instantiate()
	root.add_child(scene)
	for i in range(190): await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://build/audit_home.png")
	scene.new_game()
	await process_frame
	scene.close_stage_intro()
	for i in range(8): await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://build/audit_game.png")
	for biome in range(1, 5):
		scene.zone = biome
		scene.start_zone()
		await process_frame
		scene.close_stage_intro()
		for i in range(5): await process_frame
		root.get_viewport().get_texture().get_image().save_png("res://build/audit_zone_%d.png" % biome)
	scene.manuals = 4
	scene.energy = 100
	scene.use_skill()
	for i in range(8): await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://build/audit_flower_vfx.png")
	quit(0)
