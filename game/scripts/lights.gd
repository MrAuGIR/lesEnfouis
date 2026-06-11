class_name LightRig
extends Node2D
## Le VRAI éclairage (remplace le cône peint du proto) : obscurité ambiante
## (CanvasModulate), soleil en surface (DirectionalLight2D), cône de la lampe
## frontale + halo de corps (PointLight2D, ombres portées par les murs — les
## occulteurs vivent dans world_view.gd), torches posées et pièces du Foyer.
## Le décor est dessiné en pleine couleur : c'est la lumière qui le révèle.

const AMBIENT := Color(0.10, 0.11, 0.15)  # le noir n'est jamais total
const WARM := Color(1.0, 0.93, 0.78)      # lumière de la lampe frontale
const TORCH_COLOR := Color(1.0, 0.72, 0.35)
const ROOM_COLOR := Color(1.0, 0.95, 0.85)
const SUN_COLOR := Color(0.85, 0.90, 1.0)

const CONE_RANGE := 220.0       # px (~14 tuiles) : portée du faisceau
const CONE_COS_OUTER := 0.848   # ~32° : bord du faisceau
const CONE_COS_INNER := 0.978   # ~12° : cœur du faisceau
const LAMP_ENERGY := 1.15
const HALO_ENERGY := 0.7
const HALO_MIN := 0.15          # on se voit toujours un peu, même lampe morte
const HALO_SCALE := 0.9         # rayon ~3,5 tuiles (texture radiale de 256 px)
const TORCH_SCALE := 1.4        # rayon ~5,5 tuiles
const TORCH_ENERGY := 1.1
const ROOM_ENERGY := 0.95
const ROOM_SCALE := 1.1         # couvre l'intérieur 8x5 + déborde un peu (diffusion)

var hero: Hero
var lamp: PointLight2D
var halo: PointLight2D
var radial: Texture2D           # texture radiale partagée (halo, torches, pièces)

func _init(h: Hero) -> void:
	hero = h

func _ready() -> void:
	var mod := CanvasModulate.new()
	mod.color = AMBIENT
	add_child(mod)
	# Soleil : éclaire la surface ; sous terre, les occulteurs (murs) le bloquent.
	# (Si à l'écran il éclairait vers le haut : mettre sun.rotation = PI.)
	var sun := DirectionalLight2D.new()
	sun.color = SUN_COLOR
	sun.energy = 1.0
	sun.shadow_enabled = true
	sun.shadow_filter_smooth = 2.0
	add_child(sun)
	radial = _make_radial()
	# Cône de la lampe frontale (suit le héros, orienté vers la souris)
	lamp = PointLight2D.new()
	lamp.texture = _make_cone()
	lamp.offset = Vector2(108, 0)   # place la pointe du cône sur le héros
	lamp.color = WARM
	lamp.shadow_enabled = true
	lamp.shadow_filter = Light2D.SHADOW_FILTER_PCF13
	lamp.shadow_filter_smooth = 3.0   # ombres nettes, bord légèrement adouci
	add_child(lamp)
	# Halo doux autour du corps (jamais 100% aveugle)
	halo = PointLight2D.new()
	halo.texture = radial
	halo.texture_scale = HALO_SCALE
	halo.color = WARM
	halo.shadow_enabled = true
	halo.shadow_filter = Light2D.SHADOW_FILTER_PCF5
	halo.shadow_filter_smooth = 2.0
	add_child(halo)

# À appeler chaque frame : suit le héros et le carburant de la lampe.
func update() -> void:
	lamp.position = hero.pos
	lamp.rotation = hero.aim.angle()
	lamp.energy = LAMP_ENERGY * hero.lamp_factor
	halo.position = hero.pos
	halo.energy = maxf(HALO_MIN, HALO_ENERGY * hero.lamp_factor)

func add_torch(cell: Vector2i) -> void:
	var t := PointLight2D.new()
	t.texture = radial
	t.texture_scale = TORCH_SCALE
	t.color = TORCH_COLOR
	t.energy = TORCH_ENERGY
	t.shadow_enabled = true
	t.shadow_filter = Light2D.SHADOW_FILTER_PCF5
	t.shadow_filter_smooth = 2.0
	t.position = Vector2(cell.x + 0.5, cell.y + 0.5) * WorldGrid.TILE
	add_child(t)

# Lumière d'une pièce du Foyer (générateur implicite) : SANS ombre, pour que la
# lueur déborde des murs (diffusion autour de la base).
func add_room_light(center: Vector2) -> void:
	var r := PointLight2D.new()
	r.texture = radial
	r.texture_scale = ROOM_SCALE
	r.color = ROOM_COLOR
	r.energy = ROOM_ENERGY
	r.position = center
	add_child(r)

# Lueur générique SANS ombre (ex. : PNJ légendaire repérable de loin). Renvoie le
# nœud pour pouvoir l'éteindre (queue_free) quand la source disparaît.
func add_glow(pos: Vector2, color: Color, scale_f: float, energy: float) -> PointLight2D:
	var g := PointLight2D.new()
	g.texture = radial
	g.texture_scale = scale_f
	g.color = color
	g.energy = energy
	g.position = pos
	add_child(g)
	return g

# --- Textures générées (grey-box : pas d'assets) ----------------------------------
static func _make_radial() -> Texture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.4), Color(1, 1, 1, 0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 256
	t.height = 256
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0.0)
	return t

static func _make_cone() -> Texture2D:
	# Cône orienté vers +X, pointe en (20, 128) — décalé sur le héros via offset.
	var size := 256
	var apex := Vector2(20, size * 0.5)
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in size:
		for x in size:
			var v := Vector2(x + 0.5, y + 0.5) - apex
			var d := v.length()
			var a := 1.0
			if d > 1.0:
				var rad := 1.0 - clampf(d / CONE_RANGE, 0.0, 1.0)
				var ang := clampf((v.x / d - CONE_COS_OUTER) / (CONE_COS_INNER - CONE_COS_OUTER), 0.0, 1.0)
				a = pow(rad, 1.5) * ang
			img.set_pixel(x, y, Color(1, 1, 1, a))
	return ImageTexture.create_from_image(img)
