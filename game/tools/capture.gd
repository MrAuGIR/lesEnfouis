extends Node2D
## OUTIL TEMPORAIRE de capture (non commité) : instancie le vrai jeu, fige le temps,
## téléporte le héros + éclaire la scène pour photographier chaque lot d'assets
## (héros / blocs monde / décor de fond / ennemis) à l'échelle réelle, dans la lumière
## du jeu. Sort des PNG dans /tmp/, puis quitte.

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
	main.camera.position_smoothing_enabled = false
	Engine.time_scale = 0.0   # fige toute la simulation : poses nettes, pas de dérive ni d'IA

	var cx: int = main.world.exit_col()

	# ---- 1) HÉROS (dans le hall du Foyer, déjà éclairé) ----
	main.marker.visible = false
	_glow(Vector2((cx + 0.5) * T, (WorldGrid.BASE_DEPTH - 1) * T), Color(1.0, 0.88, 0.6), 2.2, 1.1)
	await _save("/tmp/cap_hero.png")
	_clear_glows()

	# ---- 2) BLOCS DU MONDE (bande témoin de tous les types) ----
	var R := WorldGrid.BASE_DEPTH + 30
	_build_blocks(cx, R)
	main.view.mark_dirty()
	main.hero.aim = Vector2.RIGHT
	main.hero.pos = Vector2((cx - 1 + 0.5) * T, (R + 1) * T - main.hero.half.y)
	_glow(Vector2((cx - 1) * T, (R - 1) * T), Color(1.0, 0.92, 0.72), 3.0, 1.5)
	_glow(Vector2((cx + 4) * T, (R - 1) * T), Color(1.0, 0.9, 0.7), 2.2, 1.1)
	await _save("/tmp/cap_blocs_monde.png")
	_clear_glows()

	# ---- 3) ENNEMIS (les 4 archétypes alignés, héros à gauche pour l'échelle) ----
	main.marker.visible = true
	var Re := WorldGrid.BASE_DEPTH + 40
	_carve_room(cx - 8, cx + 6, Re)
	main.view.mark_dirty()
	main.hero.pos = Vector2((cx - 7 + 0.5) * T, (Re + 1) * T - main.hero.half.y)
	main.hero.aim = Vector2.RIGHT
	main.crew.list.clear()
	main.crew._add_at(Vector2((cx - 3 + 0.5) * T, (Re + 1) * T), EnemyCrew.KIND_ROBOT, false)
	main.crew._add_at(Vector2((cx - 1 + 0.5) * T, (Re + 1) * T), EnemyCrew.KIND_FONCEUR, false)
	main.crew._add_at(Vector2((cx + 1 + 0.5) * T, (Re + 1) * T), EnemyCrew.KIND_TIREUR, false)
	main.crew._add_at(Vector2((cx + 3 + 0.5) * T, (Re + 1) * T), EnemyCrew.KIND_LOURD, false)
	_glow(Vector2(cx * T, (Re - 1) * T), Color(0.95, 0.9, 0.78), 3.4, 1.5)
	await _save("/tmp/cap_ennemis.png")
	_clear_glows()
	main.crew.list.clear()

	# ---- 4) DÉCOR DE FOND (les 3 contextes) ----
	main.marker.visible = false
	# 4a base : le hall (mur Fallout-Shelter)
	main.hero.pos = Vector2((cx + 0.5) * T, (WorldGrid.BASE_DEPTH) * T - main.hero.half.y)
	_glow(Vector2((cx + 0.5) * T, (WorldGrid.BASE_DEPTH - 2) * T), Color(1.0, 0.85, 0.55), 3.2, 1.4)
	await _save("/tmp/cap_decor_base.png")
	_clear_glows()
	# 4b tunnel : une station de métro
	if main.world.stations.size() > 0:
		var st: Rect2i = main.world.stations[0]
		var sx := st.position.x + st.size.x / 2
		var sy := st.position.y + st.size.y - 1
		main.hero.pos = Vector2((sx + 0.5) * T, (sy + 1) * T - main.hero.half.y)
		_glow(Vector2((sx + 0.5) * T, (sy - 1) * T), Color(0.8, 0.86, 1.0), 3.4, 1.4)
		await _save("/tmp/cap_decor_tunnel.png")
		_clear_glows()
	# 4c roche : une poche creusée en profondeur
	var Rr := WorldGrid.BASE_DEPTH + 52
	_carve_room(cx - 6, cx + 6, Rr)
	main.view.mark_dirty()
	main.hero.pos = Vector2((cx + 0.5) * T, (Rr + 1) * T - main.hero.half.y)
	_glow(Vector2((cx + 0.5) * T, (Rr - 1) * T), Color(0.92, 0.95, 1.0), 3.2, 1.4)
	await _save("/tmp/cap_decor_roche.png")
	_clear_glows()

	print("CAPTURE OK")
	get_tree().quit()

# Bande horizontale de tous les types de blocs (+ échelle + passerelle) sur un sol.
func _build_blocks(cx: int, R: int) -> void:
	_carve_room(cx - 8, cx + 7, R)
	for x in range(cx - 8, cx + 8):       # sol porteur sous la bande
		main.world.set_tile(x, R + 1, WorldGrid.ROCK)
	var strip := {
		cx - 7: WorldGrid.DIRT, cx - 6: WorldGrid.ROCK, cx - 5: WorldGrid.WOOD,
		cx - 4: WorldGrid.LITHIUM, cx - 3: WorldGrid.IRON, cx - 2: WorldGrid.WALL,
		cx + 0: WorldGrid.HARDROCK, cx + 1: WorldGrid.CRATE, cx + 2: WorldGrid.CRATE_OPEN,
		cx + 3: WorldGrid.BOSS_DOOR,
	}
	for x in strip:
		main.world.set_tile(x, R, strip[x])
	for y in range(R - 3, R + 1):          # échelle verticale (décor visible au travers)
		main.world.set_tile(cx + 5, y, WorldGrid.LADDER)
	for x in range(cx + 1, cx + 4):        # passerelle flottante (planches)
		main.world.set_tile(x, R - 2, WorldGrid.PASSERELLE)

# Vide une salle rectangulaire (sol = rangée gy+1 laissée/posée solide par l'appelant).
func _carve_room(x0: int, x1: int, gy: int) -> void:
	for x in range(x0, x1 + 1):
		for y in range(gy - 4, gy + 1):
			main.world.set_tile(x, y, WorldGrid.EMPTY)
		main.world.set_tile(x, gy + 1, WorldGrid.ROCK)

func _glow(p: Vector2, c: Color, scale_f: float, energy: float) -> void:
	glows.append(main.lights.add_glow(p, c, scale_f, energy))

func _clear_glows() -> void:
	for g in glows:
		if is_instance_valid(g):
			g.queue_free()
	glows.clear()

func _save(path: String) -> void:
	for i in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)
	print("saved ", path)
