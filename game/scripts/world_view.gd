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
# Décor de fond : dessiné PAR ZONE (roche partout, bande Transit, pièces du Foyer) et
# ANCRÉ AU MONDE — pas de parallaxe ; chaque région garde son propre fond où qu'on soit.

var world: WorldGrid
var hero: Hero
var light: LightField          # registre des torches posées
var crew: EnemyCrew
var pop: Population
var caravan: Caravan
var foyer: Foyer               # pour dessiner le fond des pièces de base à leur place

var _occluders: Array[LightOccluder2D] = []
var _occ_center := Vector2i(-9999, -9999)
var _occ_dirty := true

func _ready() -> void:
	# Tiling des fonds (draw_texture_rect_region répété).
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

# Pose une texture de fond TUILÉE et ANCRÉE AU MONDE sur le rectangle r (coords monde) :
# la région source démarre à r.position → continuité parfaite entre régions, zéro parallaxe.
func _bg_blit(tex: Texture2D, r: Rect2) -> void:
	if tex != null and r.size.x > 0.0 and r.size.y > 0.0:
		draw_texture_rect_region(tex, r, Rect2(r.position, r.size))

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
static func _enemy_color(kind: int) -> Color:
	match kind:
		EnemyCrew.KIND_FONCEUR: return Color(0.72, 0.48, 0.32)   # cuir de pilleur
		EnemyCrew.KIND_TIREUR: return Color(0.55, 0.58, 0.38)    # treillis olive
		EnemyCrew.KIND_LOURD: return Color(0.45, 0.48, 0.55)     # acier
		EnemyCrew.KIND_BOSS: return Color(0.48, 0.18, 0.26)      # pourpre du Roi
	return Color(0.85, 0.30, 0.25)                               # robot

# Palette des blocs (partagée avec l'éclairage de face de marker_view.gd)
static func tile_color(t: int) -> Color:
	match t:
		WorldGrid.ROCK: return Color(0.40, 0.42, 0.46)
		WorldGrid.WOOD: return Color(0.55, 0.38, 0.15)
		WorldGrid.LITHIUM: return Color(0.45, 0.74, 0.80)
		WorldGrid.WALL: return Color(0.30, 0.34, 0.42)
		WorldGrid.HARDROCK: return Color(0.18, 0.20, 0.26)
		WorldGrid.IRON: return Color(0.58, 0.40, 0.30)
		WorldGrid.CRATE: return Color(0.52, 0.38, 0.18)
		WorldGrid.CRATE_OPEN: return Color(0.30, 0.25, 0.15)
		WorldGrid.BOSS_DOOR: return Color(0.40, 0.17, 0.14)
	return Color(0.42, 0.30, 0.20)   # terre

func _draw() -> void:
	var ts := WorldGrid.TILE
	var ptx := int(hero.pos.x / ts)
	var pty := int(hero.pos.y / ts)
	# Fond : décor en RETRAIT (révélé par la lampe) — base sombre + paroi rocheuse
	# + silhouettes d'infrastructure, en PARALLAXE (région source décalée d'une
	# fraction de la position du héros) → profondeur. Puis bandes de ciel au-dessus.
	var bg_pos := Vector2((ptx - VIEW_RX) * ts, (pty - VIEW_RY) * ts)
	var bg_size := Vector2((VIEW_RX * 2) * ts, (VIEW_RY * 2) * ts)
	var dest := Rect2(bg_pos, bg_size)
	draw_rect(dest, Color(0.10, 0.11, 0.13))   # base sombre commune (jamais de trou)
	# Fond PAR ZONE (chacune à sa place, où que soit le héros) :
	_bg_blit(TileArt.bg_roche(), dest)                                   # roche partout (défaut)
	var tun := dest.intersection(Rect2(dest.position.x, WorldGrid.TRANSIT_TOP * ts,    # bande Transit
		dest.size.x, (WorldGrid.TRANSIT_BOT - WorldGrid.TRANSIT_TOP + 1) * ts))
	_bg_blit(TileArt.bg_tunnel_paroi(), tun)
	_bg_blit(TileArt.bg_tunnel_struct(), tun)
	if foyer != null:                                                    # chaque pièce du Foyer
		for mp in foyer.rooms:
			var fr: Rect2i = foyer.footprint(mp)
			_bg_blit(TileArt.bg_base(), dest.intersection(
				Rect2(fr.position.x * ts, fr.position.y * ts, fr.size.x * ts, fr.size.y * ts)))
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
				draw_texture_rect(TileArt.tex(WorldGrid.LADDER), rect, false)
				continue
			if t == WorldGrid.PASSERELLE:
				if world.is_ladder_crossing(tx, ty):
					# Croisement : l'échelle continue derrière, la passerelle DEVANT (bande)
					draw_texture_rect(TileArt.tex(WorldGrid.LADDER), rect, false)
					draw_texture_rect_region(TileArt.tex(WorldGrid.PASSERELLE),
						Rect2(tx * ts, ty * ts + 5, ts, 6), Rect2(0, 0, ts, 6))
					continue
				draw_texture_rect(TileArt.tex(WorldGrid.PASSERELLE), rect, false)
				continue
			# Caisses [E] et portes du boss : désormais texturées (cf. TileArt),
			# elles passent par la branche générique ci-dessous.
			var tex := TileArt.tex(t)   # texture pixel-art (grain, minerais, biseau)
			if tex != null:
				draw_texture_rect(tex, rect, false)
			else:
				draw_rect(rect, tile_color(t))
				draw_rect(rect, Color(0, 0, 0, 0.15), false, 1.0)
	# Rails du métro (Transit) : posés sur le sol des tunnels, clippés à la vue
	for m in world.metro_rects:
		var mr: Rect2i = m
		var fy := float(mr.position.y + mr.size.y) * ts   # haut de la rangée du sol
		var rx0 := maxi(mr.position.x, ptx - VIEW_RX) * ts
		var rx1 := mini(mr.position.x + mr.size.x, ptx + VIEW_RX) * ts
		if rx1 <= rx0 or fy < (pty - VIEW_RY) * ts or fy > (pty + VIEW_RY) * ts:
			continue
		var tie_x := rx0 - (int(rx0) % 10)
		while tie_x < rx1:   # traverses
			draw_rect(Rect2(tie_x, fy - 2.0, 5.0, 2.0), Color(0.32, 0.24, 0.14))
			tie_x += 10.0
		draw_rect(Rect2(rx0, fy - 3.5, rx1 - rx0, 1.5), Color(0.55, 0.58, 0.62))
	# Torches posées (le bâton ; la lumière vient de lights.gd)
	for c in light.torches:
		var tc := Vector2(c.x * ts + ts * 0.5, c.y * ts + ts * 0.5)
		draw_rect(Rect2(tc + Vector2(-2, -5), Vector2(4, 10)), Color(1.0, 0.75, 0.35))
	# Ennemis (dans le noir : presque invisibles — leurs repères luisent, cf. marker_view)
	for e in crew.list:
		var ep: Vector2 = e["pos"]
		var eh: Vector2 = e["half"]
		var kind := int(e["kind"])
		var ecol := _enemy_color(kind)
		if float(e["flash"]) > 0.0:
			ecol = Color(1.0, 0.95, 0.95)
		draw_rect(Rect2(ep - eh, eh * 2.0), ecol)
		draw_rect(Rect2(ep - eh, eh * 2.0), Color(0, 0, 0, 0.5), false, 1.0)
		if kind == EnemyCrew.KIND_LOURD:
			# Plaque de blindage du côté qu'il regarde (le dos est le point faible)
			var fx := ep.x + float(e["dir"]) * eh.x - (3.0 if float(e["dir"]) > 0.0 else 0.0)
			draw_rect(Rect2(fx, ep.y - eh.y, 3.0, eh.y * 2.0), Color(0.22, 0.24, 0.30))
		if not (e.get("carry", {}) as Dictionary).is_empty():
			# Porteur de raid chargé : le sac de butin sur le dos
			var bx := ep.x - float(e["dir"]) * (eh.x + 2.0) - 2.5
			draw_rect(Rect2(bx, ep.y - eh.y + 2.0, 5.0, 6.0), Color(0.75, 0.62, 0.25))
	# PNJ du Foyer (un blessé est couché au sol)
	for npc in pop.npcs:
		var np: Vector2 = npc["pos"]
		if bool(npc.get("down", false)):
			var lying := Rect2(np + Vector2(-Population.NPC_HALF.y, Population.NPC_HALF.y - 8.0),
				Vector2(Population.NPC_HALF.y * 2.0, 8.0))
			draw_rect(lying, Color(0.55, 0.55, 0.62))
			draw_rect(lying, Color(0.6, 0.15, 0.15, 0.8), false, 1.0)
			continue
		draw_rect(Rect2(np - Population.NPC_HALF, Population.NPC_HALF * 2.0), Color(0.62, 0.78, 0.92))
		draw_rect(Rect2(np - Population.NPC_HALF, Population.NPC_HALF * 2.0), Color(0, 0, 0, 0.5), false, 1.0)
	# Légendaires captifs (dorés — leur lueur vient de lights.gd)
	for c in pop.captives:
		var cp: Vector2 = c["pos"]
		draw_rect(Rect2(cp - Population.NPC_HALF, Population.NPC_HALF * 2.0), Color(0.95, 0.82, 0.40))
		draw_rect(Rect2(cp - Population.NPC_HALF, Population.NPC_HALF * 2.0), Color(0.4, 0.3, 0.05, 0.8), false, 1.0)
	# La caravane (le marchand)
	if caravan.present:
		draw_rect(Rect2(caravan.pos - Vector2(7, 11), Vector2(14, 22)), Color(0.85, 0.65, 0.30))
		draw_rect(Rect2(caravan.pos - Vector2(7, 11), Vector2(14, 22)), Color(0.3, 0.2, 0.08, 0.8), false, 1.0)
	# Le héros (porteur de la lumière)
	draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.95, 0.85, 0.5))
	draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.2, 0.15, 0.05, 0.8), false, 1.0)
