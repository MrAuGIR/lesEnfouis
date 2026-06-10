extends Node2D
## Les Enfouis — MVP (grey-box). Orchestration : crée les systèmes, route les
## entrées, fait tourner la boucle. La logique vit dans les modules :
##   world_grid (monde) · hero (héros) · light_field (lumière) · inventory (sac)
##   foyer (base à pièces) · population (PNJ) · caravan (troc) · enemy_crew (robots)
##   combat (armes) · world_view (rendu) · hud · inv_ui / room_ui / trade_ui (écrans)

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
var foyer: Foyer
var pop: Population
var caravan: Caravan
var crew: EnemyCrew
var combat: Combat
var view: WorldView
var camera: Camera2D
var hud: Hud
var inv_ui: InvUI
var room_ui: RoomUI
var trade_ui: TradeUI

var dig_level := 0                # palier d'outil : 0 Pierre, 1 Fer, 2 Acier
var dig_target := Vector2i(-1, -1)
var dig_progress := 0.0
var won := false
var inv_open := false             # l'écran d'inventaire est ouvert (fige le jeu)

# Mode placement (construction libre) : type de pièce en cours, -1 sinon.
var placing := -1
var slots_t := 0.0                # recalcul périodique des slots (connecteurs posés…)

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
	foyer = Foyer.new(world)
	pop = Population.new(world, foyer)
	caravan = Caravan.new(world, foyer)
	crew = EnemyCrew.new(world, light, hero)
	crew.spawn(foyer.pos)
	view = WorldView.new()
	view.world = world
	view.hero = hero
	view.light = light
	view.crew = crew
	view.foyer = foyer
	view.pop = pop
	view.caravan = caravan
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
	# Écrans plein écran (masqués par défaut), au-dessus du HUD
	inv_ui = InvUI.new()
	inv_ui.bag = bag
	inv_ui.foyer = foyer
	inv_ui.hero = hero
	inv_ui.hud = hud
	_setup_screen(inv_ui)
	room_ui = RoomUI.new()
	room_ui.foyer = foyer
	room_ui.pop = pop
	room_ui.hud = hud
	room_ui.on_choose = _start_placement
	_setup_screen(room_ui)
	trade_ui = TradeUI.new()
	trade_ui.foyer = foyer
	trade_ui.caravan = caravan
	trade_ui.combat = combat
	trade_ui.hud = hud
	_setup_screen(trade_ui)
	_update_hud()

func _setup_screen(ui: Control) -> void:
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_STOP
	ui.visible = false
	hud.add_child(ui)

# Un écran est ouvert (inventaire, cellule, troc) → fige héros/robots/armes/creusage.
func _ui_open() -> bool:
	return inv_open or room_ui.visible or trade_ui.visible

# --- Boucle -------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	hero.move(delta, not _ui_open())
	if not _ui_open():
		crew.update(delta)   # un écran ouvert fige le jeu (héros ET robots)
	if hero.hp <= 0.0:
		_die()
	camera.global_position = hero.pos

func _process(delta: float) -> void:
	_update_aim()
	hero.deplete_lamp(delta)
	foyer.produce(delta, pop)
	var pop_msg := pop.update(delta)
	if pop_msg != "":
		hud.flash(pop_msg)
	var car_msg := caravan.update(delta)
	if car_msg != "":
		hud.flash(car_msg)
	if trade_ui.visible and not caravan.present:
		trade_ui.visible = false   # la caravane est repartie pendant le troc
	_check_exit()
	var gas_msg := hero.update_gas(delta)
	if gas_msg != "":
		hud.flash(gas_msg)
	if hero.hp <= 0.0:
		_die()
	combat.update(delta, not _ui_open() and placing < 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT))
	_handle_dig(delta)
	if placing >= 0:
		slots_t -= delta
		if slots_t <= 0.0:   # connecteurs posés/cassés entre-temps → on rafraîchit
			slots_t = 0.5
			_refresh_slots()
	hud.tick(delta)
	_update_hud()
	view.cache_active = cache_active
	view.cache_pos = cache_pos
	view.tick(delta)
	if inv_open:
		inv_ui.queue_redraw()   # la pile tenue suit le curseur
	if trade_ui.visible:
		trade_ui.queue_redraw() # le compte à rebours de départ vit

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var panel_open := room_ui.visible or trade_ui.visible
		if event.keycode == KEY_ESCAPE:
			if inv_open:
				_toggle_inventory()
			room_ui.close()
			trade_ui.visible = false
			_stop_placement()
		elif event.keycode == KEY_B or event.physical_keycode == KEY_B:
			if placing >= 0:
				_stop_placement()
			elif room_ui.visible:
				room_ui.close()
			elif not _ui_open():
				room_ui.open_build()
		elif event.keycode == KEY_G or event.physical_keycode == KEY_G:
			if not _ui_open() and placing < 0:
				_place_walkway()
		elif event.keycode == KEY_E:
			if panel_open:
				room_ui.close()
				trade_ui.visible = false
			elif not inv_open:
				_interact()
		elif event.keycode == KEY_I or event.physical_keycode == KEY_I:
			if not panel_open:
				_toggle_inventory()
		elif event.keycode == KEY_Q:
			if not _ui_open():
				_withdraw()
		elif event.keycode == KEY_R:
			if not _ui_open():
				_refuel()
		elif event.keycode == KEY_T:
			if not _ui_open():
				_place_torch()
		elif event.keycode == KEY_F or event.physical_keycode == KEY_F:
			if not _ui_open():
				_place_ladder()
		elif event.keycode == KEY_3 or event.physical_keycode == KEY_3:
			if not _ui_open():
				_upgrade_tool()
		elif event.keycode == KEY_4 or event.physical_keycode == KEY_4:
			if not _ui_open():
				_craft_antipol()
		elif event.keycode == KEY_X or event.physical_keycode == KEY_X:
			combat.swap_weapon()
		elif event.keycode == KEY_M or event.physical_keycode == KEY_M:
			hud.flash(hero.toggle_antipol())
		elif event.keycode == KEY_K:
			hero.damage(Hero.MAX_HP)   # mort de test
	elif event is InputEventMouseButton and event.pressed and not _ui_open():
		if placing >= 0:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_place_click(get_global_mouse_position())
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_stop_placement()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
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
		for t in Inventory.STORE_TYPES:
			cache[t] = bag.count(t)
		bag.clear()
	hero.spawn()   # réapparition au Foyer, PV au max
	hud.flash("Tu es mort... reapparition au Foyer." + ("  >> CACHE laissee sur place <<" if cache_active else ""))

# --- Construction libre (mode placement) -----------------------------------------
func _start_placement(type: int) -> void:
	placing = type
	slots_t = 0.5
	_refresh_slots()
	hud.flash("Placement : %s — clique un slot vert ([B]/clic droit : annuler)" % Foyer.ROOM_NAMES[type])

func _stop_placement() -> void:
	placing = -1
	view.build_room = -1
	view.build_slots = []

func _refresh_slots() -> void:
	var ts := float(WorldGrid.TILE)
	var rects := []
	for mp in foyer.valid_slots():
		var fp := foyer.footprint(mp)
		rects.append(Rect2(Vector2(fp.position) * ts, Vector2(fp.size) * ts))
	view.build_room = placing
	view.build_slots = rects

func _place_click(world_pos: Vector2) -> void:
	for mp in foyer.valid_slots():
		var fp := foyer.footprint(mp)
		var r := Rect2(Vector2(fp.position) * float(WorldGrid.TILE), Vector2(fp.size) * float(WorldGrid.TILE))
		if not r.has_point(world_pos):
			continue
		if not foyer.can_pay(Foyer.ROOM_COSTS[placing]):
			hud.flash("Pas assez en stock pour : %s" % Foyer.ROOM_NAMES[placing])
			return
		foyer.place(mp, placing)
		hud.flash("%s : construit ! (%s)" % [Foyer.ROOM_NAMES[placing], Foyer.ROOM_NOTES[placing]])
		if not foyer.can_pay(Foyer.ROOM_COSTS[placing]):
			_stop_placement()   # plus les moyens d'enchaîner
		else:
			_refresh_slots()    # on reste en mode placement pour enchaîner
		return

# Passerelle [G] : un plancher de bois devant soi, au niveau du sol (1 bois = 1 bloc).
func _place_walkway() -> void:
	var ts := float(WorldGrid.TILE)
	var dir := 1 if hero.aim.x >= 0.0 else -1
	var tx := int(floor(hero.pos.x / ts)) + dir
	var ty := int(floor((hero.pos.y + hero.half.y + 1.0) / ts))   # rangée d'appui des pieds
	if world.tile(tx, ty) != WorldGrid.EMPTY:
		hud.flash("Passerelle : vise un vide devant toi (regarde vers le trou)")
		return
	if bag.count(WorldGrid.WOOD) <= 0:
		hud.flash("Passerelle : il faut du bois (1 par bloc)")
		return
	bag.remove(WorldGrid.WOOD, 1)
	world.set_tile(tx, ty, WorldGrid.PASSERELLE)
	view.add_flash(Vector2i(tx, ty), 0.12)

# [E] contextuel : caravane > cache > pièce du Foyer (hall = dépôt rapide).
func _interact() -> void:
	if caravan.near(hero.pos):
		trade_ui.visible = true
		trade_ui.queue_redraw()
		return
	if cache_active and hero.pos.distance_to(cache_pos) <= CACHE_RANGE:
		_recover_cache()
		return
	var rk = foyer.room_key_at(hero.pos)
	if rk == null:
		return
	var room := int(foyer.rooms[rk]["type"])
	if room == Foyer.ROOM_PROD:
		room_ui.open_assign(Vector2i(rk))
	elif room == Foyer.ROOM_DORTOIR:
		hero.hp = Hero.MAX_HP
		hud.flash("Tu te reposes au dortoir : PV au maximum.")
	elif room == Foyer.ROOM_ATELIER:
		hud.flash("Atelier : [3] ameliorer l'outil   [4] cartouche anti-gaz (5 Li + 3 bois)")
	else:
		_deposit()   # hall et entrepôt : dépôt rapide du sac

func _deposit() -> void:
	var moved_total := 0
	var lost := 0
	for t in Inventory.STORE_TYPES:
		var have := bag.count(t)
		if have <= 0:
			continue
		var moved := foyer.add(t, have)
		bag.remove(t, moved)
		moved_total += moved
		lost += have - moved
	if lost > 0:
		hud.flash("Stock du Foyer plein ! %d objet(s) restent dans le sac (construis un entrepot)" % lost)
	elif moved_total > 0:
		hud.flash("Depose : %d ressource(s) au stock du Foyer" % moved_total)
	else:
		hud.flash("Sac vide : rien a deposer")

func _withdraw() -> void:
	# Stock → sac : raccourci pratique (priorité au carburant, puis bois/roche/terre),
	# dans la limite des slots libres. Le réglage fin se fait à l'inventaire (touche I).
	if not foyer.inside(hero.pos):
		return
	for t in [WorldGrid.LITHIUM, WorldGrid.WOOD, WorldGrid.ROCK, WorldGrid.DIRT]:
		var moved := bag.add(t, foyer.count(t))
		foyer.remove(t, moved)

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

# --- Atelier (pièce du Foyer requise, et il faut y être) -------------------------
func _at_workshop() -> bool:
	if foyer.room_type_at(hero.pos) == Foyer.ROOM_ATELIER:
		return true
	if foyer.has_room(Foyer.ROOM_ATELIER):
		hud.flash("Va dans l'ATELIER du Foyer pour ca")
	else:
		hud.flash("Il faut un ATELIER : construis-le (touche B au Foyer)")
	return false

func _upgrade_tool() -> void:
	if not _at_workshop():
		return
	if dig_level >= DIG_TIERS.size() - 1:
		hud.flash("Outil deja au maximum (Acier)")
		return
	var cost: Dictionary = UPGRADE_COST[dig_level + 1]
	if not foyer.can_pay(cost):
		hud.flash("Pas assez en stock : %d roche + %d lithium" % [int(cost.get(WorldGrid.ROCK, 0)), int(cost.get(WorldGrid.LITHIUM, 0))])
		return
	foyer.pay(cost)
	dig_level += 1
	hud.flash("Outil ameliore : %s (creusage plus rapide)" % TIER_NAMES[dig_level])

func _craft_antipol() -> void:
	if not _at_workshop():
		return
	if not foyer.can_pay(COST_ANTIPOL):
		hud.flash("Pas assez en stock : il faut 5 lithium + 3 bois")
		return
	foyer.pay(COST_ANTIPOL)
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
	if _ui_open() or placing >= 0 or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
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
	elif t == WorldGrid.WOOD or t == WorldGrid.PASSERELLE:
		item = WorldGrid.WOOD   # une passerelle cassée rend son bois
	elif t == WorldGrid.LITHIUM:
		item = WorldGrid.LITHIUM
	if bag.add(item, 1) == 0:
		hud.flash("Sac plein ! Objet perdu (vide-le au Foyer, ou touche I)")

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
	var obj := "Objectif: REMONTER a la surface (barriere de roche dense = outil Fer)"
	if won:
		obj = "*** SORTI ! Tu as rejoint la surface ***"
	elif hero.in_gas():
		obj += ("   [GAZ: protege]" if (hero.antipol_on and hero.antipol_fuel > 0.0) else "   !! GAZ TOXIQUE : -PV !!")
	var weap := "Arme: melee" if combat.weapon == 0 else "Arme: feu (%d mun.)" % combat.ammo
	var antigas := "Anti-gaz: %s (%d)" % ["ON" if hero.antipol_on else "off", hero.antipol_charges()]
	var car_status := "ICI ! (%d s)" % maxi(0, int(caravan.stay_t)) if caravan.present else "dans %d s" % maxi(0, int(caravan.timer))
	var foyer_line := "Foyer  - Dortoir:%d  Prod:%d  Atelier:%d  Entrepot:%d    PNJ: %d/%d    Caravane: %s" % [
		foyer.room_count(Foyer.ROOM_DORTOIR), foyer.room_count(Foyer.ROOM_PROD),
		foyer.room_count(Foyer.ROOM_ATELIER), foyer.room_count(Foyer.ROOM_ENTREPOT),
		pop.npcs.size(), foyer.dortoir_capacity(), car_status]
	var hint := "[ZQSD/Fleches] bouger  [Espace] saut  [Clic G] creuser  [Clic D] attaquer  [X] arme  [I] inventaire  [B] construire  [F] echelle  [G] passerelle  [R] lampe  [T] torche  [M] anti-gaz  [E] agir  [Q] retirer  [K] mort"
	if placing >= 0:
		hint = "PLACEMENT : %s >  clique un slot vert (colle a une piece, une echelle ou une passerelle)   [B]/[Echap]/clic droit : annuler" % Foyer.ROOM_NAMES[placing]
	elif foyer.inside(hero.pos):
		hint = "FOYER >  [B] construire une piece   [E] agir ici : prod=affecter PNJ · dortoir=repos · hall/entrepot=depot · caravane=troc   [Q] retirer du stock   [3]/[4] atelier"
	hud.set_stats("%s\nPV: %d/%d    %s\nSac    - Li:%d  Bois:%d  Terre:%d  Roche:%d\nStock  - Li:%d  Bois:%d  Terre:%d  Roche:%d  Rations:%d    (%d/%d)\n%s\nLampe: %d%%   Torches: %d   %s   |   %s   |   Outil: %s" % [
		obj, int(hero.hp), int(Hero.MAX_HP), bagline,
		bag.count(WorldGrid.LITHIUM), bag.count(WorldGrid.WOOD), bag.count(WorldGrid.DIRT), bag.count(WorldGrid.ROCK),
		foyer.count(WorldGrid.LITHIUM), foyer.count(WorldGrid.WOOD), foyer.count(WorldGrid.DIRT), foyer.count(WorldGrid.ROCK),
		foyer.count(Inventory.RATIONS), foyer.stored_total(), foyer.capacity(),
		foyer_line,
		int(hero.lamp_fuel / Hero.LAMP_AUTONOMY * 100.0), light.torches.size(), antigas, weap, TIER_NAMES[dig_level]])
	hud.set_hints(hint)
