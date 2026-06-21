extends Node2D
## OUTIL TEMPORAIRE de validation (non commité) : instancie le vrai jeu et injecte
## les SPRITES du designer (echange/assets_pilleurs_boss_v2) comme CanvasItems du
## canvas par défaut — donc ÉCLAIRÉS par les vraies Light2D, exactement comme le
## décor et le héros (rectangle grey-box = référence d'échelle). Sert à répondre
## aux 5 points de validation : échelle, lisibilité dans le halo, lecture lourd
## face/dos, casque à pointe à la résolution réelle, recoloration des brassards.
## Sort des PNG dans /tmp/val_*.png puis quitte.

const T := WorldGrid.TILE
const DIR := "/home/mraugir/projects/secret_game/echange/assets_pilleurs_boss_v2/"

# pivot (x, feet_y) par type, d'après les fiches d'intégration
const PIVOT := {
	"fonceur": Vector2(16, 30), "tireur": Vector2(16, 30),
	"lourd": Vector2(24, 46), "boss": Vector2(32, 60),
}
const FILE := {
	"fonceur": "enemy_fonceur_idle_02.png", "tireur": "enemy_tireur_idle_02.png",
	"lourd": "enemy_lourd_idle_02.png", "boss": "boss_roi_idle_02.png",
}

const RECOLOR := "shader_type canvas_item;\n" + \
	"uniform vec4 faction : source_color = vec4(0.55, 0.13, 0.13, 1.0);\n" + \
	"void fragment() {\n" + \
	"  vec4 c = texture(TEXTURE, UV);\n" + \
	"  if (c.a > 0.1 && c.r > 0.80 && c.g < 0.20 && c.b > 0.80) { c.rgb = faction.rgb; }\n" + \
	"  COLOR = c;\n}"

var main: Node2D
var glows: Array = []
var sprites: Array = []
var tex_cache := {}

func _ready() -> void:
	await get_tree().process_frame
	main = load("res://scripts/main.gd").new()
	add_child(main)
	for i in 8:
		await get_tree().process_frame
	main.hud.visible = false
	main.marker.visible = false              # pas d'accents grey-box par-dessus nos sprites
	main.camera.position_smoothing_enabled = false
	Engine.time_scale = 0.0

	var cx: int = main.world.exit_col()

	# ---- 1) PILLEURS — bien éclairés, héros à gauche pour l'échelle ----
	var R := WorldGrid.BASE_DEPTH + 40
	_room(cx - 8, cx + 6, R)
	_hero_at(cx - 7, R, Vector2.RIGHT)
	_put("fonceur", cx - 3, R)
	_put("tireur", cx + 0, R)
	_put("lourd", cx + 3, R)
	_glow(Vector2(cx * T, (R - 1) * T), Color(0.96, 0.9, 0.78), 3.4, 1.5)
	await _save("/tmp/val_pilleurs.png")
	_reset()

	# ---- 2) PILLEURS DANS LE NOIR — lampe détournée, seul le halo faible reste ----
	var Rd := WorldGrid.BASE_DEPTH + 46
	_room(cx - 8, cx + 6, Rd)
	_hero_at(cx + 6, Rd, Vector2.RIGHT)      # héros loin à DROITE, lampe pointée hors champ
	_put("fonceur", cx - 3, Rd)
	_put("tireur", cx + 0, Rd)
	_put("lourd", cx + 2, Rd)
	# pas de _glow : on teste la lisibilité au bord du halo / quasi-noir ambiant
	await _save("/tmp/val_pilleurs_noir.png")
	_reset()

	# ---- 3) LOURD face / dos — deux lourds dos à dos (mirroir = scale.x -1) ----
	var Rl := WorldGrid.BASE_DEPTH + 52
	_room(cx - 7, cx + 5, Rl)
	_hero_at(cx - 6, Rl, Vector2.RIGHT)
	_put("lourd", cx - 1, Rl, false)         # regarde à droite : on voit sa FACE (vers le héros)
	_put("lourd", cx + 2, Rl, true)          # mirroir : on voit son DOS
	_glow(Vector2(cx * T, (Rl - 1) * T), Color(0.96, 0.9, 0.78), 3.2, 1.5)
	await _save("/tmp/val_lourd_facedos.png")
	_reset()

	# ---- 4) BOSS + 2 sbires + héros ----
	var Rk := WorldGrid.BASE_DEPTH + 60
	_room(cx - 9, cx + 7, Rk)
	_hero_at(cx - 8, Rk, Vector2.RIGHT)
	_put("fonceur", cx - 3, Rk)
	_put("boss", cx + 2, Rk)
	_put("tireur", cx + 5, Rk)
	_glow(Vector2(cx * T, (Rk - 1) * T), Color(0.96, 0.85, 0.7), 3.8, 1.6)
	await _save("/tmp/val_boss.png")
	_reset()

	# ---- 5) RECOLORATION DES BRASSARDS — 3 factions sur le même fonceur ----
	var Ra := WorldGrid.BASE_DEPTH + 66
	_room(cx - 7, cx + 5, Ra)
	_hero_at(cx - 6, Ra, Vector2.RIGHT)
	_put("fonceur", cx - 2, Ra, false, Color(0.55, 0.13, 0.13))   # rouge pilleurs
	_put("fonceur", cx + 1, Ra, false, Color(0.20, 0.45, 0.70))   # bleu (autre faction)
	_put("fonceur", cx + 3, Ra, false, Color(0.30, 0.55, 0.25))   # vert (autre faction)
	_glow(Vector2(cx * T, (Ra - 1) * T), Color(0.96, 0.9, 0.8), 3.2, 1.5)
	await _save("/tmp/val_armband.png")
	_reset()

	print("VALIDATE OK")
	get_tree().quit()

# --- Helpers -----------------------------------------------------------------
func _tex(type: String) -> Texture2D:
	if not tex_cache.has(type):
		var img := Image.load_from_file(DIR + FILE[type])
		tex_cache[type] = ImageTexture.create_from_image(img)
	return tex_cache[type]

# pose un sprite, PIEDS sur la rangée de sol gy (sol = gy+1), centré sur la colonne tx
func _put(type: String, tx: int, gy: int, mirror := false, faction := Color(0.55, 0.13, 0.13)) -> void:
	var pivot: Vector2 = PIVOT[type]
	var pin := Node2D.new()                  # noeud-pivot aux PIEDS (mirroir propre par scale.x)
	pin.position = Vector2((tx + 0.5) * T, (gy + 1) * T)
	pin.scale.x = -1.0 if mirror else 1.0
	var s := Sprite2D.new()
	s.texture = _tex(type)
	s.centered = false
	s.offset = -pivot                        # pivot (x, pieds) sur l'origine du noeud
	s.z_index = 5                            # au-dessus des tuiles du décor
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = RECOLOR
	mat.shader = sh
	mat.set_shader_parameter("faction", faction)
	s.material = mat
	pin.add_child(s)
	main.add_child(pin)                      # canvas par défaut → éclairé par les Light2D
	sprites.append(pin)

func _hero_at(tx: int, gy: int, aim: Vector2) -> void:
	main.hero.pos = Vector2((tx + 0.5) * T, (gy + 1) * T - main.hero.half.y)
	main.hero.aim = aim

func _room(x0: int, x1: int, gy: int) -> void:
	for x in range(x0, x1 + 1):
		for y in range(gy - 5, gy + 1):
			main.world.set_tile(x, y, WorldGrid.EMPTY)
		main.world.set_tile(x, gy + 1, WorldGrid.ROCK)
	main.view.mark_dirty()

func _glow(p: Vector2, c: Color, scale_f: float, energy: float) -> void:
	glows.append(main.lights.add_glow(p, c, scale_f, energy))

func _reset() -> void:
	for g in glows:
		if is_instance_valid(g):
			g.queue_free()
	glows.clear()
	for s in sprites:
		if is_instance_valid(s):
			s.queue_free()
	sprites.clear()
	main.crew.list.clear()

func _save(path: String) -> void:
	for i in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)
	print("saved ", path)
