class_name Inventory
extends RefCounted
## Sac à slots façon Minecraft : grille de slots, objets en piles (stacks).
## Logique pure — l'écran d'inventaire vit dans inv_ui.gd.

const BAG_SLOTS := 8             # nombre de cases du sac (la "capacité" = nb de slots)
const STACK_MAX := 64            # taille d'une pile (objets identiques empilés)

# Ressources transportables (ordre d'affichage dans l'inventaire / le stockage)
const RES_TYPES := [WorldGrid.DIRT, WorldGrid.ROCK, WorldGrid.WOOD, WorldGrid.LITHIUM]

# Chaque slot est {} (vide) ou {"type": int, "count": int}.
var slots := []

func _init() -> void:
	for i in BAG_SLOTS:
		slots.append({})

func count(t: int) -> int:
	var n := 0
	for s in slots:
		if s.has("type") and s["type"] == t:
			n += int(s["count"])
	return n

func total() -> int:
	var n := 0
	for s in slots:
		if s.has("count"):
			n += int(s["count"])
	return n

func slots_used() -> int:
	var n := 0
	for s in slots:
		if s.has("type"):
			n += 1
	return n

# Ajoute jusqu'à n objets de type t (piles existantes d'abord, puis slots vides).
# Renvoie la quantité réellement ajoutée (le reste est perdu si le sac est plein).
func add(t: int, n: int) -> int:
	var added := 0
	for s in slots:
		if added >= n:
			break
		if s.has("type") and s["type"] == t and int(s["count"]) < STACK_MAX:
			var mv: int = mini(STACK_MAX - int(s["count"]), n - added)
			s["count"] = int(s["count"]) + mv
			added += mv
	for i in slots.size():
		if added >= n:
			break
		if slots[i].is_empty():
			var mv2: int = mini(STACK_MAX, n - added)
			slots[i] = {"type": t, "count": mv2}
			added += mv2
	return added

# Retire jusqu'à n objets de type t. Renvoie la quantité réellement retirée.
func remove(t: int, n: int) -> int:
	var removed := 0
	for i in slots.size():
		if removed >= n:
			break
		if slots[i].has("type") and slots[i]["type"] == t:
			var mv: int = mini(int(slots[i]["count"]), n - removed)
			slots[i]["count"] = int(slots[i]["count"]) - mv
			removed += mv
			if int(slots[i]["count"]) <= 0:
				slots[i] = {}
	return removed

func clear() -> void:
	for i in slots.size():
		slots[i] = {}

static func res_color(t: int) -> Color:
	match t:
		WorldGrid.DIRT: return Color(0.42, 0.30, 0.20)
		WorldGrid.ROCK: return Color(0.40, 0.42, 0.46)
		WorldGrid.WOOD: return Color(0.55, 0.38, 0.15)
		WorldGrid.LITHIUM: return Color(0.45, 0.74, 0.80)
	return Color(0.6, 0.6, 0.6)

static func res_name(t: int) -> String:
	match t:
		WorldGrid.DIRT: return "Terre"
		WorldGrid.ROCK: return "Roche"
		WorldGrid.WOOD: return "Bois"
		WorldGrid.LITHIUM: return "Lithium"
	return "?"
