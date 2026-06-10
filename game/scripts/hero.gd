class_name Hero
extends RefCounted
## Le héros : état (position, vitesse, PV) + physique (déplacement, collision
## AABB-vs-grille, échelles, dégâts de chute). Lit les entrées clavier directement
## (touches PHYSIQUES → marche en ZQSD/AZERTY comme en WASD/QWERTY).

const MOVE_SPEED := 98.0    # px/s
const GRAVITY := 900.0
const JUMP_SPEED := 300.0
const CLIMB_SPEED := 85.0   # vitesse de montée/descente sur une échelle
const MAX_HP := 100.0
const FALL_SAFE := 380.0    # vitesse de chute sans dégât (px/s)
const FALL_DMG := 0.25      # dégâts par unité de vitesse au-delà du seuil

# Lampe frontale : carburant en secondes, rechargé au lithium (touche R).
const LAMP_AUTONOMY := 240.0     # secondes d'autonomie pleine de la lampe
const LAMP_LOW := 20.0           # sous ce reste (s), la lampe faiblit
const LAMP_REFILL := 90.0        # secondes rendues par unité de lithium

# Gaz toxique de surface : dégâts continus (DoT), immunité tant que l'éclairage
# anti-pollution est activé ET qu'il reste des cartouches (charges limitées).
const GAS_DPS := 9.0             # PV/s perdus dans le gaz sans protection
const ANTIPOL_PER_CHARGE := 25.0 # secondes de protection par cartouche craftée

var world: WorldGrid
var pos := Vector2.ZERO           # centre du héros (monde)
var vel := Vector2.ZERO
var half := Vector2(6, 14)        # demi-taille (~12x28 px ≈ 1,75 tuile)
var on_floor := false
var aim := Vector2.RIGHT          # direction du regard / de la lampe (vers la souris)
var hp := MAX_HP
var lamp_fuel := LAMP_AUTONOMY    # carburant restant (secondes)
var lamp_factor := 1.0            # 0..1 : intensité de la lampe selon le carburant
var antipol_fuel := 0.0           # secondes de protection anti-gaz restantes
var antipol_on := false           # éclairage anti-pollution activé ?
var was_in_gas := false           # pour signaler l'entrée dans la zone de gaz

func _init(w: WorldGrid) -> void:
	world = w

func spawn() -> void:
	# On démarre EN PROFONDEUR, posé sur le plancher de la base (pieds sur le bois en
	# BASE_DEPTH+1, tête dégagée du plafond pour éviter toute éjection au spawn).
	var cx := world.exit_col()
	pos = Vector2(cx * WorldGrid.TILE + WorldGrid.TILE * 0.5,
		(WorldGrid.BASE_DEPTH + 1) * WorldGrid.TILE - half.y)
	vel = Vector2.ZERO
	hp = MAX_HP

func damage(amount: float) -> void:
	hp = maxf(0.0, hp - amount)

func deplete_lamp(delta: float) -> void:
	lamp_fuel = maxf(0.0, lamp_fuel - delta)
	lamp_factor = clampf(lamp_fuel / LAMP_LOW, 0.0, 1.0)

# --- Gaz toxique de surface ---------------------------------------------------
func in_gas() -> bool:
	return int(floor(pos.y / WorldGrid.TILE)) < WorldGrid.GAS_FLOOR_ROW

func antipol_charges() -> int:
	return int(ceil(antipol_fuel / ANTIPOL_PER_CHARGE))

# Renvoie le message à afficher ("" si rien à signaler).
func toggle_antipol() -> String:
	if antipol_fuel <= 0.0:
		antipol_on = false
		return "Aucune cartouche anti-gaz (craft a l'atelier : touche 4)"
	antipol_on = not antipol_on
	return "Anti-pollution : %s" % ("ACTIVE" if antipol_on else "coupe")

# Avance le gaz d'un pas. Renvoie le message à afficher ("" si rien à signaler).
func update_gas(delta: float) -> String:
	var msg := ""
	var inside := in_gas()
	var protected := false
	if inside and antipol_on and antipol_fuel > 0.0:
		antipol_fuel = maxf(0.0, antipol_fuel - delta)
		protected = true
		if antipol_fuel <= 0.0:
			antipol_on = false
			msg = "Cartouches anti-gaz EPUISEES !"
	if inside and not protected:
		damage(GAS_DPS * delta)
	if inside and not was_in_gas:
		if protected:
			msg = "Zone de gaz toxique : protection anti-pollution active"
		else:
			msg = "!! GAZ TOXIQUE !! Active l'anti-pollution (M) ou redescends"
	was_in_gas = inside
	return msg

# Avance d'un pas de physique. controls=false fige les commandes (inventaire ouvert…).
func move(delta: float, controls: bool) -> void:
	var dir := 0.0
	if controls and (Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)):
		dir -= 1.0
	if controls and (Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)):
		dir += 1.0
	vel.x = dir * MOVE_SPEED

	if on_ladder():
		var climb := 0.0
		if controls and (Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)):
			climb -= 1.0
		if controls and (Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)):
			climb += 1.0
		vel.y = climb * CLIMB_SPEED
		if controls and Input.is_physical_key_pressed(KEY_SPACE):
			vel.y = -JUMP_SPEED   # sauter pour quitter l'échelle
	else:
		if controls and on_floor and (Input.is_physical_key_pressed(KEY_W) \
				or Input.is_physical_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP)):
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
		damage((vy - FALL_SAFE) * FALL_DMG)

func on_ladder() -> bool:
	var x0 := int((pos.x - half.x + 2) / WorldGrid.TILE)
	var x1 := int((pos.x + half.x - 2) / WorldGrid.TILE)
	var y0 := int((pos.y - half.y) / WorldGrid.TILE)
	var y1 := int((pos.y + half.y) / WorldGrid.TILE)
	for cy in range(y0, y1 + 1):
		for cx in range(x0, x1 + 1):
			if world.tile(cx, cy) == WorldGrid.LADDER:
				return true
	return false

func _resolve_axis(is_x: bool) -> bool:
	var landed := false
	var ts := float(WorldGrid.TILE)
	var min_tx := int(floor((pos.x - half.x) / ts))
	var max_tx := int(floor((pos.x + half.x - 0.001) / ts))
	var min_ty := int(floor((pos.y - half.y) / ts))
	var max_ty := int(floor((pos.y + half.y - 0.001) / ts))
	for ty in range(min_ty, max_ty + 1):
		for tx in range(min_tx, max_tx + 1):
			if not world.is_solid(tx, ty):
				continue
			# Bornes du héros (recalculées car pos peut bouger)
			var l := pos.x - half.x
			var r := pos.x + half.x
			var t := pos.y - half.y
			var b := pos.y + half.y
			var tl := tx * ts
			var tr := tl + ts
			var tt := ty * ts
			var tb := tt + ts
			if l < tr and r > tl and t < tb and b > tt:
				# Direction d'éjection = pénétration minimale (géométrie), PAS le signe
				# de la vitesse : sinon une tête plantée dans un plafond pendant qu'on
				# tombe (vel.y>0) éjectait vers le HAUT = tunnelisation à travers le solide.
				if is_x:
					var pen_left := r - tl    # profondeur d'enfoncement par la gauche
					var pen_right := tr - l   # ... par la droite
					if pen_left <= pen_right:
						pos.x = tl - half.x   # repoussé vers la gauche (mur à droite)
						if vel.x > 0.0:
							vel.x = 0.0
					else:
						pos.x = tr + half.x   # repoussé vers la droite (mur à gauche)
						if vel.x < 0.0:
							vel.x = 0.0
				else:
					var pen_up := b - tt      # pieds enfoncés dans une tuile en dessous
					var pen_down := tb - t    # tête enfoncée dans une tuile au-dessus
					if pen_up <= pen_down:
						pos.y = tt - half.y   # posé sur la tuile (sol)
						if vel.y > 0.0:
							vel.y = 0.0
						landed = true
					else:
						pos.y = tb + half.y   # repoussé sous la tuile (plafond)
						if vel.y < 0.0:
							vel.y = 0.0
	return landed
