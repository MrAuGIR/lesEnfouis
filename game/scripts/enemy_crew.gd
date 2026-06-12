class_name EnemyCrew
extends RefCounted
## Les ennemis. Deux populations (M3) :
##  - ROBOTS au-dessus de la barrière (zone de gaz + surface) : patrouille → poursuite.
##  - PILLEURS humains dans le Transit : gardiens des stations (postés, avec une
##    « laisse » autour de leur poste) et patrouilles le long des tunnels.
##    Trois archétypes (GDD 03) : Fonceur (contact), Tireur (garde ses distances,
##    tir hitscan) et Lourd (lent, énorme, BLINDÉ DE FACE — le dos est vulnérable).
## Chaque ennemi est un Dictionary : {kind, pos, vel, hp, max_hp, half, speed, dmg,
##  dir, on_floor, blocked, hit_cd, flash, anchor: Vector2|null, shoot_cd}

const KIND_ROBOT := 0
const KIND_FONCEUR := 1
const KIND_TIREUR := 2
const KIND_LOURD := 3
const KIND_NAMES := ["Robot", "Pilleur", "Tireur", "Lourd"]
const K_HP := [60.0, 50.0, 40.0, 220.0]
const K_SPEED := [42.0, 48.0, 40.0, 20.0]
const K_DMG := [12.0, 10.0, 8.0, 24.0]   # contact (Tireur : dégâts de ses balles)
const K_HALF := [Vector2(6, 7), Vector2(5, 10), Vector2(5, 10), Vector2(8, 12)]

const ENEMY_COUNT := 8           # robots dispersés au-dessus de la barrière
const PATROL_COUNT := 3          # pilleurs en maraude par tunnel de métro
const ENEMY_CHASE_MULT := 1.5    # vitesse en poursuite
const ENEMY_HIT_CD := 0.8        # s entre deux coups de contact d'un même ennemi
const DETECT_RANGE := 9.0        # tuiles : portée de détection du héros (avec ligne de vue)
const ENEMY_HALF := Vector2(6, 7)   # gabarit du robot (référence)
const GUARD_LEASH := 12.0        # tuiles : un gardien n'abandonne pas son poste au-delà
const LOURD_FRONT_MULT := 0.25   # dégâts encaissés DE FACE par le Lourd (blindage)
const LOURD_BACK_MULT := 1.5     # ... et dans le DOS (point faible)
const SHOOT_NEAR := 5.5          # tuiles : le Tireur recule en-deçà
const SHOOT_RANGE := 11.0        # tuiles : portée de tir du Tireur
const SHOOT_CD := 1.6            # s entre deux tirs
const SHOOT_MISS := 0.3          # part des tirs qui ratent (grey-box)

var world: WorldGrid
var light: LightField
var hero: Hero
var list := []
var shots := []                  # traceurs des tirs ennemis : {a, b: Vector2, t: float}

func _init(w: WorldGrid, l: LightField, h: Hero) -> void:
	world = w
	light = l
	hero = h

# --- Spawns -------------------------------------------------------------------
func spawn(base_pos: Vector2) -> void:
	list = []
	# ROBOTS : uniquement AU-DESSUS de la barrière (le Transit est aux humains).
	# Densité croissante vers la surface : la pression monte quand on remonte.
	var ts := WorldGrid.TILE
	var tries := 0
	while list.size() < ENEMY_COUNT and tries < 6000:
		tries += 1
		var tx := randi_range(4, WorldGrid.GRID_W - 5)
		var top := world.surface[clampi(tx, 0, WorldGrid.GRID_W - 1)]
		var ty := randi_range(top + 2, WorldGrid.BAND_TOP - 2)
		# une case vide avec du sol dessous et de la place au-dessus (tête)
		if world.tile(tx, ty) != WorldGrid.EMPTY or world.tile(tx, ty - 1) != WorldGrid.EMPTY \
				or not world.is_solid(tx, ty + 1):
			continue
		# f = 0 en surface, 1 à la barrière ; on garde surtout les spawns peu profonds.
		var f := clampf(float(ty - top) / float(WorldGrid.BAND_TOP - top), 0.0, 1.0)
		var keep := 1.0 - f
		if randf() > keep * keep:   # courbe au carré → concentre les robots vers la surface
			continue
		var p := Vector2(tx * ts + ts * 0.5, ty * ts + ts * 0.5)
		if p.distance_to(base_pos) < 26.0 * ts:
			continue   # zone de répit autour du Foyer
		_add(p, KIND_ROBOT, null)

func spawn_transit() -> void:
	# PILLEURS : gardiens postés dans chaque station (le loot se mérite) +
	# patrouilles le long des axes de métro. La station du prisonnier légendaire
	# reçoit en plus le LOURD et un gardien supplémentaire.
	var ts := float(WorldGrid.TILE)
	var guarded_st := Rect2i()
	for spot in world.captive_spots:
		if bool(spot["guarded"]):
			for s in world.stations:
				if (s as Rect2i).has_point(Vector2i(spot["cell"])):
					guarded_st = s
	for s in world.stations:
		var st: Rect2i = s
		var sx := st.position.x
		var fy := st.position.y + st.size.y      # rangée du sol (béton)
		var on_quai := Vector2((sx + 6.5) * ts, (fy - 1) * ts)   # pieds sur le quai
		var on_rails := Vector2((sx + 8.5) * ts, fy * ts)        # pieds sur les rails
		_add_at(on_quai, KIND_FONCEUR, true)
		_add_at(on_rails, KIND_TIREUR, true)
		if st == guarded_st:
			_add_at(Vector2((sx + 9.5) * ts, fy * ts), KIND_LOURD, true)
			_add_at(Vector2((sx + 2.5) * ts, (fy - 1) * ts), KIND_FONCEUR, true)
	for m in world.metro_rects:
		var mr: Rect2i = m
		var floor_y := mr.position.y + mr.size.y   # rangée du sol du tunnel
		var placed := 0
		var tries := 0
		while placed < PATROL_COUNT and tries < 200:
			tries += 1
			var tx := randi_range(mr.position.x + 3, mr.position.x + mr.size.x - 4)
			if absi(tx - world.exit_col()) < 12:
				continue   # zone de répit au-dessus du Foyer
			if world.is_solid(tx, floor_y - 1) or not world.is_solid(tx, floor_y):
				continue
			var kind := KIND_FONCEUR if randf() < 0.6 else KIND_TIREUR
			_add_at(Vector2((tx + 0.5) * ts, floor_y * ts), kind, false)
			placed += 1

# p_feet : position des PIEDS (l'ennemi est posé dessus).
func _add_at(p_feet: Vector2, kind: int, guard: bool) -> void:
	var half: Vector2 = K_HALF[kind]
	var p := p_feet - Vector2(0.0, half.y)
	_add(p, kind, p if guard else null)

func _add(p: Vector2, kind: int, anchor) -> void:
	list.append({"kind": kind, "pos": p, "vel": Vector2.ZERO,
		"hp": K_HP[kind], "max_hp": K_HP[kind], "half": K_HALF[kind],
		"speed": K_SPEED[kind], "dmg": K_DMG[kind],
		"dir": (1.0 if randf() < 0.5 else -1.0),
		"on_floor": false, "blocked": false, "hit_cd": 0.0, "flash": 0.0,
		"anchor": anchor, "shoot_cd": 0.0})

# --- Dégâts reçus (le Lourd est blindé de face, vulnérable dans le dos) ------------
static func hurt(e: Dictionary, dmg: float, from_x: float) -> void:
	if int(e["kind"]) == KIND_LOURD:
		var attack_side := signf(from_x - e["pos"].x)
		dmg *= LOURD_FRONT_MULT if attack_side == signf(float(e["dir"])) else LOURD_BACK_MULT
	e["hp"] = float(e["hp"]) - dmg
	e["flash"] = 0.16

# --- Boucle -------------------------------------------------------------------
func update(delta: float) -> void:
	var ts := float(WorldGrid.TILE)
	for s in shots:
		s.t -= delta
	shots = shots.filter(func(s): return s.t > 0.0)
	for e in list:
		if e.get("raid", false):
			continue   # les assaillants de raid sont pilotés par raids.gd
		e["hit_cd"] = maxf(0.0, float(e["hit_cd"]) - delta)
		e["flash"] = maxf(0.0, float(e["flash"]) - delta)
		e["shoot_cd"] = maxf(0.0, float(e["shoot_cd"]) - delta)
		var half: Vector2 = e["half"]
		var to_player: Vector2 = hero.pos - e["pos"]
		var dist := to_player.length()
		var ec := Vector2(e["pos"].x / ts, e["pos"].y / ts)
		var chasing := dist < DETECT_RANGE * ts \
			and light.los_clear_from(ec, int(hero.pos.x / ts), int(hero.pos.y / ts))
		# Un gardien n'est pas attiré au-delà de sa laisse (il retourne à son poste).
		if chasing and e["anchor"] != null \
				and Vector2(e["anchor"]).distance_to(hero.pos) > GUARD_LEASH * ts:
			chasing = false
		var speed_mult := 1.0
		if chasing and int(e["kind"]) == KIND_TIREUR:
			# Le Tireur garde ses distances et tire à vue.
			e["dir"] = signf(to_player.x) if absf(to_player.x) > 2.0 else e["dir"]
			if dist < SHOOT_NEAR * ts:
				e["vel"].x = -signf(to_player.x) * float(e["speed"])
			elif dist > SHOOT_RANGE * ts:
				e["vel"].x = signf(to_player.x) * float(e["speed"])
			else:
				e["vel"].x = 0.0
				if float(e["shoot_cd"]) <= 0.0:
					_fire(e)
		else:
			if chasing:
				e["dir"] = signf(to_player.x) if absf(to_player.x) > 2.0 else e["dir"]
				if bool(e["blocked"]) and bool(e["on_floor"]):
					e["vel"].y = -Hero.JUMP_SPEED * 0.8   # saute l'obstacle pour poursuivre
				speed_mult = ENEMY_CHASE_MULT
			elif e["anchor"] != null and absf(float(Vector2(e["anchor"]).x) - e["pos"].x) > 3.0 * ts:
				# Gardien loin de son poste : il y retourne.
				e["dir"] = signf(Vector2(e["anchor"]).x - e["pos"].x)
			elif bool(e["on_floor"]):
				# patrouille : demi-tour au mur ou au bord du vide (ne pas tomber bêtement)
				var ahead_x: float = e["pos"].x + float(e["dir"]) * (half.x + 3.0)
				var foot_y: float = e["pos"].y + half.y + 4.0
				if bool(e["blocked"]) or not world.is_solid(int(ahead_x / ts), int(foot_y / ts)):
					e["dir"] = -float(e["dir"])
			e["vel"].x = float(e["dir"]) * float(e["speed"]) * speed_mult
		e["blocked"] = false
		_move(e, delta)
		# Contact → dégâts au héros (avec cooldown par ennemi) + petit recul
		if _aabb_overlap(hero.pos, hero.half, e["pos"], half) and float(e["hit_cd"]) <= 0.0:
			e["hit_cd"] = ENEMY_HIT_CD
			hero.damage(float(e["dmg"]))
			hero.vel.x = signf(hero.pos.x - e["pos"].x) * Hero.MOVE_SPEED

func _fire(e: Dictionary) -> void:
	e["shoot_cd"] = SHOOT_CD
	var muzzle: Vector2 = Vector2(e["pos"]) + Vector2(0.0, -4.0)
	var end := hero.pos
	if randf() < SHOOT_MISS:
		end = hero.pos + Vector2(randf_range(-14.0, 14.0), randf_range(-18.0, 8.0))
	else:
		hero.damage(float(e["dmg"]))
		hero.vel.x += signf(hero.pos.x - e["pos"].x) * 40.0
	shots.append({"a": muzzle, "b": end, "t": 0.12})

func _move(e: Dictionary, delta: float) -> void:
	var half: Vector2 = e["half"]
	e["pos"].x += e["vel"].x * delta
	var rx := _collide_axis(e["pos"], half, e["vel"], true)
	e["pos"] = rx["pos"]
	e["vel"] = rx["vel"]
	if bool(rx["blocked"]):
		e["blocked"] = true
	e["vel"].y += Hero.GRAVITY * delta
	e["vel"].y = clampf(e["vel"].y, -Hero.JUMP_SPEED, 600.0)
	e["pos"].y += e["vel"].y * delta
	var ry := _collide_axis(e["pos"], half, e["vel"], false)
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
