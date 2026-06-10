class_name WorldView
extends Node2D
## Rendu grey-box du monde : tuiles éclairées, héros, repères (base, sortie),
## feedback de creusage. Aucune logique de jeu — il lit l'état et dessine.

const VIEW_RX := 34   # demi-largeur de la fenêtre de tuiles dessinées
const VIEW_RY := 22

var world: WorldGrid
var hero: Hero
var light: LightField
var crew: EnemyCrew
var combat: Combat
var camp: BaseCamp

var dig_target := Vector2i(-1, -1)
var dig_frac := 0.0               # progression du creusage (0..1)
var flashes := []                 # éclats de creusage : {cell:Vector2i, t:float}
var cache_active := false         # cache de butin à dessiner (mort du héros)
var cache_pos := Vector2.ZERO
var cache_range := 2.0 * WorldGrid.TILE

func add_flash(cell: Vector2i, dur: float) -> void:
	flashes.append({"cell": cell, "t": dur})

func tick(delta: float) -> void:
	for f in flashes:
		f.t -= delta
	flashes = flashes.filter(func(f): return f.t > 0.0)
	queue_redraw()

func _draw() -> void:
	var ts := WorldGrid.TILE
	var c_dirt := Color(0.42, 0.30, 0.20)
	var c_rock := Color(0.40, 0.42, 0.46)
	var c_wood := Color(0.55, 0.38, 0.15)
	var c_lith := Color(0.45, 0.74, 0.80)
	var c_wall := Color(0.30, 0.34, 0.42)
	var c_hard := Color(0.18, 0.20, 0.26)
	var ptx := int(hero.pos.x / ts)
	var pty := int(hero.pos.y / ts)
	# Fond sombre
	var bg_pos := Vector2((ptx - VIEW_RX) * ts, (pty - VIEW_RY) * ts)
	var bg_size := Vector2((VIEW_RX * 2) * ts, (VIEW_RY * 2) * ts)
	draw_rect(Rect2(bg_pos, bg_size), Color(0.04, 0.04, 0.06))
	# Tuiles visibles, éclairées
	for ty in range(pty - VIEW_RY, pty + VIEW_RY):
		for tx in range(ptx - VIEW_RX, ptx + VIEW_RX):
			var rect := Rect2(tx * ts, ty * ts, ts, ts)
			var t := world.tile(tx, ty)
			if t == WorldGrid.EMPTY:
				# Lueur dans l'air : haze douce qui rend le faisceau visible SANS recouvrir
				# le décor (courbe glow² → concentrée sur le cœur du faisceau).
				var glow := maxf(light.lamp_light(tx, ty), light.torch_light(tx, ty))
				if glow > 0.02:
					var g := glow * glow
					draw_rect(rect, Color(1.0, 0.94, 0.80, g * 0.14))
				elif ty < world.surface[clampi(tx, 0, WorldGrid.GRID_W - 1)] + 2:
					var sky := light.sky_light(tx, ty)
					if sky > 0.02:
						draw_rect(rect, Color(0.55, 0.65, 0.78, sky * 0.10))
				continue
			if t == WorldGrid.LADDER:
				var bl := light.brightness(tx, ty)
				var lc := Color(0.78, 0.56, 0.30, 0.45 + 0.55 * bl)
				draw_rect(Rect2(tx * ts + 3, ty * ts, 2, ts), lc)
				draw_rect(Rect2(tx * ts + ts - 5, ty * ts, 2, ts), lc)
				draw_rect(Rect2(tx * ts + 3, ty * ts + 4, ts - 8, 2), lc)
				draw_rect(Rect2(tx * ts + 3, ty * ts + 10, ts - 8, 2), lc)
				continue
			var b := light.brightness(tx, ty)
			var col := c_dirt
			if t == WorldGrid.ROCK:
				col = c_rock
			elif t == WorldGrid.WOOD:
				col = c_wood
			elif t == WorldGrid.LITHIUM:
				col = c_lith
			elif t == WorldGrid.WALL:
				col = c_wall
			elif t == WorldGrid.HARDROCK:
				col = c_hard
			draw_rect(rect, Color(col.r * b, col.g * b, col.b * b))
			draw_rect(rect, Color(0, 0, 0, 0.15 * b), false, 1.0)
	# Voile de gaz toxique (gris-jaune) sur la zone de surface, au-dessus de GAS_FLOOR_ROW
	var gas_top := float((pty - VIEW_RY) * ts)
	var gas_bot := minf(float(WorldGrid.GAS_FLOOR_ROW * ts), float((pty + VIEW_RY) * ts))
	if gas_bot > gas_top:
		var gx := float((ptx - VIEW_RX) * ts)
		var gw := float((VIEW_RX * 2) * ts)
		draw_rect(Rect2(Vector2(gx, gas_top), Vector2(gw, gas_bot - gas_top)), Color(0.65, 0.62, 0.20, 0.16))
	# Éclats de creusage (feedback de cassage)
	for f in flashes:
		var a: float = clampf(f.t / 0.18, 0.0, 1.0)
		draw_rect(Rect2(f.cell.x * ts, f.cell.y * ts, ts, ts), Color(1.0, 0.9, 0.6, a * 0.7))
	# Cible de creusage + progression
	if dig_target.x >= 0:
		var rpos := Vector2(dig_target.x * ts, dig_target.y * ts)
		draw_rect(Rect2(rpos, Vector2(ts, ts)), Color(1, 1, 1, 0.15 + 0.35 * clampf(dig_frac, 0.0, 1.0)))
		draw_rect(Rect2(rpos, Vector2(ts, ts)), Color(1, 1, 1, 0.7), false, 1.0)
	# Torches posées
	for c in light.torches:
		var tc := Vector2(c.x * ts + ts * 0.5, c.y * ts + ts * 0.5)
		draw_circle(tc, LightField.TORCH_CORE * ts, Color(1.0, 0.7, 0.3, 0.12))
		draw_rect(Rect2(tc + Vector2(-2, -5), Vector2(4, 10)), Color(1.0, 0.75, 0.35))
	# Robots (visibles surtout sous la lumière — sinon silhouette à peine perceptible)
	for e in crew.list:
		var ep: Vector2 = e["pos"]
		var eh := EnemyCrew.ENEMY_HALF
		var vis: float = maxf(0.28, light.brightness(int(ep.x / ts), int(ep.y / ts)))
		var ecol := Color(1.0, 0.95, 0.95) if float(e["flash"]) > 0.0 else Color(0.85, 0.30, 0.25)
		draw_rect(Rect2(ep - eh, eh * 2.0), Color(ecol.r * vis, ecol.g * vis, ecol.b * vis))
		draw_rect(Rect2(ep - eh, eh * 2.0), Color(0, 0, 0, 0.5 * vis), false, 1.0)
		# "oeil" tourné vers le sens de marche
		draw_rect(Rect2(ep + Vector2(float(e["dir"]) * 2.0 - 1.5, -3.0), Vector2(3, 3)), Color(1.0, 0.85, 0.4, vis))
		if float(e["hp"]) < EnemyCrew.ENEMY_HP:
			var w := eh.x * 2.0
			var frac: float = clampf(float(e["hp"]) / EnemyCrew.ENEMY_HP, 0.0, 1.0)
			draw_rect(Rect2(ep + Vector2(-eh.x, -eh.y - 5.0), Vector2(w, 2)), Color(0.25, 0.0, 0.0))
			draw_rect(Rect2(ep + Vector2(-eh.x, -eh.y - 5.0), Vector2(w * frac, 2)), Color(0.95, 0.25, 0.25))
	# Repères : base (départ, en profondeur) et sortie (objectif, en surface)
	var font := ThemeDB.fallback_font
	var ex := world.exit_col()
	var exit_p := Vector2(ex * ts + ts * 0.5, world.surface[ex] * ts)
	draw_rect(Rect2(exit_p + Vector2(-WorldGrid.EXIT_HALF * ts, -3), Vector2(WorldGrid.EXIT_HALF * 2 * ts, 3)), Color(0.95, 0.85, 0.3, 0.85))
	draw_string(font, exit_p + Vector2(-14, -6), "SORTIE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.95, 0.55))
	draw_circle(camp.pos, BaseCamp.BASE_RANGE, Color(0.3, 0.9, 0.4, 0.08))
	draw_rect(Rect2(camp.pos + Vector2(-9, -3), Vector2(18, 6)), Color(0.3, 0.85, 0.4))
	draw_string(font, camp.pos + Vector2(-12, -7), "BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.6, 1.0, 0.7))
	# Bâtiments construits (avec étiquettes)
	if camp.has_prod:
		var pr := camp.pos + Vector2(-3.6 * ts, -2.0 * ts)
		draw_rect(Rect2(pr, Vector2(2.4 * ts, 2.0 * ts)), Color(0.25, 0.45, 0.70))
		draw_rect(Rect2(pr + Vector2(0.9 * ts, 1.0 * ts), Vector2(6, 12)), Color(0.95, 0.9, 0.65))  # PNJ
		draw_string(font, pr + Vector2(1, -2), "PROD", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.7, 0.85, 1.0))
	if camp.has_workshop:
		var ws := camp.pos + Vector2(1.2 * ts, -2.0 * ts)
		draw_rect(Rect2(ws, Vector2(2.4 * ts, 2.0 * ts)), Color(0.60, 0.45, 0.25))
		draw_string(font, ws + Vector2(1, -2), "ATELIER", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.85, 0.6))
	# Cache de butin (déposée à la mort, à récupérer)
	if cache_active:
		draw_circle(cache_pos, cache_range, Color(0.95, 0.75, 0.25, 0.16))
		draw_rect(Rect2(cache_pos + Vector2(-4, -4), Vector2(8, 8)), Color(0.95, 0.8, 0.3))
	# Halo central + héros (le héros porte la lumière ; le halo faiblit avec le carburant)
	draw_circle(hero.pos, LightField.LAMP_AMBIENT_CORE * ts, Color(1.0, 0.93, 0.78, 0.07 * hero.lamp_factor))
	draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.95, 0.85, 0.5))
	draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.2, 0.15, 0.05, 0.8), false, 1.0)
	# Arc de coup (feedback du clic droit, mêlée)
	if combat.atk_t > 0.0:
		var aa: float = clampf(combat.atk_t / Combat.MELEE_VIS, 0.0, 1.0)
		draw_circle(hero.pos + hero.aim * Combat.MELEE_RANGE * 0.55, Combat.MELEE_RANGE * 0.5, Color(1.0, 1.0, 1.0, 0.20 * aa))
	# Traceur de tir (arme à feu)
	if combat.tracer_t > 0.0:
		var ta: float = clampf(combat.tracer_t / Combat.GUN_TRACER_T, 0.0, 1.0)
		draw_line(combat.tracer_a, combat.tracer_b, Color(1.0, 0.9, 0.4, 0.5 + 0.4 * ta), 1.5)
		draw_circle(combat.tracer_b, 2.5, Color(1.0, 0.85, 0.4, ta))
