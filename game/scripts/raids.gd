class_name Raids
extends RefCounted
## Les raids (M4) : à intervalles réguliers (intensité croissante), des pilleurs
## partent des bouts des tunnels de métro et convergent vers le hall du Foyer en
## suivant le terrain OUVERT (tunnels creusés, échelles, passerelles — BFS façon
## plateforme : on monte par les échelles ou une marche d'une tuile, on descend
## en se laissant tomber). Annonce + compte à rebours, puis PORTEURS : un
## assaillant qui atteint le dépôt se charge de ressources et fuit vers son
## tunnel — le tuer fait tomber le butin (récupérable au contact) ; le vol n'est
## consommé que s'il s'échappe. Les PNJ affectés au BUNKER-DÉFENSE tirent
## automatiquement (dégâts selon leur stat Garde). Les PNJ touchés tombent
## BLESSÉS (infirmerie) — jamais de mort définitive (GDD 03).
## Les assaillants vivent dans crew.list (combat et rendu inchangés) mais sont
## pilotés ici, en cinématique le long de leur chemin (flag "raid").

const RAID_GRACE := 150.0    # s avant le 1er raid — CONFORT DE TEST (M6)
const RAID_PERIOD := 150.0   # s entre deux raids — CONFORT DE TEST (M6)
const ALERT_TIME := 60.0     # s d'alerte avant l'assaut (le temps de rentrer)
const RETRY_TIME := 45.0     # s avant de retester quand aucun chemin n'existe
const WAVE_BASE := 3         # taille de la 1re vague…
const WAVE_MAX := 8          # …et plafond
const LOURD_FROM_WAVE := 3   # un Lourd porteur mène l'assaut à partir de cette vague
const CARRY_MAX := 8         # ressources emportées par porteur
const FLEE_MULT := 0.85      # un porteur chargé ralentit
const FALL_MULT := 2.2       # descente le long du chemin (chute)
const PAUSE_AFTER_HIT := 0.5 # s d'arrêt après un coup porté
const SPAWN_STAGGER := 1.2   # s entre deux entrées d'assaillants (vague étalée)
const DEF_RANGE := 12.0      # tuiles : portée de tir du bunker-défense
const DEF_CD := 1.4          # s entre deux tirs d'un garde posté
const DEF_DMG_BASE := 4.0    # dégâts d'un tir = base + Garde * bonus
const DEF_DMG_GARDE := 4.0
const DEF_SCRAP := 2         # ferraille récupérée par les gardes sur leurs victimes
const PICKUP_RANGE := 1.5    # tuiles : ramassage auto du butin tombé
const BFS_LIMIT := 24000     # garde-fou du pathfinding

const ST_IDLE := 0
const ST_ALERT := 1
const ST_ACTIVE := 2

var world: WorldGrid
var foyer: Foyer
var pop: Population
var crew: EnemyCrew
var hero: Hero
var light: LightField
var bag: Inventory

var state := ST_IDLE
var timer := RAID_GRACE
var wave := 0
var stolen_total := 0        # ressources réellement parties pendant le raid en cours
var drops := []              # butin tombé : {"pos": Vector2, "carry": Dictionary}
var no_path_warned := false

func _init(w: WorldGrid, f: Foyer, p: Population, c: EnemyCrew, h: Hero,
		l: LightField, b: Inventory) -> void:
	world = w
	foyer = f
	pop = p
	crew = c
	hero = h
	light = l
	bag = b

# --- Boucle (appelée par main, figée quand un écran est ouvert) ---------------------
func update(delta: float) -> Array:
	var msgs := []
	match state:
		ST_IDLE:
			timer -= delta
			if timer <= 0.0:
				_try_alert(msgs)
		ST_ALERT:
			timer -= delta
			if timer <= 0.0:
				_launch(msgs)
		ST_ACTIVE:
			_run_raiders(delta, msgs)
			_run_defense(delta)
			if _raider_count() == 0:
				state = ST_IDLE
				timer = RAID_PERIOD
				if stolen_total > 0:
					msgs.append("Le raid est fini : les pilleurs ont emporte %d ressource(s)..." % stolen_total)
				else:
					msgs.append("*** RAID REPOUSSE ! Le Foyer est sauf. ***")
	_pickup_drops(msgs)
	return msgs

func status_text() -> String:
	match state:
		ST_ALERT:
			return "!! RAID DANS %d s !!" % maxi(0, ceili(timer))
		ST_ACTIVE:
			return "!! RAID EN COURS : %d assaillant(s) !!" % _raider_count()
	return "prochain raid : %d s" % maxi(0, ceili(timer))

func _raider_count() -> int:
	var n := 0
	for e in crew.list:
		if e.get("raid", false):
			n += 1
	return n

# --- Déclenchement -------------------------------------------------------------------
func _try_alert(msgs: Array) -> void:
	# Pas de chemin ouvert jusqu'au hall = pas de raid : les pilleurs suivent
	# TES tunnels. On retente régulièrement (le joueur finit par percer).
	if _spawns_with_path().is_empty():
		timer = RETRY_TIME
		if not no_path_warned:
			no_path_warned = true
			msgs.append("Des pilleurs rodent dans les tunnels... (aucun passage vers le Foyer pour l'instant)")
		return
	state = ST_ALERT
	timer = ALERT_TIME
	msgs.append("!! ALERTE : des pilleurs se rassemblent dans les tunnels — RAID dans %d s !!" % int(ALERT_TIME))

func _launch(msgs: Array) -> void:
	var spawns := _spawns_with_path()
	if spawns.is_empty():   # passage rebouché pendant l'alerte (passerelle...)
		state = ST_IDLE
		timer = RAID_PERIOD
		msgs.append("Les pilleurs n'ont pas trouve de passage : raid annule.")
		return
	wave += 1
	stolen_total = 0
	var count := mini(WAVE_BASE + (wave - 1), WAVE_MAX)
	for i in count:
		var sp: Dictionary = spawns[i % spawns.size()]
		var kind := EnemyCrew.KIND_LOURD if wave >= LOURD_FROM_WAVE and i == 0 \
			else EnemyCrew.KIND_FONCEUR
		_add_raider(sp, kind, float(i) * SPAWN_STAGGER)
	state = ST_ACTIVE
	msgs.append("!! LE RAID EST LA : %d assaillant(s) ! Defends le depot du Foyer !" % count)

func _add_raider(sp: Dictionary, kind: int, pause: float) -> void:
	var cell: Vector2i = sp["cell"]
	var half: Vector2 = EnemyCrew.K_HALF[kind]
	crew.list.append({"kind": kind, "pos": _cell_pos(cell, half), "vel": Vector2.ZERO,
		"hp": EnemyCrew.K_HP[kind], "max_hp": EnemyCrew.K_HP[kind], "half": half,
		"speed": EnemyCrew.K_SPEED[kind], "dmg": EnemyCrew.K_DMG[kind],
		"dir": 1.0, "on_floor": true, "blocked": false, "hit_cd": 0.0, "flash": 0.0,
		"anchor": null, "shoot_cd": 0.0,
		"raid": true, "path": sp["path"], "wp": 0, "fleeing": false,
		"carry": {}, "pause": pause, "spawn": cell})

# --- Assaillants (cinématique le long du chemin + contact) ---------------------------
func _run_raiders(delta: float, msgs: Array) -> void:
	var keep := []
	for e in crew.list:
		if not e.get("raid", false):
			keep.append(e)
			continue
		if float(e["hp"]) <= 0.0:   # abattu par le bunker-défense (le héros passe par combat)
			_drop_carry(e)
			foyer.add(Inventory.FERRAILLE, DEF_SCRAP)   # les gardes récupèrent la ferraille
			msgs.append("Un assaillant abattu par la garde du Foyer !")
			continue
		e["hit_cd"] = maxf(0.0, float(e["hit_cd"]) - delta)
		e["flash"] = maxf(0.0, float(e["flash"]) - delta)
		_contact(e, msgs)
		if float(e["pause"]) > 0.0:
			e["pause"] = float(e["pause"]) - delta
			keep.append(e)
			continue
		if not _follow(e, delta):
			keep.append(e)
			continue
		if not bool(e["fleeing"]):   # arrivé au dépôt : il se charge et fait demi-tour
			_grab(e, msgs)
			keep.append(e)
		else:                        # sorti par son tunnel : le vol est consommé
			var n := _carry_total(e["carry"])
			stolen_total += n
			if n > 0:
				msgs.append("Un porteur s'est enfui avec %s !" % _carry_text(e["carry"]))
	crew.list = keep

func _contact(e: Dictionary, msgs: Array) -> void:
	if float(e["hit_cd"]) > 0.0:
		return
	var half: Vector2 = e["half"]
	if EnemyCrew._aabb_overlap(hero.pos, hero.half, e["pos"], half):
		e["hit_cd"] = EnemyCrew.ENEMY_HIT_CD
		e["pause"] = PAUSE_AFTER_HIT
		hero.damage(float(e["dmg"]))
		hero.vel.x = signf(hero.pos.x - e["pos"].x) * Hero.MOVE_SPEED
		return
	for npc in pop.npcs:
		if bool(npc.get("down", false)):
			continue
		if EnemyCrew._aabb_overlap(Vector2(npc["pos"]), Population.NPC_HALF, e["pos"], half):
			e["hit_cd"] = EnemyCrew.ENEMY_HIT_CD
			e["pause"] = PAUSE_AFTER_HIT
			var msg := pop.hurt_npc(npc, float(e["dmg"]))
			if msg != "":
				msgs.append(msg)
			return

# Avance le long du chemin. Renvoie true quand le dernier point est atteint.
func _follow(e: Dictionary, delta: float) -> bool:
	var path: Array = e["path"]
	var wp := int(e["wp"])
	if wp >= path.size():
		return true
	var target := _cell_pos(path[wp], e["half"])
	var d := target - Vector2(e["pos"])
	var spd := float(e["speed"]) * (FLEE_MULT if bool(e["fleeing"]) else 1.0)
	if d.y > 4.0:
		spd *= FALL_MULT   # descente : il se laisse tomber
	if absf(d.x) > 1.0:
		e["dir"] = signf(d.x)
	e["pos"] = Vector2(e["pos"]).move_toward(target, spd * delta)
	if Vector2(e["pos"]).distance_to(target) < 1.5:
		e["wp"] = wp + 1
		return wp + 1 >= path.size()
	return false

func _grab(e: Dictionary, msgs: Array) -> void:
	e["carry"] = _steal()
	e["fleeing"] = true
	e["pause"] = 0.8
	if _carry_total(e["carry"]) > 0:
		msgs.append("Un porteur pille le depot : %s ! Rattrape-le !" % _carry_text(e["carry"]))
	# Chemin de fuite depuis ici ; à défaut (passage rebouché), il rebrousse son chemin.
	var path: Array = e["path"]
	var here: Vector2i = path[maxi(int(e["wp"]) - 1, 0)] if not path.is_empty() \
		else Vector2i(int(e["pos"].x / WorldGrid.TILE), int(e["pos"].y / WorldGrid.TILE))
	var flee := _find_path(here, Vector2i(e["spawn"]))
	if flee.is_empty():
		flee = []
		for i in range(int(e["wp"]) - 1, -1, -1):
			flee.append(path[i])
	e["path"] = flee
	e["wp"] = 0

func _steal() -> Dictionary:
	# Se sert dans les ressources les plus abondantes du stock, jusqu'à CARRY_MAX.
	var carry := {}
	var left := CARRY_MAX
	while left > 0:
		var best := -1
		var bestn := 0
		for t in foyer.store:
			if foyer.count(t) > bestn:
				best = int(t)
				bestn = foyer.count(t)
		if bestn <= 0:
			break
		var take := mini(left, bestn)
		foyer.remove(best, take)
		carry[best] = int(carry.get(best, 0)) + take
		left -= take
	return carry

# --- Bunker-défense : les PNJ affectés tirent sur les assaillants à portée ------------
func _run_defense(delta: float) -> void:
	var ts := float(WorldGrid.TILE)
	for mp in foyer.rooms:
		if int(foyer.rooms[mp]["type"]) != Foyer.ROOM_DEFENSE:
			continue
		var ir := foyer.interior(Vector2i(mp))
		var center := (Vector2(ir.position) + Vector2(ir.size) * 0.5) * ts
		for n in pop.assigned_to(Vector2i(mp)):
			var npc: Dictionary = pop.npcs[n]
			if bool(npc.get("down", false)):
				continue
			npc["def_cd"] = maxf(0.0, float(npc.get("def_cd", 0.0)) - delta)
			if float(npc["def_cd"]) > 0.0:
				continue
			var best = null
			var bestd := DEF_RANGE * ts
			for e in crew.list:
				if not e.get("raid", false) or float(e["hp"]) <= 0.0:
					continue
				var d := center.distance_to(Vector2(e["pos"]))
				if d < bestd and light.los_clear_from(center / ts,
						int(e["pos"].x / ts), int(e["pos"].y / ts)):
					best = e
					bestd = d
			if best != null:
				npc["def_cd"] = DEF_CD
				EnemyCrew.hurt(best, DEF_DMG_BASE + DEF_DMG_GARDE * float(npc["garde"]), center.x)
				crew.shots.append({"a": center + Vector2(0.0, -6.0), "b": Vector2(best["pos"]), "t": 0.12})

# --- Butin tombé (porteur abattu) : ramassage auto au contact -------------------------
func drop_at(p: Vector2, carry: Dictionary) -> void:
	if not carry.is_empty():
		drops.append({"pos": p, "carry": carry.duplicate()})

func _drop_carry(e: Dictionary) -> void:
	drop_at(Vector2(e["pos"]), e["carry"])
	e["carry"] = {}

func _pickup_drops(msgs: Array) -> void:
	var keep := []
	for dr in drops:
		if hero.pos.distance_to(Vector2(dr["pos"])) > PICKUP_RANGE * WorldGrid.TILE:
			keep.append(dr)
			continue
		var carry: Dictionary = dr["carry"]
		var got := 0
		for t in carry.keys():
			var moved := bag.add(int(t), int(carry[t]))
			got += moved
			carry[t] = int(carry[t]) - moved
			if int(carry[t]) <= 0:
				carry.erase(t)
		if got > 0:
			msgs.append("Butin recupere : +%d ressource(s) au sac !" % got)
		if not carry.is_empty():   # sac plein : le reste attend par terre
			msgs.append("(sac plein : il reste du butin au sol)")
			keep.append(dr)
	drops = keep

static func _carry_total(carry: Dictionary) -> int:
	var n := 0
	for t in carry:
		n += int(carry[t])
	return n

static func _carry_text(carry: Dictionary) -> String:
	var parts := []
	for t in carry:
		parts.append("%d %s" % [int(carry[t]), Inventory.res_name(int(t))])
	return " + ".join(parts)

# --- Pathfinding : BFS « plateforme » sur les cases des PIEDS -------------------------
# Une case est tenable si le corps (2 tuiles de haut) y passe. On marche si on a
# un appui (sol plein ou échelle), on grimpe une marche d'UNE tuile, on monte par
# les échelles, on descend en tombant (jamais de remontée sans échelle).
func _spawns_with_path() -> Array:
	var out := []
	var target := _hall_target()
	for m in world.metro_rects:
		var mr: Rect2i = m
		var fy := mr.position.y + mr.size.y - 1   # rangée des pieds (sol du tunnel)
		for cx in [mr.position.x + 1, mr.position.x + mr.size.x - 2]:
			var cell := Vector2i(cx, fy)
			if not _passable(cell):
				continue
			var path := _find_path(cell, target)
			if not path.is_empty():
				out.append({"cell": cell, "path": path})
	return out

func _hall_target() -> Vector2i:
	var o := world.hall_origin()
	return Vector2i(o.x + WorldGrid.MOD_W / 2, o.y + WorldGrid.MOD_H - 2)

func _cell_pos(c: Vector2i, half: Vector2) -> Vector2:
	var ts := float(WorldGrid.TILE)
	return Vector2((c.x + 0.5) * ts, (c.y + 1) * ts - half.y)

func _passable(c: Vector2i) -> bool:
	return not world.is_solid(c.x, c.y) and not world.is_solid(c.x, c.y - 1)

func _supported(c: Vector2i) -> bool:
	return world.is_solid(c.x, c.y + 1) or world.tile(c.x, c.y) == WorldGrid.LADDER

func _find_path(from: Vector2i, to: Vector2i) -> Array:
	if not _passable(from):
		return []
	var prev := {from: from}
	var queue := [from]
	var qi := 0
	while qi < queue.size() and queue.size() < BFS_LIMIT:
		var c: Vector2i = queue[qi]
		qi += 1
		if c == to:
			var path := [to]
			while path[path.size() - 1] != from:
				path.append(prev[path[path.size() - 1]])
			path.reverse()
			return path
		for nb in _neighbors(c):
			if not prev.has(nb):
				prev[nb] = c
				queue.append(nb)
	return []

func _neighbors(c: Vector2i) -> Array:
	var out := []
	var down := c + Vector2i(0, 1)
	if not world.is_solid(down.x, down.y):   # descendre / se laisser tomber
		out.append(down)
	if world.tile(c.x, c.y) == WorldGrid.LADDER and _passable(c + Vector2i(0, -1)):
		out.append(c + Vector2i(0, -1))      # grimper l'échelle
	if _supported(c):
		for sx in [-1, 1]:
			var side := c + Vector2i(sx, 0)
			if _passable(side):
				out.append(side)             # marcher
			if _passable(c + Vector2i(0, -1)):
				if _passable(c + Vector2i(sx, -1)):
					out.append(c + Vector2i(sx, -1))   # marche d'une tuile
				if _passable(c + Vector2i(0, -2)) and _passable(c + Vector2i(sx, -2)):
					out.append(c + Vector2i(sx, -2))   # petit saut (rame échouée, quai)
	return out
