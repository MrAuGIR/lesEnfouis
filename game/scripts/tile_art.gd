class_name TileArt
extends RefCounted
## Génère par CODE les textures pixel-art 16×16 des blocs du monde (lot « tileset »).
## Conforme à la bible visuelle (tuiles 16 px). Zéro fichier externe : chaque texture
## est authorée pixel par pixel via Image, en mémoire, puis mise en cache. Partagé par
## world_view.gd (blocs révélés) et marker_view.gd (faces éclairées) → rendu cohérent.
## Le bruit est DÉTERMINISTE (hash sur les coordonnées) : texture stable, pas de
## scintillement, et le résultat est le même à chaque lancement.
##
## Lisibilité daltonien : les minerais se distinguent par la FORME, pas que la couleur —
## lithium = cristaux ANGULAIRES, fer = nodules RONDS.

const S := 16   # côté de la tuile (= WorldGrid.TILE)

static var _cache: Dictionary = {}

# Texture du type de tuile t, ou null si non géré (l'appelant retombe sur l'aplat).
static func tex(t: int) -> Texture2D:
	if _cache.has(t):
		return _cache[t]
	var img := _build(t)
	var tx: Texture2D = ImageTexture.create_from_image(img) if img != null else null
	_cache[t] = tx
	return tx

# --- Décor de fond (parallaxe) -----------------------------------------------
# Deux couches en retrait derrière les tuiles : paroi rocheuse (loin) + silhouettes
# d'infrastructure (étais, traverses, tuyau). Désaturées/sombres (bible) : révélées
# dimensions par la lampe comme le reste. Tuilées par world_view avec parallaxe.
static var _bg_wall: Texture2D
static var _bg_struct: Texture2D
static var _bg_base: Texture2D

static func bg_wall() -> Texture2D:
	if _bg_wall == null:
		_bg_wall = ImageTexture.create_from_image(_build_bg_wall())
	return _bg_wall

static func bg_struct() -> Texture2D:
	if _bg_struct == null:
		_bg_struct = ImageTexture.create_from_image(_build_bg_struct())
	return _bg_struct

# Mur intérieur du Foyer : panneaux finis, teinte chaude (le havre), rivets.
static func bg_base() -> Texture2D:
	if _bg_base == null:
		_bg_base = ImageTexture.create_from_image(_build_bg_base())
	return _bg_base

static func _build_bg_base() -> Image:
	# 64×64, PANNEAUX VERTICAUX (pas de grille de carrés) : seams verticaux irréguliers,
	# pas de joint horizontal, rivets épars → lecture « mur continu », pas « blocs collés ».
	var w := 64
	var im := Image.create(w, w, false, Image.FORMAT_RGBA8)
	var base := Color(0.22, 0.19, 0.16)            # gris-brun chaud, désaturé (le havre)
	for y in w:
		for x in w:
			im.set_pixel(x, y, _shade(base, (_h(x, y, 95) - 0.5) * 0.05))
	var seams := [0, 19, 38, 51]                   # largeurs de panneaux irrégulières
	for sx: int in seams:
		for y in w:
			im.set_pixel(sx, y, _shade(base, -0.07))               # creux du joint
			im.set_pixel((sx + 1) % w, y, _shade(base, 0.05))      # arête éclairée
		im.set_pixel((sx + 2) % w, 5, _shade(base, 0.13))          # rivet haut, épars
		im.set_pixel((sx + 2) % w, w - 6, _shade(base, 0.13))      # rivet bas
	for k in 5:                                     # éraflures horizontales discrètes
		var sy := int(_h(k, 0, 96) * (w - 4)) + 2
		var sx0 := int(_h(0, k, 97) * (w - 18))
		for x in range(sx0, sx0 + 12):
			im.set_pixel(x, sy, _shade(im.get_pixel(x, sy), -0.03))
	return im

# Paroi du fond : roche sombre désaturée. 48×48 (période de répétition longue) ;
# strates rares et irrégulières (pas de bandes régulières → pas d'effet « blocs collés »).
static func _build_bg_wall() -> Image:
	var w := 48
	var im := Image.create(w, w, false, Image.FORMAT_RGBA8)
	var base := Color(0.13, 0.14, 0.17)
	for y in w:
		for x in w:
			var c := _shade(base, (_h(x, y, 91) - 0.5) * 0.09)
			if _h(x, y, 94) > 0.86:      # renfoncements sombres épars
				c = _shade(c, -0.05)
			im.set_pixel(x, y, c)
	for sy: int in [13, 34]:             # 2 strates discrètes, à des hauteurs irrégulières
		for x in w:
			if _h(x, sy, 98) > 0.25:     # discontinues (pas une ligne pleine)
				im.set_pixel(x, sy, _shade(im.get_pixel(x, sy), -0.045))
	return im

# Silhouettes d'infrastructure (transparent ailleurs) : étai vertical + traverse
# + tuyau. Tuilé → colonnes de soutènement récurrentes. Garde l'alpha (≠ _shade).
static func _build_bg_struct() -> Image:
	var w := 48
	var h := 64
	var im := Image.create(w, h, false, Image.FORMAT_RGBA8)
	im.fill(Color(0, 0, 0, 0))
	var wood := Color(0.17, 0.14, 0.10, 0.88)
	var wood_d := Color(0.10, 0.08, 0.05, 0.90)
	var metal := Color(0.16, 0.17, 0.20, 0.85)
	for y in h:                          # étai vertical (x 21..26) + arêtes sombres
		for x in range(21, 27):
			im.set_pixel(x, y, wood)
		im.set_pixel(21, y, wood_d)
		im.set_pixel(26, y, wood_d)
		for x in range(6, 9):            # tuyau métallique (x 6..8)
			im.set_pixel(x, y, metal)
	for x in range(14, 34):              # traverse courte (≠ pleine largeur → pas de grille)
		for y in range(10, 15):
			im.set_pixel(x, y, wood)
		im.set_pixel(x, 10, wood_d)
		im.set_pixel(x, 14, wood_d)
	for d in 6:                          # jambes de force diagonales (look charpente)
		im.set_pixel(20 - d, 15 + d, wood)
		im.set_pixel(27 + d, 15 + d, wood)
	for bx in [18, 24, 30]:              # boulons sur la traverse
		im.set_pixel(bx, 12, Color(0.30, 0.26, 0.18, 0.95))
	for y in range(30, 33):              # joint du tuyau
		for x in range(5, 10):
			im.set_pixel(x, y, Color(0.22, 0.23, 0.26, 0.9))
	return im

# --- Outils ------------------------------------------------------------------
# Hash déterministe 0..1 à partir de (x, y) et d'une graine (canal de bruit).
static func _h(x: int, y: int, s: int) -> float:
	var n := ((x + 1) * 73856093) ^ ((y + 1) * 19349663) ^ ((s + 7) * 83492791)
	n = absi(n)
	n = (n * 1103515245 + 12345) & 0x7fffffff
	return float((n >> 8) & 0xffff) / 65535.0

static func _shade(c: Color, d: float) -> Color:
	return Color(clampf(c.r + d, 0.0, 1.0), clampf(c.g + d, 0.0, 1.0), clampf(c.b + d, 0.0, 1.0), 1.0)

static func _img() -> Image:
	return Image.create(S, S, false, Image.FORMAT_RGBA8)

# Remplissage granuleux : base + grain déterministe (contraste = amplitude).
static func _fill_noisy(img: Image, base: Color, contrast: float, seed: int) -> void:
	for y in S:
		for x in S:
			var n := _h(x, y, seed)
			img.set_pixel(x, y, _shade(base, (n - 0.5) * contrast))

# Biseau : bords haut/gauche éclaircis, bas/droite assombris → volume léger +
# séparation nette des tuiles (un cadre = repère de forme, utile en daltonisme).
static func _bevel(img: Image, light: float, dark: float) -> void:
	for i in S:
		img.set_pixel(i, 0, _shade(img.get_pixel(i, 0), light))         # haut
		img.set_pixel(0, i, _shade(img.get_pixel(0, i), light))         # gauche
		img.set_pixel(i, S - 1, _shade(img.get_pixel(i, S - 1), dark))  # bas
		img.set_pixel(S - 1, i, _shade(img.get_pixel(S - 1, i), dark))  # droite

# Cadre 1 px tout autour (lecture « objet/structure », pas un bloc naturel).
static func _frame(img: Image, c: Color) -> void:
	for i in S:
		img.set_pixel(i, 0, c)
		img.set_pixel(i, S - 1, c)
		img.set_pixel(0, i, c)
		img.set_pixel(S - 1, i, c)

# Cristal angulaire (losange) — signature visuelle du lithium.
static func _crystal(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if absi(dx) + absi(dy) > r:
				continue
			var px := cx + dx
			var py := cy + dy
			if px < 1 or px > S - 2 or py < 1 or py > S - 2:
				continue
			# cœur plus clair, arête plus sombre → facette
			var edge := absi(dx) + absi(dy) >= r - 1
			img.set_pixel(px, py, _shade(c, -0.18) if edge else _shade(c, 0.12))

# Nodule rond — signature visuelle du fer (≠ cristal angulaire).
static func _nodule(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if dx * dx + dy * dy > r * r:
				continue
			var px := cx + dx
			var py := cy + dy
			if px < 1 or px > S - 2 or py < 1 or py > S - 2:
				continue
			# reflet en haut-gauche → rondeur
			var hi := dx <= 0 and dy <= 0 and dx * dx + dy * dy <= (r - 1) * (r - 1)
			img.set_pixel(px, py, _shade(c, 0.18) if hi else _shade(c, -0.10))

# --- Peintres par type -------------------------------------------------------
static func _build(t: int) -> Image:
	var img := _img()
	match t:
		WorldGrid.DIRT:
			_fill_noisy(img, Color(0.42, 0.30, 0.20), 0.20, 11)
			# quelques cailloux sombres parsemés
			for k in 5:
				var cx := int(_h(k, 0, 21) * (S - 4)) + 2
				var cy := int(_h(0, k, 22) * (S - 4)) + 2
				_nodule(img, cx, cy, 1, Color(0.30, 0.21, 0.13))
			_bevel(img, 0.06, -0.10)
		WorldGrid.ROCK:
			_fill_noisy(img, Color(0.40, 0.42, 0.46), 0.16, 31)
			_crack(img, Color(0.24, 0.25, 0.29), 41)
			_bevel(img, 0.07, -0.11)
		WorldGrid.WALL:
			# béton de bunker : appareil de blocs (mortier sombre) = lecture « bâti »
			_fill_noisy(img, Color(0.30, 0.34, 0.42), 0.10, 51)
			var mortar := Color(0.18, 0.20, 0.26)
			for x in S:
				img.set_pixel(x, 7, mortar)              # joint horizontal médian
				img.set_pixel(x, 8, _shade(mortar, 0.03))
			for y in S:
				img.set_pixel(7 if y < 8 else 11, y, mortar)  # joint vertical décalé entre rangées
			_bevel(img, 0.10, -0.08)
		WorldGrid.HARDROCK:
			# roche dense INDESTRUCTIBLE : striations diagonales serrées = barrière
			_fill_noisy(img, Color(0.18, 0.20, 0.26), 0.08, 61)
			for y in S:
				for x in S:
					if (x + y) % 4 == 0:
						img.set_pixel(x, y, _shade(img.get_pixel(x, y), -0.07))
			_bevel(img, 0.06, -0.06)
		WorldGrid.WOOD:
			# étai de bois : grain vertical + nœud
			var wbase := Color(0.55, 0.38, 0.15)
			for y in S:
				for x in S:
					var col := _shade(wbase, (_h(x, 0, 71) - 0.5) * 0.20)   # veine par colonne
					col = _shade(col, (_h(x, y, 72) - 0.5) * 0.06)          # grain fin
					img.set_pixel(x, y, col)
			for x in range(2, S, 5):                                        # lignes de grain
				for y in S:
					img.set_pixel(x, y, _shade(img.get_pixel(x, y), -0.12))
			_nodule(img, 10, 6, 2, Color(0.40, 0.26, 0.10))                 # nœud
			_bevel(img, 0.10, -0.12)
		WorldGrid.LITHIUM:
			_fill_noisy(img, Color(0.40, 0.42, 0.46), 0.14, 31)            # gangue de roche
			_crystal(img, 5, 6, 3, Color(0.45, 0.74, 0.80))
			_crystal(img, 11, 10, 2, Color(0.52, 0.80, 0.86))
			_crystal(img, 8, 3, 1, Color(0.58, 0.86, 0.92))
			_bevel(img, 0.07, -0.11)
		WorldGrid.IRON:
			_fill_noisy(img, Color(0.40, 0.42, 0.46), 0.14, 31)            # gangue de roche
			_nodule(img, 5, 5, 2, Color(0.58, 0.40, 0.30))
			_nodule(img, 11, 9, 3, Color(0.62, 0.43, 0.32))
			_nodule(img, 7, 12, 1, Color(0.58, 0.40, 0.30))
			_bevel(img, 0.07, -0.11)
		WorldGrid.CRATE:
			# caisse à fouiller [E] : planches + croix de renfort, cadre marqué
			var wb := Color(0.52, 0.38, 0.18)
			for y in S:
				for x in S:
					img.set_pixel(x, y, _shade(wb, (_h(x, y, 81) - 0.5) * 0.10))
			for ry in [4, 9, 14]:                       # rails horizontaux
				for x in S:
					img.set_pixel(x, ry, _shade(wb, -0.14))
			for i in S:                                 # croix de renfort (bois clair)
				img.set_pixel(i, i, _shade(wb, 0.18))
				img.set_pixel(S - 1 - i, i, _shade(wb, 0.18))
			_frame(img, _shade(wb, -0.24))
			_bevel(img, 0.10, -0.12)
		WorldGrid.CRATE_OPEN:
			# caisse déjà vidée : couvercle ouvert (intérieur sombre), bois terni
			var ob := Color(0.34, 0.27, 0.14)
			for y in S:
				for x in S:
					img.set_pixel(x, y, _shade(ob, (_h(x, y, 82) - 0.5) * 0.10))
			for y in range(2, 7):                       # ouverture sombre (vidée)
				for x in range(2, S - 2):
					img.set_pixel(x, y, Color(0.10, 0.08, 0.05))
			for ry in [10, 13]:                         # planches restantes
				for x in S:
					img.set_pixel(x, ry, _shade(ob, -0.12))
			_frame(img, _shade(ob, -0.20))
			_bevel(img, 0.06, -0.10)
		WorldGrid.BOSS_DOOR:
			# portes scellées du Roi : métal rouillé, vantaux, barre à chevrons
			# (danger doublé par la FORME — chevrons + rivets — pas que le rouge).
			var mb := Color(0.40, 0.17, 0.14)
			for y in S:
				for x in S:
					img.set_pixel(x, y, _shade(mb, (_h(x, y, 83) - 0.5) * 0.10))
			for y in S:                                 # joint central des deux vantaux
				img.set_pixel(7, y, _shade(mb, -0.22))
				img.set_pixel(8, y, _shade(mb, 0.06))
			for x in S:                                 # barre de renfort + chevrons clairs
				img.set_pixel(x, 7, _shade(mb, -0.16))
				img.set_pixel(x, 8, _shade(mb, -0.16))
				if x % 4 < 2:
					img.set_pixel(x, 7, _shade(mb, 0.26))
			for p: Vector2i in [Vector2i(2, 2), Vector2i(13, 2), Vector2i(2, 13), Vector2i(13, 13)]:
				img.set_pixel(p.x, p.y, _shade(mb, 0.32))   # rivets d'angle
			_frame(img, Color(0.14, 0.06, 0.05))
		WorldGrid.LADDER:
			# échelle de bois : 2 montants + barreaux, TRANSPARENT entre (décor visible)
			img.fill(Color(0, 0, 0, 0))
			var rail := Color(0.60, 0.42, 0.20, 1.0)
			var rail_d := Color(0.42, 0.28, 0.12, 1.0)
			var rung := Color(0.72, 0.54, 0.30, 1.0)
			for y in S:
				img.set_pixel(3, y, rail_d)
				img.set_pixel(4, y, rail)
				img.set_pixel(11, y, rail)
				img.set_pixel(12, y, rail_d)
			for ry: int in [3, 11]:                 # barreaux (2 px) reliant les montants
				for x in range(4, 12):
					img.set_pixel(x, ry, rung)
					img.set_pixel(x, ry + 1, rail_d)
		WorldGrid.PASSERELLE:
			# planche de bois (sol) : boards horizontaux, PAS de bord vertical → continu
			var pb := Color(0.52, 0.38, 0.17)
			for y in S:
				for x in S:
					img.set_pixel(x, y, _shade(pb, (_h(y, x, 84) - 0.5) * 0.08))
			for x in S:
				img.set_pixel(x, 1, _shade(pb, 0.12))   # reflet sur la surface de marche
			for sy: int in [0, 6, 11]:               # joints entre planches
				for x in S:
					img.set_pixel(x, sy, _shade(pb, -0.18))
			for ny: int in [3, 8, 13]:               # clous aux extrémités
				img.set_pixel(2, ny, _shade(pb, 0.16))
				img.set_pixel(13, ny, _shade(pb, 0.16))
		_:
			return null
	return img

# Fissure : marche aléatoire déterministe verticale, en pixels sombres.
static func _crack(img: Image, c: Color, seed: int) -> void:
	var x := int(_h(0, 0, seed) * (S - 6)) + 3
	for y in range(2, S - 2):
		img.set_pixel(clampi(x, 1, S - 2), y, c)
		x += -1 if _h(x, y, seed) < 0.5 else 1
