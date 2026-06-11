class_name LightField
extends RefCounted
## La part CPU de la lumière, depuis le passage au vrai éclairage (lights.gd +
## occulteurs dans world_view.gd) : registre des torches, lignes de vue (IA des
## robots), et l'ÉCLAIRAGE DE FACE — la lumière GPU s'arrête au premier bloc
## (ombres), donc la première couche de blocs est redessinée dans sa couleur
## (cf. marker_view.gd) pour que le joueur devine ce qu'il va miner.

# Alignés sur le cône GPU de lights.gd (mêmes angles / portées, en tuiles)
const FACE_RANGE := 13.75        # portée du faisceau (= LightRig.CONE_RANGE / 16)
const FACE_BEAM_CORE := 3.0      # plein au départ du faisceau
const AMB_CORE := 1.2            # halo de corps : plein autour du héros
const AMB_RADIUS := 3.5          # halo de corps : portée
const AMB_MAX := 0.75
const TORCH_RADIUS := 5.6        # (= LightRig.TORCH_SCALE * 128 px / 2 / 16)
const TORCH_CORE := 1.5
const SKY_FADE := 14.0           # déclin de la lumière du jour avec la profondeur
const ROOM_LIGHT := 0.85         # pièces du Foyer (générateur implicite)
const ROOM_FADE := 4.0           # diffusion autour des pièces

var world: WorldGrid
var hero: Hero
var foyer: Foyer                  # branché par main.gd
var torches: Array[Vector2i] = [] # torches posées (sécurisent un chemin)

func _init(w: WorldGrid, h: Hero) -> void:
	world = w
	hero = h

# Lumière reçue par la FACE d'un bloc de bordure (toutes sources confondues).
func face_light(tx: int, ty: int) -> float:
	var v := maxf(_lamp(tx, ty), _torch(tx, ty))
	v = maxf(v, _sky(tx, ty))
	v = maxf(v, _room(tx, ty))
	return clampf(v, 0.0, 1.0)

func _lamp(tx: int, ty: int) -> float:
	if hero.lamp_factor <= 0.0:
		return 0.0
	var ts := float(WorldGrid.TILE)
	var hc := Vector2(hero.pos.x / ts, hero.pos.y / ts)
	var v := Vector2(tx + 0.5, ty + 0.5) - hc
	var d := v.length()
	# Halo de corps (toutes directions)
	var amb := 1.0 - clampf((d - AMB_CORE) / (AMB_RADIUS - AMB_CORE), 0.0, 1.0)
	amb = amb * amb * AMB_MAX
	# Faisceau (mêmes angles que le cône GPU)
	var beam := 0.0
	if d > 0.001:
		var ang := clampf((v.dot(hero.aim) / d - LightRig.CONE_COS_OUTER) \
			/ (LightRig.CONE_COS_INNER - LightRig.CONE_COS_OUTER), 0.0, 1.0)
		var rad := 1.0 - clampf((d - FACE_BEAM_CORE) / (FACE_RANGE - FACE_BEAM_CORE), 0.0, 1.0)
		beam = ang * rad * rad
	var lit := maxf(amb, beam) * hero.lamp_factor
	if lit > 0.02 and not los_clear_from(hc, tx, ty):
		return 0.0
	return lit

func _torch(tx: int, ty: int) -> float:
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

func _sky(tx: int, ty: int) -> float:
	var s := world.surface[clampi(tx, 0, WorldGrid.GRID_W - 1)]
	if ty < s:
		return 1.0
	return 1.0 - clampf(float(ty - s) / SKY_FADE, 0.0, 1.0)

func _room(tx: int, ty: int) -> float:
	if foyer == null:
		return 0.0
	var best := 0.0
	for mp in foyer.rooms:
		var r: Rect2i = foyer.interior(mp)
		var dx := maxi(maxi(r.position.x - tx, tx - (r.end.x - 1)), 0)
		var dy := maxi(maxi(r.position.y - ty, ty - (r.end.y - 1)), 0)
		var d := float(maxi(dx, dy))
		if d <= 0.0:
			return ROOM_LIGHT
		best = maxf(best, ROOM_LIGHT * (1.0 - d / ROOM_FADE))
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
