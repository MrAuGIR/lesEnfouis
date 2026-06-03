extends Node2D
## Les Enfouis — Prototype, Jalon 0 : mouvement & creusage.
## Tout est en grey-box (rectangles colorés) : on teste UNIQUEMENT le fun du
## creuser → récolter. Aucun art final (cf. docs/PROTOTYPE.md).

# --- Paramètres réglables (valeurs de départ — cf. PROTOTYPE.md) -------------
const TILE := 16            # taille de tuile (figée dans la DA)
const GRID_W := 240
const GRID_H := 240
const AIR_ROWS := 8         # rangées de ciel/vide en haut

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

# Types de tuile
const EMPTY := 0
const DIRT := 1
const ROCK := 2

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

var flashes := []   # éclats de creusage : {cell:Vector2i, t:float}

var camera: Camera2D
var hud: Label

# --- Init -------------------------------------------------------------------
func _ready() -> void:
	randomize()
	_generate_world()
	_spawn_player()
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
			grid[y * GRID_W + x] = t

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
	hud.text = "Terre: %d    Roche: %d\n[A/D ou ←/→] bouger   [Espace] sauter   [Clic gauche] creuser" % [res_dirt, res_rock]

# --- Boucle -----------------------------------------------------------------
func _physics_process(delta: float) -> void:
	_move(delta)
	if camera:
		camera.global_position = pos

func _process(delta: float) -> void:
	_update_aim()
	_handle_dig(delta)
	_update_flashes(delta)
	queue_redraw()

func _update_aim() -> void:
	var v := get_global_mouse_position() - pos
	if v.length() > 1.0:
		aim = v.normalized()

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
	# Axe Y
	pos.y += vel.y * delta
	on_floor = _resolve_axis(false)

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
	var need := DIG_TIME * (ROCK_MULT if _tile(tx, ty) == ROCK else 1.0)
	if dig_progress >= need:
		_break_tile(tx, ty)
		dig_target = Vector2i(-1, -1)
		dig_progress = 0.0

func _break_tile(tx: int, ty: int) -> void:
	var t := _tile(tx, ty)
	grid[ty * GRID_W + tx] = EMPTY
	if t == ROCK:
		res_rock += 1
	else:
		res_dirt += 1
	flashes.append({"cell": Vector2i(tx, ty), "t": 0.18})
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
	return t == DIRT or t == ROCK

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
	var lit := maxf(amb, beam)
	# Occlusion : la lumière s'arrête au premier bloc plein (ligne de vue)
	if lit > 0.02 and not _los_clear(tx, ty):
		return 0.0
	return clampf(lit, 0.0, 1.0)

func _los_clear(tx: int, ty: int) -> bool:
	# Vrai si rien de plein ne bloque entre le héros et la tuile (cible exclue :
	# le mur qu'on regarde est éclairé sur sa face, mais pas ce qu'il y a derrière).
	var a := Vector2(pos.x / TILE, pos.y / TILE)
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
	return clampf(maxf(_sky_light(tx, ty) * SKY_STRENGTH, _lamp_light(tx, ty)), AMBIENT_MIN, 1.0)

# --- Rendu (grey-box) -------------------------------------------------------
func _draw() -> void:
	var c_dirt := Color(0.42, 0.30, 0.20)
	var c_rock := Color(0.40, 0.42, 0.46)
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
				# Halo de la lampe / lumière du jour visibles dans le vide
				var lamp := _lamp_light(tx, ty)
				if lamp > 0.02:
					draw_rect(rect, Color(c_lamp.r, c_lamp.g, c_lamp.b, lamp * 0.22))
				elif ty < surface[clampi(tx, 0, GRID_W - 1)] + 2:
					var sky := _sky_light(tx, ty)
					if sky > 0.02:
						draw_rect(rect, Color(0.5, 0.6, 0.7, sky * 0.10))
				continue
			var b := _brightness(tx, ty)
			var col := c_dirt if t == DIRT else c_rock
			draw_rect(rect, Color(col.r * b, col.g * b, col.b * b))
			draw_rect(rect, Color(0, 0, 0, 0.15 * b), false, 1.0)
	# Éclats de creusage (feedback de cassage)
	for f in flashes:
		var a: float = clampf(f.t / 0.18, 0.0, 1.0)
		draw_rect(Rect2(f.cell.x * TILE, f.cell.y * TILE, TILE, TILE), Color(1.0, 0.9, 0.6, a * 0.7))
	# Cible de creusage + progression
	if dig_target.x >= 0:
		var need := DIG_TIME * (ROCK_MULT if _tile(dig_target.x, dig_target.y) == ROCK else 1.0)
		var p: float = clampf(dig_progress / need, 0.0, 1.0)
		var rpos := Vector2(dig_target.x * TILE, dig_target.y * TILE)
		draw_rect(Rect2(rpos, Vector2(TILE, TILE)), Color(1, 1, 1, 0.15 + 0.35 * p))
		draw_rect(Rect2(rpos, Vector2(TILE, TILE)), Color(1, 1, 1, 0.7), false, 1.0)
	# Halo central + héros (le héros porte la lumière)
	draw_circle(pos, LAMP_AMBIENT_CORE * TILE, Color(c_lamp.r, c_lamp.g, c_lamp.b, 0.10))
	draw_rect(Rect2(pos - half, half * 2.0), Color(0.95, 0.85, 0.5))
	draw_rect(Rect2(pos - half, half * 2.0), Color(0.2, 0.15, 0.05, 0.8), false, 1.0)
