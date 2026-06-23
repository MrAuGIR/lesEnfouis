extends Node2D
## OUTIL TEMPORAIRE (non commité) : pose des pilleurs (tous types/états) et le Roi
## près du héros, sous l'éclairage réel, et photographie le rendu sprite. Vérifie
## l'échelle, l'ancrage au sol (pivot pieds), le flip, et le mapping des anims.
## Sort /tmp/val_sprites_*.png puis quitte.

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

	var crew = main.crew
	var hero = main.hero
	var EC = EnemyCrew
	var fy: float = hero.pos.y + hero.half.y   # ligne de sol (pieds)
	var x0: float = hero.pos.x - 80.0

	# Rangée de pilleurs, états forcés ----------------------------------------------
	var specs := [
		{"kind": EC.KIND_FONCEUR, "dir": 1.0, "tag": "fonceur idle"},
		{"kind": EC.KIND_FONCEUR, "dir": 1.0, "hit": true, "tag": "fonceur attq"},
		{"kind": EC.KIND_TIREUR, "dir": 1.0, "tag": "tireur idle"},
		{"kind": EC.KIND_TIREUR, "dir": 1.0, "shoot": true, "tag": "tireur tir"},
		{"kind": EC.KIND_LOURD, "dir": 1.0, "tag": "lourd FACE"},
		{"kind": EC.KIND_LOURD, "dir": -1.0, "tag": "lourd DOS"},
		{"kind": EC.KIND_LOURD, "dir": 1.0, "flash": true, "tag": "lourd touche"},
	]
	var x := x0
	for s in specs:
		var kind: int = s["kind"]
		var half: Vector2 = EC.K_HALF[kind]
		var e := {"kind": kind, "pos": Vector2(x, fy - half.y), "vel": Vector2.ZERO,
			"hp": EC.K_HP[kind], "max_hp": EC.K_HP[kind], "half": half,
			"speed": EC.K_SPEED[kind], "dmg": EC.K_DMG[kind], "dir": float(s["dir"]),
			"on_floor": true, "blocked": false, "hit_cd": 0.0, "flash": 0.0,
			"anchor": null, "shoot_cd": 0.0}
		if s.get("hit", false): e["hit_cd"] = EC.ENEMY_HIT_CD
		if s.get("shoot", false): e["shoot_cd"] = EC.SHOOT_CD
		if s.get("flash", false): e["flash"] = 0.16
		crew.list.append(e)
		_glow(Vector2(x, fy - half.y), 0.9)
		x += 30.0
	# un cadavre en cours d'anim de mort
	var lc := {"kind": EC.KIND_FONCEUR, "pos": Vector2(x, fy - 16.0), "dir": 1.0,
		"half": EC.K_HALF[EC.KIND_FONCEUR]}
	crew.add_corpse(lc)
	crew.corpses[0]["age"] = 0.12
	_glow(Vector2(x, fy - 16.0), 0.9)

	main.hero.aim = Vector2.RIGHT
	_frame_hero(Vector2(x0 + 90.0, fy - 30.0))
	await _save("/tmp/val_sprites_pilleurs.png")

	# Le Roi : capturé DANS SON ARÈNE (pas de PNJ du Foyer pour le masquer) ---------
	_clear_list(crew)
	var boss = main.boss
	var bp: Vector2 = boss.boss["pos"]
	boss.boss["dir"] = -1.0
	_glow(bp + Vector2(0.0, -16.0), 1.0)
	_frame_hero(bp + Vector2(40.0, -4.0))

	var states := [
		["idle", func(): boss.phase = boss.P_STALK; boss.enraged = false; boss.boss["vel"].x = 0.0],
		["telegraphe", func(): boss.phase = boss.P_TELEGRAPH],
		["charge", func(): boss.phase = boss.P_CHARGE; boss.boss["vel"].x = 50.0],
		["slam", func(): boss.phase = boss.P_RECOVER; boss.phase_t = boss.SLAM_RECOVER * 0.5],
		["invocation", func(): boss.phase = boss.P_STALK; boss.invoke_t = boss.INVOKE_TIME * 0.5],
		["enrage", func(): boss.invoke_t = 0.0; boss.enraged = true; boss.boss["vel"].x = 0.0],
	]
	for st in states:
		st[1].call()
		await _save("/tmp/val_sprites_boss_%s.png" % st[0])

	print("VALIDATE SPRITES OK")
	get_tree().quit()

func _clear_list(crew) -> void:
	crew.list = crew.list.filter(func(e): return e.get("boss", false))
	crew.corpses.clear()
	_clear_glows()

func _frame_hero(p: Vector2) -> void:
	main.hero.pos = p

func _glow(p: Vector2, s: float) -> void:
	glows.append(main.lights.add_glow(p, Color(1.0, 0.9, 0.7), s, 1.2))

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
