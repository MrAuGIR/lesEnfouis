class_name BossFight
extends RefCounted
## Le Roi des Galeries (M5) : chef de la faction des pilleurs des tunnels. Il
## trône dans un grand TERMINAL scellé au bout de l'axe de métro inférieur.
## [E] sur les portes : elles s'ouvrent... puis se REFERMENT derrière le héros —
## le combat va au bout. Pattern (GDD 03, interview 2026-06-12) : charge
## télégraphée en ligne droite (esquive verticale : quai, estrade) + frappe au
## sol qui fait pleuvoir des GRAVATS sur zones télégraphées ; vagues de SBIRES
## aux paliers de PV (75/50/25 %) ; ENRAGE à 50 % (plus vite, plus fort, jets
## de VAPEUR périodiques au sol). Vaincu, il lâche la CHARGE DE PERÇAGE — le
## seul moyen d'ouvrir la barrière de roche dense — et sa faction décapitée
## lance des raids réduits (raids.subdued). Jamais de revanche : mort = mort.
## Le Roi vit dans crew.list (flag "boss" : armes du héros et rendu inchangés)
## mais est piloté ICI ; ses sbires sont des pilleurs normaux ancrés au centre
## de l'arène (flag "boss_minion", dispersés à la mort du Roi).

const ST_SEALED := 0          # portes closes, le Roi attend sur son trône
const ST_OPEN := 1            # portes ouvertes : entrer... ou renoncer
const ST_FIGHT := 2
const ST_DEAD := 3

const OPEN_TIME := 12.0       # s avant que les portes ne se referment toutes seules
const STALK_MIN := 1.1        # s de marche d'approche entre deux charges
const STALK_MAX := 2.0
const TELEGRAPH_TIME := 0.8   # s d'arrêt télégraphié avant la charge
const TELEGRAPH_ENRAGE := 0.55
const CHARGE_SPEED := 215.0   # px/s pendant la charge
const CHARGE_DMG := 26.0      # contact pendant la charge (sinon dmg du dict)
const CHARGE_TIME_MAX := 1.6  # s : garde-fou si rien n'arrête la charge
const SLAM_RANGE := 3.0       # tuiles : onde de la frappe au sol
const SLAM_DMG := 14.0
const SLAM_RECOVER := 0.9     # s de récupération après la frappe (fenêtre de dégâts)
const DEBRIS_COUNT := 3       # gravats par frappe (+1 en enrage)
const DEBRIS_WARN := 1.0      # s d'ombre télégraphiée avant la chute
const DEBRIS_SPEED := 250.0   # px/s de chute
const DEBRIS_DMG := 16.0
const DEBRIS_HALF := Vector2(6.0, 5.0)
const WAVE_AT := [0.75, 0.5, 0.25]  # paliers de PV → vague de sbires
const WAVE_SIZE := 3          # 2 fonceurs + 1 tireur
const ENRAGE_AT := 0.5        # fraction de PV de la phase 2
const ENRAGE_SPEED := 1.35
const ENRAGE_DMG := 1.25
const INVOKE_TIME := 0.6      # s : durée de la pose d'invocation (anim) sur appel de sbires
const VENT_PERIOD := 3.4      # s du cycle d'un jet de vapeur (enrage)
const VENT_WARN := 0.8        # s de sifflement avant le jet
const VENT_ON := 1.0          # s de jet actif
const VENT_DPS := 20.0        # PV/s dans le jet
const VENT_H := 3             # hauteur du jet (tuiles)
const DOOR_RANGE := 4.0       # tuiles : portée du [E] sur les portes
const PICKUP_RANGE := 1.5     # tuiles : ramassage de la charge de perçage

const P_STALK := 0
const P_TELEGRAPH := 1
const P_CHARGE := 2
const P_RECOVER := 3

var world: WorldGrid
var hero: Hero
var crew: EnemyCrew
var raids: Raids
var mark_dirty := Callable()  # branché par main : view.mark_dirty (portes = occulteurs)

var state := ST_SEALED
var boss = null               # le dict du Roi dans crew.list (null une fois mort)
var open_t := 0.0
var phase := P_STALK
var phase_t := 0.0
var charge_dir := 1.0
var enraged := false
var waves_done := 0
var slam_t := 0.0             # feedback de l'onde (lu par marker_view)
var slam_pos := Vector2.ZERO
var debris := []              # {"pos": Vector2, "warn": float} — chute après l'ombre
var vents := []               # {"cell": Vector2i, "t": float} — cycle local (enrage)
var charge_pos := Vector2.ZERO  # où la charge de perçage est tombée
var charge_taken := false
var invoke_t := 0.0           # > 0 : le Roi tient sa pose d'invocation (rendu, world_view)

func _init(w: WorldGrid, h: Hero, c: EnemyCrew, r: Raids) -> void:
	world = w
	hero = h
	crew = c
	raids = r
	_spawn_boss()
	_make_vents()

func _spawn_boss() -> void:
	var half: Vector2 = EnemyCrew.K_HALF[EnemyCrew.KIND_BOSS]
	crew.list.append({"kind": EnemyCrew.KIND_BOSS, "pos": _feet_pos(world.boss_spawn, half),
		"vel": Vector2.ZERO, "hp": EnemyCrew.K_HP[EnemyCrew.KIND_BOSS],
		"max_hp": EnemyCrew.K_HP[EnemyCrew.KIND_BOSS], "half": half,
		"speed": EnemyCrew.K_SPEED[EnemyCrew.KIND_BOSS], "dmg": EnemyCrew.K_DMG[EnemyCrew.KIND_BOSS],
		"dir": -1.0, "on_floor": true, "blocked": false, "hit_cd": 0.0, "flash": 0.0,
		"anchor": null, "shoot_cd": 0.0, "boss": true})
	boss = crew.list[crew.list.size() - 1]

func _make_vents() -> void:
	# Trois conduites au sol, en quarts de l'arène (sur le quai : posées dessus).
	var a := world.boss_arena
	for i in 3:
		var x := a.position.x + (i + 1) * a.size.x / 4
		var fy := a.position.y + a.size.y - 1
		while world.is_solid(x, fy) and fy > a.position.y:
			fy -= 1
		vents.append({"cell": Vector2i(x, fy), "t": float(i) * 1.2})

static func _feet_pos(cell: Vector2i, half: Vector2) -> Vector2:
	var ts := float(WorldGrid.TILE)
	return Vector2((cell.x + 0.5) * ts, (cell.y + 1) * ts - half.y)

# --- Portes ([E] depuis main._interact) ---------------------------------------------
func door_center() -> Vector2:
	var ts := float(WorldGrid.TILE)
	var s := Vector2.ZERO
	for c in world.boss_door_cells:
		s += Vector2((c.x + 0.5) * ts, (c.y + 0.5) * ts)
	return s / float(world.boss_door_cells.size())

func door_near(p: Vector2) -> bool:
	return (state == ST_SEALED or state == ST_OPEN) \
		and p.distance_to(door_center()) <= DOOR_RANGE * WorldGrid.TILE

func try_open() -> String:
	if state == ST_OPEN:
		return "Les portes sont ouvertes... Le Roi des Galeries t'attend au fond."
	state = ST_OPEN
	open_t = OPEN_TIME
	_set_door(true)
	return "Les portes du terminal s'ouvrent en grincant... ENTRE — elles se REFERMERONT derriere toi !"

func _set_door(open: bool) -> void:
	for c in world.boss_door_cells:
		world.set_tile(c.x, c.y, WorldGrid.EMPTY if open else WorldGrid.BOSS_DOOR)
	if mark_dirty.is_valid():
		mark_dirty.call()

func fighting() -> bool:
	return state == ST_FIGHT

func _hero_inside() -> bool:
	# Bien À L'INTÉRIEUR (1,5 tuile passé les portes : on ne referme pas sur lui).
	var ts := float(WorldGrid.TILE)
	var a := world.boss_arena
	var r := Rect2(Vector2(a.position) * ts, Vector2(a.size) * ts)
	return r.has_point(hero.pos) and hero.pos.x >= (a.position.x + 1.5) * ts

# --- Boucle (appelée par main, figée quand un écran est ouvert) -----------------------
func update(delta: float) -> Array:
	var msgs := []
	slam_t = maxf(0.0, slam_t - delta)
	match state:
		ST_SEALED:
			# Entré en creusant un mur, ou blessé à travers une brèche : le combat
			# commence quand même (portes closes — elles le sont déjà).
			if _hero_inside() or (boss != null and float(boss["hp"]) < float(boss["max_hp"])):
				state = ST_FIGHT
				phase = P_STALK
				phase_t = 1.2
				msgs.append("!! Tu as force l'antre : LE ROI DES GALERIES se dresse !!")
		ST_OPEN:
			open_t -= delta
			if _hero_inside():
				_set_door(false)
				state = ST_FIGHT
				phase = P_STALK
				phase_t = 1.2
				msgs.append("!! Les portes se REFERMENT ! LE ROI DES GALERIES se dresse !!")
			elif open_t <= 0.0:
				_set_door(false)
				state = ST_SEALED
		ST_FIGHT:
			_run_fight(delta, msgs)
		ST_DEAD:
			_pickup_charge(msgs)
	return msgs

func _run_fight(delta: float, msgs: Array) -> void:
	if boss == null:
		return
	if float(boss["hp"]) <= 0.0:
		_win(msgs)
		return
	var frac := float(boss["hp"]) / float(boss["max_hp"])
	if not enraged and frac <= ENRAGE_AT:
		enraged = true
		msgs.append("!! LE ROI ENTRE EN RAGE — les conduites de vapeur LACHENT !!")
	if waves_done < WAVE_AT.size() and frac <= float(WAVE_AT[waves_done]):
		waves_done += 1
		_call_minions()
		invoke_t = INVOKE_TIME
		msgs.append("Le Roi appelle ses sbires : %d pilleurs debarquent !" % WAVE_SIZE)
	invoke_t = maxf(0.0, invoke_t - delta)
	boss["hit_cd"] = maxf(0.0, float(boss["hit_cd"]) - delta)
	boss["flash"] = maxf(0.0, float(boss["flash"]) - delta)
	phase_t -= delta
	var spd_mult := ENRAGE_SPEED if enraged else 1.0
	match phase:
		P_STALK:
			var dx := hero.pos.x - float(boss["pos"].x)
			if absf(dx) > 4.0:
				boss["dir"] = signf(dx)
			boss["vel"].x = float(boss["dir"]) * float(boss["speed"]) * spd_mult
			if bool(boss["blocked"]) and bool(boss["on_floor"]):
				boss["vel"].y = -Hero.JUMP_SPEED * 0.7   # enjambe quai/estrade
			if phase_t <= 0.0:
				phase = P_TELEGRAPH
				phase_t = TELEGRAPH_ENRAGE if enraged else TELEGRAPH_TIME
				charge_dir = signf(hero.pos.x - float(boss["pos"].x))
				if charge_dir == 0.0:
					charge_dir = float(boss["dir"])
		P_TELEGRAPH:
			boss["vel"].x = 0.0
			boss["dir"] = charge_dir
			if phase_t <= 0.0:
				phase = P_CHARGE
				phase_t = CHARGE_TIME_MAX
		P_CHARGE:
			boss["vel"].x = charge_dir * CHARGE_SPEED * spd_mult
			var passed := (hero.pos.x - float(boss["pos"].x)) * charge_dir < -28.0
			if bool(boss["blocked"]) or passed or phase_t <= 0.0:
				_slam()
		P_RECOVER:
			boss["vel"].x = 0.0
			if phase_t <= 0.0:
				phase = P_STALK
				phase_t = randf_range(STALK_MIN, STALK_MAX)
	boss["blocked"] = false
	crew._move(boss, delta)
	_contact_hero()
	_run_debris(delta)
	if enraged:
		_run_vents(delta)

# --- Frappe au sol + gravats ---------------------------------------------------------
func _slam() -> void:
	phase = P_RECOVER
	phase_t = SLAM_RECOVER
	slam_t = 0.35
	slam_pos = Vector2(boss["pos"]) + Vector2(0.0, float(Vector2(boss["half"]).y))
	boss["vel"].x = 0.0
	var ts := float(WorldGrid.TILE)
	# Onde courte au ras du sol : touche le héros proche (pas s'il a pris de la hauteur)
	var d := hero.pos - Vector2(boss["pos"])
	if absf(d.x) <= SLAM_RANGE * ts and d.y > -1.2 * ts and d.y < 2.0 * ts:
		hero.damage(SLAM_DMG * (ENRAGE_DMG if enraged else 1.0))
		hero.vel.x = signf(d.x if d.x != 0.0 else 1.0) * Hero.MOVE_SPEED * 1.6
		hero.vel.y = -120.0
	# ... et la voûte lâche : gravats télégraphiés (le premier vise le héros)
	var a := world.boss_arena
	var n := DEBRIS_COUNT + (1 if enraged else 0)
	for i in n:
		var cx := randi_range(a.position.x + 1, a.position.x + a.size.x - 2)
		if i == 0:
			cx = clampi(int(hero.pos.x / ts), a.position.x + 1, a.position.x + a.size.x - 2)
		debris.append({"pos": Vector2((cx + 0.5) * ts, float(a.position.y) * ts + 6.0),
			"warn": DEBRIS_WARN})

func _run_debris(delta: float) -> void:
	var ts := float(WorldGrid.TILE)
	var keep := []
	for d in debris:
		if float(d["warn"]) > 0.0:
			d["warn"] = float(d["warn"]) - delta
			keep.append(d)
			continue
		d["pos"] = Vector2(d["pos"]) + Vector2(0.0, DEBRIS_SPEED * delta)
		var p: Vector2 = d["pos"]
		if absf(p.x - hero.pos.x) < DEBRIS_HALF.x + hero.half.x \
				and absf(p.y - hero.pos.y) < DEBRIS_HALF.y + hero.half.y:
			hero.damage(DEBRIS_DMG)   # le gravat éclate sur le héros
			continue
		if world.is_solid(int(p.x / ts), int((p.y + DEBRIS_HALF.y) / ts)):
			continue                  # éclate sur le premier appui (sol, quai)
		keep.append(d)
	debris = keep

# --- Jets de vapeur (enrage) -----------------------------------------------------------
func vent_phase(v: Dictionary) -> int:   # 0 = repos, 1 = sifflement, 2 = jet
	var t := float(v["t"])
	if t < VENT_PERIOD - VENT_WARN - VENT_ON:
		return 0
	if t < VENT_PERIOD - VENT_ON:
		return 1
	return 2

func _run_vents(delta: float) -> void:
	var ts := float(WorldGrid.TILE)
	for v in vents:
		v["t"] = fmod(float(v["t"]) + delta, VENT_PERIOD)
		if vent_phase(v) != 2:
			continue
		var c: Vector2i = v["cell"]
		var r := Rect2(c.x * ts, float(c.y - VENT_H + 1) * ts, ts, float(VENT_H) * ts)
		var h := Rect2(hero.pos - hero.half, hero.half * 2.0)
		if r.intersects(h):
			hero.damage(VENT_DPS * delta)

# --- Contact & sbires ------------------------------------------------------------------
func _contact_hero() -> void:
	if float(boss["hit_cd"]) > 0.0:
		return
	if not EnemyCrew._aabb_overlap(hero.pos, hero.half, Vector2(boss["pos"]), Vector2(boss["half"])):
		return
	boss["hit_cd"] = EnemyCrew.ENEMY_HIT_CD
	var dmg := CHARGE_DMG if phase == P_CHARGE else float(boss["dmg"])
	if enraged:
		dmg *= ENRAGE_DMG
	hero.damage(dmg)
	hero.vel.x = signf(hero.pos.x - float(boss["pos"].x)) * Hero.MOVE_SPEED * (2.0 if phase == P_CHARGE else 1.0)
	hero.vel.y = -100.0

func _call_minions() -> void:
	# Pilleurs normaux (IA d'enemy_crew), ancrés au CENTRE de l'arène : la laisse
	# des gardiens les y maintient. Dispersés à la mort du Roi.
	var ts := float(WorldGrid.TILE)
	var a := world.boss_arena
	var fy := a.position.y + a.size.y      # rangée du sol (béton)
	var anchor := Vector2((a.position.x + a.size.x * 0.5) * ts, (fy - 1) * ts)
	var spots := [a.position.x + 2, a.position.x + a.size.x - 3, a.position.x + a.size.x / 2]
	for i in WAVE_SIZE:
		var kind := EnemyCrew.KIND_TIREUR if i == WAVE_SIZE - 1 else EnemyCrew.KIND_FONCEUR
		var x := int(spots[i % spots.size()])
		var feet := fy
		while world.is_solid(x, feet - 1) and feet > a.position.y:
			feet -= 1   # par-dessus quai/estrade
		var half: Vector2 = EnemyCrew.K_HALF[kind]
		crew.list.append({"kind": kind, "pos": Vector2((x + 0.5) * ts, feet * ts - half.y),
			"vel": Vector2.ZERO, "hp": EnemyCrew.K_HP[kind], "max_hp": EnemyCrew.K_HP[kind],
			"half": half, "speed": EnemyCrew.K_SPEED[kind], "dmg": EnemyCrew.K_DMG[kind],
			"dir": 1.0, "on_floor": true, "blocked": false, "hit_cd": 0.0, "flash": 0.0,
			"anchor": anchor, "shoot_cd": 0.0, "boss_minion": true})

func _scatter_minions() -> void:
	crew.list = crew.list.filter(func(e): return not e.get("boss_minion", false))

# --- Victoire / défaite ------------------------------------------------------------------
func _win(msgs: Array) -> void:
	state = ST_DEAD
	charge_pos = Vector2(boss["pos"])
	crew.add_corpse(boss, "boss_roi")   # mise en scène de la chute (anim mort)
	crew.list.erase(boss)
	boss = null
	debris = []
	_scatter_minions()
	_set_door(true)   # les portes s'ouvrent pour de bon
	raids.subdued = true
	msgs.append("*** LE ROI DES GALERIES EST TOMBE ! Il lache une CHARGE DE PERCAGE. ***")
	msgs.append("Sa faction se disperse : les raids seront plus rares et plus faibles.")

func _pickup_charge(msgs: Array) -> void:
	if charge_taken:
		return
	if hero.pos.distance_to(charge_pos) <= PICKUP_RANGE * WorldGrid.TILE:
		charge_taken = true
		msgs.append("CHARGE DE PERCAGE recuperee ! Pose-la SOUS la barriere de roche dense ([E]) et REMONTE.")

# Mort du héros pendant l'assaut : le Roi regagne son trône, l'arène se rescelle.
func notify_hero_death() -> void:
	if state != ST_FIGHT and state != ST_OPEN:
		return
	state = ST_SEALED
	_set_door(false)
	debris = []
	_scatter_minions()
	enraged = false
	waves_done = 0
	phase = P_STALK
	phase_t = 1.2
	invoke_t = 0.0
	if boss != null:
		boss["hp"] = boss["max_hp"]
		boss["pos"] = _feet_pos(world.boss_spawn, Vector2(boss["half"]))
		boss["vel"] = Vector2.ZERO

# --- Animation (lue par world_view) ----------------------------------------------------
# Nom de l'anim courante du Roi selon sa phase de combat (cf. SpriteDB "boss_roi").
func anim_name() -> String:
	if boss == null:
		return "idle"
	if float(boss["flash"]) > 0.0:
		return "touche"
	if invoke_t > 0.0:
		return "invocation"
	match phase:
		P_TELEGRAPH: return "telegraphe"
		P_CHARGE: return "charge_enrage" if enraged else "charge"
		P_RECOVER: return "slam"
		_:
			if absf(float(boss["vel"].x)) > 4.0:
				return "marche"
			return "idle_enrage" if enraged else "idle"

# Âge (s) dans l'anim one-shot courante (slam/invocation) — 0 pour les boucles.
func anim_age() -> float:
	if invoke_t > 0.0:
		return INVOKE_TIME - invoke_t
	if phase == P_RECOVER:
		return SLAM_RECOVER - phase_t
	return 0.0
