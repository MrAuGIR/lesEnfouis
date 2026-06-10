extends Node2D
## Les Enfouis — MVP (grey-box). Orchestration : crée les systèmes, route les
## entrées, fait tourner la boucle. La logique vit dans les modules :
##   world_grid (monde) · hero (héros) · light_field (lumière)
##   world_view (rendu) · hud (interface)

# Creusage
const DIG_TIME := 0.28           # s pour creuser 1 bloc de terre (le nerf du game feel)
const REACH := 3.5 * WorldGrid.TILE   # portée de creusage autour du héros
const DIG_TIERS := [1.0, 0.65, 0.45]  # mult. de temps (Pierre→Fer→Acier)
const TIER_NAMES := ["Pierre", "Fer", "Acier"]

var world: WorldGrid
var hero: Hero
var light: LightField
var view: WorldView
var camera: Camera2D
var hud: Hud

var base_pos := Vector2.ZERO      # point de départ / dépôt (en profondeur)
var dig_level := 0                # palier d'outil : 0 Pierre, 1 Fer, 2 Acier (économie en M1+)
var dig_target := Vector2i(-1, -1)
var dig_progress := 0.0
var won := false

func _ready() -> void:
	randomize()
	world = WorldGrid.new()
	world.generate()
	hero = Hero.new(world)
	hero.spawn()
	base_pos = hero.pos
	light = LightField.new(world, hero)
	view = WorldView.new()
	view.world = world
	view.hero = hero
	view.light = light
	view.base_pos = base_pos
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
	_update_hud()

# --- Boucle -------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	hero.move(delta, true)
	if hero.hp <= 0.0:
		_respawn()
	camera.global_position = hero.pos

func _process(delta: float) -> void:
	_update_aim()
	_handle_dig(delta)
	_check_exit()
	hud.tick(delta)
	_update_hud()
	view.tick(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_K:
			hero.damage(Hero.MAX_HP)   # mort de test

func _update_aim() -> void:
	var v := get_global_mouse_position() - hero.pos
	if v.length() > 1.0:
		hero.aim = v.normalized()

func _respawn() -> void:
	# Réapparition à la base, PV pleins (la cache de butin arrive avec le sac, M1).
	hero.pos = base_pos
	hero.vel = Vector2.ZERO
	hero.hp = Hero.MAX_HP
	hud.flash("Tu es mort... reapparition a la base.")

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

# --- Creusage -----------------------------------------------------------------
func _handle_dig(delta: float) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
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
	view.dig_target = dig_target
	view.dig_frac = dig_progress / need if dig_target.x >= 0 else 0.0

func _reset_dig() -> void:
	dig_target = Vector2i(-1, -1)
	dig_progress = 0.0
	view.dig_target = dig_target
	view.dig_frac = 0.0

func _dig_need(tx: int, ty: int) -> float:
	return DIG_TIME * DIG_TIERS[dig_level] * world.dig_mult(world.tile(tx, ty))

func _break_tile(tx: int, ty: int) -> void:
	# La récolte (sac à slots) arrive en M1 — pour l'instant on casse, c'est tout.
	world.set_tile(tx, ty, WorldGrid.EMPTY)
	view.add_flash(Vector2i(tx, ty), 0.18)

func _in_reach(tx: int, ty: int) -> bool:
	var center := Vector2(tx * WorldGrid.TILE + WorldGrid.TILE * 0.5, ty * WorldGrid.TILE + WorldGrid.TILE * 0.5)
	return hero.pos.distance_to(center) <= REACH

# --- HUD ----------------------------------------------------------------------
func _update_hud() -> void:
	var obj := "Objectif: REMONTER a la surface (barriere de roche dense = outil Fer)"
	if won:
		obj = "*** SORTI ! Tu as rejoint la surface ***"
	hud.set_stats("%s\nPV: %d/%d    Outil: %s" % [obj, int(hero.hp), int(Hero.MAX_HP), TIER_NAMES[dig_level]])
	hud.set_hints("[ZQSD/Fleches] bouger/grimper  [Espace] saut  [Clic G] creuser  [K] mort  --  M0 fondations : sac/combat/base arrivent en M1+")
