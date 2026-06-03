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
const BAG_CAP := 25              # capacité du sac (nb d'objets transportés)
const MAX_HP := 100.0
const FALL_SAFE := 380.0         # vitesse de chute sans dégât (px/s)
const FALL_DMG := 0.25           # dégâts par unité de vitesse au-delà du seuil
const BASE_RANGE := 2.6 * TILE   # portée de dépôt à la base
const CACHE_RANGE := 2.0 * TILE  # portée de récupération d'une cache

# Types de tuile
const EMPTY := 0
const DIRT := 1
const ROCK := 2
const WOOD := 3    # étais de bois (dans la terre) → torches + construction/craft
const LITHIUM := 4 # minerai de lithium (dans la roche) → recharge la lampe frontale
const WALL := 5    # béton d'un bunker abandonné (creusable, sans ressource : gravats)

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

var res_dirt := 0
var res_rock := 0
var res_wood := 0
var res_lithium := 0

var lamp_fuel := LAMP_AUTONOMY    # carburant restant (secondes)
var lamp_factor := 1.0            # 0..1 : intensité de la lampe selon le carburant
var torches: Array[Vector2i] = [] # torches posées (sécurisent un chemin)

var hp := MAX_HP
var store_dirt := 0               # stockage de la base (butin déposé)
var store_rock := 0
var store_wood := 0
var store_lithium := 0
var base_pos := Vector2.ZERO      # point de dépôt (surface, départ)
var cache_active := false         # une cache de butin attend d'être récupérée
var cache_pos := Vector2.ZERO
var cache := {"dirt": 0, "rock": 0, "wood": 0, "lithium": 0}

var flashes := []   # éclats de creusage : {cell:Vector2i, t:float}

var camera: Camera2D
var hud: Label

# --- Init -------------------------------------------------------------------
func _ready() -> void:
	randomize()
	_generate_world()
	_spawn_player()
	base_pos = pos
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
	_update_hud()

func _update_hud() -> void:
	var bagline := "Sac: %d/%d" % [_bag_total(), BAG_CAP]
	if _bag_total() >= BAG_CAP:
		bagline += "  (PLEIN)"
	if cache_active:
		bagline += "     >> CACHE a recuperer <<"
	hud.text = "PV: %d/%d    %s\nPortes - Li:%d  Bois:%d  Terre:%d  Roche:%d\nBase   - Li:%d  Bois:%d  Terre:%d  Roche:%d\nLampe: %d%%    Torches: %d\n[A/D] bouger  [Espace] saut  [Clic] creuser  [R] lampe  [T] torche  [E] deposer/recuperer  [Q] retirer (base->sac)  [K] mort (test)" % [int(hp), int(MAX_HP), bagline, res_lithium, res_wood, res_dirt, res_rock, store_lithium, store_wood, store_dirt, store_rock, int(lamp_fuel / LAMP_AUTONOMY * 100.0), torches.size()]

# --- Boucle -----------------------------------------------------------------
func _physics_process(delta: float) -> void:
	_move(delta)
	if camera:
		camera.global_position = pos

func _process(delta: float) -> void:
	_update_aim()
	_deplete_lamp(delta)
	_handle_dig(delta)
	_update_flashes(delta)
	_update_hud()
	queue_redraw()

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
		elif event.keycode == KEY_E:
			_interact()
		elif event.keycode == KEY_Q:
			_withdraw()
		elif event.keycode == KEY_K:
			_damage(MAX_HP)   # mort de test

func _refuel() -> void:
	if res_lithium > 0 and lamp_fuel < LAMP_AUTONOMY:
		res_lithium -= 1
		lamp_fuel = minf(LAMP_AUTONOMY, lamp_fuel + LAMP_REFILL)

func _place_torch() -> void:
	var cell := Vector2i(int(floor(pos.x / TILE)), int(floor(pos.y / TILE)))
	if res_wood > 0 and not _is_solid(cell.x, cell.y) and not torches.has(cell):
		res_wood -= 1
		torches.append(cell)

func _bag_total() -> int:
	return res_dirt + res_rock + res_wood + res_lithium

func _damage(amount: float) -> void:
	hp = maxf(0.0, hp - amount)
	if hp <= 0.0:
		_die()
	_update_hud()

func _die() -> void:
	# Largue le butin transporté dans une cache (Souls). Une cache précédente est perdue.
	if _bag_total() > 0:
		cache_active = true
		cache_pos = pos
		cache = {"dirt": res_dirt, "rock": res_rock, "wood": res_wood, "lithium": res_lithium}
		res_dirt = 0
		res_rock = 0
		res_wood = 0
		res_lithium = 0
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
	store_dirt += res_dirt
	store_rock += res_rock
	store_wood += res_wood
	store_lithium += res_lithium
	res_dirt = 0
	res_rock = 0
	res_wood = 0
	res_lithium = 0
	hp = MAX_HP   # on se soigne à la base
	_update_hud()

func _withdraw() -> void:
	# Base → sac (en priorité le carburant), dans la limite de capacité.
	if pos.distance_to(base_pos) > BASE_RANGE:
		return
	var space := BAG_CAP - _bag_total()
	var n := mini(space, store_lithium)
	res_lithium += n
	store_lithium -= n
	space -= n
	n = mini(space, store_wood)
	res_wood += n
	store_wood -= n
	space -= n
	n = mini(space, store_rock)
	res_rock += n
	store_rock -= n
	space -= n
	n = mini(space, store_dirt)
	res_dirt += n
	store_dirt -= n
	_update_hud()

func _recover_cache() -> void:
	res_dirt += cache["dirt"]
	res_rock += cache["rock"]
	res_wood += cache["wood"]
	res_lithium += cache["lithium"]
	cache_active = false
	_update_hud()

# --- Déplacement + collision contre la grille -------------------------------
func _move(delta: float) -> void:
	var dir := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir += 1.0
	vel.x = dir * MOVE_SPEED

	if on_floor and (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)):
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
	var cell := Vector2i(tx, ty)
	if cell != dig_target:
		dig_target = cell
		dig_progress = 0.0
	dig_progress += delta
	var need := DIG_TIME * (ROCK_MULT if _is_hard(_tile(tx, ty)) else 1.0)
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
	if _bag_total() >= BAG_CAP:
		_update_hud()
		return   # sac plein : la ressource est perdue
	if t == ROCK:
		res_rock += 1
	elif t == WOOD:
		res_wood += 1
	elif t == LITHIUM:
		res_lithium += 1
	else:
		res_dirt += 1
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
	return grid[ty * GRID_W + tx] != EMPTY

func _is_diggable(tx: int, ty: int) -> bool:
	var t := _tile(tx, ty)
	return t == DIRT or t == ROCK or t == WOOD or t == LITHIUM or t == WALL

func _is_hard(t: int) -> bool:
	return t == ROCK or t == LITHIUM or t == WALL   # creusage plus lent

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

# --- Rendu (grey-box) -------------------------------------------------------
func _draw() -> void:
	var c_dirt := Color(0.42, 0.30, 0.20)
	var c_rock := Color(0.40, 0.42, 0.46)
	var c_wood := Color(0.55, 0.38, 0.15)
	var c_lith := Color(0.45, 0.74, 0.80)
	var c_wall := Color(0.30, 0.34, 0.42)
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
			draw_rect(rect, Color(col.r * b, col.g * b, col.b * b))
			draw_rect(rect, Color(0, 0, 0, 0.15 * b), false, 1.0)
	# Éclats de creusage (feedback de cassage)
	for f in flashes:
		var a: float = clampf(f.t / 0.18, 0.0, 1.0)
		draw_rect(Rect2(f.cell.x * TILE, f.cell.y * TILE, TILE, TILE), Color(1.0, 0.9, 0.6, a * 0.7))
	# Cible de creusage + progression
	if dig_target.x >= 0:
		var need := DIG_TIME * (ROCK_MULT if _is_hard(_tile(dig_target.x, dig_target.y)) else 1.0)
		var p: float = clampf(dig_progress / need, 0.0, 1.0)
		var rpos := Vector2(dig_target.x * TILE, dig_target.y * TILE)
		draw_rect(Rect2(rpos, Vector2(TILE, TILE)), Color(1, 1, 1, 0.15 + 0.35 * p))
		draw_rect(Rect2(rpos, Vector2(TILE, TILE)), Color(1, 1, 1, 0.7), false, 1.0)
	# Torches posées
	for c in torches:
		var tc := Vector2(c.x * TILE + TILE * 0.5, c.y * TILE + TILE * 0.5)
		draw_circle(tc, TORCH_CORE * TILE, Color(1.0, 0.7, 0.3, 0.12))
		draw_rect(Rect2(tc + Vector2(-2, -5), Vector2(4, 10)), Color(1.0, 0.75, 0.35))
	# Base (dépôt, à la surface) et cache de butin (à la mort)
	draw_circle(base_pos, BASE_RANGE, Color(0.3, 0.9, 0.4, 0.08))
	draw_rect(Rect2(base_pos + Vector2(-9, -3), Vector2(18, 6)), Color(0.3, 0.85, 0.4))
	if cache_active:
		draw_circle(cache_pos, CACHE_RANGE, Color(0.95, 0.75, 0.25, 0.16))
		draw_rect(Rect2(cache_pos + Vector2(-4, -4), Vector2(8, 8)), Color(0.95, 0.8, 0.3))
	# Halo central + héros (le héros porte la lumière ; le halo faiblit avec le carburant)
	draw_circle(pos, LAMP_AMBIENT_CORE * TILE, Color(c_lamp.r, c_lamp.g, c_lamp.b, 0.10 * lamp_factor))
	draw_rect(Rect2(pos - half, half * 2.0), Color(0.95, 0.85, 0.5))
	draw_rect(Rect2(pos - half, half * 2.0), Color(0.2, 0.15, 0.05, 0.8), false, 1.0)
