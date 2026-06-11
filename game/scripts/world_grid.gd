class_name WorldGrid
extends RefCounted
## Le monde en tuiles : génération procédurale, accès à la grille, creusage.
## Données pures — aucun rendu ici (cf. world_view.gd) ni physique (cf. hero.gd).

const TILE := 16            # taille de tuile (figée dans la DA)
const GRID_W := 240
const GRID_H := 240
const AIR_ROWS := 8         # rangées de ciel/vide en haut

# Types de tuile
const EMPTY := 0
const DIRT := 1
const ROCK := 2
const WOOD := 3    # étais de bois (structures humaines) → torches + construction/craft
const LITHIUM := 4 # minerai de lithium (dans la roche) → recharge la lampe frontale
const WALL := 5    # béton d'un bunker abandonné (creusable, sans ressource : gravats)
const HARDROCK := 6 # roche dense (barrière) : nécessite l'outil Fer (niveau >= 1)
const LADDER := 7   # échelle (construite en bois) : on grimpe dessus
const PASSERELLE := 9  # plancher de bois construit (1 bois = 1 bloc) — l'id 8 est réservé aux rations

# Bunkers abandonnés (seule source de bois : structures humaines, pas le sol)
const STRUCT_COUNT := 60
const STRUCT_MIN_W := 6
const STRUCT_MAX_W := 10
const STRUCT_MIN_H := 4
const STRUCT_MAX_H := 6

# Orientation : on PART de la profondeur (base sûre) et on REMONTE vers la surface (climax).
const BASE_DEPTH := AIR_ROWS + 58 # profondeur de la base / point de départ (zone calme)
const BAND_TOP := AIR_ROWS + 30   # barrière de roche dense ENTRE la base et la surface (gate : outil Fer)
const BAND_H := 4                 # épaisseur de la barrière (tuiles)
const EXIT_HALF := 4              # demi-largeur de la zone de SORTIE en surface (tuiles)
const GAS_FLOOR_ROW := AIR_ROWS + 20  # tuiles AU-DESSUS de cette rangée = zone de gaz toxique

const ROCK_MULT := 2.5            # la roche se creuse plus lentement
const HARD_MULT := 4.5            # creusage de la roche dense (très lent)

# Le Foyer (M2) : pièces construites librement sur une grille de MODULES au
# gabarit unique (intérieur 8x5, murs mitoyens partagés). Seul le hall de départ
# est préconstruit ; le reste se bâtit en jeu (cf. foyer.gd).
const MOD_W := 10                 # empreinte d'un module, murs compris
const MOD_H := 7
const PITCH_X := MOD_W - 1        # pas de la grille (les murs mitoyens se partagent)
const PITCH_Y := MOD_H - 1

var grid := PackedByteArray()
var surface := PackedInt32Array() # hauteur du terrain par colonne (lumière du ciel)

func generate() -> void:
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
	_place_hall()
	_place_barrier_and_exit()

func _place_barrier_and_exit() -> void:
	# Barrière de roche dense (gate : outil Fer requis) à franchir pour remonter vers la surface.
	for x in GRID_W:
		for y in range(BAND_TOP, BAND_TOP + BAND_H):
			grid[y * GRID_W + x] = HARDROCK
	# Dégage la colonne de sortie en surface (zone de SORTIE = objectif).
	var cx := exit_col()
	for xx in range(cx - EXIT_HALF, cx + EXIT_HALF + 1):
		var top := surface[clampi(xx, 0, GRID_W - 1)]
		for yy in range(top, top + 2):
			grid[yy * GRID_W + xx] = EMPTY

func _place_structures() -> void:
	# Bunkers abandonnés : petites salles en béton contenant du bois (seule source).
	for n in STRUCT_COUNT:
		var w := randi_range(STRUCT_MIN_W, STRUCT_MAX_W)
		var h := randi_range(STRUCT_MIN_H, STRUCT_MAX_H)
		var x0 := randi_range(2, GRID_W - w - 2)
		var y0 := randi_range(AIR_ROWS + 14, GRID_H - h - 2)
		_carve_structure(x0, y0, w, h)
	# (la salle de départ du proto est remplacée par le hall du Foyer — cf. _place_hall)

func _carve_structure(x0: int, y0: int, w: int, h: int) -> void:
	for y in range(y0, y0 + h):
		for x in range(x0, x0 + w):
			var border := x == x0 or x == x0 + w - 1 or y == y0 or y == y0 + h - 1
			grid[y * GRID_W + x] = WALL if border else EMPTY
	# Rangée de caisses/poutres de bois sur le sol intérieur (bois garanti)
	var floor_y := y0 + h - 2
	for x in range(x0 + 1, x0 + w - 1):
		grid[floor_y * GRID_W + x] = WOOD

func exit_col() -> int:
	return int(GRID_W * 0.5)

# --- Le Foyer (géométrie de la grille de modules, partagée avec foyer.gd) -------
func hall_origin() -> Vector2i:   # coin haut-gauche (tuiles) du module HALL de départ
	return Vector2i(exit_col() - 5, BASE_DEPTH - 5)

func _place_hall() -> void:
	# Le hall de départ : seul module préconstruit. Portes latérales au ras du
	# sol, caisses de bois (premier bois garanti). Le reste du Foyer se bâtit en
	# jeu, en mode construction (touche B) sur la grille de modules.
	var o := hall_origin()
	for y in range(o.y, o.y + MOD_H):
		for x in range(o.x, o.x + MOD_W):
			var border := x == o.x or x == o.x + MOD_W - 1 or y == o.y or y == o.y + MOD_H - 1
			grid[y * GRID_W + x] = WALL if border else EMPTY
	for dy in [1, 2]:   # portes (2 tuiles de haut, au ras du sol intérieur)
		grid[(o.y + MOD_H - 1 - dy) * GRID_W + o.x] = EMPTY
		grid[(o.y + MOD_H - 1 - dy) * GRID_W + o.x + MOD_W - 1] = EMPTY
	for dx in range(1, 4):  # caisses de bois sur le sol, côté gauche
		grid[(o.y + MOD_H - 2) * GRID_W + o.x + dx] = WOOD

# --- Accès -------------------------------------------------------------------
func tile(tx: int, ty: int) -> int:
	if tx < 0 or tx >= GRID_W or ty < 0 or ty >= GRID_H:
		return EMPTY
	return grid[ty * GRID_W + tx]

func set_tile(tx: int, ty: int, t: int) -> void:
	if tx < 0 or tx >= GRID_W or ty < 0 or ty >= GRID_H:
		return
	grid[ty * GRID_W + tx] = t

func is_solid(tx: int, ty: int) -> bool:
	if tx < 0 or tx >= GRID_W:
		return true        # murs latéraux
	if ty < 0:
		return false       # ciel
	if ty >= GRID_H:
		return true        # sol du monde
	var t := grid[ty * GRID_W + tx]
	return t != EMPTY and t != LADDER   # l'échelle se traverse

# Passerelle posée en travers d'une colonne d'échelle : dessinée DEVANT l'échelle,
# on grimpe au travers et [S] descend au travers (cf. hero.gd). Les robots, eux,
# la voient pleine (is_solid) et marchent dessus.
func is_ladder_crossing(tx: int, ty: int) -> bool:
	return tile(tx, ty) == PASSERELLE \
		and (tile(tx, ty - 1) == LADDER or tile(tx, ty + 1) == LADDER)

func is_diggable(tx: int, ty: int) -> bool:
	var t := tile(tx, ty)
	return t == DIRT or t == ROCK or t == WOOD or t == LITHIUM or t == WALL \
		or t == HARDROCK or t == PASSERELLE

func dig_mult(t: int) -> float:
	if t == HARDROCK:
		return HARD_MULT
	if t == ROCK or t == LITHIUM or t == WALL:
		return ROCK_MULT
	return 1.0
