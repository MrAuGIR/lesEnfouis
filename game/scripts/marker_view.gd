class_name MarkerView
extends Node2D
## Calque d'infos AU-DESSUS de la lumière (monté dans un CanvasLayer en
## follow_viewport : coordonnées monde, mais non assombri par l'éclairage) :
## étiquettes, teintes de pièces, slots de construction, jauges, feedbacks de
## combat/creusage, marqueurs. Le monde éclairé, lui, vit dans world_view.gd.

const ROOM_TINTS := [
	Color(0.95, 0.75, 0.35, 0.10),   # dortoir
	Color(0.45, 0.85, 0.45, 0.10),   # production (rations)
	Color(0.95, 0.55, 0.30, 0.10),   # atelier
	Color(0.50, 0.65, 0.95, 0.10),   # entrepôt
	Color(0.75, 0.85, 0.80, 0.07),   # hall
	Color(0.95, 0.40, 0.40, 0.10),   # infirmerie
	Color(0.60, 0.62, 0.70, 0.10),   # bunker-défense
]
const ROOM_LABELS := ["DORTOIR", "PROD. RATIONS", "ATELIER", "ENTREPOT", "HALL",
	"INFIRMERIE", "BUNKER-DEF."]

var world: WorldGrid
var hero: Hero
var light: LightField
var foyer: Foyer
var pop: Population
var caravan: Caravan
var crew: EnemyCrew
var combat: Combat
var raids: Raids
var boss: BossFight

var dig_target := Vector2i(-1, -1)
var dig_frac := 0.0               # progression du creusage (0..1)
var flashes := []                 # éclats de creusage : {cell:Vector2i, t:float}
var cache_active := false         # cache de butin (mort du héros)
var cache_pos := Vector2.ZERO
var cache_range := 2.0 * WorldGrid.TILE
var build_room := -1              # mode placement : type de pièce en cours (-1 = aucun)
var build_slots := []             # mode placement : slots valides (Array de Rect2, px monde)
var loot_cell := Vector2i(-1, -1) # conteneur fouillable à portée ([E]), -1 sinon

func _light_passes(tx: int, ty: int) -> bool:
	var t := world.tile(tx, ty)
	return t == WorldGrid.EMPTY or t == WorldGrid.LADDER or t == WorldGrid.PASSERELLE

func add_flash(cell: Vector2i, dur: float) -> void:
	flashes.append({"cell": cell, "t": dur})

func tick(delta: float) -> void:
	for f in flashes:
		f.t -= delta
	flashes = flashes.filter(func(f): return f.t > 0.0)
	queue_redraw()

func _draw() -> void:
	var ts := WorldGrid.TILE
	var font := ThemeDB.fallback_font
	var ptx := int(hero.pos.x / ts)
	var pty := int(hero.pos.y / ts)
	# Éclairage de FACE : la lumière GPU s'arrête au premier bloc (ombres), on
	# redessine donc la première couche de blocs dans sa couleur, à l'intensité
	# de la lumière reçue — le joueur devine ce qu'il va miner.
	for ty in range(pty - WorldView.VIEW_RY, pty + WorldView.VIEW_RY):
		for tx in range(ptx - WorldView.VIEW_RX, ptx + WorldView.VIEW_RX):
			var t := world.tile(tx, ty)
			if t == WorldGrid.EMPTY or t == WorldGrid.LADDER or t == WorldGrid.PASSERELLE:
				continue
			if not (_light_passes(tx - 1, ty) or _light_passes(tx + 1, ty) \
					or _light_passes(tx, ty - 1) or _light_passes(tx, ty + 1)):
				continue   # bloc enfoui : il reste dans l'ombre
			var v := light.face_light(tx, ty)
			if v <= 0.04:
				continue
			var col := WorldView.tile_color(t)
			draw_rect(Rect2(tx * ts, ty * ts, ts, ts), Color(col.r, col.g, col.b, v * 0.85))
			draw_rect(Rect2(tx * ts, ty * ts, ts, ts), Color(0, 0, 0, 0.15 * v), false, 1.0)
	# Voile de gaz toxique (info de zone) au-dessus de GAS_FLOOR_ROW
	var gas_top := float((pty - WorldView.VIEW_RY) * ts)
	var gas_bot := minf(float(WorldGrid.GAS_FLOOR_ROW * ts), float((pty + WorldView.VIEW_RY) * ts))
	if gas_bot > gas_top:
		var gx := float((ptx - WorldView.VIEW_RX) * ts)
		var gw := float((WorldView.VIEW_RX * 2) * ts)
		draw_rect(Rect2(Vector2(gx, gas_top), Vector2(gw, gas_bot - gas_top)), Color(0.65, 0.62, 0.20, 0.16))
	# Sortie (objectif, en surface)
	var ex := world.exit_col()
	var exit_p := Vector2(ex * ts + ts * 0.5, world.surface[ex] * ts)
	draw_rect(Rect2(exit_p + Vector2(-WorldGrid.EXIT_HALF * ts, -3), Vector2(WorldGrid.EXIT_HALF * 2 * ts, 3)), Color(0.95, 0.85, 0.3, 0.85))
	draw_string(font, exit_p + Vector2(-14, -6), "SORTIE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.95, 0.55))
	# Le Foyer : étiquette + pièces (teinte + nom + postes occupés)
	var ho := world.hall_origin()
	draw_string(font, Vector2((ho.x + 3) * ts, ho.y * ts - 5), "LE FOYER",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.6, 1.0, 0.7))
	for mp in foyer.rooms:
		var ir := foyer.interior(mp)
		var rr := Rect2(Vector2(ir.position) * float(ts), Vector2(ir.size) * float(ts))
		var room := int(foyer.rooms[mp]["type"])
		draw_rect(rr, ROOM_TINTS[room])
		draw_rect(rr, Color(ROOM_TINTS[room].r, ROOM_TINTS[room].g, ROOM_TINTS[room].b, 0.55), false, 1.0)
		var lbl: String = ROOM_LABELS[room]
		if int(Foyer.ROOM_SLOTS[room]) > 0:
			lbl += "  %d/%d" % [pop.assigned_to(Vector2i(mp)).size(), int(Foyer.ROOM_SLOTS[room])]
		draw_string(font, rr.position + Vector2(4, 10), lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 7,
			Color(ROOM_TINTS[room].r, ROOM_TINTS[room].g, ROOM_TINTS[room].b, 0.95))
	# Mode placement : slots fantômes (celui sous la souris en surbrillance)
	if build_room >= 0:
		var mouse := get_global_mouse_position()
		for s in build_slots:
			var sr: Rect2 = s
			var hover := sr.has_point(mouse)
			draw_rect(sr, Color(0.4, 0.95, 0.5, 0.16 if hover else 0.06))
			draw_rect(sr, Color(0.4, 0.95, 0.5, 0.9 if hover else 0.35), false, 1.0)
			if hover:
				draw_string(font, sr.position + Vector2(4, 12), ROOM_LABELS[build_room] + " ICI",
					HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.75, 1.0, 0.8))
	# Cache de butin (déposée à la mort, à récupérer)
	if cache_active:
		draw_circle(cache_pos, cache_range, Color(0.95, 0.75, 0.25, 0.16))
		draw_rect(Rect2(cache_pos + Vector2(-4, -4), Vector2(8, 8)), Color(0.95, 0.8, 0.3))
	# Ennemis : repère luisant dans le noir (œil robot / frontale de pilleur) + jauge de PV
	for e in crew.list:
		var ep: Vector2 = e["pos"]
		var eh: Vector2 = e["half"]
		var kind := int(e["kind"])
		if kind == EnemyCrew.KIND_ROBOT:
			draw_rect(Rect2(ep + Vector2(float(e["dir"]) * 2.0 - 1.5, -3.0), Vector2(3, 3)), Color(1.0, 0.25, 0.15, 0.95))
		elif kind == EnemyCrew.KIND_BOSS:    # la COURONNE du Roi + son regard
			for i in 3:
				draw_rect(Rect2(ep + Vector2(-7.0 + float(i) * 5.0, -eh.y - 5.0), Vector2(3, 4)), Color(0.95, 0.78, 0.25))
			draw_rect(Rect2(ep + Vector2(-8.0, -eh.y - 2.0), Vector2(16, 2)), Color(0.95, 0.78, 0.25))
			draw_rect(Rect2(ep + Vector2(float(e["dir"]) * 4.0 - 2.0, -eh.y + 4.0), Vector2(4, 2)), Color(1.0, 0.2, 0.1, 0.95))
		elif kind == EnemyCrew.KIND_LOURD:   # visière rouge du Lourd
			draw_rect(Rect2(ep + Vector2(float(e["dir"]) * 3.0 - 2.5, -eh.y + 2.0), Vector2(5, 2)), Color(1.0, 0.2, 0.1, 0.95))
		else:   # frontale des pilleurs (ils explorent aussi dans le noir)
			draw_rect(Rect2(ep + Vector2(float(e["dir"]) * 3.0 - 1.0, -eh.y + 2.0), Vector2(2, 2)), Color(1.0, 0.85, 0.5, 0.95))
		if float(e["hp"]) < float(e["max_hp"]):
			var w := eh.x * 2.0
			var frac: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
			draw_rect(Rect2(ep + Vector2(-eh.x, -eh.y - 5.0), Vector2(w, 2)), Color(0.25, 0.0, 0.0))
			draw_rect(Rect2(ep + Vector2(-eh.x, -eh.y - 5.0), Vector2(w * frac, 2)), Color(0.95, 0.25, 0.25))
	# Tirs des pilleurs (traceurs)
	for s in crew.shots:
		var sa: float = clampf(float(s.t) / 0.12, 0.0, 1.0)
		draw_line(s.a, s.b, Color(1.0, 0.45, 0.25, 0.4 + 0.5 * sa), 1.2)
	# Légendaires captifs : étiquette + invite de libération
	for c in pop.captives:
		var cp: Vector2 = c["pos"]
		var near := hero.pos.distance_to(cp) <= 2.0 * ts
		var lbl := "[E] LIBERER" if near else "PRISONNIER"
		var lw := font.get_string_size(lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 7).x
		draw_string(font, cp + Vector2(-lw * 0.5, -Population.NPC_HALF.y - 4.0), lbl,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.9, 0.5, 0.95))
	# Conteneur fouillable à portée
	if loot_cell.x >= 0:
		draw_rect(Rect2(loot_cell.x * ts, loot_cell.y * ts, ts, ts), Color(1.0, 0.9, 0.5, 0.8), false, 1.0)
		draw_string(font, Vector2(loot_cell.x * ts - 8, loot_cell.y * ts - 4), "[E] FOUILLER",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.9, 0.5))
	# Butin de raid tombé au sol (porteur abattu) : ramassage auto au contact
	if raids != null:
		for dr in raids.drops:
			var dp: Vector2 = dr["pos"]
			draw_rect(Rect2(dp + Vector2(-4, -4), Vector2(8, 8)), Color(0.85, 0.68, 0.22))
			draw_string(font, dp + Vector2(-12, -8), "BUTIN", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.85, 0.4))
	# Le Roi des Galeries (M5) : portes, jauge d'arène, télégraphes, charge de perçage
	if boss != null:
		_draw_boss(font, float(ts))
	# Noms des PNJ (un blessé est signalé en rouge)
	for npc in pop.npcs:
		var np: Vector2 = npc["pos"]
		var nm := String(npc["name"]).split(" ")[0]
		if bool(npc.get("down", false)):
			nm += " (BLESSE)"
		var nw := font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 6).x
		var ncol := Color(0.95, 0.45, 0.40, 0.95) if bool(npc.get("down", false)) \
			else Color(0.8, 0.88, 0.95, 0.9)
		draw_string(font, np + Vector2(-nw * 0.5, -Population.NPC_HALF.y - 3.0), nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, ncol)
	# Caravane : étiquette + zone de troc
	if caravan.present:
		draw_circle(caravan.pos, Caravan.TRADE_RANGE, Color(0.9, 0.7, 0.3, 0.07))
		draw_string(font, caravan.pos + Vector2(-26, -16), "CARAVANE [E]", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.85, 0.5))
	# Éclats de creusage (feedback de cassage)
	for f in flashes:
		var a: float = clampf(f.t / 0.18, 0.0, 1.0)
		draw_rect(Rect2(f.cell.x * ts, f.cell.y * ts, ts, ts), Color(1.0, 0.9, 0.6, a * 0.7))
	# Cible de creusage + progression
	if dig_target.x >= 0:
		var rpos := Vector2(dig_target.x * ts, dig_target.y * ts)
		draw_rect(Rect2(rpos, Vector2(ts, ts)), Color(1, 1, 1, 0.15 + 0.35 * clampf(dig_frac, 0.0, 1.0)))
		draw_rect(Rect2(rpos, Vector2(ts, ts)), Color(1, 1, 1, 0.7), false, 1.0)
	# Arc de coup (mêlée) + traceur de tir
	if combat.atk_t > 0.0:
		var aa: float = clampf(combat.atk_t / Combat.MELEE_VIS, 0.0, 1.0)
		draw_circle(hero.pos + hero.aim * Combat.MELEE_RANGE * 0.55, Combat.MELEE_RANGE * 0.5, Color(1.0, 1.0, 1.0, 0.20 * aa))
	if combat.tracer_t > 0.0:
		var ta: float = clampf(combat.tracer_t / Combat.GUN_TRACER_T, 0.0, 1.0)
		draw_line(combat.tracer_a, combat.tracer_b, Color(1.0, 0.9, 0.4, 0.5 + 0.4 * ta), 1.5)
		draw_circle(combat.tracer_b, 2.5, Color(1.0, 0.85, 0.4, ta))

func _draw_boss(font: Font, ts: float) -> void:
	var gold := Color(1.0, 0.85, 0.4)
	# Invite sur les portes scellées/ouvertes
	if boss.state == BossFight.ST_SEALED or boss.state == BossFight.ST_OPEN:
		var dc := boss.door_center()
		if hero.pos.distance_to(dc) <= 8.0 * ts:
			var lbl := "[E] TERMINAL DU ROI DES GALERIES" if boss.state == BossFight.ST_SEALED \
				else "ENTRE ! (les portes ne resteront pas ouvertes...)"
			var lw := font.get_string_size(lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
			draw_string(font, dc + Vector2(-lw * 0.5, -3.0 * ts), lbl,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.55, 0.45))
			if boss.state == BossFight.ST_SEALED:
				draw_string(font, dc + Vector2(-lw * 0.5, -3.0 * ts + 9.0),
					"il ne laissera personne ressortir", HORIZONTAL_ALIGNMENT_LEFT, -1, 7,
					Color(1.0, 0.55, 0.45, 0.8))
	var a: Rect2i = world.boss_arena
	# Combat : grande jauge du Roi au-dessus de l'arène + point d'exclamation télégraphié
	if boss.state == BossFight.ST_FIGHT and boss.boss != null:
		var frac: float = clampf(float(boss.boss["hp"]) / float(boss.boss["max_hp"]), 0.0, 1.0)
		var bx := float(a.position.x) * ts
		var by := float(a.position.y) * ts - 10.0
		var bw := float(a.size.x) * ts
		draw_rect(Rect2(bx, by, bw, 5.0), Color(0.2, 0.02, 0.02, 0.9))
		draw_rect(Rect2(bx, by, bw * frac, 5.0), Color(0.85, 0.15, 0.20))
		draw_rect(Rect2(bx, by, bw, 5.0), Color(0, 0, 0, 0.8), false, 1.0)
		draw_string(font, Vector2(bx, by - 3.0), "LE ROI DES GALERIES" + ("  — ENRAGE" if boss.enraged else ""),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.35, 0.35))
		if boss.phase == BossFight.P_TELEGRAPH:
			var bp: Vector2 = boss.boss["pos"]
			draw_string(font, bp + Vector2(-3.0, -float(Vector2(boss.boss["half"]).y) - 10.0), "!",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.25, 0.15))
	# Onde de la frappe au sol
	if boss.slam_t > 0.0:
		var sf: float = 1.0 - boss.slam_t / 0.35
		draw_arc(boss.slam_pos, BossFight.SLAM_RANGE * ts * maxf(sf, 0.15), PI, TAU, 24,
			Color(1.0, 0.7, 0.3, 0.7 * (1.0 - sf)), 2.0)
	# Gravats : ombre télégraphiée au sol, puis la pierre qui tombe
	for d in boss.debris:
		var p: Vector2 = d["pos"]
		if float(d["warn"]) > 0.0:
			var c := Vector2i(int(p.x / ts), int(p.y / ts))
			var fy := c.y
			while not world.is_solid(c.x, fy + 1) and fy < c.y + 12:
				fy += 1
			var pulse := 0.35 + 0.45 * (1.0 - float(d["warn"]) / BossFight.DEBRIS_WARN)
			draw_rect(Rect2(c.x * ts + 2.0, (fy + 1) * ts - 4.0, ts - 4.0, 3.0),
				Color(1.0, 0.4, 0.2, pulse))
		else:
			draw_rect(Rect2(p - BossFight.DEBRIS_HALF, BossFight.DEBRIS_HALF * 2.0), Color(0.45, 0.42, 0.40))
			draw_rect(Rect2(p - BossFight.DEBRIS_HALF, BossFight.DEBRIS_HALF * 2.0), Color(0.1, 0.1, 0.1, 0.8), false, 1.0)
	# Jets de vapeur (enrage) : sifflement puis colonne brûlante
	if boss.state == BossFight.ST_FIGHT and boss.enraged:
		for v in boss.vents:
			var c2: Vector2i = v["cell"]
			var ph: int = boss.vent_phase(v)
			if ph == 1:
				draw_rect(Rect2(c2.x * ts + 5.0, (c2.y + 1) * ts - 4.0, ts - 10.0, 4.0),
					Color(1.0, 0.6, 0.2, 0.8))
			elif ph == 2:
				var r := Rect2(c2.x * ts, float(c2.y - BossFight.VENT_H + 1) * ts, ts, float(BossFight.VENT_H) * ts)
				draw_rect(r, Color(0.95, 0.95, 1.0, 0.45))
				draw_rect(r, Color(1.0, 1.0, 1.0, 0.7), false, 1.0)
	# La charge de perçage (la clé de la surface), à ramasser au contact
	if boss.state == BossFight.ST_DEAD and not boss.charge_taken:
		draw_circle(boss.charge_pos, 1.5 * ts, Color(1.0, 0.8, 0.3, 0.10))
		draw_rect(Rect2(boss.charge_pos + Vector2(-4, -4), Vector2(8, 8)), gold)
		draw_rect(Rect2(boss.charge_pos + Vector2(-4, -4), Vector2(8, 8)), Color(0.4, 0.25, 0.05), false, 1.0)
		draw_string(font, boss.charge_pos + Vector2(-38.0, -10.0), "CHARGE DE PERCAGE",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 7, gold)
