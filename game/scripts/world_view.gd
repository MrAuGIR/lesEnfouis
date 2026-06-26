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
var boss_fight: BossFight      # pour connaître l'anim du Roi (phase/enrage) — branché par main
var combat: Combat             # pour connaître l'anim du héros (mêlée/tir) — branché par main

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

const BG_PANEL := 128.0   # panneau de mur du Foyer (128 px = 8 tuiles), lot modulaire v8
# Les props v8 sont exportés ~3× trop grands (échelle d'aperçu, relica de l'ancien
# fond sur-zoomé) : un terminal de 88×80 px ≈ 5 tuiles alors qu'un objet posé à côté
# d'un héros (≈1,75 tuile) doit faire ~1,5-2 tuiles. On les ramène à l'échelle monde
# au dessin (non destructif, source PNG intacte). Ajuste ce facteur au visuel.
const PROP_SCALE := 1.0 / 3.0
# 1 prop focal par TYPE de pièce : [fichier, ancrage] (ancrage "sol" ou "mur").
# Réglage purement déco — modifiable librement (ajustement au visuel).
const ROOM_PROP := {
	Foyer.ROOM_HALL: ["prop_terminal_01.png", "sol"],
	Foyer.ROOM_ATELIER: ["prop_coffret_electrique_01.png", "mur"],
	Foyer.ROOM_ENTREPOT: ["prop_etagere_chargee_01.png", "sol"],
	Foyer.ROOM_DORTOIR: ["prop_affiche_01.png", "mur"],
	Foyer.ROOM_INFIRMERIE: ["prop_lampe_murale_01.png", "mur"],
	Foyer.ROOM_FORAGE: ["prop_ventilation_01.png", "mur"],
	Foyer.ROOM_MINE: ["prop_ventilation_01.png", "mur"],
	Foyer.ROOM_DEFENSE: ["prop_coffret_electrique_01.png", "mur"],
}

# --- Décor de CAVERNE (lot designer) -----------------------------------------
const BG_ROCHE_PANEL := 256.0   # tuile de paroi roche (256 px), 3 variantes dispersées
# Props de caverne semés dans les zones creusées (échelle + densité à régler au visuel).
const CAV_PROP_SCALE := 1.0 / 5.0
const CAV_PROP_SEED := 71
const CAV_HANG := ["prop_stalactite_01.png", "prop_stalactite_02.png", "prop_racines_01.png"]
const CAV_FLOOR := ["prop_gravats_01.png", "prop_veine_minerale_01.png", "prop_veine_minerale_02.png",
	"prop_champignon_01.png", "prop_mousse_01.png", "prop_mousse_02.png",
	"prop_cristal_01.png", "prop_cristal_02.png", "prop_cristal_03.png",
	"prop_fissure_01.png", "prop_tuyau_01.png", "prop_tuyau_02.png", "prop_tuyau_03.png"]

# Mur du Foyer : remplit r en panneaux 128 px, une VARIANTE par panneau (ancré monde).
func _bg_base_blit(r: Rect2) -> void:
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return
	var x := floorf(r.position.x / BG_PANEL) * BG_PANEL
	while x < r.position.x + r.size.x:
		var y := floorf(r.position.y / BG_PANEL) * BG_PANEL
		while y < r.position.y + r.size.y:
			var panel := Rect2(x, y, BG_PANEL, BG_PANEL)
			var clip := r.intersection(panel)
			if clip.size.x > 0.0 and clip.size.y > 0.0:
				var tex := TileArt.bg_base_at(int(x / BG_PANEL), int(y / BG_PANEL))
				if tex != null:
					draw_texture_rect_region(tex, clip, Rect2(clip.position - panel.position, clip.size))
			y += BG_PANEL
		x += BG_PANEL

# Pose le prop focal d'une pièce (au sol ou accroché au mur), décalé de la trappe
# d'échelle centrale, clippé à la fenêtre. Dans la passe fond → éclairé par la lampe.
func _draw_room_prop(mp: Vector2i, dest: Rect2) -> void:
	var rt := int(foyer.rooms[mp]["type"])
	if not ROOM_PROP.has(rt):
		return
	var spec: Array = ROOM_PROP[rt]
	var tex: Texture2D = TileArt.prop(spec[0])
	if tex == null:
		return
	var ts := float(WorldGrid.TILE)
	var it: Rect2i = foyer.interior(mp)
	var ix := it.position.x * ts
	var iy := it.position.y * ts
	var iw := it.size.x * ts
	var ih := it.size.y * ts
	var sz := tex.get_size() * PROP_SCALE    # ramené à l'échelle monde (cf. PROP_SCALE)
	var px: float
	var py: float
	if spec[1] == "sol":
		px = ix + iw * 0.62 - sz.x * 0.5    # décalé à droite de la trappe centrale
		py = iy + ih - sz.y                 # pieds posés sur le sol intérieur
	else:
		px = ix + iw * 0.28 - sz.x * 0.5    # accroché en haut, à gauche du centre
		py = iy + ts * 0.5                  # un peu sous le plafond
	var r := Rect2(Vector2(roundf(px), roundf(py)), sz)
	if dest.intersects(r):
		draw_texture_rect(tex, r, false)

# Paroi roche : remplit r en panneaux 256 px, une VARIANTE par panneau (ancré monde).
func _bg_roche_blit(r: Rect2) -> void:
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return
	var x := floorf(r.position.x / BG_ROCHE_PANEL) * BG_ROCHE_PANEL
	while x < r.position.x + r.size.x:
		var y := floorf(r.position.y / BG_ROCHE_PANEL) * BG_ROCHE_PANEL
		while y < r.position.y + r.size.y:
			var panel := Rect2(x, y, BG_ROCHE_PANEL, BG_ROCHE_PANEL)
			var clip := r.intersection(panel)
			if clip.size.x > 0.0 and clip.size.y > 0.0:
				var tex := TileArt.bg_roche_at(int(x / BG_ROCHE_PANEL), int(y / BG_ROCHE_PANEL))
				if tex != null:
					draw_texture_rect_region(tex, clip, Rect2(clip.position - panel.position, clip.size))
			y += BG_ROCHE_PANEL
		x += BG_ROCHE_PANEL

# Sème les props de caverne dans les cellules creusées (roche) : stalactites/racines
# au plafond, gravats/cristaux/tuyaux au sol. Déterministe (hash de cellule) → stable.
func _draw_caverne_props(dest: Rect2) -> void:
	var ts := float(WorldGrid.TILE)
	var cx0 := int(floor(dest.position.x / ts))
	var cy0 := int(floor(dest.position.y / ts))
	var cx1 := int(ceil((dest.position.x + dest.size.x) / ts))
	var cy1 := int(ceil((dest.position.y + dest.size.y) / ts))
	for cy in range(cy0, cy1):
		if cy >= WorldGrid.TRANSIT_TOP and cy <= WorldGrid.TRANSIT_BOT:
			continue   # la bande Transit a ses propres structures
		for cx in range(cx0, cx1):
			if world.tile(cx, cy) != WorldGrid.EMPTY:
				continue
			if foyer != null and foyer.inside(Vector2(cx * ts + ts * 0.5, cy * ts + ts * 0.5)):
				continue
			var h0 := _phash(cx, cy, CAV_PROP_SEED)
			if world.is_solid(cx, cy - 1) and world.tile(cx, cy + 1) == WorldGrid.EMPTY and h0 < 0.05:
				_blit_cav_prop(CAV_HANG, cx, cy, true)
			elif world.is_solid(cx, cy + 1) and world.tile(cx, cy - 1) == WorldGrid.EMPTY and h0 >= 0.05 and h0 < 0.13:
				_blit_cav_prop(CAV_FLOOR, cx, cy, false)

func _blit_cav_prop(set: Array, cx: int, cy: int, hang: bool) -> void:
	var pick: String = set[mini(int(_phash(cx, cy, CAV_PROP_SEED + 1) * set.size()), set.size() - 1)]
	var tex: Texture2D = TileArt.caverne_prop(pick)
	if tex == null:
		return
	var ts := float(WorldGrid.TILE)
	var sz := tex.get_size() * CAV_PROP_SCALE
	var px := cx * ts + ts * 0.5 - sz.x * 0.5
	var py := cy * ts if hang else (cy + 1) * ts - sz.y   # accroché au plafond / posé au sol
	draw_texture_rect(tex, Rect2(Vector2(roundf(px), roundf(py)), sz), false)

# Hash déterministe 0..1 (même principe que TileArt._h) pour semer sans état.
func _phash(x: int, y: int, s: int) -> float:
	var n := ((x + 1) * 73856093) ^ ((y + 1) * 19349663) ^ ((s + 7) * 83492791)
	n = absi(n)
	n = (n * 1103515245 + 12345) & 0x7fffffff
	return float((n >> 8) & 0xffff) / 65535.0

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

# --- Sprites animés (pilleurs + Roi), cf. SpriteDB --------------------------------
const ATK_SHOW := 0.4   # s d'affichage de l'anim d'attaque après son déclenchement

# Horloge globale (s) pour les boucles d'anim (idle/marche…).
func _clock() -> float:
	return float(Time.get_ticks_msec()) / 1000.0

# Anim courante d'un ennemi → {entity, anim, loop, age}. {} si pas de sprite (robot).
# Dérivée des états déjà exposés (flash/hit_cd/shoot_cd/vel) — aucune IA touchée.
func _actor_anim(e: Dictionary) -> Dictionary:
	if e.get("boss", false):
		if boss_fight == null:
			return {}
		var ba: String = boss_fight.anim_name()
		return {"entity": "boss_roi", "anim": ba, "loop": SpriteDB.is_loop("boss_roi", ba),
			"age": boss_fight.anim_age()}
	var kind := int(e["kind"])
	var entity := EnemyCrew.entity_name(kind)
	if entity == "" or not SpriteDB.PIVOT.has(entity):
		return {}
	var anim := ""
	var age := 0.0
	if float(e["flash"]) > 0.0:
		anim = "touche"
	elif kind == EnemyCrew.KIND_TIREUR and float(e["shoot_cd"]) > EnemyCrew.SHOOT_CD - ATK_SHOW:
		anim = "attaque_tir"
		age = EnemyCrew.SHOOT_CD - float(e["shoot_cd"])
	elif kind != EnemyCrew.KIND_TIREUR and float(e["hit_cd"]) > EnemyCrew.ENEMY_HIT_CD - ATK_SHOW:
		anim = "attaque"
		age = EnemyCrew.ENEMY_HIT_CD - float(e["hit_cd"])
	else:
		anim = "marche" if absf(float(e["vel"].x)) > 4.0 else "idle"
	# Le Lourd : face ou dos selon son orientation par rapport au héros (dos = point faible).
	if kind == EnemyCrew.KIND_LOURD and (anim == "idle" or anim == "marche"):
		var facing_hero := signf(hero.pos.x - float(e["pos"].x)) == signf(float(e["dir"]))
		anim = ("face_" if facing_hero else "dos_") + anim
	return {"entity": entity, "anim": anim, "loop": SpriteDB.is_loop(entity, anim), "age": age}

# Dessine une frame ancrée au PIVOT (pieds), flippée selon dir (sprites = regard à droite).
func _blit_sprite(tex: Texture2D, entity: String, feet: Vector2, dir: float, flash: bool) -> void:
	var piv := SpriteDB.pivot(entity)
	var mod := Color(1.6, 1.5, 1.5) if flash else Color.WHITE
	draw_set_transform(feet, 0.0, Vector2(-1.0 if dir < 0.0 else 1.0, 1.0))
	draw_texture(tex, -piv, mod)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# Anim courante du héros → {anim, loop, age}. Dérivée des états déjà exposés
# (combat, creusage, échelle, vol, PV) — priorité du plus « fort » au plus calme.
func _hero_anim() -> Dictionary:
	if hero.hp <= 0.0:
		return {"anim": "mort", "loop": false, "age": 1.0}
	if hero.hurt_t > 0.0:
		return {"anim": "touche", "loop": false, "age": 0.25 - hero.hurt_t}
	if combat != null and combat.weapon == 0 and combat.atk_t > 0.0:
		return {"anim": "attaque", "loop": false, "age": Combat.MELEE_CD - combat.atk_cd}
	if combat != null and combat.weapon == 1 and combat.tracer_t > 0.0:
		return {"anim": "tir", "loop": false, "age": Combat.GUN_CD - combat.gun_cd}
	if hero.dig_active:
		return {"anim": "creuse", "loop": true, "age": 0.0}
	if hero.on_ladder():
		return {"anim": "echelle", "loop": true, "age": 0.0}
	if not hero.on_floor:
		return {"anim": "saut", "loop": true, "age": 0.0}
	var anim := "marche" if absf(hero.vel.x) > 4.0 else "idle"
	return {"anim": anim, "loop": true, "age": 0.0}

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
	_bg_roche_blit(dest)                                                 # roche partout (3 variantes)
	var tun := dest.intersection(Rect2(dest.position.x, WorldGrid.TRANSIT_TOP * ts,    # bande Transit
		dest.size.x, (WorldGrid.TRANSIT_BOT - WorldGrid.TRANSIT_TOP + 1) * ts))
	_bg_blit(TileArt.bg_tunnel_paroi(), tun)
	_bg_blit(TileArt.bg_tunnel_struct(), tun)
	if foyer != null:                                                    # chaque pièce du Foyer
		for mp in foyer.rooms:
			var fr: Rect2i = foyer.footprint(mp)
			_bg_base_blit(dest.intersection(
				Rect2(fr.position.x * ts, fr.position.y * ts, fr.size.x * ts, fr.size.y * ts)))
		for mp in foyer.rooms:                                              # props focaux par-dessus le mur
			_draw_room_prop(mp, dest)
	_draw_caverne_props(dest)                                            # props semés dans la roche creusée
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
			var tex := TileArt.tex_at(t, tx, ty)   # texture pixel-art (variante par cellule)
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
	# Cadavres (anim de mort) — sous les vivants, le temps de la chute
	for c in crew.corpses:
		var ctex := SpriteDB.frame_at(c["entity"], "mort", float(c["age"]))
		if ctex != null:
			_blit_sprite(ctex, c["entity"], Vector2(c["pos"]) + Vector2(0.0, Vector2(c["half"]).y),
				float(c["dir"]), false)
	# Ennemis (dans le noir : presque invisibles — leurs repères luisent, cf. marker_view)
	# Sprites animés pour les pilleurs + le Roi ; les robots gardent le rect grey-box.
	for e in crew.list:
		var ep: Vector2 = e["pos"]
		var eh: Vector2 = e["half"]
		var kind := int(e["kind"])
		var info := _actor_anim(e)
		if not info.is_empty():
			var tex: Texture2D = SpriteDB.frame(info["entity"], info["anim"], _clock(), 0.0) \
				if bool(info["loop"]) else SpriteDB.frame_at(info["entity"], info["anim"], float(info["age"]))
			if tex != null:
				_blit_sprite(tex, info["entity"], ep + Vector2(0.0, eh.y), float(e["dir"]), float(e["flash"]) > 0.0)
		else:
			var ecol := _enemy_color(kind)
			if float(e["flash"]) > 0.0:
				ecol = Color(1.0, 0.95, 0.95)
			draw_rect(Rect2(ep - eh, eh * 2.0), ecol)
			draw_rect(Rect2(ep - eh, eh * 2.0), Color(0, 0, 0, 0.5), false, 1.0)
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
	# La caravane (le marchand) — regard vers la gauche (vers le hall / le héros qui approche)
	if caravan.present:
		var mfeet := caravan.pos + Vector2(0.0, 11.0)
		var mtex: Texture2D = SpriteDB.frame("marchant", "idle", _clock(), 0.0)
		if mtex != null:
			_blit_sprite(mtex, "marchant", mfeet, -1.0, false)
		else:
			draw_rect(Rect2(caravan.pos - Vector2(7, 11), Vector2(14, 22)), Color(0.85, 0.65, 0.30))
			draw_rect(Rect2(caravan.pos - Vector2(7, 11), Vector2(14, 22)), Color(0.3, 0.2, 0.08, 0.8), false, 1.0)
	# Le héros (porteur de la lumière) — regard = direction de la lampe (visée souris)
	var hinfo := _hero_anim()
	var hdir := -1.0 if hero.aim.x < 0.0 else 1.0
	var htex: Texture2D = SpriteDB.frame("hero", hinfo["anim"], _clock(), 0.0) \
		if bool(hinfo["loop"]) else SpriteDB.frame_at("hero", hinfo["anim"], float(hinfo["age"]))
	if htex != null:
		_blit_sprite(htex, "hero", hero.pos + Vector2(0.0, hero.half.y), hdir, hero.hurt_t > 0.0)
	else:
		draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.95, 0.85, 0.5))
		draw_rect(Rect2(hero.pos - hero.half, hero.half * 2.0), Color(0.2, 0.15, 0.05, 0.8), false, 1.0)
