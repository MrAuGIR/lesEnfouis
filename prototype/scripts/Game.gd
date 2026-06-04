extends Node2D
## Les Enfouis — Prototype, Jalon 0 : mouvement & creusage.
## Tout est en grey-box (rectangles colorés) : on teste UNIQUEMENT le fun du
## creuser → récolter. Aucun art final (cf. docs/PROTOTYPE.md).

# --- Paramètres réglables (valeurs de départ — cf. PROTOTYPE.md) -------------
const TILE := 16            # taille de tuile (figée dans la DA)
const GRID_W := 240
const GRID_H := 240
const AIR_ROWS := 8         # rangées de ciel/vide en haut

# Bunkers abandonnés (seule source de bois : structures humaines, pas le sol)
const STRUCT_COUNT := 60
const STRUCT_MIN_W := 6
const STRUCT_MAX_W := 10
const STRUCT_MIN_H := 4
const STRUCT_MAX_H := 6

const MOVE_SPEED := 98.0    # px/s
const GRAVITY := 900.0
const JUMP_SPEED := 300.0
const CLIMB_SPEED := 85.0        # vitesse de montée/descente sur une échelle
const LADDER_MAX := 10           # longueur max d'une pose d'échelle (tuiles, 1 bois/tuile)

const DIG_TIME := 0.28      # s pour creuser 1 bloc de terre (le nerf du game feel)
const ROCK_MULT := 2.5      # la roche est plus lente
const REACH := 3.5 * TILE   # portée de creusage autour du héros

# --- Lumière (Jalon 1) ------------------------------------------------------
# Lampe frontale (casque) : un faisceau dirigé vers la souris + un halo doux
# autour du corps (on n'est jamais aveugle à ses pieds).
const LAMP_AMBIENT_CORE := 1.2   # tuiles : plein autour du corps
const LAMP_AMBIENT_RADIUS := 3.2 # tuiles : portée du halo de corps
const LAMP_AMBIENT_MAX := 0.75   # le halo de corps est un peu moins fort que le faisceau
const LAMP_BEAM_CORE := 2.5      # tuiles : plein au départ du faisceau
const LAMP_BEAM_RANGE := 9.5     # tuiles : portée du faisceau
const LAMP_COS_INNER := 0.94     # cos(~20°) : cœur du faisceau
const LAMP_COS_OUTER := 0.55     # cos(~57°) : bord du faisceau
const SKY_FADE := 14.0      # profondeur sur laquelle la lumière du jour décline
const SKY_STRENGTH := 1.0   # intensité de la lumière du jour en surface
const AMBIENT_MIN := 0.05   # luminosité minimale (le noir n'est jamais total)

# --- Carburant & torches ----------------------------------------------------
const LAMP_AUTONOMY := 240.0     # secondes d'autonomie pleine de la lampe
const LAMP_LOW := 20.0           # sous ce reste (s), la lampe faiblit
const LAMP_REFILL := 90.0        # secondes rendues par unité de lithium (touche R)
const TORCH_RADIUS := 5.5        # tuiles : portée d'une torche posée
const TORCH_CORE := 1.5          # tuiles : pleine lumière au pied de la torche

# --- Sac, base, mort (Jalon 2) ----------------------------------------------
# Inventaire façon Minecraft : grille de slots, objets en piles (stacks).
const BAG_SLOTS := 8             # nombre de cases du sac (la "capacité" = nb de slots)
const STACK_MAX := 64            # taille d'une pile (objets identiques empilés)
# UI de l'inventaire (calque écran)
const SLOT := 28                 # px : taille d'une case
const SLOT_PAD := 5              # px : espace entre cases
const INV_COLS := 4              # colonnes de la grille du sac
const MAX_HP := 100.0
const FALL_SAFE := 380.0         # vitesse de chute sans dégât (px/s)
const FALL_DMG := 0.25           # dégâts par unité de vitesse au-delà du seuil
const BASE_RANGE := 2.6 * TILE   # portée de dépôt à la base
const CACHE_RANGE := 2.0 * TILE  # portée de récupération d'une cache

# --- Base : pièces, PNJ, craft (Jalon 3) ------------------------------------
const COST_PROD := {"rock": 12, "wood": 8}        # coût de la salle de production
const COST_WORKSHOP := {"rock": 15, "wood": 6}    # coût de l'atelier
const PROD_INTERVAL := 12.0      # s entre deux unités produites par le PNJ
const DIG_TIERS := [1.0, 0.65, 0.45]              # mult. de temps (Pierre→Fer→Acier)
const TIER_NAMES := ["Pierre", "Fer", "Acier"]
const UPGRADE_COST := [{}, {"rock": 15, "lithium": 8}, {"rock": 25, "lithium": 16}]

# --- Combat (Jalon 5a : mêlée) ----------------------------------------------
const ENEMY_COUNT := 8           # robots dispersés dans le sous-sol
const ENEMY_HP := 60.0
const ENEMY_SPEED := 42.0        # px/s en patrouille
const ENEMY_CHASE_MULT := 1.5    # vitesse en poursuite
const ENEMY_DMG := 12.0          # dégâts de contact au héros
const ENEMY_HIT_CD := 0.8        # s entre deux coups d'un même robot
const ENEMY_LOOT := 3            # lithium (batteries) lâché à la mort
const DETECT_RANGE := 9.0        # tuiles : portée de détection du héros (avec ligne de vue)
const ENEMY_HALF := Vector2(6, 7)
const MELEE_RANGE := 1.7 * TILE  # portée du coup
const MELEE_ARC := 0.2           # produit scalaire mini (cône d'attaque vers la souris)
const MELEE_DMG := 34.0          # ~2 coups pour tuer un robot
const MELEE_CD := 0.42           # s entre deux coups du héros
const MELEE_VIS := 0.16          # s d'affichage de l'arc de coup
const MELEE_KNOCK := 120.0       # recul infligé au robot touché
# Arme à feu (J5b) : tir hitscan, munitions rares
const GUN_DMG := 40.0            # ~2 balles pour détruire un robot
const GUN_RANGE := 14.0 * TILE   # portée du tir
const GUN_CD := 0.5              # s entre deux tirs
const GUN_TRACER_T := 0.08       # s d'affichage du traceur
const START_AMMO := 24           # munitions de départ — CONFORT DE TEST (à remettre à 0/qqs)
const ENEMY_AMMO_DROP := 2       # munitions lâchées par un robot (avec une probabilité)
const ENEMY_AMMO_CHANCE := 0.6   # probabilité qu'un robot lâche des munitions

# --- Objectif (Jalon 4) -----------------------------------------------------
const HARD_MULT := 4.5            # creusage de la roche dense (très lent)
const BAND_TOP := AIR_ROWS + 50   # profondeur de la barrière de roche dense
const BAND_H := 4                 # épaisseur de la barrière (tuiles)
const ARTEFACT_Y := AIR_ROWS + 60 # profondeur de l'artefact (sous la barrière)

# Types de tuile
const EMPTY := 0
const DIRT := 1
const ROCK := 2
const WOOD := 3    # étais de bois (dans la terre) → torches + construction/craft
const LITHIUM := 4 # minerai de lithium (dans la roche) → recharge la lampe frontale
const WALL := 5    # béton d'un bunker abandonné (creusable, sans ressource : gravats)
const HARDROCK := 6 # roche dense (barrière) : nécessite l'outil Fer (niveau >= 1)
const ARTEFACT := 7 # objectif à rapporter à la base
const LADDER := 8   # échelle (construite en bois) : on grimpe dessus

# Ressources transportables (ordre d'affichage dans l'inventaire / le stockage)
const RES_TYPES := [DIRT, ROCK, WOOD, LITHIUM]

# --- État -------------------------------------------------------------------
var grid := PackedByteArray()
var surface := PackedInt32Array() # hauteur du terrain par colonne (lumière du ciel)
var pos := Vector2.ZERO           # centre du héros (monde)
var vel := Vector2.ZERO
var half := Vector2(6, 14)        # demi-taille du héros (~12x28 px ≈ 1,75 tuile)
var on_floor := false
var aim := Vector2.RIGHT          # direction du faisceau de lampe (vers la souris)

var dig_target := Vector2i(-1, -1)
var dig_progress := 0.0

# Sac = grille de slots ; chaque slot est {} (vide) ou {"type":int,"count":int}.
var bag := []
var held := {}            # pile "tenue" au curseur dans l'inventaire (clic prendre/poser)
var inv_open := false     # l'écran d'inventaire est-il ouvert ?

var lamp_fuel := LAMP_AUTONOMY    # carburant restant (secondes)
var lamp_factor := 1.0            # 0..1 : intensité de la lampe selon le carburant
var torches: Array[Vector2i] = [] # torches posées (sécurisent un chemin)

var hp := MAX_HP
# Stock de départ — CONFORT DE TEST (prototype) : permet de construire/améliorer
# tout de suite sans grinder. À remettre à 0 avant tout équilibrage sérieux.
var store_dirt := 40              # stockage de la base (butin déposé)
var store_rock := 80
var store_wood := 40
var store_lithium := 40
var base_pos := Vector2.ZERO      # point de dépôt (surface, départ)
var cache_active := false         # une cache de butin attend d'être récupérée
var cache_pos := Vector2.ZERO
var cache := {"dirt": 0, "rock": 0, "wood": 0, "lithium": 0}

var has_prod := false             # salle de production construite (+1 PNJ)
var has_workshop := false         # atelier construit (débloque l'amélioration d'outil)
var prod_timer := 0.0
var dig_level := 0                # palier d'outil : 0 Pierre, 1 Fer, 2 Acier
var dig_time := DIG_TIME          # temps de creusage courant (selon le palier)

var has_artefact := false         # objectif transporté
var cache_artefact := false       # l'artefact est tombé dans la cache (mort)
var won := false                  # objectif accompli

# Combat (J5a) : chaque robot = {pos,vel:Vector2, hp:float, dir:float,
# on_floor:bool, blocked:bool, hit_cd:float, flash:float}
var enemies := []
var atk_cd := 0.0                 # cooldown du coup du héros
var atk_t := 0.0                  # reste d'affichage de l'arc de coup
var weapon := 0                   # arme courante : 0 = mêlée, 1 = arme à feu
var ammo := START_AMMO            # munitions (réserve dédiée, pas dans le sac)
var gun_cd := 0.0                 # cooldown de tir
var tracer_t := 0.0               # reste d'affichage du traceur de tir
var tracer_a := Vector2.ZERO      # extrémités du traceur (départ → impact)
var tracer_b := Vector2.ZERO

var flashes := []   # éclats de creusage : {cell:Vector2i, t:float}

var camera: Camera2D
var hud: Label
var msg_label: Label
var msg_t := 0.0
var inv_ui: Control

# --- Init -------------------------------------------------------------------
func _ready() -> void:
	randomize()
	_init_bag()
	_generate_world()
	_spawn_player()
	base_pos = pos
	_spawn_enemies()
	_make_camera()
	_make_hud()

func _generate_world() -> void:
	grid.resize(GRID_W * GRID_H)
	surface.resize(GRID_W)

	var h_noise := FastNoiseLite.new()      # relief de la surface
	h_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	h_noise.frequency = 0.03
	h_noise.seed = randi()

	var cave_noise := FastNoiseLite.new()   # cavités
	cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	cave_noise.frequency = 0.08
	cave_noise.seed = randi()

	var rock_noise := FastNoiseLite.new()   # filons de roche
	rock_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	rock_noise.frequency = 0.11
	rock_noise.seed = randi()

	for x in GRID_W:
		var top := AIR_ROWS + int((h_noise.get_noise_1d(float(x)) * 0.5 + 0.5) * 10.0)
		surface[x] = top
		for y in GRID_H:
			var t := EMPTY
			if y >= top:
				t = DIRT
				var depth := float(y - top)
				# Cavités (pas trop près de la surface) → donnent envie d'explorer
				if depth > 3.0 and cave_noise.get_noise_2d(float(x), float(y)) > 0.33:
					t = EMPTY
				else:
					# Roche : de plus en plus fréquente avec la profondeur
					var thresh := 0.5 - clampf(depth / 120.0, 0.0, 0.3)
					if rock_noise.get_noise_2d(float(x), float(y)) > thresh:
						t = ROCK
					# Lithium : petits dépôts, plus fréquents dans la roche
					var lith_chance := 0.10 if t == ROCK else 0.02
					if randf() < lith_chance:
						t = LITHIUM
			grid[y * GRID_W + x] = t
	_place_structures()
	_place_objective()

func _place_objective() -> void:
	# Barrière de roche dense (gate : outil Fer requis) + artefact dessous.
	for x in GRID_W:
		for y in range(BAND_TOP, BAND_TOP + BAND_H):
			grid[y * GRID_W + x] = HARDROCK
	var cx := int(GRID_W * 0.5)
	for yy in range(ARTEFACT_Y - 1, ARTEFACT_Y + 2):
		for xx in range(cx - 2, cx + 3):
			grid[yy * GRID_W + xx] = EMPTY
	grid[ARTEFACT_Y * GRID_W + cx] = ARTEFACT

func _place_structures() -> void:
	# Bunkers abandonnés : petites salles en béton contenant du bois (seule source).
	for n in STRUCT_COUNT:
		var w := randi_range(STRUCT_MIN_W, STRUCT_MAX_W)
		var h := randi_range(STRUCT_MIN_H, STRUCT_MAX_H)
		var x0 := randi_range(2, GRID_W - w - 2)
		var y0 := randi_range(AIR_ROWS + 14, GRID_H - h - 2)
		_carve_structure(x0, y0, w, h)
	# Un bunker garanti juste sous le point de départ (pour amorcer la partie)
	var cx := int(GRID_W * 0.5)
	_carve_structure(cx - 4, surface[cx] + 8, 9, 5)

func _carve_structure(x0: int, y0: int, w: int, h: int) -> void:
	for y in range(y0, y0 + h):
		for x in range(x0, x0 + w):
			var border := x == x0 or x == x0 + w - 1 or y == y0 or y == y0 + h - 1
			grid[y * GRID_W + x] = WALL if border else EMPTY
	# Rangée de caisses/poutres de bois sur le sol intérieur (bois garanti)
	var floor_y := y0 + h - 2
	for x in range(x0 + 1, x0 + w - 1):
		grid[floor_y * GRID_W + x] = WOOD

func _spawn_player() -> void:
	var cx := int(GRID_W * 0.5)
	pos = Vector2(cx * TILE + TILE * 0.5, (surface[cx] - 1) * TILE)

func _make_camera() -> void:
	camera = Camera2D.new()
	camera.zoom = Vector2(2.5, 2.5)   # on grossit : ~30 tuiles de large à l'écran
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	add_child(camera)
	camera.make_current()

func _make_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(12, 8)
	hud.add_theme_color_override("font_color", Color(0.85, 0.9, 0.8))
	layer.add_child(hud)
	msg_label = Label.new()
	msg_label.position = Vector2(12, 142)
	msg_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.45))
	layer.add_child(msg_label)
	# Calque d'inventaire (plein écran, masqué par défaut)
	inv_ui = preload("res://scripts/InvUI.gd").new()
	inv_ui.game = self
	inv_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	inv_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	inv_ui.visible = false
	layer.add_child(inv_ui)
	_update_hud()

func _flash_msg(text: String) -> void:
	msg_t = 2.5
	if msg_label:
		msg_label.text = text

func _update_hud() -> void:
	var bagline := "Sac: %d/%d slots" % [_bag_slots_used(), BAG_SLOTS]
	if _bag_slots_used() >= BAG_SLOTS:
		bagline += "  (PLEIN)"
	if cache_active:
		bagline += "     >> CACHE a recuperer <<"
	var base_line := "Base: Production[%s]  Atelier[%s]  Outil: %s" % ["ON" if has_prod else "-", "ON" if has_workshop else "-", TIER_NAMES[dig_level]]
	var obj := "Objectif: descendre chercher l'Artefact (roche dense profonde = outil Fer)"
	if won:
		obj = "*** GAGNE ! Artefact rapporte a la base ***"
	elif has_artefact:
		obj = ">> Artefact EN MAIN -- rentre le deposer a la base ! <<"
	var weap := "Arme: melee" if weapon == 0 else "Arme: feu (%d mun.)" % ammo
	var hint := "[ZQSD/Fleches] bouger/grimper  [Espace] saut  [Clic G] creuser  [Clic D] attaquer  [Molette/X] arme  [I] inventaire  [F] echelle  [R] lampe  [T] torche  [E] deposer  [Q] retirer  [K] mort"
	if _near_base():
		hint = "BASE >  [1] Production (12 roche/8 bois)   [2] Atelier (15 roche/6 bois)   [3] Ameliorer outil   [I] inventaire  [E] deposer  [Q] retirer"
	hud.text = "%s\nPV: %d/%d    %s\nSac    - Li:%d  Bois:%d  Terre:%d  Roche:%d\nBase   - Li:%d  Bois:%d  Terre:%d  Roche:%d\nLampe: %d%%   Torches: %d   %s   |   %s\n%s" % [obj, int(hp), int(MAX_HP), bagline, _bag_count(LITHIUM), _bag_count(WOOD), _bag_count(DIRT), _bag_count(ROCK), store_lithium, store_wood, store_dirt, store_rock, int(lamp_fuel / LAMP_AUTONOMY * 100.0), torches.size(), weap, base_line, hint]

# --- Boucle -----------------------------------------------------------------
func _physics_process(delta: float) -> void:
	_move(delta)
	_update_enemies(delta)
	if camera:
		camera.global_position = pos

func _process(delta: float) -> void:
	_update_aim()
	_deplete_lamp(delta)
	_produce(delta)
	_check_artefact()
	_update_combat(delta)
	_handle_dig(delta)
	_update_flashes(delta)
	_update_hud()
	if inv_open and inv_ui:
		inv_ui.queue_redraw()   # la pile tenue suit le curseur
	if msg_t > 0.0:
		msg_t -= delta
		if msg_t <= 0.0 and msg_label:
			msg_label.text = ""
	queue_redraw()

func _produce(delta: float) -> void:
	# Le PNJ de la salle de production génère du lithium en passif (même absent).
	if not has_prod:
		return
	prod_timer += delta
	if prod_timer >= PROD_INTERVAL:
		prod_timer -= PROD_INTERVAL
		store_lithium += 1

func _update_aim() -> void:
	var v := get_global_mouse_position() - pos
	if v.length() > 1.0:
		aim = v.normalized()

func _deplete_lamp(delta: float) -> void:
	lamp_fuel = maxf(0.0, lamp_fuel - delta)
	lamp_factor = clampf(lamp_fuel / LAMP_LOW, 0.0, 1.0)

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
		elif event.keycode == KEY_I or event.physical_keycode == KEY_I:
			_toggle_inventory()
		elif event.keycode == KEY_X or event.physical_keycode == KEY_X:
			_swap_weapon()
		elif event.keycode == KEY_K:
			_damage(MAX_HP)   # mort de test
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_swap_weapon()

func _refuel() -> void:
	if _bag_count(LITHIUM) > 0 and lamp_fuel < LAMP_AUTONOMY:
		_bag_remove(LITHIUM, 1)
		lamp_fuel = minf(LAMP_AUTONOMY, lamp_fuel + LAMP_REFILL)

func _place_torch() -> void:
	var cell := Vector2i(int(floor(pos.x / TILE)), int(floor(pos.y / TILE)))
	if _bag_count(WOOD) > 0 and not _is_solid(cell.x, cell.y) and not torches.has(cell):
		_bag_remove(WOOD, 1)
		torches.append(cell)

# --- Sac (slots + piles) ----------------------------------------------------
func _init_bag() -> void:
	bag = []
	for i in BAG_SLOTS:
		bag.append({})

func _bag_count(t: int) -> int:
	var n := 0
	for s in bag:
		if s.has("type") and s["type"] == t:
			n += int(s["count"])
	return n

func _bag_total() -> int:
	var n := 0
	for s in bag:
		if s.has("count"):
			n += int(s["count"])
	return n

func _bag_slots_used() -> int:
	var n := 0
	for s in bag:
		if s.has("type"):
			n += 1
	return n

# Ajoute jusqu'à n objets de type t (piles existantes d'abord, puis slots vides).
# Renvoie la quantité réellement ajoutée (le reste est perdu si le sac est plein).
func _bag_add(t: int, n: int) -> int:
	var added := 0
	for s in bag:
		if added >= n:
			break
		if s.has("type") and s["type"] == t and int(s["count"]) < STACK_MAX:
			var mv: int = mini(STACK_MAX - int(s["count"]), n - added)
			s["count"] = int(s["count"]) + mv
			added += mv
	for i in bag.size():
		if added >= n:
			break
		if bag[i].is_empty():
			var mv2: int = mini(STACK_MAX, n - added)
			bag[i] = {"type": t, "count": mv2}
			added += mv2
	return added

# Retire jusqu'à n objets de type t. Renvoie la quantité réellement retirée.
func _bag_remove(t: int, n: int) -> int:
	var removed := 0
	for i in bag.size():
		if removed >= n:
			break
		if bag[i].has("type") and bag[i]["type"] == t:
			var mv: int = mini(int(bag[i]["count"]), n - removed)
			bag[i]["count"] = int(bag[i]["count"]) - mv
			removed += mv
			if int(bag[i]["count"]) <= 0:
				bag[i] = {}
	return removed

func _bag_clear() -> void:
	for i in bag.size():
		bag[i] = {}

func _on_ladder() -> bool:
	var x0 := int((pos.x - half.x + 2) / TILE)
	var x1 := int((pos.x + half.x - 2) / TILE)
	var y0 := int((pos.y - half.y) / TILE)
	var y1 := int((pos.y + half.y) / TILE)
	for cy in range(y0, y1 + 1):
		for cx in range(x0, x1 + 1):
			if _tile(cx, cy) == LADDER:
				return true
	return false

func _place_ladder() -> void:
	# Pose une échelle dans la colonne, des pieds vers le haut, en remplissant le
	# vide jusqu'au premier bloc plein (1 bois par tuile). Idéal pour remonter un puits.
	var cx := int(pos.x / TILE)
	var ty := int((pos.y + half.y - 1) / TILE)
	var placed := 0
	while placed < LADDER_MAX and ty >= 0:
		var t := _tile(cx, ty)
		if t == EMPTY:
			if _bag_count(WOOD) <= 0:
				break
			grid[ty * GRID_W + cx] = LADDER
			_bag_remove(WOOD, 1)
			placed += 1
		elif t == LADDER and placed == 0:
			pass   # on démarre sur/dans une échelle : on la traverse pour combler le vide au-dessus
		else:
			break  # bloc plein, OU échelle déjà posée au-dessus → stop (pas de dépassement)
		ty -= 1
	if placed > 0:
		_flash_msg("Echelle posee : %d tuiles (-%d bois)" % [placed, placed])
	else:
		_flash_msg("Echelle : rien a poser (pas de place ou pas de bois)")
	_update_hud()

func _check_artefact() -> void:
	if has_artefact:
		return
	var x0 := int((pos.x - half.x) / TILE)
	var x1 := int((pos.x + half.x) / TILE)
	var y0 := int((pos.y - half.y) / TILE)
	var y1 := int((pos.y + half.y) / TILE)
	for cy in range(y0, y1 + 1):
		for cx in range(x0, x1 + 1):
			if _tile(cx, cy) == ARTEFACT:
				grid[cy * GRID_W + cx] = EMPTY
				has_artefact = true
				_flash_msg("Artefact recupere ! Rentre le deposer a la base.")

func _damage(amount: float) -> void:
	hp = maxf(0.0, hp - amount)
	if hp <= 0.0:
		_die()
	_update_hud()

func _die() -> void:
	# Largue le butin transporté dans une cache (Souls). Une cache précédente est perdue.
	if _bag_total() > 0 or has_artefact:
		cache_active = true
		cache_pos = pos
		cache = {"dirt": _bag_count(DIRT), "rock": _bag_count(ROCK), "wood": _bag_count(WOOD), "lithium": _bag_count(LITHIUM)}
		cache_artefact = has_artefact
		_bag_clear()
		has_artefact = false
	# Réapparition à la base, PV pleins
	pos = base_pos
	vel = Vector2.ZERO
	hp = MAX_HP

func _interact() -> void:
	if pos.distance_to(base_pos) <= BASE_RANGE:
		_deposit()
	elif cache_active and pos.distance_to(cache_pos) <= CACHE_RANGE:
		_recover_cache()

func _deposit() -> void:
	for t in RES_TYPES:
		_store_add(t, _bag_count(t))
	_bag_clear()
	hp = MAX_HP   # on se soigne à la base
	if has_artefact:
		has_artefact = false
		won = true
		_flash_msg("*** OBJECTIF ATTEINT ! Artefact rapporte a la base. Bravo ! ***")
	_update_hud()

func _withdraw() -> void:
	# Base → sac : raccourci pratique (priorité au carburant, puis bois/roche/terre),
	# dans la limite des slots libres. Le réglage fin se fait à l'inventaire (touche I).
	if pos.distance_to(base_pos) > BASE_RANGE:
		return
	for t in [LITHIUM, WOOD, ROCK, DIRT]:
		var moved := _bag_add(t, _store_count(t))
		_store_remove(t, moved)
	_update_hud()

func _recover_cache() -> void:
	_bag_add(DIRT, int(cache["dirt"]))
	_bag_add(ROCK, int(cache["rock"]))
	_bag_add(WOOD, int(cache["wood"]))
	_bag_add(LITHIUM, int(cache["lithium"]))
	if cache_artefact:
		has_artefact = true
		cache_artefact = false
		_flash_msg("Artefact recupere dans la cache !")
	cache_active = false
	_update_hud()

func _store_count(t: int) -> int:
	match t:
		DIRT: return store_dirt
		ROCK: return store_rock
		WOOD: return store_wood
		LITHIUM: return store_lithium
	return 0

func _store_add(t: int, n: int) -> void:
	match t:
		DIRT: store_dirt += n
		ROCK: store_rock += n
		WOOD: store_wood += n
		LITHIUM: store_lithium += n

func _store_remove(t: int, n: int) -> void:
	_store_add(t, -n)

func _near_base() -> bool:
	return pos.distance_to(base_pos) <= BASE_RANGE

func _can_pay(cost: Dictionary) -> bool:
	return store_rock >= int(cost.get("rock", 0)) and store_wood >= int(cost.get("wood", 0)) \
		and store_lithium >= int(cost.get("lithium", 0)) and store_dirt >= int(cost.get("dirt", 0))

func _pay(cost: Dictionary) -> void:
	store_rock -= int(cost.get("rock", 0))
	store_wood -= int(cost.get("wood", 0))
	store_lithium -= int(cost.get("lithium", 0))
	store_dirt -= int(cost.get("dirt", 0))

func _build_production() -> void:
	if not _near_base():
		_flash_msg("Approche-toi de la base (zone verte)")
		return
	if has_prod:
		_flash_msg("Production deja construite")
		return
	if not _can_pay(COST_PROD):
		_flash_msg("Pas assez en base : il faut 12 roche + 8 bois")
		return
	_pay(COST_PROD)
	has_prod = true   # un PNJ y est affecté automatiquement (grey-box)
	_flash_msg("Production construite ! Un PNJ produit du lithium en passif.")
	_update_hud()

func _build_workshop() -> void:
	if not _near_base():
		_flash_msg("Approche-toi de la base (zone verte)")
		return
	if has_workshop:
		_flash_msg("Atelier deja construit")
		return
	if not _can_pay(COST_WORKSHOP):
		_flash_msg("Pas assez en base : il faut 15 roche + 6 bois")
		return
	_pay(COST_WORKSHOP)
	has_workshop = true
	_flash_msg("Atelier construit ! Tu peux ameliorer l'outil (touche 3).")
	_update_hud()

func _upgrade_tool() -> void:
	if not _near_base():
		_flash_msg("Approche-toi de la base (zone verte)")
		return
	if not has_workshop:
		_flash_msg("Atelier requis d'abord (touche 2)")
		return
	if dig_level >= DIG_TIERS.size() - 1:
		_flash_msg("Outil deja au maximum (Acier)")
		return
	var cost: Dictionary = UPGRADE_COST[dig_level + 1]
	if not _can_pay(cost):
		_flash_msg("Pas assez en base : %d roche + %d lithium" % [int(cost.get("rock", 0)), int(cost.get("lithium", 0))])
		return
	_pay(cost)
	dig_level += 1
	dig_time = DIG_TIME * DIG_TIERS[dig_level]
	_flash_msg("Outil ameliore : %s (creusage plus rapide)" % TIER_NAMES[dig_level])
	_update_hud()

# --- Combat (J5a : mêlée) ---------------------------------------------------
func _spawn_enemies() -> void:
	enemies = []
	# Rencontre garantie pour amorcer le combat : un robot dans le bunker de départ
	# (juste sous le spawn), facile à trouver dès la première descente.
	var cx := int(GRID_W * 0.5)
	_add_enemy(Vector2((cx + 2) * TILE + TILE * 0.5, (surface[cx] + 10) * TILE + TILE * 0.5))
	# Le reste dispersé dans les cavernes du sous-sol.
	var tries := 0
	while enemies.size() < ENEMY_COUNT and tries < 3000:
		tries += 1
		var tx := randi_range(4, GRID_W - 5)
		var ty := randi_range(AIR_ROWS + 16, GRID_H - 4)
		# une case vide avec du sol dessous et de la place au-dessus (tête)
		if _tile(tx, ty) != EMPTY or _tile(tx, ty - 1) != EMPTY or not _is_solid(tx, ty + 1):
			continue
		var p := Vector2(tx * TILE + TILE * 0.5, ty * TILE + TILE * 0.5)
		if p.distance_to(base_pos) < 10.0 * TILE:
			continue   # petite zone de répit autour de la base
		_add_enemy(p)

func _add_enemy(p: Vector2) -> void:
	enemies.append({"pos": p, "vel": Vector2.ZERO, "hp": ENEMY_HP, "dir": (1.0 if randf() < 0.5 else -1.0), "on_floor": false, "blocked": false, "hit_cd": 0.0, "flash": 0.0})

func _update_enemies(delta: float) -> void:
	if inv_open:
		return   # l'inventaire fige le jeu (héros ET robots)
	for e in enemies:
		e["hit_cd"] = maxf(0.0, float(e["hit_cd"]) - delta)
		e["flash"] = maxf(0.0, float(e["flash"]) - delta)
		var to_player: Vector2 = pos - e["pos"]
		var dist := to_player.length()
		var ec := Vector2(e["pos"].x / TILE, e["pos"].y / TILE)
		var chasing := dist < DETECT_RANGE * TILE and _los_clear_from(ec, int(pos.x / TILE), int(pos.y / TILE))
		if chasing:
			e["dir"] = signf(to_player.x) if absf(to_player.x) > 2.0 else e["dir"]
			if bool(e["blocked"]) and bool(e["on_floor"]):
				e["vel"].y = -JUMP_SPEED * 0.8   # saute l'obstacle pour poursuivre
		else:
			# patrouille : demi-tour au mur ou au bord du vide (ne pas tomber bêtement)
			if bool(e["on_floor"]):
				var ahead_x: float = e["pos"].x + e["dir"] * (ENEMY_HALF.x + 3.0)
				var foot_y: float = e["pos"].y + ENEMY_HALF.y + 4.0
				if bool(e["blocked"]) or not _is_solid(int(ahead_x / TILE), int(foot_y / TILE)):
					e["dir"] = -float(e["dir"])
		e["blocked"] = false
		var spd := ENEMY_SPEED * (ENEMY_CHASE_MULT if chasing else 1.0)
		e["vel"].x = float(e["dir"]) * spd
		_move_enemy(e, delta)
		# Contact → dégâts au héros (avec cooldown par robot) + petit recul
		if _aabb_overlap(pos, half, e["pos"], ENEMY_HALF) and float(e["hit_cd"]) <= 0.0:
			e["hit_cd"] = ENEMY_HIT_CD
			_damage(ENEMY_DMG)
			vel.x = signf(pos.x - e["pos"].x) * MOVE_SPEED

func _move_enemy(e: Dictionary, delta: float) -> void:
	e["pos"].x += e["vel"].x * delta
	var rx := _collide_axis(e["pos"], ENEMY_HALF, e["vel"], true)
	e["pos"] = rx["pos"]
	e["vel"] = rx["vel"]
	if bool(rx["blocked"]):
		e["blocked"] = true
	e["vel"].y += GRAVITY * delta
	e["vel"].y = clampf(e["vel"].y, -JUMP_SPEED, 600.0)
	e["pos"].y += e["vel"].y * delta
	var ry := _collide_axis(e["pos"], ENEMY_HALF, e["vel"], false)
	e["pos"] = ry["pos"]
	e["vel"] = ry["vel"]
	e["on_floor"] = bool(ry["landed"])

# Résolution AABB-vs-grille générique (pour les robots ; pure, sans état membre).
func _collide_axis(p: Vector2, hf: Vector2, v: Vector2, is_x: bool) -> Dictionary:
	var landed := false
	var blocked := false
	var min_tx := int(floor((p.x - hf.x) / TILE))
	var max_tx := int(floor((p.x + hf.x - 0.001) / TILE))
	var min_ty := int(floor((p.y - hf.y) / TILE))
	var max_ty := int(floor((p.y + hf.y - 0.001) / TILE))
	for ty in range(min_ty, max_ty + 1):
		for tx in range(min_tx, max_tx + 1):
			if not _is_solid(tx, ty):
				continue
			var l := p.x - hf.x
			var r := p.x + hf.x
			var t := p.y - hf.y
			var b := p.y + hf.y
			var tl := tx * TILE
			var tr := tl + TILE
			var tt := ty * TILE
			var tb := tt + TILE
			if l < tr and r > tl and t < tb and b > tt:
				if is_x:
					if v.x > 0.0:
						p.x = tl - hf.x
					elif v.x < 0.0:
						p.x = tr + hf.x
					v.x = 0.0
					blocked = true
				else:
					if v.y > 0.0:
						p.y = tt - hf.y
						landed = true
					elif v.y < 0.0:
						p.y = tb + hf.y
					v.y = 0.0
	return {"pos": p, "vel": v, "landed": landed, "blocked": blocked}

func _aabb_overlap(p1: Vector2, h1: Vector2, p2: Vector2, h2: Vector2) -> bool:
	return absf(p1.x - p2.x) < h1.x + h2.x and absf(p1.y - p2.y) < h1.y + h2.y

func _update_combat(delta: float) -> void:
	atk_cd = maxf(0.0, atk_cd - delta)
	atk_t = maxf(0.0, atk_t - delta)
	gun_cd = maxf(0.0, gun_cd - delta)
	tracer_t = maxf(0.0, tracer_t - delta)
	if inv_open:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if weapon == 0 and atk_cd <= 0.0:
			_melee_attack()
		elif weapon == 1 and gun_cd <= 0.0:
			_gun_fire()

func _swap_weapon() -> void:
	weapon = 1 - weapon
	if weapon == 1:
		_flash_msg("Arme : arme a feu (%d munitions)" % ammo)
	else:
		_flash_msg("Arme : melee")
	_update_hud()

func _melee_attack() -> void:
	atk_cd = MELEE_CD
	atk_t = MELEE_VIS
	for e in enemies:
		var v: Vector2 = e["pos"] - pos
		var d := v.length()
		if d <= MELEE_RANGE and (d < 0.001 or v.normalized().dot(aim) >= MELEE_ARC):
			e["hp"] = float(e["hp"]) - MELEE_DMG
			e["flash"] = MELEE_VIS
			e["vel"] += aim * MELEE_KNOCK
	_cull_enemies()

func _gun_fire() -> void:
	if ammo <= 0:
		gun_cd = 0.25
		_flash_msg("Plus de munitions ! (passe en melee : molette/X)")
		return
	ammo -= 1
	gun_cd = GUN_CD
	# Distance jusqu'au premier mur sur le rayon (occlusion).
	var wall_d := GUN_RANGE
	var steps := int(GUN_RANGE / (TILE * 0.5))
	for i in range(1, steps + 1):
		var d := float(i) * TILE * 0.5
		var p := pos + aim * d
		if _is_solid(int(p.x / TILE), int(p.y / TILE)):
			wall_d = d
			break
	# Robot le plus proche traversé par le rayon, avant le mur.
	var target = null
	var target_d := wall_d
	for e in enemies:
		var to_e: Vector2 = e["pos"] - pos
		var proj := to_e.dot(aim)
		if proj <= 0.0 or proj > target_d:
			continue
		var perp := (to_e - aim * proj).length()
		if perp <= ENEMY_HALF.y + 3.0:
			target = e
			target_d = proj
	tracer_a = pos
	tracer_b = pos + aim * target_d
	tracer_t = GUN_TRACER_T
	if target != null:
		target["hp"] = float(target["hp"]) - GUN_DMG
		target["flash"] = MELEE_VIS
		_cull_enemies()

func _cull_enemies() -> void:
	var alive := []
	for e in enemies:
		if float(e["hp"]) > 0.0:
			alive.append(e)
		else:
			_bag_add(LITHIUM, ENEMY_LOOT)
			flashes.append({"cell": Vector2i(int(e["pos"].x / TILE), int(e["pos"].y / TILE)), "t": 0.3})
			var got_ammo := 0
			if randf() < ENEMY_AMMO_CHANCE:
				got_ammo = ENEMY_AMMO_DROP
				ammo += got_ammo
			if got_ammo > 0:
				_flash_msg("Robot detruit (+%d lithium, +%d munitions)" % [ENEMY_LOOT, got_ammo])
			else:
				_flash_msg("Robot detruit (+%d lithium)" % ENEMY_LOOT)
	enemies = alive

# --- Déplacement + collision contre la grille -------------------------------
func _move(delta: float) -> void:
	var ctl := not inv_open   # commandes désactivées quand l'inventaire est ouvert
	var dir := 0.0
	# Touches physiques → marche en ZQSD (AZERTY) ou WASD (QWERTY), + flèches
	if ctl and (Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)):
		dir -= 1.0
	if ctl and (Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)):
		dir += 1.0
	vel.x = dir * MOVE_SPEED

	var on_ladder := _on_ladder()
	if on_ladder:
		var climb := 0.0
		if ctl and (Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)):
			climb -= 1.0
		if ctl and (Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)):
			climb += 1.0
		vel.y = climb * CLIMB_SPEED
		if ctl and Input.is_physical_key_pressed(KEY_SPACE):
			vel.y = -JUMP_SPEED   # sauter pour quitter l'échelle
	else:
		if ctl and on_floor and (Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP)):
			vel.y = -JUMP_SPEED
		vel.y += GRAVITY * delta
		vel.y = clampf(vel.y, -JUMP_SPEED, 600.0)

	# Axe X
	pos.x += vel.x * delta
	_resolve_axis(true)
	# Axe Y (+ dégâts de chute)
	var vy := vel.y
	var was_floor := on_floor
	pos.y += vel.y * delta
	on_floor = _resolve_axis(false)
	if on_floor and not was_floor and vy > FALL_SAFE:
		_damage((vy - FALL_SAFE) * FALL_DMG)

func _resolve_axis(is_x: bool) -> bool:
	var landed := false
	var min_tx := int(floor((pos.x - half.x) / TILE))
	var max_tx := int(floor((pos.x + half.x - 0.001) / TILE))
	var min_ty := int(floor((pos.y - half.y) / TILE))
	var max_ty := int(floor((pos.y + half.y - 0.001) / TILE))
	for ty in range(min_ty, max_ty + 1):
		for tx in range(min_tx, max_tx + 1):
			if not _is_solid(tx, ty):
				continue
			# Bornes du héros (recalculées car pos peut bouger)
			var l := pos.x - half.x
			var r := pos.x + half.x
			var t := pos.y - half.y
			var b := pos.y + half.y
			var tl := tx * TILE
			var tr := tl + TILE
			var tt := ty * TILE
			var tb := tt + TILE
			if l < tr and r > tl and t < tb and b > tt:
				if is_x:
					if vel.x > 0.0:
						pos.x = tl - half.x
					elif vel.x < 0.0:
						pos.x = tr + half.x
					vel.x = 0.0
				else:
					if vel.y > 0.0:
						pos.y = tt - half.y
						landed = true
					elif vel.y < 0.0:
						pos.y = tb + half.y
					vel.y = 0.0
	return landed

# --- Creusage ---------------------------------------------------------------
func _handle_dig(delta: float) -> void:
	if inv_open:
		dig_target = Vector2i(-1, -1)
		dig_progress = 0.0
		return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dig_target = Vector2i(-1, -1)
		dig_progress = 0.0
		return
	var m := get_global_mouse_position()
	var tx := int(floor(m.x / TILE))
	var ty := int(floor(m.y / TILE))
	if not _is_diggable(tx, ty) or not _in_reach(tx, ty):
		dig_target = Vector2i(-1, -1)
		dig_progress = 0.0
		return
	if _tile(tx, ty) == HARDROCK and dig_level < 1:
		dig_target = Vector2i(-1, -1)
		dig_progress = 0.0
		_flash_msg("Roche dense : outil en Fer requis (atelier puis amelioration)")
		return
	var cell := Vector2i(tx, ty)
	if cell != dig_target:
		dig_target = cell
		dig_progress = 0.0
	dig_progress += delta
	var need := dig_time * _dig_mult(_tile(tx, ty))
	if dig_progress >= need:
		_break_tile(tx, ty)
		dig_target = Vector2i(-1, -1)
		dig_progress = 0.0

func _break_tile(tx: int, ty: int) -> void:
	var t := _tile(tx, ty)
	grid[ty * GRID_W + tx] = EMPTY
	flashes.append({"cell": Vector2i(tx, ty), "t": 0.18})
	if t == WALL:
		_update_hud()
		return   # béton : gravats, rien à ramasser
	var item := DIRT
	if t == ROCK or t == HARDROCK:
		item = ROCK
	elif t == WOOD:
		item = WOOD
	elif t == LITHIUM:
		item = LITHIUM
	if _bag_add(item, 1) == 0:
		_flash_msg("Sac plein ! Objet perdu (vide-le a la base, ou touche I)")
	_update_hud()

func _update_flashes(delta: float) -> void:
	for f in flashes:
		f.t -= delta
	flashes = flashes.filter(func(f): return f.t > 0.0)

# --- Helpers grille ---------------------------------------------------------
func _tile(tx: int, ty: int) -> int:
	if tx < 0 or tx >= GRID_W or ty < 0 or ty >= GRID_H:
		return EMPTY
	return grid[ty * GRID_W + tx]

func _is_solid(tx: int, ty: int) -> bool:
	if tx < 0 or tx >= GRID_W:
		return true        # murs latéraux
	if ty < 0:
		return false       # ciel
	if ty >= GRID_H:
		return true        # sol du monde
	var t := grid[ty * GRID_W + tx]
	return t != EMPTY and t != ARTEFACT and t != LADDER   # artefact/échelle se traversent

func _is_diggable(tx: int, ty: int) -> bool:
	var t := _tile(tx, ty)
	return t == DIRT or t == ROCK or t == WOOD or t == LITHIUM or t == WALL or t == HARDROCK

func _dig_mult(t: int) -> float:
	if t == HARDROCK:
		return HARD_MULT
	if t == ROCK or t == LITHIUM or t == WALL:
		return ROCK_MULT
	return 1.0

func _in_reach(tx: int, ty: int) -> bool:
	var center := Vector2(tx * TILE + TILE * 0.5, ty * TILE + TILE * 0.5)
	return pos.distance_to(center) <= REACH

# --- Lumière ----------------------------------------------------------------
func _sky_light(tx: int, ty: int) -> float:
	var s := surface[clampi(tx, 0, GRID_W - 1)]
	if ty < s:
		return 1.0
	return 1.0 - clampf(float(ty - s) / SKY_FADE, 0.0, 1.0)

func _lamp_light(tx: int, ty: int) -> float:
	var hc := Vector2(pos.x / TILE, pos.y / TILE)
	var v := Vector2(tx + 0.5, ty + 0.5) - hc
	var d := v.length()
	# Halo doux autour du corps (toutes directions)
	var amb := 1.0 - clampf((d - LAMP_AMBIENT_CORE) / (LAMP_AMBIENT_RADIUS - LAMP_AMBIENT_CORE), 0.0, 1.0)
	amb = amb * amb * LAMP_AMBIENT_MAX
	# Faisceau dirigé vers la souris
	var beam := 0.0
	if d > 0.001:
		var dir := v / d
		var ang := clampf((dir.dot(aim) - LAMP_COS_OUTER) / (LAMP_COS_INNER - LAMP_COS_OUTER), 0.0, 1.0)
		var rad := 1.0 - clampf((d - LAMP_BEAM_CORE) / (LAMP_BEAM_RANGE - LAMP_BEAM_CORE), 0.0, 1.0)
		beam = ang * rad * rad
	var lit := maxf(amb, beam) * lamp_factor
	# Occlusion : la lumière s'arrête au premier bloc plein (ligne de vue)
	if lit > 0.02 and not _los_clear(tx, ty):
		return 0.0
	return clampf(lit, 0.0, 1.0)

func _torch_light(tx: int, ty: int) -> float:
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
		if l > 0.02 and not _los_clear_from(src, tx, ty):
			continue
		best = l
	return best

func _los_clear(tx: int, ty: int) -> bool:
	return _los_clear_from(Vector2(pos.x / TILE, pos.y / TILE), tx, ty)

func _los_clear_from(a: Vector2, tx: int, ty: int) -> bool:
	# Vrai si rien de plein ne bloque entre la source et la tuile (cible exclue :
	# le mur qu'on regarde est éclairé sur sa face, mais pas ce qu'il y a derrière).
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
		if _is_solid(cx, cy):
			return false
	return true

func _brightness(tx: int, ty: int) -> float:
	var light := maxf(_sky_light(tx, ty) * SKY_STRENGTH, _lamp_light(tx, ty))
	light = maxf(light, _torch_light(tx, ty))
	return clampf(light, AMBIENT_MIN, 1.0)

# --- Inventaire (slots + piles, façon Minecraft) ----------------------------
func _toggle_inventory() -> void:
	inv_open = not inv_open
	if inv_ui:
		inv_ui.visible = inv_open
		inv_ui.queue_redraw()
	if not inv_open and not held.is_empty():
		# On referme en tenant une pile : on la repose au sac (ou au stockage si près base).
		var back := _bag_add(int(held["type"]), int(held["count"]))
		var rest := int(held["count"]) - back
		if rest > 0 and _near_base():
			_store_add(int(held["type"]), rest)
			rest = 0
		if rest > 0:
			_flash_msg("Inventaire plein : %d objet(s) perdu(s)" % rest)
		held = {}
	_update_hud()

func _res_color(t: int) -> Color:
	match t:
		DIRT: return Color(0.42, 0.30, 0.20)
		ROCK: return Color(0.40, 0.42, 0.46)
		WOOD: return Color(0.55, 0.38, 0.15)
		LITHIUM: return Color(0.45, 0.74, 0.80)
	return Color(0.6, 0.6, 0.6)

func _res_name(t: int) -> String:
	match t:
		DIRT: return "Terre"
		ROCK: return "Roche"
		WOOD: return "Bois"
		LITHIUM: return "Lithium"
	return "?"

func _inv_layout(sz: Vector2) -> Dictionary:
	var cols := INV_COLS
	var rows := int(ceil(float(BAG_SLOTS) / float(cols)))
	var step := SLOT + SLOT_PAD
	var bag_w := cols * step - SLOT_PAD
	var bag_h := rows * step - SLOT_PAD
	var near := _near_base()
	var store_rows := RES_TYPES.size()
	var store_h := store_rows * step - SLOT_PAD
	var gap := 70
	var total_w := bag_w
	if near:
		total_w += gap + SLOT
	var ox := (sz.x - total_w) * 0.5
	var oy := (sz.y - bag_h) * 0.5
	var bag_rects := []
	for i in BAG_SLOTS:
		var r := i / cols
		var c := i % cols
		bag_rects.append(Rect2(ox + c * step, oy + r * step, SLOT, SLOT))
	var store_rects := []
	var store_origin := Vector2.ZERO
	if near:
		var sx := ox + bag_w + gap
		var sy := (sz.y - store_h) * 0.5
		store_origin = Vector2(sx, sy)
		for i in store_rows:
			store_rects.append(Rect2(sx, sy + i * step, SLOT, SLOT))
	return {"bag": bag_rects, "store": store_rects, "near": near, "bag_origin": Vector2(ox, oy), "store_origin": store_origin, "bag_h": bag_h}

func draw_inventory(cv: Control) -> void:
	var sz := cv.get_size()
	var font := ThemeDB.fallback_font
	cv.draw_rect(Rect2(Vector2.ZERO, sz), Color(0, 0, 0, 0.55))
	var L := _inv_layout(sz)
	var bo: Vector2 = L["bag_origin"]
	cv.draw_string(font, bo + Vector2(0, -10), "SAC  (%d/%d slots)" % [_bag_slots_used(), BAG_SLOTS], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.9, 0.95, 0.85))
	var bag_rects: Array = L["bag"]
	for i in BAG_SLOTS:
		_draw_slot(cv, font, bag_rects[i], bag[i], false)
	if bool(L["near"]):
		var so: Vector2 = L["store_origin"]
		cv.draw_string(font, so + Vector2(0, -10), "STOCKAGE BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.6, 1.0, 0.7))
		var store_rects: Array = L["store"]
		for i in RES_TYPES.size():
			var rt: int = RES_TYPES[i]
			_draw_slot(cv, font, store_rects[i], {"type": rt, "count": _store_count(rt)}, false)
	else:
		var note := "Approche-toi de la base pour acceder au stockage"
		var nw := font.get_string_size(note, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		cv.draw_string(font, Vector2((sz.x - nw) * 0.5, bo.y + float(L["bag_h"]) + 28), note, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.85, 0.8, 0.5))
	if not held.is_empty():
		var m := cv.get_local_mouse_position()
		_draw_slot(cv, font, Rect2(m - Vector2(SLOT * 0.5, SLOT * 0.5), Vector2(SLOT, SLOT)), held, true)
	var help := "Clic: prendre / poser / fusionner     Maj+Clic: transfert rapide sac <-> base     [I] fermer"
	var hw := font.get_string_size(help, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	cv.draw_string(font, Vector2((sz.x - hw) * 0.5, sz.y - 26), help, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.82, 0.88))

func _draw_slot(cv: Control, font: Font, rect: Rect2, slot: Dictionary, floating: bool) -> void:
	if not floating:
		cv.draw_rect(rect, Color(0.12, 0.13, 0.16, 0.96))
		cv.draw_rect(rect, Color(0.5, 0.52, 0.58), false, 1.0)
	if slot.has("type") and int(slot.get("count", 0)) > 0:
		cv.draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), _res_color(int(slot["type"])))
		var n := str(int(slot["count"]))
		var ns := font.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
		cv.draw_string(font, rect.position + Vector2(rect.size.x - 3 - ns.x, rect.size.y - 3), n, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1))

func inventory_click(p: Vector2, shift: bool) -> void:
	if inv_ui == null:
		return
	var L := _inv_layout(inv_ui.get_size())
	var bag_rects: Array = L["bag"]
	for i in BAG_SLOTS:
		if (bag_rects[i] as Rect2).has_point(p):
			_click_bag(i, shift)
			inv_ui.queue_redraw()
			return
	if bool(L["near"]):
		var store_rects: Array = L["store"]
		for i in RES_TYPES.size():
			if (store_rects[i] as Rect2).has_point(p):
				_click_store(int(RES_TYPES[i]), shift)
				inv_ui.queue_redraw()
				return
	# Clic dans le vide en tenant une pile → on la repose dans le sac.
	if not held.is_empty():
		var back := _bag_add(int(held["type"]), int(held["count"]))
		if back > 0:
			held["count"] = int(held["count"]) - back
			if int(held["count"]) <= 0:
				held = {}
		inv_ui.queue_redraw()

func _click_bag(i: int, shift: bool) -> void:
	if shift:
		if not _near_base():
			_flash_msg("Approche la base pour stocker")
			return
		if bag[i].has("type"):
			_store_add(int(bag[i]["type"]), int(bag[i]["count"]))
			bag[i] = {}
		_update_hud()
		return
	if held.is_empty():
		if bag[i].has("type"):
			held = bag[i]
			bag[i] = {}
	else:
		if bag[i].is_empty():
			bag[i] = held
			held = {}
		elif int(bag[i]["type"]) == int(held["type"]):
			var mv: int = mini(STACK_MAX - int(bag[i]["count"]), int(held["count"]))
			bag[i]["count"] = int(bag[i]["count"]) + mv
			held["count"] = int(held["count"]) - mv
			if int(held["count"]) <= 0:
				held = {}
		else:
			var tmp = bag[i]
			bag[i] = held
			held = tmp
	_update_hud()

func _click_store(rt: int, shift: bool) -> void:
	if shift:
		var moved := _bag_add(rt, _store_count(rt))
		_store_remove(rt, moved)
		_update_hud()
		return
	if held.is_empty():
		var take: int = mini(STACK_MAX, _store_count(rt))
		if take > 0:
			held = {"type": rt, "count": take}
			_store_remove(rt, take)
	else:
		if int(held["type"]) == rt:
			_store_add(rt, int(held["count"]))
			held = {}
		else:
			_flash_msg("Ce casier ne prend que: %s" % _res_name(rt))
	_update_hud()

# --- Rendu (grey-box) -------------------------------------------------------
func _draw() -> void:
	var c_dirt := Color(0.42, 0.30, 0.20)
	var c_rock := Color(0.40, 0.42, 0.46)
	var c_wood := Color(0.55, 0.38, 0.15)
	var c_lith := Color(0.45, 0.74, 0.80)
	var c_wall := Color(0.30, 0.34, 0.42)
	var c_hard := Color(0.18, 0.20, 0.26)
	var c_lamp := Color(1.0, 0.85, 0.55)
	var ptx := int(pos.x / TILE)
	var pty := int(pos.y / TILE)
	var rx := 34
	var ry := 22
	# Fond sombre
	var bg_pos := Vector2((ptx - rx) * TILE, (pty - ry) * TILE)
	var bg_size := Vector2((rx * 2) * TILE, (ry * 2) * TILE)
	draw_rect(Rect2(bg_pos, bg_size), Color(0.04, 0.04, 0.06))
	# Tuiles visibles, éclairées
	for ty in range(pty - ry, pty + ry):
		for tx in range(ptx - rx, ptx + rx):
			var rect := Rect2(tx * TILE, ty * TILE, TILE, TILE)
			var t := _tile(tx, ty)
			if t == EMPTY:
				# Halo de la lampe / des torches / du jour, visibles dans le vide
				var glow := maxf(_lamp_light(tx, ty), _torch_light(tx, ty))
				if glow > 0.02:
					draw_rect(rect, Color(c_lamp.r, c_lamp.g, c_lamp.b, glow * 0.22))
				elif ty < surface[clampi(tx, 0, GRID_W - 1)] + 2:
					var sky := _sky_light(tx, ty)
					if sky > 0.02:
						draw_rect(rect, Color(0.5, 0.6, 0.7, sky * 0.10))
				continue
			if t == ARTEFACT:
				var ba := _brightness(tx, ty)
				draw_rect(rect, Color(1.0, 0.92, 0.35, 0.3 + 0.7 * ba))
				draw_rect(rect, Color(1.0, 1.0, 0.6, ba), false, 1.0)
				continue
			if t == LADDER:
				var bl := _brightness(tx, ty)
				var lc := Color(0.78, 0.56, 0.30, 0.45 + 0.55 * bl)
				draw_rect(Rect2(tx * TILE + 3, ty * TILE, 2, TILE), lc)
				draw_rect(Rect2(tx * TILE + TILE - 5, ty * TILE, 2, TILE), lc)
				draw_rect(Rect2(tx * TILE + 3, ty * TILE + 4, TILE - 8, 2), lc)
				draw_rect(Rect2(tx * TILE + 3, ty * TILE + 10, TILE - 8, 2), lc)
				continue
			var b := _brightness(tx, ty)
			var col := c_dirt
			if t == ROCK:
				col = c_rock
			elif t == WOOD:
				col = c_wood
			elif t == LITHIUM:
				col = c_lith
			elif t == WALL:
				col = c_wall
			elif t == HARDROCK:
				col = c_hard
			draw_rect(rect, Color(col.r * b, col.g * b, col.b * b))
			draw_rect(rect, Color(0, 0, 0, 0.15 * b), false, 1.0)
	# Éclats de creusage (feedback de cassage)
	for f in flashes:
		var a: float = clampf(f.t / 0.18, 0.0, 1.0)
		draw_rect(Rect2(f.cell.x * TILE, f.cell.y * TILE, TILE, TILE), Color(1.0, 0.9, 0.6, a * 0.7))
	# Cible de creusage + progression
	if dig_target.x >= 0:
		var need := dig_time * _dig_mult(_tile(dig_target.x, dig_target.y))
		var p: float = clampf(dig_progress / need, 0.0, 1.0)
		var rpos := Vector2(dig_target.x * TILE, dig_target.y * TILE)
		draw_rect(Rect2(rpos, Vector2(TILE, TILE)), Color(1, 1, 1, 0.15 + 0.35 * p))
		draw_rect(Rect2(rpos, Vector2(TILE, TILE)), Color(1, 1, 1, 0.7), false, 1.0)
	# Torches posées
	for c in torches:
		var tc := Vector2(c.x * TILE + TILE * 0.5, c.y * TILE + TILE * 0.5)
		draw_circle(tc, TORCH_CORE * TILE, Color(1.0, 0.7, 0.3, 0.12))
		draw_rect(Rect2(tc + Vector2(-2, -5), Vector2(4, 10)), Color(1.0, 0.75, 0.35))
	# Robots (visibles surtout sous la lumière — sinon silhouette à peine perceptible)
	for e in enemies:
		var ep: Vector2 = e["pos"]
		var vis: float = maxf(0.28, _brightness(int(ep.x / TILE), int(ep.y / TILE)))
		var flash := float(e["flash"]) > 0.0
		var col := Color(1.0, 0.95, 0.95) if flash else Color(0.85, 0.30, 0.25)
		draw_rect(Rect2(ep - ENEMY_HALF, ENEMY_HALF * 2.0), Color(col.r * vis, col.g * vis, col.b * vis))
		draw_rect(Rect2(ep - ENEMY_HALF, ENEMY_HALF * 2.0), Color(0, 0, 0, 0.5 * vis), false, 1.0)
		# "oeil" tourné vers le sens de marche
		draw_rect(Rect2(ep + Vector2(float(e["dir"]) * 2.0 - 1.5, -3.0), Vector2(3, 3)), Color(1.0, 0.85, 0.4, vis))
		if float(e["hp"]) < ENEMY_HP:
			var w := ENEMY_HALF.x * 2.0
			var frac: float = clampf(float(e["hp"]) / ENEMY_HP, 0.0, 1.0)
			draw_rect(Rect2(ep + Vector2(-ENEMY_HALF.x, -ENEMY_HALF.y - 5.0), Vector2(w, 2)), Color(0.25, 0.0, 0.0))
			draw_rect(Rect2(ep + Vector2(-ENEMY_HALF.x, -ENEMY_HALF.y - 5.0), Vector2(w * frac, 2)), Color(0.95, 0.25, 0.25))
	# Base (dépôt, à la surface) et cache de butin (à la mort)
	draw_circle(base_pos, BASE_RANGE, Color(0.3, 0.9, 0.4, 0.08))
	draw_rect(Rect2(base_pos + Vector2(-9, -3), Vector2(18, 6)), Color(0.3, 0.85, 0.4))
	# Pièces construites (avec étiquettes)
	var font := ThemeDB.fallback_font
	draw_string(font, base_pos + Vector2(-12, -7), "BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.6, 1.0, 0.7))
	if has_prod:
		var pr := base_pos + Vector2(-3.6 * TILE, -2.0 * TILE)
		draw_rect(Rect2(pr, Vector2(2.4 * TILE, 2.0 * TILE)), Color(0.25, 0.45, 0.70))
		draw_rect(Rect2(pr + Vector2(0.9 * TILE, 1.0 * TILE), Vector2(6, 12)), Color(0.95, 0.9, 0.65))  # PNJ
		draw_string(font, pr + Vector2(1, -2), "PROD", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.7, 0.85, 1.0))
	if has_workshop:
		var ws := base_pos + Vector2(1.2 * TILE, -2.0 * TILE)
		draw_rect(Rect2(ws, Vector2(2.4 * TILE, 2.0 * TILE)), Color(0.60, 0.45, 0.25))
		draw_string(font, ws + Vector2(1, -2), "ATELIER", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.85, 0.6))
	if cache_active:
		draw_circle(cache_pos, CACHE_RANGE, Color(0.95, 0.75, 0.25, 0.16))
		draw_rect(Rect2(cache_pos + Vector2(-4, -4), Vector2(8, 8)), Color(0.95, 0.8, 0.3))
	# Halo central + héros (le héros porte la lumière ; le halo faiblit avec le carburant)
	draw_circle(pos, LAMP_AMBIENT_CORE * TILE, Color(c_lamp.r, c_lamp.g, c_lamp.b, 0.10 * lamp_factor))
	draw_rect(Rect2(pos - half, half * 2.0), Color(0.95, 0.85, 0.5))
	draw_rect(Rect2(pos - half, half * 2.0), Color(0.2, 0.15, 0.05, 0.8), false, 1.0)
	# Arc de coup (feedback du clic droit, mêlée)
	if atk_t > 0.0:
		var a: float = clampf(atk_t / MELEE_VIS, 0.0, 1.0)
		draw_circle(pos + aim * MELEE_RANGE * 0.55, MELEE_RANGE * 0.5, Color(1.0, 1.0, 1.0, 0.20 * a))
	# Traceur de tir (arme à feu)
	if tracer_t > 0.0:
		var ta: float = clampf(tracer_t / GUN_TRACER_T, 0.0, 1.0)
		draw_line(tracer_a, tracer_b, Color(1.0, 0.9, 0.4, 0.5 + 0.4 * ta), 1.5)
		draw_circle(tracer_b, 2.5, Color(1.0, 0.85, 0.4, ta))
