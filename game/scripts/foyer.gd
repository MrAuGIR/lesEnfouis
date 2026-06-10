class_name Foyer
extends RefCounted
## Le Foyer (M2) : la base à pièces du jeu final. Structure préfabriquée à
## cellules PRÉDÉFINIES — chaque cellule vide peut recevoir une pièce (dortoir,
## production de rations, atelier, entrepôt). Stock commun à capacité limitée.
## Règles pures — rendu dans world_view.gd, écrans dans room_ui.gd / trade_ui.gd.

const ROOM_DORTOIR := 0
const ROOM_PROD := 1
const ROOM_ATELIER := 2
const ROOM_ENTREPOT := 3
const ROOM_NAMES := ["Dortoir", "Production (rations)", "Atelier", "Entrepot"]
const ROOM_NOTES := [
	"+3 lits : des survivants arrivent tant qu'il y a de la place",
	"3 postes de travail : affecte des PNJ ([E] dans la piece)",
	"debloque [3] ameliorer l'outil et [4] cartouche anti-gaz",
	"+300 de capacite de stockage",
]
const ROOM_COSTS: Array = [
	{WorldGrid.WOOD: 10, WorldGrid.ROCK: 6},
	{WorldGrid.ROCK: 10, WorldGrid.WOOD: 8},
	{WorldGrid.ROCK: 15, WorldGrid.WOOD: 6},
	{WorldGrid.ROCK: 12, WorldGrid.WOOD: 10},
]
const ROOM_SLOTS := [0, 3, 0, 0]  # postes de travail par type de pièce
const DORTOIR_BEDS := 3           # capacité PNJ par dortoir
const PROD_INTERVAL := 10.0       # s entre deux cycles de production
const CAP_BASE := 300             # capacité de stockage sans entrepôt
const CAP_ENTREPOT := 300         # capacité ajoutée par entrepôt

var world: WorldGrid
var pos := Vector2.ZERO           # centre du hall (repère monde, répit des robots)
var cells := []                   # {"rect": Rect2i (tuiles), "room": int (-1 = vide)}
# Stock de départ — CONFORT DE TEST : permet de construire tout de suite sans
# grinder. À remettre à 0 avant l'équilibrage (M6).
var store := {
	WorldGrid.DIRT: 40,
	WorldGrid.ROCK: 80,
	WorldGrid.WOOD: 40,
	WorldGrid.LITHIUM: 40,
	Inventory.RATIONS: 0,
}
var prod_timer := 0.0

func _init(w: WorldGrid) -> void:
	world = w
	var ts := WorldGrid.TILE
	var cx := w.exit_col()
	var x0 := w.foyer_x0()
	var top_y := w.foyer_y0() + 1
	var bot_y := w.foyer_mid() + 1
	var cell_w := cx - WorldGrid.FOYER_HALL_HALF - (x0 + 1)
	var right_x := cx + WorldGrid.FOYER_HALL_HALF + 1
	cells = [
		{"rect": Rect2i(x0 + 1, top_y, cell_w, WorldGrid.FOYER_FLOOR_H), "room": -1},
		{"rect": Rect2i(right_x, top_y, cell_w, WorldGrid.FOYER_FLOOR_H), "room": -1},
		{"rect": Rect2i(x0 + 1, bot_y, cell_w, WorldGrid.FOYER_FLOOR_H), "room": -1},
		{"rect": Rect2i(right_x, bot_y, cell_w, WorldGrid.FOYER_FLOOR_H), "room": -1},
	]
	pos = Vector2(cx * ts + ts * 0.5, WorldGrid.BASE_DEPTH * ts)

# --- Localisation ---------------------------------------------------------------
func inside(p: Vector2) -> bool:
	var tx := int(floor(p.x / WorldGrid.TILE))
	var ty := int(floor(p.y / WorldGrid.TILE))
	return tx >= world.foyer_x0() and tx <= world.foyer_x1() \
		and ty >= world.foyer_y0() and ty <= world.foyer_y1()

func cell_at(p: Vector2) -> int:
	var t := Vector2i(int(floor(p.x / WorldGrid.TILE)), int(floor(p.y / WorldGrid.TILE)))
	for i in cells.size():
		if (cells[i]["rect"] as Rect2i).has_point(t):
			return i
	return -1

func room_at(p: Vector2) -> int:
	var i := cell_at(p)
	return int(cells[i]["room"]) if i >= 0 else -1

# --- Pièces ----------------------------------------------------------------------
func room_count(type: int) -> int:
	var n := 0
	for c in cells:
		if int(c["room"]) == type:
			n += 1
	return n

func has_room(type: int) -> bool:
	return room_count(type) > 0

func dortoir_capacity() -> int:
	return DORTOIR_BEDS * room_count(ROOM_DORTOIR)

# Construit (suppose la cellule vide et le coût validés par l'appelant).
func build(i: int, type: int) -> void:
	pay(ROOM_COSTS[type])
	cells[i]["room"] = type

# --- Stock (capacité limitée ; l'entrepôt l'augmente) -----------------------------
func capacity() -> int:
	return CAP_BASE + CAP_ENTREPOT * room_count(ROOM_ENTREPOT)

func stored_total() -> int:
	var n := 0
	for t in store:
		n += int(store[t])
	return n

func free_space() -> int:
	return maxi(0, capacity() - stored_total())

func count(t: int) -> int:
	return int(store.get(t, 0))

# Ajoute jusqu'à n (limité par la place). Renvoie la quantité réellement stockée.
func add(t: int, n: int) -> int:
	var put: int = mini(n, free_space())
	if put > 0:
		store[t] = int(store.get(t, 0)) + put
	return put

func remove(t: int, n: int) -> void:
	store[t] = maxi(0, count(t) - n)

func can_pay(cost: Dictionary) -> bool:
	for t in cost:
		if count(t) < int(cost[t]):
			return false
	return true

func pay(cost: Dictionary) -> void:
	for t in cost:
		remove(int(t), int(cost[t]))

# --- Production -------------------------------------------------------------------
# Chaque PNJ affecté à une salle de production rend [stat travail] rations par cycle.
func produce(delta: float, pop) -> void:
	if not has_room(ROOM_PROD):
		return
	prod_timer += delta
	if prod_timer < PROD_INTERVAL:
		return
	prod_timer -= PROD_INTERVAL
	var made := 0
	for i in cells.size():
		if int(cells[i]["room"]) == ROOM_PROD:
			for n in pop.assigned_to(i):
				made += int(pop.npcs[n]["travail"])
	if made > 0:
		add(Inventory.RATIONS, made)
