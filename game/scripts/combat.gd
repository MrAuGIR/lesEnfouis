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
const START_AMMO := 8            # munitions de départ (le reste se fouille / se troque)
const ENEMY_LOOT := 3            # lithium (batteries) lâché à la mort d'un robot
const ENEMY_AMMO_DROP := 2       # munitions lâchées par un robot (avec une probabilité)
const ENEMY_AMMO_CHANCE := 0.6   # probabilité qu'un robot lâche des munitions
const PILLEUR_LOOT := 2          # fer (récup) lâché par un pilleur/tireur
const LOURD_LOOT := 6            # fer du Lourd (carcasse blindée)
const LOURD_AMMO := 6            # munitions garanties sur le Lourd

var hero: Hero
var world: WorldGrid
var crew: EnemyCrew
var bag: Inventory
var hud: Hud
var view: MarkerView          # feedbacks (flash, traceur lus par le calque marqueurs)
var raids: Raids              # branché par main.gd : butin des porteurs abattus (M4)

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
			EnemyCrew.hurt(e, MELEE_DMG, hero.pos.x)
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
		if perp <= (e["half"] as Vector2).y + 3.0:
			target = e
			target_d = proj
	tracer_a = hero.pos
	tracer_b = hero.pos + hero.aim * target_d
	tracer_t = GUN_TRACER_T
	if target != null:
		EnemyCrew.hurt(target, GUN_DMG, hero.pos.x)
		_cull()

func _cull() -> void:
	var ts := WorldGrid.TILE
	var alive := []
	for e in crew.list:
		# Le Roi des Galeries ne se « loote » pas ici : sa mort est mise en scène
		# par boss.gd (charge de perçage, portes, sbires).
		if float(e["hp"]) > 0.0 or e.get("boss", false):
			alive.append(e)
			continue
		view.add_flash(Vector2i(int(e["pos"].x / ts), int(e["pos"].y / ts)), 0.3)
		# Porteur de raid abattu : son butin volé tombe au sol (récupérable).
		if raids != null and not (e.get("carry", {}) as Dictionary).is_empty():
			raids.drop_at(Vector2(e["pos"]), e["carry"])
		var kind := int(e["kind"])
		var got_ammo := 0
		var lootmsg := ""
		if kind == EnemyCrew.KIND_ROBOT:
			bag.add(WorldGrid.LITHIUM, ENEMY_LOOT)
			lootmsg = "+%d lithium" % ENEMY_LOOT
			if randf() < ENEMY_AMMO_CHANCE:
				got_ammo = ENEMY_AMMO_DROP
		elif kind == EnemyCrew.KIND_LOURD:
			bag.add(WorldGrid.IRON, LOURD_LOOT)
			lootmsg = "+%d fer" % LOURD_LOOT
			got_ammo = LOURD_AMMO
		else:
			bag.add(WorldGrid.IRON, PILLEUR_LOOT)
			lootmsg = "+%d fer" % PILLEUR_LOOT
			if randf() < 0.5:
				got_ammo = ENEMY_AMMO_DROP
		ammo += got_ammo
		if got_ammo > 0:
			lootmsg += ", +%d munitions" % got_ammo
		var verb := "detruit" if kind == EnemyCrew.KIND_ROBOT else "abattu"
		hud.flash("%s %s (%s)" % [EnemyCrew.KIND_NAMES[kind], verb, lootmsg])
	crew.list = alive
