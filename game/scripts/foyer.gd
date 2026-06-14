class_name Foyer
extends RefCounted
## Le Foyer (M2) : la base à pièces, en construction LIBRE façon Fallout Shelter
## sur une grille de modules (gabarit unique 8x5 intérieur, murs mitoyens
## partagés). Un slot est constructible s'il touche une pièce existante OU un
## connecteur posé par le joueur (échelle, passerelle). Poser une pièce paye le
## coût, creuse l'espace, monte les murs et perce les portes d'un coup.
## Règles pures — rendu dans world_view.gd, écrans dans room_ui.gd / trade_ui.gd.

const ROOM_DORTOIR := 0
const ROOM_FORAGE := 1            # M6 : ex-« Production (rations) » reconvertie — extrait de la ROCHE
const ROOM_ATELIER := 2
const ROOM_ENTREPOT := 3
const ROOM_HALL := 4              # le module de départ (préconstruit, unique)
const ROOM_INFIRMERIE := 5        # lits de soin : les blessés des raids y guérissent (M4)
const ROOM_DEFENSE := 6           # bunker-défense : les PNJ affectés tirent sur les raids (M4)
const ROOM_MINE := 7             # M6 : mine de fer — les PNJ affectés extraient du FER
const BUILDABLE := [ROOM_DORTOIR, ROOM_FORAGE, ROOM_MINE, ROOM_ATELIER, ROOM_ENTREPOT,
	ROOM_INFIRMERIE, ROOM_DEFENSE]
const ROOM_NAMES := ["Dortoir", "Forage", "Atelier", "Entrepot", "Hall",
	"Infirmerie", "Bunker-defense", "Mine de fer"]
const ROOM_NOTES := [
	"+3 lits : des survivants arrivent tant qu'il y a de la place",
	"3 postes : les PNJ affectes extraient de la roche en continu (vers le stock)",
	"debloque [3] ameliorer l'outil et [4] cartouche anti-gaz",
	"+300 de capacite de stockage",
	"le coeur du Foyer : depot, arrivees, caravane",
	"2 lits de soin : les blesses des raids y guerissent vite",
	"2 postes de garde : les PNJ affectes tirent sur les assaillants",
	"2 postes : les PNJ affectes extraient du fer en continu (plus lent)",
]
const ROOM_COSTS: Array = [
	{WorldGrid.WOOD: 10, WorldGrid.ROCK: 6},
	{WorldGrid.ROCK: 12, WorldGrid.WOOD: 8},
	{WorldGrid.ROCK: 15, WorldGrid.WOOD: 6},
	{WorldGrid.ROCK: 12, WorldGrid.WOOD: 10},
	{},
	{WorldGrid.ROCK: 10, WorldGrid.WOOD: 8, WorldGrid.LITHIUM: 4},
	{WorldGrid.ROCK: 12, WorldGrid.IRON: 6, WorldGrid.WOOD: 6},
	{WorldGrid.ROCK: 14, WorldGrid.IRON: 6, WorldGrid.WOOD: 6},
]
const ROOM_SLOTS := [0, 3, 0, 0, 0, 0, 2, 2]  # postes de travail par type de pièce
const DORTOIR_BEDS := 3           # capacité PNJ par dortoir
const INFIRM_BEDS := 2            # lits de soin par infirmerie
const PROD_INTERVAL := 10.0       # s entre deux cycles de production
const CAP_BASE := 300             # capacité de stockage sans entrepôt
const CAP_ENTREPOT := 300         # capacité ajoutée par entrepôt
const SLOT_SCAN := 6              # rayon (en modules) du scan de slots autour des pièces

var world: WorldGrid
var pos := Vector2.ZERO           # centre du hall (repère monde, répit des robots)
var rooms := {}                   # Vector2i (coord. module) -> {"type": int}
# Petit kit de départ (M6) : juste de quoi bâtir la première pièce ; le reste se
# mine à la main / s'explore, puis le Forage prend le relais pour la roche.
var store := {
	WorldGrid.DIRT: 0,
	WorldGrid.ROCK: 16,
	WorldGrid.WOOD: 12,
	WorldGrid.LITHIUM: 0,
	WorldGrid.IRON: 0,
}
var prod_timer := 0.0

func _init(w: WorldGrid) -> void:
	world = w
	rooms[Vector2i.ZERO] = {"type": ROOM_HALL}
	var o := w.hall_origin()
	pos = Vector2((o.x + WorldGrid.MOD_W * 0.5) * WorldGrid.TILE,
		(o.y + WorldGrid.MOD_H * 0.5) * WorldGrid.TILE)

# --- Grille de modules ------------------------------------------------------------
func module_tl(mp: Vector2i) -> Vector2i:   # coin haut-gauche (tuiles) d'un module
	return world.hall_origin() + Vector2i(mp.x * WorldGrid.PITCH_X, mp.y * WorldGrid.PITCH_Y)

func footprint(mp: Vector2i) -> Rect2i:     # empreinte murs compris (tuiles)
	return Rect2i(module_tl(mp), Vector2i(WorldGrid.MOD_W, WorldGrid.MOD_H))

func interior(mp: Vector2i) -> Rect2i:      # intérieur 8x5 (tuiles)
	return Rect2i(module_tl(mp) + Vector2i.ONE, Vector2i(WorldGrid.MOD_W - 2, WorldGrid.MOD_H - 2))

# Renvoie la coord. module de la pièce contenant p (Vector2i), ou null.
func room_key_at(p: Vector2) -> Variant:
	var t := Vector2i(int(floor(p.x / WorldGrid.TILE)), int(floor(p.y / WorldGrid.TILE)))
	for mp in rooms:
		if footprint(mp).has_point(t):
			return mp
	return null

func inside(p: Vector2) -> bool:
	return room_key_at(p) != null

func room_type_at(p: Vector2) -> int:
	var k = room_key_at(p)
	return int(rooms[k]["type"]) if k != null else -1

# --- Pièces ------------------------------------------------------------------------
func room_count(type: int) -> int:
	var n := 0
	for mp in rooms:
		if int(rooms[mp]["type"]) == type:
			n += 1
	return n

func has_room(type: int) -> bool:
	return room_count(type) > 0

func dortoir_capacity() -> int:
	return DORTOIR_BEDS * room_count(ROOM_DORTOIR)

# --- Slots de construction ----------------------------------------------------------
func valid_slots() -> Array:
	var lo := Vector2i(999999, 999999)
	var hi := Vector2i(-999999, -999999)
	for mp in rooms:
		lo = Vector2i(mini(lo.x, mp.x), mini(lo.y, mp.y))
		hi = Vector2i(maxi(hi.x, mp.x), maxi(hi.y, mp.y))
	var out: Array = []
	for my in range(lo.y - SLOT_SCAN, hi.y + SLOT_SCAN + 1):
		for mx in range(lo.x - SLOT_SCAN, hi.x + SLOT_SCAN + 1):
			var mp := Vector2i(mx, my)
			if not rooms.has(mp) and _slot_ok(mp):
				out.append(mp)
	return out

func _slot_ok(mp: Vector2i) -> bool:
	var fp := footprint(mp)
	if fp.position.x < 1 or fp.position.y <= WorldGrid.AIR_ROWS \
			or fp.end.x > WorldGrid.GRID_W - 1 or fp.end.y > WorldGrid.GRID_H - 1:
		return false
	# Pas de triche : la barrière de roche dense ne se contourne pas en bâtissant.
	for y in range(fp.position.y, fp.end.y):
		for x in range(fp.position.x, fp.end.x):
			if world.tile(x, y) == WorldGrid.HARDROCK:
				return false
	# Adjacence : pièce voisine sur la grille, OU connecteur au contact de l'empreinte.
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if rooms.has(mp + d):
			return true
	for y in range(fp.position.y - 1, fp.end.y + 1):
		for x in range(fp.position.x - 1, fp.end.x + 1):
			if _is_conn(world.tile(x, y)):
				return true
	return false

static func _is_conn(t: int) -> bool:
	return t == WorldGrid.LADDER or t == WorldGrid.PASSERELLE

# --- Pose d'une pièce (suppose slot valide et coût payable) -------------------------
func place(mp: Vector2i, type: int) -> void:
	pay(ROOM_COSTS[type])
	rooms[mp] = {"type": type}
	_carve(mp)
	_open_doors(mp)

func _carve(mp: Vector2i) -> void:
	var fp := footprint(mp)
	for y in range(fp.position.y, fp.end.y):
		for x in range(fp.position.x, fp.end.x):
			var border := x == fp.position.x or x == fp.end.x - 1 \
				or y == fp.position.y or y == fp.end.y - 1
			world.set_tile(x, y, WorldGrid.WALL if border else WorldGrid.EMPTY)

func _open_doors(mp: Vector2i) -> void:
	var tl := module_tl(mp)
	# Portes vers les pièces voisines de la grille
	if rooms.has(mp + Vector2i.LEFT):
		_door_lateral(tl.x, tl.y)
	if rooms.has(mp + Vector2i.RIGHT):
		_door_lateral(tl.x + WorldGrid.MOD_W - 1, tl.y)
	if rooms.has(mp + Vector2i.UP):
		_hatch(mp)
	if rooms.has(mp + Vector2i.DOWN):
		_hatch(mp + Vector2i.DOWN)
	# Raccord aux connecteurs : on perce là où une échelle/passerelle touche le mur.
	var fp := footprint(mp)
	var x0 := fp.position.x
	var x1 := fp.end.x - 1
	var y0 := fp.position.y
	var y1 := fp.end.y - 1
	# Latéral, au niveau du sol : passage de 2 tuiles au-dessus du plancher
	if _is_conn(world.tile(x0 - 1, y1)):
		world.set_tile(x0, y1 - 1, WorldGrid.EMPTY)
		world.set_tile(x0, y1 - 2, WorldGrid.EMPTY)
	if _is_conn(world.tile(x1 + 1, y1)):
		world.set_tile(x1, y1 - 1, WorldGrid.EMPTY)
		world.set_tile(x1, y1 - 2, WorldGrid.EMPTY)
	# Vertical : une échelle contre le plafond/le sol → trappe à échelle
	for x in range(x0 + 1, x1):
		if world.tile(x, y0 - 1) == WorldGrid.LADDER:
			world.set_tile(x, y0, WorldGrid.LADDER)
		if world.tile(x, y1 + 1) == WorldGrid.LADDER:
			world.set_tile(x, y1, WorldGrid.LADDER)

# Porte latérale dans le mur de colonne wx (2 tuiles au ras du sol intérieur).
func _door_lateral(wx: int, tl_y: int) -> void:
	world.set_tile(wx, tl_y + WorldGrid.MOD_H - 2, WorldGrid.EMPTY)
	world.set_tile(wx, tl_y + WorldGrid.MOD_H - 3, WorldGrid.EMPTY)

# Trappe + colonne d'échelle entre une pièce et celle au-dessus : l'échelle part
# du sol de la pièce du BAS (lower) et traverse le plancher partagé.
func _hatch(lower: Vector2i) -> void:
	var lt := module_tl(lower)
	var x := lt.x + WorldGrid.MOD_W / 2
	for y in range(lt.y, lt.y + WorldGrid.MOD_H - 1):
		world.set_tile(x, y, WorldGrid.LADDER)

# --- Stock (capacité limitée ; l'entrepôt l'augmente) -------------------------------
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

# --- Minage automatique (M6) ---------------------------------------------------------
# Les salles de minage produisent dans le temps vers le stock de la base : le Forage
# extrait de la ROCHE, la Mine de fer du FER. Rendement = somme des stats Travail des
# PNJ affectés et valides (un blessé ne produit pas) ; le fer sort plus lentement.
# Bois et lithium restent réservés à l'extérieur (exploration) — pas d'automatisation.
func produce(delta: float, pop) -> void:
	if not (has_room(ROOM_FORAGE) or has_room(ROOM_MINE)):
		return
	prod_timer += delta
	if prod_timer < PROD_INTERVAL:
		return
	prod_timer -= PROD_INTERVAL
	var rock := 0
	var iron := 0
	for mp in rooms:
		var rt := int(rooms[mp]["type"])
		if rt != ROOM_FORAGE and rt != ROOM_MINE:
			continue
		var work := 0
		for n in pop.assigned_to(mp):
			if not bool(pop.npcs[n].get("down", false)):   # un blessé ne produit pas
				work += int(pop.npcs[n]["travail"])
		if rt == ROOM_FORAGE:
			rock += work
		else:
			iron += int(ceil(work * 0.5))   # la mine de fer rend moins (ressource premium)
	if rock > 0:
		add(WorldGrid.ROCK, rock)
	if iron > 0:
		add(WorldGrid.IRON, iron)
