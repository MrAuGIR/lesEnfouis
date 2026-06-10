class_name LightField
extends RefCounted
## Éclairage du monde : lumière du jour (déclin avec la profondeur), lampe frontale
## du héros (faisceau vers la souris + halo de corps) et torches posées.
## Tout est occlus par la ligne de vue (la lumière s'arrête au premier bloc plein).

# Lampe frontale (casque)
const LAMP_AMBIENT_CORE := 1.2   # tuiles : plein autour du corps
const LAMP_AMBIENT_RADIUS := 3.2 # tuiles : portée du halo de corps
const LAMP_AMBIENT_MAX := 0.75   # le halo de corps est un peu moins fort que le faisceau
const LAMP_BEAM_CORE := 3.0      # tuiles : plein au départ du faisceau
const LAMP_BEAM_RANGE := 14.0    # tuiles : portée du faisceau (cône plus long)
const LAMP_COS_INNER := 0.90     # cos(~26°) : cœur du faisceau (un peu plus large)
const LAMP_COS_OUTER := 0.45     # cos(~63°) : bord du faisceau (cône plus large)
const SKY_FADE := 14.0           # profondeur sur laquelle la lumière du jour décline
const SKY_STRENGTH := 1.0        # intensité de la lumière du jour en surface
const AMBIENT_MIN := 0.05        # luminosité minimale (le noir n'est jamais total)
const TORCH_RADIUS := 5.5        # tuiles : portée d'une torche posée
const TORCH_CORE := 1.5          # tuiles : pleine lumière au pied de la torche

var world: WorldGrid
var hero: Hero
var torches: Array[Vector2i] = [] # torches posées (sécurisent un chemin)

func _init(w: WorldGrid, h: Hero) -> void:
	world = w
	hero = h

func sky_light(tx: int, ty: int) -> float:
	var s := world.surface[clampi(tx, 0, WorldGrid.GRID_W - 1)]
	if ty < s:
		return 1.0
	return 1.0 - clampf(float(ty - s) / SKY_FADE, 0.0, 1.0)

func lamp_light(tx: int, ty: int) -> float:
	var ts := float(WorldGrid.TILE)
	var hc := Vector2(hero.pos.x / ts, hero.pos.y / ts)
	var v := Vector2(tx + 0.5, ty + 0.5) - hc
	var d := v.length()
	# Halo doux autour du corps (toutes directions)
	var amb := 1.0 - clampf((d - LAMP_AMBIENT_CORE) / (LAMP_AMBIENT_RADIUS - LAMP_AMBIENT_CORE), 0.0, 1.0)
	amb = amb * amb * LAMP_AMBIENT_MAX
	# Faisceau dirigé vers la souris
	var beam := 0.0
	if d > 0.001:
		var dir := v / d
		var ang := clampf((dir.dot(hero.aim) - LAMP_COS_OUTER) / (LAMP_COS_INNER - LAMP_COS_OUTER), 0.0, 1.0)
		var rad := 1.0 - clampf((d - LAMP_BEAM_CORE) / (LAMP_BEAM_RANGE - LAMP_BEAM_CORE), 0.0, 1.0)
		beam = ang * rad * rad
	var lit := maxf(amb, beam) * hero.lamp_factor
	# Occlusion : la lumière s'arrête au premier bloc plein (ligne de vue)
	if lit > 0.02 and not los_clear_from(hc, tx, ty):
		return 0.0
	return clampf(lit, 0.0, 1.0)

func torch_light(tx: int, ty: int) -> float:
	var best := 0.0
	for c in torches:
		var src := Vector2(c.x + 0.5, c.y + 0.5)
		var d := src.distance_to(Vector2(tx + 0.5, ty + 0.5))
		if d >= TORCH_RADIUS:
			continue
		var l := 1.0 - clampf((d - TORCH_CORE) / (TORCH_RADIUS - TORCH_CORE), 0.0, 1.0)
		l = l * l
		if l <= best:
			continue
		if l > 0.02 and not los_clear_from(src, tx, ty):
			continue
		best = l
	return best

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

func brightness(tx: int, ty: int) -> float:
	var light := maxf(sky_light(tx, ty) * SKY_STRENGTH, lamp_light(tx, ty))
	light = maxf(light, torch_light(tx, ty))
	return clampf(light, AMBIENT_MIN, 1.0)
