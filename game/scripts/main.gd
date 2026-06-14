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
# Paliers d'outil (M3) : forgés à partir du Fer (récupéré au combat / fouille /
# Mine de fer). L'outil n'ouvre plus la barrière (M5) mais accélère le creusage.
const UPGRADE_COST := [{},
	{WorldGrid.IRON: 10, WorldGrid.WOOD: 4},
	{WorldGrid.IRON: 20, WorldGrid.LITHIUM: 8}]
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
var raids: Raids
var combat: Combat
var view: WorldView
var marker: MarkerView
var lights: LightRig
var camera: Camera2D
var hud: Hud
var inv_ui: InvUI
var room_ui: RoomUI
var trade_ui: TradeUI

var boss: BossFight               # le Roi des Galeries (M5)

var dig_level := 0                # palier d'outil : 0 Pierre, 1 Fer, 2 Acier
var dig_target := Vector2i(-1, -1)
var dig_progress := 0.0
var won := false
var pierced := false              # la charge de perçage a ouvert le puits de la barrière
var play_time := 0.0              # temps de survie (stats de l'écran de fin)
var inv_open := false             # l'écran d'inventaire est ouvert (fige le jeu)

# Mode placement (construction libre) : type de pièce en cours, -1 sinon.
var placing := -1
var slots_t := 0.0                # recalcul périodique des slots (connecteurs posés…)

# Cache de butin (à la mort, façon Souls) : une cache précédente est perdue.
var cache_active := false
var cache_pos := Vector2.ZERO
var cache := {}

# Lueurs des légendaires captifs (index aligné sur pop.captives, éteintes à la libération)
var captive_glows := []

func _ready() -> void:
	randomize()
	world = WorldGrid.new()
	world.generate()
	hero = Hero.new(world)
	hero.spawn()
	light = LightField.new(world, hero)
	bag = Inventory.new()
	foyer = Foyer.new(world)
	light.foyer = foyer   # éclairage de face : les pièces comptent comme source
	pop = Population.new(world, foyer)
	pop.spawn_captives()   # légendaires cachés dans le Transit
	caravan = Caravan.new(world, foyer)
	crew = EnemyCrew.new(world, light, hero)
	crew.spawn(foyer.pos)     # robots, au-dessus de la barrière
	crew.spawn_transit()      # pilleurs : gardiens des stations + patrouilles
	view = WorldView.new()
	view.world = world
	view.hero = hero
	view.light = light
	view.crew = crew
	view.pop = pop
	view.caravan = caravan
	add_child(view)
	# Le vrai éclairage : obscurité + soleil + lampe/halo (+ torches, pièces)
	lights = LightRig.new(hero)
	add_child(lights)
	lights.add_room_light(_room_center(Vector2i.ZERO))   # le hall est éclairé d'office
	for c in pop.captives:   # lueur des légendaires : repérables de loin
		captive_glows.append(lights.add_glow(c["pos"], Color(1.0, 0.85, 0.45), 0.5, 0.85))
	# Calque des marqueurs : coordonnées monde, mais AU-DESSUS de la lumière
	var marker_layer := CanvasLayer.new()
	marker_layer.follow_viewport_enabled = true
	add_child(marker_layer)
	marker = MarkerView.new()
	marker.world = world
	marker.hero = hero
	marker.light = light
	marker.foyer = foyer
	marker.pop = pop
	marker.caravan = caravan
	marker.crew = crew
	marker.cache_range = CACHE_RANGE
	marker_layer.add_child(marker)
	camera = Camera2D.new()
	camera.zoom = Vector2(2.5, 2.5)   # on grossit : ~30 tuiles de large à l'écran
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	add_child(camera)
	camera.make_current()
	camera.global_position = hero.pos   # cadrage immédiat (pas de panoramique au démarrage)
	camera.reset_smoothing()
	hud = Hud.new()
	hud.layer = 2   # au-dessus du calque des marqueurs
	add_child(hud)
	combat = Combat.new(hero, world, crew, bag, hud, marker)
	marker.combat = combat
	raids = Raids.new(world, foyer, pop, crew, hero, light, bag)
	combat.raids = raids
	marker.raids = raids
	boss = BossFight.new(world, hero, crew, raids)
	boss.mark_dirty = Callable(view, "mark_dirty")   # les portes sont des occulteurs
	marker.boss = boss
	# Braseros du terminal du Roi : son antre rougeoie, on la repère de loin
	var ba := world.boss_arena
	for gx in [4, 14, 24]:
		lights.add_glow(Vector2(float(ba.position.x + gx) * WorldGrid.TILE,
			float(ba.position.y + 2) * WorldGrid.TILE), Color(1.0, 0.45, 0.22), 0.7, 0.7)
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
	room_ui.bag = bag
	room_ui.on_choose = _start_placement
	room_ui.on_deposit = _deposit
	room_ui.on_withdraw = _withdraw_one
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

# Un écran est ouvert (inventaire, cellule, troc, fin) → fige héros/robots/armes/creusage.
func _ui_open() -> bool:
	return inv_open or room_ui.visible or trade_ui.visible or hud.end_visible()

# --- Boucle -------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	hero.move(delta, not _ui_open())
	if not _ui_open():
		crew.update(delta)   # un écran ouvert fige le jeu (héros ET robots)
		for m in boss.update(delta):
			hud.flash(m)
		# Compte à rebours de raid gelé pendant le combat de boss ET pendant le passage
		# de la caravane (M6 : plus de raid qui tombe en plein troc).
		raids.hold = boss.fighting() or caravan.present
		for m in raids.update(delta):
			hud.flash(m)
	if hero.hp <= 0.0:
		_die()
	camera.global_position = hero.pos

func _process(delta: float) -> void:
	play_time += delta
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
	lights.update()
	marker.cache_active = cache_active
	marker.cache_pos = cache_pos
	marker.loot_cell = _find_crate() if not _ui_open() else Vector2i(-1, -1)
	# Coffre vidé recyclable : seulement si aucun coffre plein n'est à portée (priorité fouille).
	marker.recycle_cell = _find_near_tile(WorldGrid.CRATE_OPEN) if (not _ui_open() and marker.loot_cell.x < 0) else Vector2i(-1, -1)
	marker.tick(delta)
	view.tick(delta)
	if inv_open:
		inv_ui.queue_redraw()   # la pile tenue suit le curseur
	if trade_ui.visible:
		trade_ui.queue_redraw() # le compte à rebours de départ vit

func _input(event: InputEvent) -> void:
	if hud.end_visible():   # écran de fin : une touche/un clic pour reprendre
		if (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
			hud.hide_end()
		return
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
	# Fin du MVP : le PREMIER PAS à l'air libre, après avoir percé la barrière
	# avec la charge du Roi (seul passage possible vers la surface).
	if won:
		return
	var tx := int(hero.pos.x / WorldGrid.TILE)
	var ty := int((hero.pos.y + hero.half.y) / WorldGrid.TILE)   # niveau des pieds
	if ty <= world.surface[clampi(tx, 0, WorldGrid.GRID_W - 1)]:
		won = true
		hud.show_end(_end_text())

func _end_text() -> String:
	var mins := int(play_time / 60.0)
	var secs := int(play_time) % 60
	return "***  FIN DU MVP — LES ENFOUIS  ***\n\n" \
		+ "Tu as vaincu le Roi des Galeries, perce la barriere\nde roche dense et rejoint la SURFACE a l'air libre.\n\n" \
		+ "Temps de survie     : %d min %02d s\n" % [mins, secs] \
		+ "PNJ au Foyer        : %d\n" % pop.npcs.size() \
		+ "Raids repousses     : %d\n" % raids.repelled \
		+ "Ressources en stock : %d\n\n" % foyer.stored_total() \
		+ "(une touche pour continuer a jouer librement)"

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
	boss.notify_hero_death()   # le Roi regagne son trône, l'arène se rescelle
	hud.flash("Tu es mort... reapparition au Foyer." + ("  >> CACHE laissee sur place <<" if cache_active else ""))

# --- Construction libre (mode placement) -----------------------------------------
func _start_placement(type: int) -> void:
	placing = type
	slots_t = 0.5
	_refresh_slots()
	hud.flash("Placement : %s — clique un slot vert ([B]/clic droit : annuler)" % Foyer.ROOM_NAMES[type])

func _stop_placement() -> void:
	placing = -1
	marker.build_room = -1
	marker.build_slots = []

func _refresh_slots() -> void:
	var ts := float(WorldGrid.TILE)
	var rects := []
	for mp in foyer.valid_slots():
		var fp := foyer.footprint(mp)
		rects.append(Rect2(Vector2(fp.position) * ts, Vector2(fp.size) * ts))
	marker.build_room = placing
	marker.build_slots = rects

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
		view.mark_dirty()
		lights.add_room_light(_room_center(mp))
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
	view.mark_dirty()
	marker.add_flash(Vector2i(tx, ty), 0.12)

func _room_center(mp: Vector2i) -> Vector2:
	var ir := foyer.interior(mp)
	return (Vector2(ir.position) + Vector2(ir.size) * 0.5) * float(WorldGrid.TILE)

# [E] contextuel : caravane > cache > légendaire > conteneur > pièce du Foyer.
func _interact() -> void:
	if caravan.near(hero.pos):
		trade_ui.visible = true
		trade_ui.queue_redraw()
		return
	if cache_active and hero.pos.distance_to(cache_pos) <= CACHE_RANGE:
		_recover_cache()
		return
	if boss.door_near(hero.pos):
		hud.flash(boss.try_open())
		return
	if boss.charge_taken and not pierced and _pierce_barrier():
		return
	var ci := _captive_near()
	if ci >= 0:
		hud.flash(pop.free_captive(ci))
		if ci < captive_glows.size():   # on éteint sa lueur
			(captive_glows[ci] as Node).queue_free()
			captive_glows.remove_at(ci)
		return
	var lc := _find_crate()
	if lc.x >= 0:
		_loot_crate(lc)
		return
	var rc := _find_near_tile(WorldGrid.CRATE_OPEN)
	if rc.x >= 0:
		_recycle_crate(rc)
		return
	var rk = foyer.room_key_at(hero.pos)
	if rk == null:
		return
	var room := int(foyer.rooms[rk]["type"])
	if room == Foyer.ROOM_FORAGE or room == Foyer.ROOM_MINE or room == Foyer.ROOM_DEFENSE:
		room_ui.open_assign(Vector2i(rk))
	elif room == Foyer.ROOM_INFIRMERIE:
		hud.flash("Infirmerie : %d blesse(s) au Foyer (%d lit(s) de soin par infirmerie)" % \
			[pop.down_count(), Foyer.INFIRM_BEDS])
	elif room == Foyer.ROOM_DORTOIR:
		hero.hp = Hero.MAX_HP
		hud.flash("Tu te reposes au dortoir : PV au maximum.")
	elif room == Foyer.ROOM_ATELIER:
		if dig_level < DIG_TIERS.size() - 1:
			hud.flash("Atelier : [3] forger l'outil %s (%s)   [4] cartouche anti-gaz (5 Li + 3 bois)" % \
				[TIER_NAMES[dig_level + 1], _cost_text(UPGRADE_COST[dig_level + 1])])
		else:
			hud.flash("Atelier : outil au maximum   [4] cartouche anti-gaz (5 Li + 3 bois)")
	else:
		room_ui.open_stock(Vector2i(rk))   # hall et entrepôt : panneau dépôt / retrait

# La charge de perçage du Roi (M5) : [E] juste SOUS la barrière → un puits
# d'échelles s'ouvre à travers la roche dense, la voie de la surface est libre.
func _pierce_barrier() -> bool:
	var ts := WorldGrid.TILE
	var cx := int(hero.pos.x / ts)
	var feet := int((hero.pos.y + hero.half.y - 1.0) / ts)
	var base := WorldGrid.BAND_TOP + WorldGrid.BAND_H
	if feet < base or feet > base + 2:
		hud.flash("La charge doit etre posee juste SOUS la barriere de roche dense.")
		return false
	for y in range(WorldGrid.BAND_TOP, feet):
		world.set_tile(cx, y, WorldGrid.LADDER)
	pierced = true
	view.mark_dirty()
	marker.add_flash(Vector2i(cx, WorldGrid.BAND_TOP + 2), 0.3)
	hud.flash("BOOM ! La charge perce la barriere — un puits d'echelles monte vers la SURFACE. REMONTE !")
	return true

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

func _withdraw_one(t: int) -> void:
	# Stock → sac : retire toute la ressource demandée, dans la limite des slots libres.
	# Appelé par le panneau Stock (room_ui) — plus de touche dédiée (conflit AZERTY [Q]).
	var have := foyer.count(t)
	if have <= 0:
		hud.flash("Aucune %s en stock" % Inventory.res_name(t))
		return
	var moved := bag.add(t, have)
	foyer.remove(t, moved)
	if moved <= 0:
		hud.flash("Sac plein : impossible de retirer")
	elif moved < have:
		hud.flash("Retire %d %s (sac plein : %d restent en stock)" % [moved, Inventory.res_name(t), have - moved])
	else:
		hud.flash("Retire %d %s du stock" % [moved, Inventory.res_name(t)])

func _recover_cache() -> void:
	for t in cache:
		bag.add(t, int(cache[t]))
	cache_active = false
	hud.flash("Butin de la cache recupere !")

# --- Fouille (M3) : conteneurs du Transit, [E], vidés une fois pour toutes ---------
func _captive_near() -> int:
	for i in pop.captives.size():
		if hero.pos.distance_to(pop.captives[i]["pos"]) <= 2.0 * WorldGrid.TILE:
			return i
	return -1

func _find_crate() -> Vector2i:
	return _find_near_tile(WorldGrid.CRATE)

func _find_near_tile(t: int) -> Vector2i:
	var hx := int(hero.pos.x / WorldGrid.TILE)
	var hy := int(hero.pos.y / WorldGrid.TILE)
	for dy in range(-1, 3):
		for dx in range(-2, 3):
			if world.tile(hx + dx, hy + dy) == t:
				return Vector2i(hx + dx, hy + dy)
	return Vector2i(-1, -1)

func _loot_crate(cell: Vector2i) -> void:
	world.set_tile(cell.x, cell.y, WorldGrid.CRATE_OPEN)
	view.mark_dirty()
	marker.add_flash(cell, 0.2)
	var roll := randf()
	var msg: String
	if roll < 0.35:
		msg = _loot_to_bag(WorldGrid.WOOD, randi_range(2, 4))
	elif roll < 0.65:
		msg = _loot_to_bag(WorldGrid.IRON, randi_range(2, 4))
	elif roll < 0.85:
		var n := randi_range(4, 8)
		combat.ammo += n
		msg = "+%d munitions" % n
	else:
		msg = _loot_to_bag(WorldGrid.LITHIUM, randi_range(2, 3))
	# Bonus bois : une planche ou deux de récup en plus du loot principal — le bois
	# est le goulot de la construction (M6), on le rend un peu plus présent.
	if randf() < 0.35:
		var w := randi_range(1, 2)
		bag.add(WorldGrid.WOOD, w)
		msg += "  (+%d bois)" % w
	hud.flash("Fouille : %s" % msg)

# Recyclage d'un conteneur déjà fouillé (M6) : [E] le démantèle pour son bois,
# une seule fois (la caisse disparaît du décor).
func _recycle_crate(cell: Vector2i) -> void:
	world.set_tile(cell.x, cell.y, WorldGrid.EMPTY)
	view.mark_dirty()
	marker.add_flash(cell, 0.2)
	var w := randi_range(1, 2)
	var got := bag.add(WorldGrid.WOOD, w)
	if got > 0:
		hud.flash("Caisse demantelee : +%d bois" % got)
	else:
		hud.flash("Caisse demantelee, mais ton sac est plein !")

func _loot_to_bag(t: int, n: int) -> String:
	var got := bag.add(t, n)
	var msg := "+%d %s" % [got, Inventory.res_name(t)]
	if got < n:
		msg += "  (sac plein : %d perdu(s) !)" % (n - got)
	return msg

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
		lights.add_torch(cell)

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
		view.mark_dirty()
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
		hud.flash("Outil %s : il faut %s (en stock au Foyer)" % [TIER_NAMES[dig_level + 1], _cost_text(cost)])
		return
	foyer.pay(cost)
	dig_level += 1
	hud.flash("Outil ameliore : %s (creusage plus rapide)" % TIER_NAMES[dig_level])

static func _cost_text(cost: Dictionary) -> String:
	var parts := []
	for t in cost:
		parts.append("%d %s" % [int(cost[t]), Inventory.res_name(int(t))])
	return " + ".join(parts)

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
	if world.tile(tx, ty) == WorldGrid.HARDROCK and _in_reach(tx, ty):
		_reset_dig()   # indestructible : seul l'indice s'affiche (charge du Roi, M5)
		hud.flash("Roche dense : rien ne l'entame. Le ROI DES GALERIES detiendrait de quoi la percer...")
		return
	if not world.is_diggable(tx, ty) or not _in_reach(tx, ty):
		_reset_dig()
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
	marker.dig_target = dig_target
	marker.dig_frac = dig_progress / need

func _reset_dig() -> void:
	dig_target = Vector2i(-1, -1)
	dig_progress = 0.0
	marker.dig_target = dig_target
	marker.dig_frac = 0.0

func _dig_need(tx: int, ty: int) -> float:
	return DIG_TIME * DIG_TIERS[dig_level] * world.dig_mult(world.tile(tx, ty))

func _break_tile(tx: int, ty: int) -> void:
	var t := world.tile(tx, ty)
	world.set_tile(tx, ty, WorldGrid.EMPTY)
	view.mark_dirty()
	marker.add_flash(Vector2i(tx, ty), 0.18)
	if t == WorldGrid.WALL:
		return   # béton : gravats, rien à ramasser
	var item := WorldGrid.DIRT
	if t == WorldGrid.ROCK or t == WorldGrid.HARDROCK:
		item = WorldGrid.ROCK
	elif t == WorldGrid.WOOD or t == WorldGrid.PASSERELLE:
		item = WorldGrid.WOOD   # une passerelle cassée rend son bois
	elif t == WorldGrid.LITHIUM:
		item = WorldGrid.LITHIUM
	elif t == WorldGrid.IRON:
		item = WorldGrid.IRON
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
	var obj := "Objectif: vaincre le ROI DES GALERIES (terminal scelle au bout du tunnel inferieur)"
	if won:
		obj = "*** FIN DU MVP : tu as rejoint la surface ! ***"
	elif pierced:
		obj = "Objectif: REMONTE par le puits perce dans la barriere, jusqu'a la SURFACE !"
	elif boss.charge_taken:
		obj = "Objectif: pose la CHARGE DE PERCAGE juste sous la barriere ([E]) puis remonte"
	elif boss.state == BossFight.ST_DEAD:
		obj = "Objectif: ramasse la CHARGE DE PERCAGE dans le terminal du Roi"
	if not won and hero.in_gas():
		obj += ("   [GAZ: protege]" if (hero.antipol_on and hero.antipol_fuel > 0.0) else "   !! GAZ TOXIQUE : -PV !!")
	var weap := "Arme: melee" if combat.weapon == 0 else "Arme: feu (%d mun.)" % combat.ammo
	var antigas := "Anti-gaz: %s (%d)" % ["ON" if hero.antipol_on else "off", hero.antipol_charges()]
	var car_status := "ICI ! (%d s)" % maxi(0, int(caravan.stay_t)) if caravan.present else "dans %d s" % maxi(0, int(caravan.timer))
	var npc_status := "%d/%d" % [pop.npcs.size(), foyer.dortoir_capacity()]
	if pop.down_count() > 0:
		npc_status += " (%d blesse(s))" % pop.down_count()
	var foyer_line := "Foyer  - Dortoir:%d  Forage:%d  Mine:%d  Atelier:%d  Entrepot:%d    PNJ: %s    Caravane: %s    |    %s" % [
		foyer.room_count(Foyer.ROOM_DORTOIR), foyer.room_count(Foyer.ROOM_FORAGE),
		foyer.room_count(Foyer.ROOM_MINE),
		foyer.room_count(Foyer.ROOM_ATELIER), foyer.room_count(Foyer.ROOM_ENTREPOT),
		npc_status, car_status, raids.status_text()]
	var hint := "[ZQSD/Fleches] bouger  [Espace] saut  [Clic G] creuser  [Clic D] attaquer  [X] arme  [I] inventaire  [B] construire  [F] echelle  [G] passerelle  [R] lampe  [T] torche  [M] anti-gaz  [E] agir  [K] mort"
	if placing >= 0:
		hint = "PLACEMENT : %s >  clique un slot vert (colle a une piece, une echelle ou une passerelle)   [B]/[Echap]/clic droit : annuler" % Foyer.ROOM_NAMES[placing]
	elif foyer.inside(hero.pos):
		hint = "FOYER >  [B] construire   [E] agir ici : forage/mine=affecter PNJ · dortoir=repos · hall/entrepot=STOCK (deposer/retirer) · caravane=troc   [3]/[4] atelier"
	hud.set_stats("%s\nPV: %d/%d    %s\nSac    - Li:%d  Bois:%d  Terre:%d  Roche:%d  Fer:%d\nStock  - Li:%d  Bois:%d  Terre:%d  Roche:%d  Fer:%d    (%d/%d)\n%s\nLampe: %d%%   Torches: %d   %s   |   %s   |   Outil: %s" % [
		obj, int(hero.hp), int(Hero.MAX_HP), bagline,
		bag.count(WorldGrid.LITHIUM), bag.count(WorldGrid.WOOD), bag.count(WorldGrid.DIRT), bag.count(WorldGrid.ROCK),
		bag.count(WorldGrid.IRON),
		foyer.count(WorldGrid.LITHIUM), foyer.count(WorldGrid.WOOD), foyer.count(WorldGrid.DIRT), foyer.count(WorldGrid.ROCK),
		foyer.count(WorldGrid.IRON), foyer.stored_total(), foyer.capacity(),
		foyer_line,
		int(hero.lamp_fuel / Hero.LAMP_AUTONOMY * 100.0), light.torches.size(), antigas, weap, TIER_NAMES[dig_level]])
	hud.set_hints(hint)
