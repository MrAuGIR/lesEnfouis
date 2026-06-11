class_name WorldView
extends Node2D
## Rendu du MONDE éclairé (grey-box) : ciel/fond de caverne, tuiles, torches,
## robots, PNJ, caravane, héros — dessinés en PLEINE couleur : c'est l'éclairage
## (lights.gd) qui révèle. Les marqueurs/infos par-dessus vivent dans
## marker_view.gd (non assombris). Gère aussi les OCCULTEURS d'ombres : les
## blocs pleins arrêtent la lumière (échelles et passerelles la laissent passer).

const VIEW_RX := 34   # demi-largeur de la fenêtre de tuiles dessinées
const VIEW_RY := 22
const OCC_MARGIN := 6 # marge d'occulteurs autour de la fenêtre (lumières proches)

var world: WorldGrid
var hero: Hero
var light: LightField          # registre des torches posées
var crew: EnemyCrew
var pop: Population
var caravan: Caravan

var _occluders: Array[LightOccluder2D] = []
var _occ_center := Vector2i(-9999, -9999)
var _occ_dirty := true

func tick(_delta: float) -> void:
	queue_redraw()
	var c := Vector2i(int(hero.pos.x / WorldGrid.TILE), int(hero.pos.y / WorldGrid.TILE))
	if _occ_dirty or c != _occ_center:
		_occ_center = c
		_occ_dirty = false
		_rebuild_occluders()

# À appeler quand le monde change (creusage, construction, échelle, passerelle).
func mark_dirty() -> void:
	_occ_dirty = true

# --- Occulteurs : meshing glouton des blocs pleins en rectangles -------------------
func _occludes(tx: int, ty: int) -> bool:
	var t := world.tile(tx, ty)
	return t != WorldGrid.EMPTY and t != WorldGrid.LADDER and t != WorldGrid.PASSERELLE \
		and ty >= 0 and ty < WorldGrid.GRID_H and tx >= 0 and tx < WorldGrid.GRID_W

func _rebuild_occluders() -> void:
	var ts := float(WorldGrid.TILE)
	var x0 := _occ_center.x - VIEW_RX - OCC_MARGIN
	var x1 := _occ_center.x + VIEW_RX + OCC_MARGIN
	var y0 := _occ_center.y - VIEW_RY - OCC_MARGIN
	var y1 := _occ_center.y + VIEW_RY + OCC_MARGIN
	var w := x1 - x0 + 1
	var used := {}
	var n := 0
	for ty in range(y0, y1 + 1):
		for tx in range(x0, x1 + 1):
			var idx := (ty - y0) * w + (tx - x0)
			if used.has(idx) or not _occludes(tx, ty):
				continue
			# Étend la rangée vers la droite, puis le bloc vers le bas (glouton)
			var rw := 1
			while tx + rw <= x1 and not used.has(idx + rw) and _occludes(tx + rw, ty):
				rw += 1
			var rh := 1
			while ty + rh <= y1:
				var full := true
				for k in rw:
					if used.has(idx + rh * w + k) or not _occludes(tx + k, ty + rh):
						full = false
						break
				if not full:
					break
				rh += 1
			for ry in rh:
				for rx in rw:
					used[idx + ry * w + rx] = true
			_set_occluder(n, Rect2(tx * ts, ty * ts, rw * ts, rh * ts))
			n += 1
	for i in range(n, _occluders.size()):
		_occluders[i].visible = false

func _set_occluder(i: int, r: Rect2) -> void:
	while _occluders.size() <= i:
		var o := LightOccluder2D.new()
		o.occluder = OccluderPolygon2D.new()
		add_child(o)
		_occluders.append(o)
	var occ := _occluders[i]
	occ.visible = true
	(occ.occluder as OccluderPolygon2D).polygon = PackedVector2Array([
		r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])

# --- Dessin -------------------------------------------------------------------
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
	# Fond : caverne (révélé par la lampe) + bandes de ciel au-dessus du relief
	var bg_pos := Vector2((ptx - VIEW_RX) * ts, (pty - VIEW_RY) * ts)
	var bg_size := Vector2((VIEW_RX * 2) * ts, (VIEW_RY * 2) * ts)
	draw_rect(Rect2(bg_pos, bg_size), Color(0.16, 0.17, 0.20))
	for tx in range(ptx - VIEW_RX, ptx + VIEW_RX):
		var s := world.surface[clampi(tx, 0, WorldGrid.GRID_W - 1)]
		if s > pty - VIEW_RY:
			draw_rect(Rect2(tx * ts, (pty - VIEW_RY) * ts, ts, (mini(s, pty + VIEW_RY) - (pty - VIEW_RY)) * ts),
				Color(0.55, 0.62, 0.72))
	# Tuiles (pleine couleur — la lumière fait le reste)
	for ty in range(pty - VIEW_RY, pty + VIEW_RY):
		for tx in range(ptx - VIEW_RX, ptx + VIEW_RX):
			var rect := Rect2(tx * ts, ty * ts, ts, ts)
			var t := world.tile(tx, ty)
			if t == WorldGrid.EMPTY:
				continue
			if t == WorldGrid.LADDER:
				var lc := Color(0.78, 0.56, 0.30)
				draw_rect(Rect2(tx * ts + 3, ty * ts, 2, ts), lc)
				draw_rect(Rect2(tx * ts + ts - 5, ty * ts, 2, ts), lc)
				draw_rect(Rect2(tx * ts + 3, ty * ts + 4, ts - 8, 2), lc)
				draw_rect(Rect2(tx * ts + 3, ty * ts + 10, ts - 8, 2), lc)
				continue
			if t == WorldGrid.PASSERELLE:
				if world.is_ladder_crossing(tx, ty):
					# Croisement : l'échelle continue derrière, la passerelle DEVANT
					var lc2 := Color(0.78, 0.56, 0.30)
					draw_rect(Rect2(tx * ts + 3, ty * ts, 2, ts), lc2)
					draw_rect(Rect2(tx * ts + ts - 5, ty * ts, 2, ts), lc2)
					draw_rect(Rect2(tx * ts, ty * ts + 5, ts, 6), Color(0.50, 0.36, 0.16))
					draw_rect(Rect2(tx * ts, ty * ts + 5, ts, 6), Color(0.7, 0.55, 0.28, 0.8), false, 1.0)
					continue
				draw_rect(rect, Color(0.50, 0.36, 0.16))
				draw_rect(Rect2(tx * ts, ty * ts + 4, ts, 1), Color(0.24, 0.16, 0.06))
				draw_rect(Rect2(tx * ts, ty * ts + 10, ts, 1), Color(0.24, 0.16, 0.06))
				draw_rect(rect, Color(0.7, 0.55, 0.28, 0.8), false, 1.0)
				continue
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
			draw_rect(rect, col)
			draw_rect(rect, Color(0, 0, 0, 0.15), false, 1.0)
	# Torches posées (le bâton ; la lumière vient de lights.gd)
	for c in light.torches:
		var tc := Vector2(c.x * ts + ts * 0.5, c.y * ts + ts * 0.5)
		draw_rect(Rect2(tc + Vector2(-2, -5), Vector2(4, 10)), Color(1.0, 0.75, 0.35))
	# Robots (dans le noir : presque invisibles — leurs yeux luisent, cf. marker_view)
	for e in crew.list:
		var ep: Vector2 = e["pos"]
		var eh := EnemyCrew.ENEMY_HALF
		var ecol := Color(1.0, 0.95, 0.95) if float(e["flash"]) > 0.0 else Color(0.85, 0.30, 0.25)
		draw_rect(Rect2(ep - eh, eh * 2.0), ecol)
		draw_rect(Rect2(ep - eh, eh * 2.0), Color(0, 0, 0, 0.5), false, 1.0)
	# PNJ du Foyer
	for npc in pop.npcs:
		var np: Vector2 = npc["pos"]
		draw_rect(Rect2(np - Population.NPC_HALF, Population.NPC_HALF * 2.0), Color(0.62, 0.78, 0.92))
		draw_rect(Rect2(np - Population.NPC_HALF, Population.NPC_HALF * 2.0), Color(0, 0, 0, 0.5), false, 1.0)
	# La caravane (le marchand)
	if caravan.present:
		draw_rect(Rect2(caravan.pos - Vector2(7, 11), Vector2(14, 22)), Color(0.85, 0.65, 0.30))
		draw_rect(Rect2(caravan.pos - Vector2(7, 11), Vector2(14, 22)), Color(0.3, 0.2, 0.08, 0.8), false, 1.0)
	# Le héros (porteur de la lumière)
	draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.95, 0.85, 0.5))
	draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.2, 0.15, 0.05, 0.8), false, 1.0)
