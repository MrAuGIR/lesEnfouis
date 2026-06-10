class_name EnemyCrew
extends RefCounted
## Les robots : spawn à densité croissante vers la surface, IA patrouille →
## poursuite à vue, dégâts de contact. Chaque robot est un Dictionary :
## {pos, vel: Vector2, hp: float, dir: float, on_floor, blocked: bool, hit_cd, flash: float}

const ENEMY_COUNT := 8           # robots dispersés dans le sous-sol
const ENEMY_HP := 60.0
const ENEMY_SPEED := 42.0        # px/s en patrouille
const ENEMY_CHASE_MULT := 1.5    # vitesse en poursuite
const ENEMY_DMG := 12.0          # dégâts de contact au héros
const ENEMY_HIT_CD := 0.8        # s entre deux coups d'un même robot
const DETECT_RANGE := 9.0        # tuiles : portée de détection du héros (avec ligne de vue)
const ENEMY_HALF := Vector2(6, 7)

var world: WorldGrid
var light: LightField
var hero: Hero
var list := []

func _init(w: WorldGrid, l: LightField, h: Hero) -> void:
	world = w
	light = l
	hero = h

func spawn(base_pos: Vector2) -> void:
	list = []
	# Gradient de danger : la PROFONDEUR (près de la base) est calme, la SURFACE est
	# hostile. Densité croissante vers le haut : la pression monte quand on remonte.
	var ts := WorldGrid.TILE
	var tries := 0
	while list.size() < ENEMY_COUNT and tries < 6000:
		tries += 1
		var tx := randi_range(4, WorldGrid.GRID_W - 5)
		var top := world.surface[clampi(tx, 0, WorldGrid.GRID_W - 1)]
		var ty := randi_range(top + 2, WorldGrid.BASE_DEPTH - 2)
		# une case vide avec du sol dessous et de la place au-dessus (tête)
		if world.tile(tx, ty) != WorldGrid.EMPTY or world.tile(tx, ty - 1) != WorldGrid.EMPTY \
				or not world.is_solid(tx, ty + 1):
			continue
		# f = 0 en surface, 1 au niveau de la base ; on garde surtout les spawns peu profonds.
		var f := clampf(float(ty - top) / float(WorldGrid.BASE_DEPTH - top), 0.0, 1.0)
		var keep := 1.0 - f
		if randf() > keep * keep:   # courbe au carré → concentre les robots vers la surface
			continue
		var p := Vector2(tx * ts + ts * 0.5, ty * ts + ts * 0.5)
		if p.distance_to(base_pos) < 12.0 * ts:
			continue   # zone de répit autour de la base profonde
		_add(p)

func _add(p: Vector2) -> void:
	list.append({"pos": p, "vel": Vector2.ZERO, "hp": ENEMY_HP,
		"dir": (1.0 if randf() < 0.5 else -1.0),
		"on_floor": false, "blocked": false, "hit_cd": 0.0, "flash": 0.0})

func update(delta: float) -> void:
	var ts := float(WorldGrid.TILE)
	for e in list:
		e["hit_cd"] = maxf(0.0, float(e["hit_cd"]) - delta)
		e["flash"] = maxf(0.0, float(e["flash"]) - delta)
		var to_player: Vector2 = hero.pos - e["pos"]
		var dist := to_player.length()
		var ec := Vector2(e["pos"].x / ts, e["pos"].y / ts)
		var chasing := dist < DETECT_RANGE * ts \
			and light.los_clear_from(ec, int(hero.pos.x / ts), int(hero.pos.y / ts))
		if chasing:
			e["dir"] = signf(to_player.x) if absf(to_player.x) > 2.0 else e["dir"]
			if bool(e["blocked"]) and bool(e["on_floor"]):
				e["vel"].y = -Hero.JUMP_SPEED * 0.8   # saute l'obstacle pour poursuivre
		else:
			# patrouille : demi-tour au mur ou au bord du vide (ne pas tomber bêtement)
			if bool(e["on_floor"]):
				var ahead_x: float = e["pos"].x + e["dir"] * (ENEMY_HALF.x + 3.0)
				var foot_y: float = e["pos"].y + ENEMY_HALF.y + 4.0
				if bool(e["blocked"]) or not world.is_solid(int(ahead_x / ts), int(foot_y / ts)):
					e["dir"] = -float(e["dir"])
		e["blocked"] = false
		var spd := ENEMY_SPEED * (ENEMY_CHASE_MULT if chasing else 1.0)
		e["vel"].x = float(e["dir"]) * spd
		_move(e, delta)
		# Contact → dégâts au héros (avec cooldown par robot) + petit recul
		if _aabb_overlap(hero.pos, hero.half, e["pos"], ENEMY_HALF) and float(e["hit_cd"]) <= 0.0:
			e["hit_cd"] = ENEMY_HIT_CD
			hero.damage(ENEMY_DMG)
			hero.vel.x = signf(hero.pos.x - e["pos"].x) * Hero.MOVE_SPEED

func _move(e: Dictionary, delta: float) -> void:
	e["pos"].x += e["vel"].x * delta
	var rx := _collide_axis(e["pos"], ENEMY_HALF, e["vel"], true)
	e["pos"] = rx["pos"]
	e["vel"] = rx["vel"]
	if bool(rx["blocked"]):
		e["blocked"] = true
	e["vel"].y += Hero.GRAVITY * delta
	e["vel"].y = clampf(e["vel"].y, -Hero.JUMP_SPEED, 600.0)
	e["pos"].y += e["vel"].y * delta
	var ry := _collide_axis(e["pos"], ENEMY_HALF, e["vel"], false)
	e["pos"] = ry["pos"]
	e["vel"] = ry["vel"]
	e["on_floor"] = bool(ry["landed"])

# Résolution AABB-vs-grille (pure, sans état) — éjection par pénétration minimale,
# même règle que Hero._resolve_axis (cf. le commentaire là-bas).
func _collide_axis(p: Vector2, hf: Vector2, v: Vector2, is_x: bool) -> Dictionary:
	var landed := false
	var blocked := false
	var ts := float(WorldGrid.TILE)
	var min_tx := int(floor((p.x - hf.x) / ts))
	var max_tx := int(floor((p.x + hf.x - 0.001) / ts))
	var min_ty := int(floor((p.y - hf.y) / ts))
	var max_ty := int(floor((p.y + hf.y - 0.001) / ts))
	for ty in range(min_ty, max_ty + 1):
		for tx in range(min_tx, max_tx + 1):
			if not world.is_solid(tx, ty):
				continue
			var l := p.x - hf.x
			var r := p.x + hf.x
			var t := p.y - hf.y
			var b := p.y + hf.y
			var tl := tx * ts
			var tr := tl + ts
			var tt := ty * ts
			var tb := tt + ts
			if l < tr and r > tl and t < tb and b > tt:
				if is_x:
					var pen_left := r - tl
					var pen_right := tr - l
					if pen_left <= pen_right:
						p.x = tl - hf.x
						if v.x > 0.0:
							v.x = 0.0
					else:
						p.x = tr + hf.x
						if v.x < 0.0:
							v.x = 0.0
					blocked = true
				else:
					var pen_up := b - tt
					var pen_down := tb - t
					if pen_up <= pen_down:
						p.y = tt - hf.y
						if v.y > 0.0:
							v.y = 0.0
						landed = true
					else:
						p.y = tb + hf.y
						if v.y < 0.0:
							v.y = 0.0
	return {"pos": p, "vel": v, "landed": landed, "blocked": blocked}

static func _aabb_overlap(p1: Vector2, h1: Vector2, p2: Vector2, h2: Vector2) -> bool:
	return absf(p1.x - p2.x) < h1.x + h2.x and absf(p1.y - p2.y) < h1.y + h2.y
