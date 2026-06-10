extends Node2D
## Les Enfouis — MVP (grey-box). Orchestration : crée les systèmes, route les
## entrées, fait tourner la boucle. La logique vit dans les modules :
##   world_grid (monde) · hero (héros) · light_field (lumière) · inventory (sac)
##   base_camp (base) · enemy_crew (robots) · combat (armes) · world_view (rendu)
##   hud (interface) · inv_ui (écran d'inventaire)

# Creusage
const DIG_TIME := 0.28           # s pour creuser 1 bloc de terre (le nerf du game feel)
const REACH := 3.5 * WorldGrid.TILE   # portée de creusage autour du héros
const DIG_TIERS := [1.0, 0.65, 0.45]  # mult. de temps (Pierre→Fer→Acier)
const TIER_NAMES := ["Pierre", "Fer", "Acier"]
const UPGRADE_COST := [{}, {WorldGrid.ROCK: 15, WorldGrid.LITHIUM: 8}, {WorldGrid.ROCK: 25, WorldGrid.LITHIUM: 16}]
const COST_ANTIPOL := {WorldGrid.LITHIUM: 5, WorldGrid.WOOD: 3}  # cartouche anti-gaz (atelier)
const LADDER_MAX := 10           # longueur max d'une pose d'échelle (tuiles, 1 bois/tuile)
const CACHE_RANGE := 2.0 * WorldGrid.TILE  # portée de récupération d'une cache

var world: WorldGrid
var hero: Hero
var light: LightField
var bag: Inventory
var camp: BaseCamp
var crew: EnemyCrew
var combat: Combat
var view: WorldView
var camera: Camera2D
var hud: Hud
var inv_ui: InvUI

var dig_level := 0                # palier d'outil : 0 Pierre, 1 Fer, 2 Acier
var dig_target := Vector2i(-1, -1)
var dig_progress := 0.0
var won := false
var inv_open := false             # l'écran d'inventaire est ouvert (fige le jeu)

# Cache de butin (à la mort, façon Souls) : une cache précédente est perdue.
var cache_active := false
var cache_pos := Vector2.ZERO
var cache := {}

func _ready() -> void:
	randomize()
	world = WorldGrid.new()
	world.generate()
	hero = Hero.new(world)
	hero.spawn()
	light = LightField.new(world, hero)
	bag = Inventory.new()
	camp = BaseCamp.new()
	camp.pos = hero.pos
	crew = EnemyCrew.new(world, light, hero)
	crew.spawn(camp.pos)
	view = WorldView.new()
	view.world = world
	view.hero = hero
	view.light = light
	view.crew = crew
	view.camp = camp
	view.cache_range = CACHE_RANGE
	add_child(view)
	camera = Camera2D.new()
	camera.zoom = Vector2(2.5, 2.5)   # on grossit : ~30 tuiles de large à l'écran
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	add_child(camera)
	camera.make_current()
	camera.global_position = hero.pos   # cadrage immédiat (pas de panoramique au démarrage)
	camera.reset_smoothing()
	hud = Hud.new()
	add_child(hud)
	combat = Combat.new(hero, world, crew, bag, hud, view)
	view.combat = combat
	# Calque d'inventaire (plein écran, masqué par défaut), au-dessus du HUD
	inv_ui = InvUI.new()
	inv_ui.bag = bag
	inv_ui.camp = camp
	inv_ui.hero = hero
	inv_ui.hud = hud
	inv_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	inv_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	inv_ui.visible = false
	hud.add_child(inv_ui)
	_update_hud()

# --- Boucle -------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	hero.move(delta, not inv_open)
	if not inv_open:
		crew.update(delta)   # l'inventaire fige le jeu (héros ET robots)
	if hero.hp <= 0.0:
		_die()
	camera.global_position = hero.pos

func _process(delta: float) -> void:
	_update_aim()
	hero.deplete_lamp(delta)
	camp.produce(delta)
	_check_exit()
	var gas_msg := hero.update_gas(delta)
	if gas_msg != "":
		hud.flash(gas_msg)
	if hero.hp <= 0.0:
		_die()
	combat.update(delta, not inv_open and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT))
	_handle_dig(delta)
	hud.tick(delta)
	_update_hud()
	view.cache_active = cache_active
	view.cache_pos = cache_pos
	view.tick(delta)
	if inv_open:
		inv_ui.queue_redraw()   # la pile tenue suit le curseur

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_refuel()
		elif event.keycode == KEY_T:
			_place_torch()
		elif event.keycode == KEY_F or event.physical_keycode == KEY_F:
			_place_ladder()
		elif event.keycode == KEY_E:
			_interact()
		elif event.keycode == KEY_Q:
			_withdraw()
		elif event.keycode == KEY_1 or event.physical_keycode == KEY_1:
			_build_production()
		elif event.keycode == KEY_2 or event.physical_keycode == KEY_2:
			_build_workshop()
		elif event.keycode == KEY_3 or event.physical_keycode == KEY_3:
			_upgrade_tool()
		elif event.keycode == KEY_4 or event.physical_keycode == KEY_4:
			_craft_antipol()
		elif event.keycode == KEY_I or event.physical_keycode == KEY_I:
			_toggle_inventory()
		elif event.keycode == KEY_X or event.physical_keycode == KEY_X:
			combat.swap_weapon()
		elif event.keycode == KEY_M or event.physical_keycode == KEY_M:
			hud.flash(hero.toggle_antipol())
		elif event.keycode == KEY_K:
			hero.damage(Hero.MAX_HP)   # mort de test
	elif event is InputEventMouseButton and event.pressed and not inv_open:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			combat.swap_weapon()

func _update_aim() -> void:
	var v := get_global_mouse_position() - hero.pos
	if v.length() > 1.0:
		hero.aim = v.normalized()

func _check_exit() -> void:
	# Victoire : rejoindre la SORTIE en surface (zone centrale, au niveau du sol ou au-dessus).
	if won:
		return
	var cx := world.exit_col()
	var tx := int(hero.pos.x / WorldGrid.TILE)
	var ty := int((hero.pos.y + hero.half.y) / WorldGrid.TILE)   # niveau des pieds
	if absi(tx - cx) <= WorldGrid.EXIT_HALF and ty <= world.surface[clampi(tx, 0, WorldGrid.GRID_W - 1)]:
		won = true
		hud.flash("*** SORTI ! Tu as rejoint la surface. Bravo ! ***")

# --- Mort / cache -------------------------------------------------------------
func _die() -> void:
	# Largue le butin transporté dans une cache (Souls). Une cache précédente est perdue.
	if bag.total() > 0:
		cache_active = true
		cache_pos = hero.pos
		cache = {}
		for t in Inventory.RES_TYPES:
			cache[t] = bag.count(t)
		bag.clear()
	hero.pos = camp.pos
	hero.vel = Vector2.ZERO
	hero.hp = Hero.MAX_HP
	hud.flash("Tu es mort... reapparition a la base." + ("  >> CACHE laissee sur place <<" if cache_active else ""))

func _interact() -> void:
	if camp.near(hero.pos):
		_deposit()
	elif cache_active and hero.pos.distance_to(cache_pos) <= CACHE_RANGE:
		_recover_cache()

func _deposit() -> void:
	for t in Inventory.RES_TYPES:
		camp.add(t, bag.count(t))
	bag.clear()
	hero.hp = Hero.MAX_HP   # on se soigne à la base

func _withdraw() -> void:
	# Base → sac : raccourci pratique (priorité au carburant, puis bois/roche/terre),
	# dans la limite des slots libres. Le réglage fin se fait à l'inventaire (touche I).
	if not camp.near(hero.pos):
		return
	for t in [WorldGrid.LITHIUM, WorldGrid.WOOD, WorldGrid.ROCK, WorldGrid.DIRT]:
		var moved := bag.add(t, camp.count(t))
		camp.remove(t, moved)

func _recover_cache() -> void:
	for t in cache:
		bag.add(t, int(cache[t]))
	cache_active = false
	hud.flash("Butin de la cache recupere !")

# --- Actions (lampe, torche, échelle) ------------------------------------------
func _refuel() -> void:
	if bag.count(WorldGrid.LITHIUM) > 0 and hero.lamp_fuel < Hero.LAMP_AUTONOMY:
		bag.remove(WorldGrid.LITHIUM, 1)
		hero.lamp_fuel = minf(Hero.LAMP_AUTONOMY, hero.lamp_fuel + Hero.LAMP_REFILL)

func _place_torch() -> void:
	var cell := Vector2i(int(floor(hero.pos.x / WorldGrid.TILE)), int(floor(hero.pos.y / WorldGrid.TILE)))
	if bag.count(WorldGrid.WOOD) > 0 and not world.is_solid(cell.x, cell.y) and not light.torches.has(cell):
		bag.remove(WorldGrid.WOOD, 1)
		light.torches.append(cell)

func _place_ladder() -> void:
	# Pose une échelle dans la colonne, des pieds vers le haut, en remplissant le
	# vide jusqu'au premier bloc plein (1 bois par tuile). Idéal pour remonter un puits.
	var cx := int(hero.pos.x / WorldGrid.TILE)
	var ty := int((hero.pos.y + hero.half.y - 1) / WorldGrid.TILE)
	var placed := 0
	while placed < LADDER_MAX and ty >= 0:
		var t := world.tile(cx, ty)
		if t == WorldGrid.EMPTY:
			if bag.count(WorldGrid.WOOD) <= 0:
				break
			world.set_tile(cx, ty, WorldGrid.LADDER)
			bag.remove(WorldGrid.WOOD, 1)
			placed += 1
		elif t == WorldGrid.LADDER and placed == 0:
			pass   # on démarre sur/dans une échelle : on la traverse pour combler le vide au-dessus
		else:
			break  # bloc plein, OU échelle déjà posée au-dessus → stop (pas de dépassement)
		ty -= 1
	if placed > 0:
		hud.flash("Echelle posee : %d tuiles (-%d bois)" % [placed, placed])
	else:
		hud.flash("Echelle : rien a poser (pas de place ou pas de bois)")

# --- Base (constructions simples — remplacées par les pièces du Foyer en M2) ----
func _build_production() -> void:
	if not camp.near(hero.pos):
		hud.flash("Approche-toi de la base (zone verte)")
		return
	if camp.has_prod:
		hud.flash("Production deja construite")
		return
	if not camp.can_pay(BaseCamp.COST_PROD):
		hud.flash("Pas assez en base : il faut 12 roche + 8 bois")
		return
	camp.pay(BaseCamp.COST_PROD)
	camp.has_prod = true   # un PNJ y est affecté automatiquement (grey-box)
	hud.flash("Production construite ! Un PNJ produit du lithium en passif.")

func _build_workshop() -> void:
	if not camp.near(hero.pos):
		hud.flash("Approche-toi de la base (zone verte)")
		return
	if camp.has_workshop:
		hud.flash("Atelier deja construit")
		return
	if not camp.can_pay(BaseCamp.COST_WORKSHOP):
		hud.flash("Pas assez en base : il faut 15 roche + 6 bois")
		return
	camp.pay(BaseCamp.COST_WORKSHOP)
	camp.has_workshop = true
	hud.flash("Atelier construit ! Tu peux ameliorer l'outil (touche 3).")

func _upgrade_tool() -> void:
	if not camp.near(hero.pos):
		hud.flash("Approche-toi de la base (zone verte)")
		return
	if not camp.has_workshop:
		hud.flash("Atelier requis d'abord (touche 2)")
		return
	if dig_level >= DIG_TIERS.size() - 1:
		hud.flash("Outil deja au maximum (Acier)")
		return
	var cost: Dictionary = UPGRADE_COST[dig_level + 1]
	if not camp.can_pay(cost):
		hud.flash("Pas assez en base : %d roche + %d lithium" % [int(cost.get(WorldGrid.ROCK, 0)), int(cost.get(WorldGrid.LITHIUM, 0))])
		return
	camp.pay(cost)
	dig_level += 1
	hud.flash("Outil ameliore : %s (creusage plus rapide)" % TIER_NAMES[dig_level])

func _craft_antipol() -> void:
	if not camp.near(hero.pos):
		hud.flash("Approche-toi de la base (zone verte)")
		return
	if not camp.has_workshop:
		hud.flash("Atelier requis pour crafter (touche 2)")
		return
	if not camp.can_pay(COST_ANTIPOL):
		hud.flash("Pas assez en base : il faut 5 lithium + 3 bois")
		return
	camp.pay(COST_ANTIPOL)
	hero.antipol_fuel += Hero.ANTIPOL_PER_CHARGE
	hud.flash("Cartouche anti-gaz craftee (%d). Activer : touche M." % hero.antipol_charges())

# --- Inventaire ----------------------------------------------------------------
func _toggle_inventory() -> void:
	inv_open = not inv_open
	inv_ui.visible = inv_open
	inv_ui.queue_redraw()
	if not inv_open:
		inv_ui.drop_held()

# --- Creusage -----------------------------------------------------------------
func _handle_dig(delta: float) -> void:
	if inv_open or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_reset_dig()
		return
	var m := get_global_mouse_position()
	var tx := int(floor(m.x / WorldGrid.TILE))
	var ty := int(floor(m.y / WorldGrid.TILE))
	if not world.is_diggable(tx, ty) or not _in_reach(tx, ty):
		_reset_dig()
		return
	if world.tile(tx, ty) == WorldGrid.HARDROCK and dig_level < 1:
		_reset_dig()
		hud.flash("Roche dense : outil en Fer requis (atelier puis amelioration)")
		return
	var cell := Vector2i(tx, ty)
	if cell != dig_target:
		dig_target = cell
		dig_progress = 0.0
	dig_progress += delta
	var need := _dig_need(tx, ty)
	if dig_progress >= need:
		_break_tile(tx, ty)
		_reset_dig()
		return
	view.dig_target = dig_target
	view.dig_frac = dig_progress / need

func _reset_dig() -> void:
	dig_target = Vector2i(-1, -1)
	dig_progress = 0.0
	view.dig_target = dig_target
	view.dig_frac = 0.0

func _dig_need(tx: int, ty: int) -> float:
	return DIG_TIME * DIG_TIERS[dig_level] * world.dig_mult(world.tile(tx, ty))

func _break_tile(tx: int, ty: int) -> void:
	var t := world.tile(tx, ty)
	world.set_tile(tx, ty, WorldGrid.EMPTY)
	view.add_flash(Vector2i(tx, ty), 0.18)
	if t == WorldGrid.WALL:
		return   # béton : gravats, rien à ramasser
	var item := WorldGrid.DIRT
	if t == WorldGrid.ROCK or t == WorldGrid.HARDROCK:
		item = WorldGrid.ROCK
	elif t == WorldGrid.WOOD:
		item = WorldGrid.WOOD
	elif t == WorldGrid.LITHIUM:
		item = WorldGrid.LITHIUM
	if bag.add(item, 1) == 0:
		hud.flash("Sac plein ! Objet perdu (vide-le a la base, ou touche I)")

func _in_reach(tx: int, ty: int) -> bool:
	var center := Vector2(tx * WorldGrid.TILE + WorldGrid.TILE * 0.5, ty * WorldGrid.TILE + WorldGrid.TILE * 0.5)
	return hero.pos.distance_to(center) <= REACH

# --- HUD ----------------------------------------------------------------------
func _update_hud() -> void:
	var bagline := "Sac: %d/%d slots" % [bag.slots_used(), Inventory.BAG_SLOTS]
	if bag.slots_used() >= Inventory.BAG_SLOTS:
		bagline += "  (PLEIN)"
	if cache_active:
		bagline += "     >> CACHE a recuperer <<"
	var base_line := "Base: Production[%s]  Atelier[%s]  Outil: %s" % ["ON" if camp.has_prod else "-", "ON" if camp.has_workshop else "-", TIER_NAMES[dig_level]]
	var obj := "Objectif: REMONTER a la surface (barriere de roche dense = outil Fer)"
	if won:
		obj = "*** SORTI ! Tu as rejoint la surface ***"
	elif hero.in_gas():
		obj += ("   [GAZ: protege]" if (hero.antipol_on and hero.antipol_fuel > 0.0) else "   !! GAZ TOXIQUE : -PV !!")
	var weap := "Arme: melee" if combat.weapon == 0 else "Arme: feu (%d mun.)" % combat.ammo
	var antigas := "Anti-gaz: %s (%d)" % ["ON" if hero.antipol_on else "off", hero.antipol_charges()]
	var hint := "[ZQSD/Fleches] bouger/grimper  [Espace] saut  [Clic G] creuser  [Clic D] attaquer  [Molette/X] arme  [I] inventaire  [F] echelle  [R] lampe  [T] torche  [M] anti-gaz  [E] deposer  [Q] retirer  [K] mort"
	if camp.near(hero.pos):
		hint = "BASE >  [1] Production (12 roche/8 bois)   [2] Atelier (15 roche/6 bois)   [3] Ameliorer outil   [4] Cartouche anti-gaz (5 Li/3 bois)   [I] inventaire  [E] deposer  [Q] retirer"
	hud.set_stats("%s\nPV: %d/%d    %s\nSac    - Li:%d  Bois:%d  Terre:%d  Roche:%d\nBase   - Li:%d  Bois:%d  Terre:%d  Roche:%d\nLampe: %d%%   Torches: %d   %s   |   %s   |   %s" % [
		obj, int(hero.hp), int(Hero.MAX_HP), bagline,
		bag.count(WorldGrid.LITHIUM), bag.count(WorldGrid.WOOD), bag.count(WorldGrid.DIRT), bag.count(WorldGrid.ROCK),
		camp.count(WorldGrid.LITHIUM), camp.count(WorldGrid.WOOD), camp.count(WorldGrid.DIRT), camp.count(WorldGrid.ROCK),
		int(hero.lamp_fuel / Hero.LAMP_AUTONOMY * 100.0), light.torches.size(), antigas, weap, base_line])
	hud.set_hints(hint)
