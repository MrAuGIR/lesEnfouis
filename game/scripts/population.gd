class_name Population
extends RefCounted
## Les PNJ du Foyer : arrivée automatique (tant que le dortoir a des lits libres),
## identité (nom + stats), affectation aux pièces et petite vie de fourmilière
## (déambulation grey-box, sans physique). Pas de besoins en M2 — décision de
## design : les rations sont une ressource d'échange, pas de survie.

const ARRIVAL_INTERVAL := 45.0   # s entre deux arrivées — CONFORT DE TEST (M6)
const WALK_SPEED := 26.0
const NPC_HALF := Vector2(5, 11)
const FIRST_NAMES := ["Marek", "Lena", "Igor", "Sacha", "Mina", "Pavel", "Jeanne",
	"Theo", "Olga", "Bruno", "Anya", "Karl", "Sonia", "Milo", "Vera", "Dima"]
const LAST_NAMES := ["Kovac", "Fersen", "Brodski", "Lemaire", "Volkov", "Marchal",
	"Oblak", "Renard", "Petrov", "Garnier", "Sokol", "Vidal", "Moreau", "Zaitsev",
	"Roche", "Danek"]

var world: WorldGrid
var foyer: Foyer
var npcs := []   # {"name", "travail", "garde": int, "cell": Vector2i|null (pièce), "pos", "dir", "pause"}
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
	for npc in npcs:
		_walk(npc, delta)
	return msg

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
	}
	npcs.append(npc)
	return "Un survivant rejoint le Foyer : %s (Travail %d / Garde %d)" % \
		[nm, int(npc["travail"]), int(npc["garde"])]

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
