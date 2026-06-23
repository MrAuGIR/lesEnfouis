extends Node2D
## OUTIL TEMPORAIRE (non commité) : bâtit quelques pièces de types variés autour du
## Hall et photographie le Foyer (murs en panneaux + props focaux) sous l'éclairage
## réel. Sort /tmp/val_foyer_*.png puis quitte.

const T := WorldGrid.TILE
var main: Node2D
var glows: Array = []

func _ready() -> void:
	await get_tree().process_frame
	main = load("res://scripts/main.gd").new()
	add_child(main)
	for i in 8:
		await get_tree().process_frame
	main.hud.visible = false
	main.marker.visible = false
	main.camera.position_smoothing_enabled = false
	Engine.time_scale = 0.0

	var f = main.foyer
	# Rangée + étage de pièces (insertion directe : on court-circuite coût/adjacence)
	_room(f, Vector2i(-1, 0), Foyer.ROOM_ATELIER)
	_room(f, Vector2i(1, 0), Foyer.ROOM_DORTOIR)
	_room(f, Vector2i(2, 0), Foyer.ROOM_INFIRMERIE)
	_room(f, Vector2i(0, 1), Foyer.ROOM_ENTREPOT)
	_room(f, Vector2i(1, 1), Foyer.ROOM_FORAGE)
	main.view.mark_dirty()

	# Cadrage 1 : la rangée du haut (atelier / hall / dortoir)
	_frame_on(f, Vector2i(0, 0))
	await _save("/tmp/val_foyer_haut.png")
	# Cadrage 2 : dortoir / infirmerie + étage du bas
	_frame_on(f, Vector2i(1, 0), Vector2(2.0 * T, 3.0 * T))
	await _save("/tmp/val_foyer_bas.png")

	print("VALIDATE FOYER OK")
	get_tree().quit()

func _room(f, mp: Vector2i, type: int) -> void:
	f.rooms[mp] = {"type": type}
	f._carve(mp)
	f._open_doors(mp)

func _frame_on(f, mp: Vector2i, off := Vector2.ZERO) -> void:
	var it: Rect2i = f.interior(mp)
	var c := Vector2((it.position.x + it.size.x * 0.5) * T, (it.position.y + it.size.y * 0.5) * T)
	main.hero.pos = c + off
	main.hero.aim = Vector2.RIGHT
	_clear_glows()
	for k in f.rooms:
		var ic: Rect2i = f.interior(k)
		_glow(Vector2((ic.position.x + ic.size.x * 0.5) * T, (ic.position.y + ic.size.y * 0.5) * T),
			Color(1.0, 0.88, 0.62), 2.4, 1.2)

func _glow(p: Vector2, c: Color, s: float, e: float) -> void:
	glows.append(main.lights.add_glow(p, c, s, e))

func _clear_glows() -> void:
	for g in glows:
		if is_instance_valid(g):
			g.queue_free()
	glows.clear()

func _save(path: String) -> void:
	for i in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("saved ", path)
