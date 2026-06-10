class_name Caravan
extends RefCounted
## La caravane marchande : passe périodiquement au Foyer (étage haut), reste un
## moment puis repart. Commerce en TROC : ressource contre ressource, depuis le
## stock du Foyer (les munitions vont directement à l'arme — cf. main.gd).

const FIRST_DELAY := 40.0        # premier passage rapide — CONFORT DE TEST (M6)
const PERIOD := 150.0            # s entre deux passages
const STAY := 60.0               # s de présence au Foyer
const TRADE_RANGE := 2.5 * WorldGrid.TILE
const AMMO := -1                 # pseudo-ressource des offres : munitions

const OFFERS: Array = [
	{"give": {WorldGrid.ROCK: 12}, "get": {WorldGrid.LITHIUM: 4}},
	{"give": {WorldGrid.DIRT: 30}, "get": {WorldGrid.WOOD: 6}},
	{"give": {WorldGrid.WOOD: 10}, "get": {AMMO: 8}},
	{"give": {Inventory.RATIONS: 8}, "get": {WorldGrid.LITHIUM: 6}},
	{"give": {WorldGrid.LITHIUM: 12}, "get": {AMMO: 20}},
]

var foyer: Foyer
var present := false
var timer := FIRST_DELAY
var stay_t := 0.0
var pos := Vector2.ZERO          # poste du marchand (étage haut, à droite du hall)

func _init(w: WorldGrid, f: Foyer) -> void:
	foyer = f
	var ts := WorldGrid.TILE
	pos = Vector2((w.exit_col() + 3) * ts + ts * 0.5, w.foyer_mid() * ts - 11.0)

# Avance d'un pas. Renvoie le message à afficher ("" si rien à signaler).
func update(delta: float) -> String:
	if present:
		stay_t -= delta
		if stay_t <= 0.0:
			present = false
			timer = PERIOD
			return "La caravane repart. Prochain passage dans %d s." % int(PERIOD)
	else:
		timer -= delta
		if timer <= 0.0:
			present = true
			stay_t = STAY
			return "CARAVANE AU FOYER ! Troc : [E] pres du marchand (etage haut)"
	return ""

func near(p: Vector2) -> bool:
	return present and pos.distance_to(p) <= TRADE_RANGE

# --- Offres -----------------------------------------------------------------------
static func res_label(t: int) -> String:
	return "munitions" if t == AMMO else Inventory.res_name(t)

static func side_text(d: Dictionary) -> String:
	var parts := []
	for t in d:
		parts.append("%d %s" % [int(d[t]), res_label(int(t))])
	return " + ".join(parts)

static func offer_text(i: int) -> String:
	var o: Dictionary = OFFERS[i]
	return "%s  ->  %s" % [side_text(o["give"]), side_text(o["get"])]

func can_trade(i: int) -> bool:
	var o: Dictionary = OFFERS[i]
	if not foyer.can_pay(o["give"]):
		return false
	# Place nette nécessaire au stock (ce qu'on paye libère de la place)
	var net := 0
	for t in o["get"]:
		if int(t) != AMMO:
			net += int(o["get"][t])
	for t in o["give"]:
		net -= int(o["give"][t])
	return net <= foyer.free_space()

# Exécute l'offre (suppose can_trade). Renvoie les munitions obtenues (0 sinon).
func trade(i: int) -> int:
	var o: Dictionary = OFFERS[i]
	foyer.pay(o["give"])
	var ammo := 0
	for t in o["get"]:
		if int(t) == AMMO:
			ammo += int(o["get"][t])
		else:
			foyer.add(int(t), int(o["get"][t]))
	return ammo
