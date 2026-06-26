class_name SpriteDB
extends RefCounted
## Banque de sprites animés des PILLEURS et du ROI DES GALERIES (lot designer v3).
## Charge les frames PNG individuelles à la demande, les met en cache, et rend la
## frame courante d'une animation. Le rendu (world_view) ancre au PIVOT (pieds)
## et flippe selon la direction (les sprites regardent à DROITE). Pas de masque
## magenta dans cette livraison : le brassard rouge = couleur de la faction Pilleurs
## (bakée) — suffisant pour le MVP (une seule faction). Cf. [[da-pixelart-pass]].

# Pivot (px depuis le coin haut-gauche de la frame) par entité : x = milieu, y = pieds.
const PIVOT := {
	"hero": Vector2(16, 30),
	"enemy_fonceur": Vector2(16, 30),
	"enemy_tireur": Vector2(16, 30),
	"enemy_lourd": Vector2(24, 46),
	"boss_roi": Vector2(32, 60),
}

# Sous-dossier de res://art/ par entité (défaut : "enemies"). Le héros a sa propre
# livraison (hero_sprites_production), rangée à part des pilleurs/boss.
const ROOT := {"hero": "hero"}

# entité -> { anim -> [nb_frames, fps, loop] }. loop=false → animation one-shot
# (l'index suit une PROGRESSION 0→1 fournie par l'appelant : attaque/touché/mort).
const ANIM := {
	"hero": {
		"idle": [6, 8, true], "marche": [6, 10, true], "saut": [4, 7, true],
		"echelle": [4, 10, true], "creuse": [6, 12, true],
		"tir": [6, 18, false], "attaque": [6, 18, false],
		"touche": [6, 14, false], "mort": [6, 8, false]},
	"enemy_fonceur": {
		"idle": [2, 4, true], "marche": [4, 10, true], "attaque": [3, 12, false],
		"touche": [1, 1, false], "mort": [3, 8, false]},
	"enemy_tireur": {
		"idle": [2, 4, true], "marche": [4, 10, true], "attaque_tir": [4, 14, false],
		"touche": [1, 1, false], "mort": [3, 8, false]},
	"enemy_lourd": {
		"face_idle": [2, 4, true], "face_marche": [4, 8, true],
		"dos_idle": [2, 4, true], "dos_marche": [4, 8, true],
		"attaque": [4, 10, false], "touche": [1, 1, false], "mort": [3, 8, false]},
	"boss_roi": {
		"idle": [2, 3, true], "marche": [3, 8, true], "telegraphe": [2, 6, true],
		"charge": [3, 12, true], "charge_enrage": [2, 14, true], "slam": [3, 12, false],
		"invocation": [3, 8, false], "idle_enrage": [2, 4, true],
		"touche": [1, 1, false], "mort": [4, 8, false]},
}

static var _cache: Dictionary = {}   # "entity/anim" -> Array[Texture2D]

static func _frames(entity: String, anim: String) -> Array:
	var key := entity + "/" + anim
	if _cache.has(key):
		return _cache[key]
	var n := int(ANIM[entity][anim][0])
	var dir: String = ROOT.get(entity, "enemies")
	var arr: Array = []
	for i in range(1, n + 1):
		arr.append(load("res://art/%s/%s/%s_%s_%02d.png" % [dir, entity, entity, anim, i]))
	_cache[key] = arr
	return arr

static func has(entity: String, anim: String) -> bool:
	return ANIM.has(entity) and ANIM[entity].has(anim)

# Frame courante. clock = horloge globale (s) pour les boucles (idle/marche/…) ;
# progress ∈ [0,1] pour les one-shot (attaque/touché/mort) — l'appelant le calcule.
static func frame(entity: String, anim: String, clock: float, progress: float) -> Texture2D:
	if not has(entity, anim):
		return null
	var meta: Array = ANIM[entity][anim]
	var n := int(meta[0])
	var frames := _frames(entity, anim)
	if frames.is_empty():
		return null
	var idx := (int(clock * float(meta[1])) % n) if bool(meta[2]) else clampi(int(progress * n), 0, n - 1)
	return frames[idx]

# Anim one-shot indexée par ÂGE (s) depuis son déclenchement : la frame avance à
# fps puis se FIGE sur la dernière (attaque/tir/slam/invocation/mort). loop ignoré.
static func frame_at(entity: String, anim: String, age: float) -> Texture2D:
	if not has(entity, anim):
		return null
	var meta: Array = ANIM[entity][anim]
	var frames := _frames(entity, anim)
	if frames.is_empty():
		return null
	return frames[clampi(int(age * float(meta[1])), 0, int(meta[0]) - 1)]

static func is_loop(entity: String, anim: String) -> bool:
	return has(entity, anim) and bool(ANIM[entity][anim][2])

# Durée (s) de l'anim jouée à son fps (sert au TTL des cadavres).
static func dur(entity: String, anim: String) -> float:
	if not has(entity, anim):
		return 0.0
	var meta: Array = ANIM[entity][anim]
	return float(meta[0]) / float(meta[1])

static func pivot(entity: String) -> Vector2:
	return PIVOT.get(entity, Vector2(16, 30))
