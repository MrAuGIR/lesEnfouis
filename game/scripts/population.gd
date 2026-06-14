class_name Population
extends RefCounted
## Les PNJ du Foyer : arrivée automatique (tant que le dortoir a des lits libres),
## identité (nom + stats), affectation aux pièces et petite vie de fourmilière
## (déambulation grey-box, sans physique). Pas de besoins de survie au MVP.

const ARRIVAL_INTERVAL := 75.0   # s entre deux arrivées de survivants
const WALK_SPEED := 26.0
const NPC_HALF := Vector2(5, 11)
# Blessures (M4) : à 0 PV un PNJ tombe BLESSÉ (inactif), jamais de mort définitive
# (GDD 03). Transport auto vers un lit d'infirmerie libre ; sans lit, il récupère
# sur place, beaucoup plus lentement.
const NPC_HP := 40.0
const HEAL_TIME := 40.0          # s de soin sur un lit d'infirmerie
const GROUND_HEAL := 150.0       # s de récupération au sol (pas de lit libre)
const FIRST_NAMES := ["Marek", "Lena", "Igor", "Sacha", "Mina", "Pavel", "Jeanne",
	"Theo", "Olga", "Bruno", "Anya", "Karl", "Sonia", "Milo", "Vera", "Dima"]
const LAST_NAMES := ["Kovac", "Fersen", "Brodski", "Lemaire", "Volkov", "Marchal",
	"Oblak", "Renard", "Petrov", "Garnier", "Sokol", "Vidal", "Moreau", "Zaitsev",
	"Roche", "Danek"]
# PNJ légendaires (M3) : cachés dans le Transit, stats 4-5, rejoignent le Foyer
# seuls une fois libérés ([E]).
const LEGEND_NAMES := ["Vesna \"la Foreuse\" Olszak", "Anton \"Six-Doigts\" Marek",
	"Irma \"la Taupe\" Castell"]
const LEGEND_TRAVEL := 18.0   # s de trajet d'un légendaire libéré vers le Foyer

var world: WorldGrid
var foyer: Foyer
var npcs := []   # {"name", "travail", "garde": int, "cell": Vector2i|null (pièce), "pos", "dir", "pause"}
var captives := []   # légendaires à libérer : {"name", "travail", "garde", "pos": Vector2, "guarded"}
var incoming := []   # légendaires libérés, en route : {"npc": Dictionary, "t": float}
var arrival_timer := 0.0

func _init(w: WorldGrid, f: Foyer) -> void:
	world = w
	foyer = f

# Avance d'un pas. Renvoie le message à afficher ("" si rien à signaler).
func update(delta: float) -> String:
	var msg := ""
	arrival_timer += delta
	if arrival_timer >= ARRIVAL_INTERVAL:
		arrival_timer = 0.0
		if npcs.size() < foyer.dortoir_capacity():
			msg = _arrive()
	# Légendaires en route vers le Foyer (ils voyagent seuls, sans danger)
	for inc in incoming:
		inc["t"] = float(inc["t"]) - delta
		if float(inc["t"]) <= 0.0:
			var npc: Dictionary = inc["npc"]
			npcs.append(npc)
			msg = "%s (LEGENDAIRE) est arrive au Foyer ! (Travail %d / Garde %d)" % \
				[npc["name"], int(npc["travail"]), int(npc["garde"])]
	incoming = incoming.filter(func(inc): return float(inc["t"]) > 0.0)
	for npc in npcs:
		if bool(npc.get("down", false)):
			var m := _heal(npc, delta)
			if m != "":
				msg = m
		else:
			_walk(npc, delta)
	return msg

# --- Blessés (M4) -------------------------------------------------------------------
# Inflige des dégâts à un PNJ (raid). Renvoie le message à afficher ("" sinon).
func hurt_npc(npc: Dictionary, dmg: float) -> String:
	if bool(npc.get("down", false)):
		return ""
	npc["hp"] = float(npc.get("hp", NPC_HP)) - dmg
	if float(npc["hp"]) <= 0.0:
		npc["down"] = true
		npc["heal_cell"] = null
		npc["heal_t"] = GROUND_HEAL
		return "%s est blesse(e) ! (soins : infirmerie)" % npc["name"]
	return ""

func down_count() -> int:
	var n := 0
	for npc in npcs:
		if bool(npc.get("down", false)):
			n += 1
	return n

func _heal(npc: Dictionary, delta: float) -> String:
	var msg := ""
	if npc.get("heal_cell") == null:
		var bed = _free_bed()
		if bed != null:   # transport auto vers le lit (grey-box : téléporté)
			npc["heal_cell"] = bed
			npc["heal_t"] = HEAL_TIME
			var ir := foyer.interior(Vector2i(bed))
			npc["pos"] = Vector2((ir.position.x + ir.size.x * 0.5) * WorldGrid.TILE,
				float(ir.position.y + ir.size.y) * WorldGrid.TILE - NPC_HALF.y)
			msg = "%s est transporte(e) a l'infirmerie." % npc["name"]
	npc["heal_t"] = float(npc["heal_t"]) - delta
	if float(npc["heal_t"]) <= 0.0:
		npc["down"] = false
		npc["hp"] = NPC_HP
		npc["heal_cell"] = null
		msg = "%s est sur pied !" % npc["name"]
	return msg

# Une infirmerie avec un lit de soin libre, ou null.
func _free_bed():
	for mp in foyer.rooms:
		if int(foyer.rooms[mp]["type"]) != Foyer.ROOM_INFIRMERIE:
			continue
		var used := 0
		for npc in npcs:
			if bool(npc.get("down", false)) and npc.get("heal_cell") != null \
					and Vector2i(npc["heal_cell"]) == Vector2i(mp):
				used += 1
		if used < Foyer.INFIRM_BEDS:
			return mp
	return null

# --- Affectation (cell = coord. module de la pièce, ou null si libre) -------------
func assigned_to(cell: Vector2i) -> Array:
	var out := []
	for i in npcs.size():
		if npcs[i]["cell"] != null and Vector2i(npcs[i]["cell"]) == cell:
			out.append(i)
	return out

func assign(i: int, cell: Vector2i) -> void:
	npcs[i]["cell"] = cell
	npcs[i]["pause"] = 0.0

func unassign(i: int) -> void:
	npcs[i]["cell"] = null

# --- Arrivées ---------------------------------------------------------------------
func _arrive() -> String:
	var nm := "%s %s" % [FIRST_NAMES[randi() % FIRST_NAMES.size()],
		LAST_NAMES[randi() % LAST_NAMES.size()]]
	var o := world.hall_origin()
	var npc := {
		"name": nm,
		"travail": randi_range(1, 3),
		"garde": randi_range(1, 3),
		"cell": null,
		"pos": Vector2(foyer.pos.x, (o.y + WorldGrid.MOD_H - 1) * WorldGrid.TILE - NPC_HALF.y),
		"dir": (1.0 if randf() < 0.5 else -1.0),
		"pause": 1.5,
		"hp": NPC_HP, "down": false, "heal_t": 0.0, "heal_cell": null, "def_cd": 0.0,
	}
	npcs.append(npc)
	return "Un survivant rejoint le Foyer : %s (Travail %d / Garde %d)" % \
		[nm, int(npc["travail"]), int(npc["garde"])]

# --- Légendaires (M3) --------------------------------------------------------------
func spawn_captives() -> void:
	captives = []
	for i in world.captive_spots.size():
		var spot: Dictionary = world.captive_spots[i]
		var c: Vector2i = spot["cell"]
		captives.append({
			"name": LEGEND_NAMES[i % LEGEND_NAMES.size()],
			"travail": randi_range(4, 5),
			"garde": randi_range(4, 5),
			"pos": Vector2((c.x + 0.5) * WorldGrid.TILE, (c.y + 1) * WorldGrid.TILE - NPC_HALF.y),
			"guarded": bool(spot["guarded"]),
		})

# Libère le captif i : il part rejoindre le Foyer par ses propres moyens.
func free_captive(i: int) -> String:
	var c: Dictionary = captives[i]
	captives.remove_at(i)
	var o := world.hall_origin()
	incoming.append({"t": LEGEND_TRAVEL, "npc": {
		"name": c["name"], "travail": c["travail"], "garde": c["garde"],
		"cell": null,
		"pos": Vector2(foyer.pos.x, (o.y + WorldGrid.MOD_H - 1) * WorldGrid.TILE - NPC_HALF.y),
		"dir": 1.0, "pause": 1.5,
		"hp": NPC_HP, "down": false, "heal_t": 0.0, "heal_cell": null, "def_cd": 0.0,
	}})
	return "%s est libre ! Il/elle rejoint le Foyer par ses propres moyens. (Travail %d / Garde %d)" % \
		[c["name"], int(c["travail"]), int(c["garde"])]

# --- Déambulation (grey-box : aller-retour sur le sol de sa zone) -----------------
func _zone(npc: Dictionary) -> Rect2i:
	if npc["cell"] != null:
		return foyer.interior(Vector2i(npc["cell"]))
	# PNJ libre : flâne dans le hall (en évitant les caisses du côté gauche)
	var it := foyer.interior(Vector2i.ZERO)
	return Rect2i(it.position + Vector2i(3, 0), Vector2i(it.size.x - 3, it.size.y))

func _walk(npc: Dictionary, delta: float) -> void:
	var z := _zone(npc)
	var ts := float(WorldGrid.TILE)
	npc["pos"].y = float(z.position.y + z.size.y) * ts - NPC_HALF.y
	if float(npc["pause"]) > 0.0:
		npc["pause"] = float(npc["pause"]) - delta
		return
	var minx := float(z.position.x) * ts + NPC_HALF.x + 2.0
	var maxx := float(z.position.x + z.size.x) * ts - NPC_HALF.x - 2.0
	npc["pos"].x = clampf(float(npc["pos"].x) + float(npc["dir"]) * WALK_SPEED * delta, minx, maxx)
	if float(npc["pos"].x) <= minx or float(npc["pos"].x) >= maxx:
		npc["dir"] = -float(npc["dir"])
		npc["pause"] = randf_range(0.4, 1.6)
	elif randf() < delta * 0.15:
		npc["pause"] = randf_range(0.5, 2.0)
