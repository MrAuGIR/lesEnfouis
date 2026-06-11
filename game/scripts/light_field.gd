class_name LightField
extends RefCounted
## Depuis le passage au vrai éclairage (lights.gd + occulteurs dans
## world_view.gd), ce module ne garde que la part GAMEPLAY de la lumière :
## le registre des torches posées et les lignes de vue (IA des robots).

var world: WorldGrid
var hero: Hero
var torches: Array[Vector2i] = [] # torches posées (sécurisent un chemin)

func _init(w: WorldGrid, h: Hero) -> void:
	world = w
	hero = h

func los_clear_from(a: Vector2, tx: int, ty: int) -> bool:
	# Vrai si rien de plein ne bloque entre la source (en tuiles) et la tuile (cible
	# exclue : le mur qu'on regarde est éclairé sur sa face, pas ce qu'il y a derrière).
	var b := Vector2(tx + 0.5, ty + 0.5)
	var steps := int(ceil(a.distance_to(b) * 2.0))
	if steps <= 1:
		return true
	for i in range(1, steps):
		var p := a.lerp(b, float(i) / float(steps))
		var cx := int(floor(p.x))
		var cy := int(floor(p.y))
		if cx == tx and cy == ty:
			continue
		if world.is_solid(cx, cy):
			return false
	return true
