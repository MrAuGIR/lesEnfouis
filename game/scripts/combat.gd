class_name Combat
extends RefCounted
## Les armes du héros : coup de mêlée (arc vers la souris, cooldown) et arme à
## feu (tir hitscan visé souris, occlusion par les murs, munitions limitées).
## Les robots détruits lâchent du lithium (et parfois des munitions).

const MELEE_RANGE := 1.7 * WorldGrid.TILE  # portée du coup
const MELEE_ARC := 0.2           # produit scalaire mini (cône d'attaque vers la souris)
const MELEE_DMG := 34.0          # ~2 coups pour tuer un robot
const MELEE_CD := 0.42           # s entre deux coups du héros
const MELEE_VIS := 0.16          # s d'affichage de l'arc de coup
const MELEE_KNOCK := 120.0       # recul infligé au robot touché
const GUN_DMG := 40.0            # ~2 balles pour détruire un robot
const GUN_RANGE := 14.0 * WorldGrid.TILE   # portée du tir
const GUN_CD := 0.5              # s entre deux tirs
const GUN_TRACER_T := 0.08       # s d'affichage du traceur
const START_AMMO := 24           # munitions de départ — CONFORT DE TEST (à remettre à 0/qqs, M6)
const ENEMY_LOOT := 3            # lithium (batteries) lâché à la mort d'un robot
const ENEMY_AMMO_DROP := 2       # munitions lâchées par un robot (avec une probabilité)
const ENEMY_AMMO_CHANCE := 0.6   # probabilité qu'un robot lâche des munitions

var hero: Hero
var world: WorldGrid
var crew: EnemyCrew
var bag: Inventory
var hud: Hud
var view: MarkerView          # feedbacks (flash, traceur lus par le calque marqueurs)

var weapon := 0                  # arme courante : 0 = mêlée, 1 = arme à feu
var ammo := START_AMMO           # munitions (réserve dédiée, pas dans le sac)
var atk_cd := 0.0                # cooldown du coup du héros
var atk_t := 0.0                 # reste d'affichage de l'arc de coup
var gun_cd := 0.0
var tracer_t := 0.0              # reste d'affichage du traceur de tir
var tracer_a := Vector2.ZERO     # extrémités du traceur (départ → impact)
var tracer_b := Vector2.ZERO

func _init(h: Hero, w: WorldGrid, c: EnemyCrew, b: Inventory, ui: Hud, v: MarkerView) -> void:
	hero = h
	world = w
	crew = c
	bag = b
	hud = ui
	view = v

# attacking = clic droit maintenu et commandes actives (inventaire fermé).
func update(delta: float, attacking: bool) -> void:
	atk_cd = maxf(0.0, atk_cd - delta)
	atk_t = maxf(0.0, atk_t - delta)
	gun_cd = maxf(0.0, gun_cd - delta)
	tracer_t = maxf(0.0, tracer_t - delta)
	if not attacking:
		return
	if weapon == 0 and atk_cd <= 0.0:
		_melee_attack()
	elif weapon == 1 and gun_cd <= 0.0:
		_gun_fire()

func swap_weapon() -> void:
	weapon = 1 - weapon
	if weapon == 1:
		hud.flash("Arme : arme a feu (%d munitions)" % ammo)
	else:
		hud.flash("Arme : melee")

func _melee_attack() -> void:
	atk_cd = MELEE_CD
	atk_t = MELEE_VIS
	for e in crew.list:
		var v: Vector2 = e["pos"] - hero.pos
		var d := v.length()
		if d <= MELEE_RANGE and (d < 0.001 or v.normalized().dot(hero.aim) >= MELEE_ARC):
			e["hp"] = float(e["hp"]) - MELEE_DMG
			e["flash"] = MELEE_VIS
			e["vel"] += hero.aim * MELEE_KNOCK
	_cull()

func _gun_fire() -> void:
	if ammo <= 0:
		gun_cd = 0.25
		hud.flash("Plus de munitions ! (passe en melee : molette/X)")
		return
	ammo -= 1
	gun_cd = GUN_CD
	# Distance jusqu'au premier mur sur le rayon (occlusion).
	var ts := float(WorldGrid.TILE)
	var wall_d := GUN_RANGE
	var steps := int(GUN_RANGE / (ts * 0.5))
	for i in range(1, steps + 1):
		var d := float(i) * ts * 0.5
		var p := hero.pos + hero.aim * d
		if world.is_solid(int(p.x / ts), int(p.y / ts)):
			wall_d = d
			break
	# Robot le plus proche traversé par le rayon, avant le mur.
	var target = null
	var target_d := wall_d
	for e in crew.list:
		var to_e: Vector2 = e["pos"] - hero.pos
		var proj := to_e.dot(hero.aim)
		if proj <= 0.0 or proj > target_d:
			continue
		var perp := (to_e - hero.aim * proj).length()
		if perp <= EnemyCrew.ENEMY_HALF.y + 3.0:
			target = e
			target_d = proj
	tracer_a = hero.pos
	tracer_b = hero.pos + hero.aim * target_d
	tracer_t = GUN_TRACER_T
	if target != null:
		target["hp"] = float(target["hp"]) - GUN_DMG
		target["flash"] = MELEE_VIS
		_cull()

func _cull() -> void:
	var ts := WorldGrid.TILE
	var alive := []
	for e in crew.list:
		if float(e["hp"]) > 0.0:
			alive.append(e)
		else:
			bag.add(WorldGrid.LITHIUM, ENEMY_LOOT)
			view.add_flash(Vector2i(int(e["pos"].x / ts), int(e["pos"].y / ts)), 0.3)
			var got_ammo := 0
			if randf() < ENEMY_AMMO_CHANCE:
				got_ammo = ENEMY_AMMO_DROP
				ammo += got_ammo
			if got_ammo > 0:
				hud.flash("Robot detruit (+%d lithium, +%d munitions)" % [ENEMY_LOOT, got_ammo])
			else:
				hud.flash("Robot detruit (+%d lithium)" % ENEMY_LOOT)
	crew.list = alive
