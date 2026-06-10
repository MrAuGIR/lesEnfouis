class_name BaseCamp
extends RefCounted
## La base simple du proto : point de dépôt, stockage par ressource, deux
## bâtiments (production, atelier) et production passive de lithium.
## REMPLACÉE en M2 par le vrai système de pièces du Foyer (GDD 06).

const BASE_RANGE := 2.6 * WorldGrid.TILE          # portée de dépôt à la base
const COST_PROD := {WorldGrid.ROCK: 12, WorldGrid.WOOD: 8}      # salle de production
const COST_WORKSHOP := {WorldGrid.ROCK: 15, WorldGrid.WOOD: 6}  # atelier
const PROD_INTERVAL := 12.0      # s entre deux unités produites par le PNJ

var pos := Vector2.ZERO          # point de dépôt (la salle de départ, en profondeur)
# Stock de départ — CONFORT DE TEST : permet de construire/améliorer tout de
# suite sans grinder. À remettre à 0 avant tout équilibrage sérieux (M6).
var store := {
	WorldGrid.DIRT: 40,
	WorldGrid.ROCK: 80,
	WorldGrid.WOOD: 40,
	WorldGrid.LITHIUM: 40,
}
var has_prod := false            # salle de production construite (+1 PNJ)
var has_workshop := false        # atelier construit (débloque l'amélioration d'outil)
var prod_timer := 0.0

func near(p: Vector2) -> bool:
	return pos.distance_to(p) <= BASE_RANGE

func count(t: int) -> int:
	return int(store.get(t, 0))

func add(t: int, n: int) -> void:
	store[t] = int(store.get(t, 0)) + n

func remove(t: int, n: int) -> void:
	add(t, -n)

func can_pay(cost: Dictionary) -> bool:
	for t in cost:
		if count(t) < int(cost[t]):
			return false
	return true

func pay(cost: Dictionary) -> void:
	for t in cost:
		remove(t, int(cost[t]))

# Le PNJ de la salle de production génère du lithium en passif (même absent).
func produce(delta: float) -> void:
	if not has_prod:
		return
	prod_timer += delta
	if prod_timer >= PROD_INTERVAL:
		prod_timer -= PROD_INTERVAL
		add(WorldGrid.LITHIUM, 1)
