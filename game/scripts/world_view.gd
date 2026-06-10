class_name WorldView
extends Node2D
## Rendu grey-box du monde : tuiles éclairées, héros, repères (base, sortie),
## feedback de creusage. Aucune logique de jeu — il lit l'état et dessine.

const VIEW_RX := 34   # demi-largeur de la fenêtre de tuiles dessinées
const VIEW_RY := 22

var world: WorldGrid
var hero: Hero
var light: LightField

var base_pos := Vector2.ZERO
var dig_target := Vector2i(-1, -1)
var dig_frac := 0.0               # progression du creusage (0..1)
var flashes := []                 # éclats de creusage : {cell:Vector2i, t:float}

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
	# Repères : base (départ, en profondeur) et sortie (objectif, en surface)
	var font := ThemeDB.fallback_font
	var ex := world.exit_col()
	var exit_p := Vector2(ex * ts + ts * 0.5, world.surface[ex] * ts)
	draw_rect(Rect2(exit_p + Vector2(-WorldGrid.EXIT_HALF * ts, -3), Vector2(WorldGrid.EXIT_HALF * 2 * ts, 3)), Color(0.95, 0.85, 0.3, 0.85))
	draw_string(font, exit_p + Vector2(-14, -6), "SORTIE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.95, 0.55))
	draw_circle(base_pos, 2.6 * ts, Color(0.3, 0.9, 0.4, 0.08))
	draw_rect(Rect2(base_pos + Vector2(-9, -3), Vector2(18, 6)), Color(0.3, 0.85, 0.4))
	draw_string(font, base_pos + Vector2(-12, -7), "BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.6, 1.0, 0.7))
	# Halo central + héros (le héros porte la lumière ; le halo faiblit avec le carburant)
	draw_circle(hero.pos, LightField.LAMP_AMBIENT_CORE * ts, Color(1.0, 0.93, 0.78, 0.07 * hero.lamp_factor))
	draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.95, 0.85, 0.5))
	draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.2, 0.15, 0.05, 0.8), false, 1.0)
