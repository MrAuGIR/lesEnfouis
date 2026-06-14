class_name Hud
extends CanvasLayer
## Interface écran (1:1, non affectée par le zoom caméra) — passe UX/HUD (M7).
## HUD dessiné en zones aux 4 coins pour la lisibilité (grey-box) :
##  - haut-gauche : état du monde (raid, caravane, PNJ, Foyer) ;
##  - haut-centre : objectif + bandeau d'alerte (gaz / raid) qui pulse ;
##  - droite : Sac + Stock, chaque ressource en pastille COULEUR + NOM + nombre
##    (le texte est toujours présent : l'utilisateur est daltonien) ;
##  - bas-gauche : PV (barre + chiffres), lampe, arme / anti-gaz / outil ;
##  - bas-centre : invite contextuelle [E] bien visible (« où agir ») ;
##  - bas : aide condensée.
## Le HUD ne connaît PAS l'état du jeu : main.gd lui passe un dictionnaire (set_state).

# Panneau interne dessiné (un CanvasLayer ne peut pas dessiner lui-même).
class HudPanel extends Control:
	var hud: Hud
	func _draw() -> void:
		hud._draw_hud(self)

var panel: HudPanel
var msg_label: Label
var msg_t := 0.0
var t_acc := 0.0
var state := {}
var end_panel: ColorRect      # écran de fin du MVP (M5) : voile + texte centré
var end_label: Label

func _ready() -> void:
	panel = HudPanel.new()
	panel.hud = self
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	# Message de résultat d'action (toast) : centré sous le bandeau d'alerte
	msg_label = Label.new()
	msg_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.45))
	msg_label.add_theme_font_size_override("font_size", 12)
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	msg_label.position = Vector2(0, 52)
	add_child(msg_label)
	# Écran de fin (masqué) : voile sombre plein écran + texte doré centré
	end_panel = ColorRect.new()
	end_panel.color = Color(0.02, 0.02, 0.04, 0.82)
	end_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_panel.visible = false
	add_child(end_panel)
	end_label = Label.new()
	end_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	end_label.add_theme_font_size_override("font_size", 15)
	end_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
	end_panel.add_child(end_label)

# main.gd pousse l'état complet chaque frame.
func set_state(s: Dictionary) -> void:
	state = s
	if panel != null:
		panel.queue_redraw()

func show_end(text: String) -> void:
	end_label.text = text
	end_panel.visible = true

func hide_end() -> void:
	end_panel.visible = false

func end_visible() -> bool:
	return end_panel != null and end_panel.visible

func flash(text: String) -> void:
	msg_t = 2.5
	msg_label.text = text

func tick(delta: float) -> void:
	t_acc += delta
	if msg_t > 0.0:
		msg_t -= delta
		if msg_t <= 0.0:
			msg_label.text = ""
	if panel != null:
		panel.queue_redraw()   # le pouls du bandeau d'alerte a besoin d'un redraw continu

# --- Dessin -------------------------------------------------------------------------
const COL_TXT := Color(0.86, 0.90, 0.84)
const COL_DIM := Color(0.62, 0.66, 0.62)
const COL_PANEL := Color(0.08, 0.09, 0.12, 0.72)
const COL_BORDER := Color(0.40, 0.44, 0.50, 0.85)

func _font() -> Font:
	return ThemeDB.fallback_font

func _draw_hud(c: HudPanel) -> void:
	if state.is_empty():
		return
	var sz := c.size
	var font := _font()
	_draw_world_status(c, font)
	_draw_objective(c, font, sz)
	_draw_resources(c, font, sz)
	_draw_survival(c, font, sz)
	_draw_context(c, font, sz)

func _panel_box(c: HudPanel, r: Rect2) -> void:
	c.draw_rect(r, COL_PANEL)
	c.draw_rect(r, COL_BORDER, false, 1.0)

# Haut-gauche : état du monde.
func _draw_world_status(c: HudPanel, font: Font) -> void:
	var lines: Array = state.get("world", [])
	if lines.is_empty():
		return
	var r := Rect2(8, 8, 250, 18 + lines.size() * 15)
	_panel_box(c, r)
	var y := 22.0
	for ln in lines:
		c.draw_string(font, Vector2(16, y), String(ln), HORIZONTAL_ALIGNMENT_LEFT, 240, 11, COL_TXT)
		y += 15.0

# Haut-centre : objectif + bandeau d'alerte (pulsé).
func _draw_objective(c: HudPanel, font: Font, sz: Vector2) -> void:
	var obj := String(state.get("objectif", ""))
	if obj != "":
		var w := font.get_string_size(obj, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		c.draw_string(font, Vector2((sz.x - w) * 0.5, 24), obj, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.95, 0.95, 0.86))
	var alert: Dictionary = state.get("alert", {})
	var atext := String(alert.get("text", ""))
	if atext != "":
		var pulse := 0.6 + 0.4 * sin(t_acc * 6.0)
		var col: Color = Color(1.0, 0.35, 0.30, pulse) if bool(alert.get("danger", false)) else Color(1.0, 0.82, 0.40, pulse)
		var aw := font.get_string_size(atext, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		var br := Rect2((sz.x - aw) * 0.5 - 12, 32, aw + 24, 24)
		c.draw_rect(br, Color(0.12, 0.04, 0.04, 0.6) if bool(alert.get("danger", false)) else Color(0.10, 0.08, 0.03, 0.6))
		c.draw_rect(br, col, false, 1.5)
		c.draw_string(font, Vector2((sz.x - aw) * 0.5, 49), atext, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, col)

# Droite : Sac + Stock (pastille couleur + NOM + nombre — texte toujours présent).
func _draw_resources(c: HudPanel, font: Font, sz: Vector2) -> void:
	var bag: Dictionary = state.get("bag", {})
	var stock: Dictionary = state.get("stock", {})
	var x := sz.x - 174.0
	var rows := Inventory.RES_TYPES.size() + Inventory.STORE_TYPES.size() + 2
	var r := Rect2(x - 8, 64, 174, 14 + rows * 16)
	_panel_box(c, r)
	var y := 80.0
	c.draw_string(font, Vector2(x, y), "SAC  %s" % String(state.get("bag_slots", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.85, 0.92, 0.7))
	y += 17.0
	for t in Inventory.RES_TYPES:
		y = _draw_res_row(c, font, x, y, int(t), int(bag.get(t, 0)))
	y += 6.0
	c.draw_string(font, Vector2(x, y), "STOCK  %d/%d" % [int(state.get("stored", 0)), int(state.get("cap", 0))], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.7, 0.82, 0.92))
	y += 17.0
	for t in Inventory.STORE_TYPES:
		y = _draw_res_row(c, font, x, y, int(t), int(stock.get(t, 0)))

func _draw_res_row(c: HudPanel, font: Font, x: float, y: float, t: int, n: int) -> float:
	# Pastille : carré coloré + liseré (forme/bordure = repère non coloré) ...
	var sw := 11.0
	c.draw_rect(Rect2(x, y - 9, sw, sw), Inventory.res_color(t))
	c.draw_rect(Rect2(x, y - 9, sw, sw), Color(0.85, 0.87, 0.9, 0.8), false, 1.0)
	# ... + NOM + nombre (le texte porte l'info, indispensable en daltonien).
	var col := COL_TXT if n > 0 else COL_DIM
	c.draw_string(font, Vector2(x + sw + 6, y), "%s  %d" % [Inventory.res_name(t), n], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, col)
	return y + 16.0

# Bas-gauche : PV, lampe, arme / anti-gaz / outil.
func _draw_survival(c: HudPanel, font: Font, sz: Vector2) -> void:
	var x := 10.0
	var y := sz.y - 74.0
	_panel_box(c, Rect2(x - 2, y - 16, 304, 70))
	# PV
	_draw_bar(c, font, x, y, "PV", float(state.get("hp", 0)) / maxf(1.0, float(state.get("hp_max", 1))),
		Color(0.85, 0.30, 0.32), "%d/%d" % [int(state.get("hp", 0)), int(state.get("hp_max", 0))])
	y += 18.0
	# Lampe
	_draw_bar(c, font, x, y, "Lampe", clampf(float(state.get("lamp", 0)), 0.0, 1.0),
		Color(0.92, 0.82, 0.40), "%d%%" % int(float(state.get("lamp", 0)) * 100.0))
	y += 18.0
	c.draw_string(font, Vector2(x, y + 4), String(state.get("gear", "")), HORIZONTAL_ALIGNMENT_LEFT, 298, 11, COL_TXT)

func _draw_bar(c: HudPanel, font: Font, x: float, y: float, label: String, frac: float, fill: Color, value: String) -> void:
	c.draw_string(font, Vector2(x, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, COL_DIM)
	var bx := x + 44.0
	var bw := 110.0
	var bh := 10.0
	var br := Rect2(bx, y - 9, bw, bh)
	c.draw_rect(br, Color(0.05, 0.05, 0.07, 0.9))
	c.draw_rect(Rect2(bx, y - 9, bw * clampf(frac, 0.0, 1.0), bh), fill)
	c.draw_rect(br, COL_BORDER, false, 1.0)
	c.draw_string(font, Vector2(bx + bw + 6, y), value, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, COL_TXT)

# Bas-centre : invite contextuelle (« où agir ») + aide condensée.
func _draw_context(c: HudPanel, font: Font, sz: Vector2) -> void:
	var ctx := String(state.get("context", ""))
	if ctx != "":
		var w := font.get_string_size(ctx, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		var r := Rect2((sz.x - w) * 0.5 - 12, sz.y - 58, w + 24, 24)
		c.draw_rect(r, Color(0.06, 0.10, 0.08, 0.78))
		c.draw_rect(r, Color(0.55, 0.85, 0.6, 0.9), false, 1.0)
		c.draw_string(font, Vector2((sz.x - w) * 0.5, sz.y - 41), ctx, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.8, 0.97, 0.82))
	var help := String(state.get("controls", ""))
	if help != "":
		var hw := font.get_string_size(help, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
		c.draw_string(font, Vector2((sz.x - hw) * 0.5, sz.y - 8), help, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, COL_DIM)
