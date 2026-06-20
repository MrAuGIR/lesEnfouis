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
		_:
			return null
	return img

# Fissure : marche aléatoire déterministe verticale, en pixels sombres.
static func _crack(img: Image, c: Color, seed: int) -> void:
	var x := int(_h(0, 0, seed) * (S - 6)) + 3
	for y in range(2, S - 2):
		img.set_pixel(clampi(x, 1, S - 2), y, c)
		x += -1 if _h(x, y, seed) < 0.5 else 1
