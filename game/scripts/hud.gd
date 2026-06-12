class_name Hud
extends CanvasLayer
## Interface écran (1:1, non affectée par le zoom caméra) : bloc de stats en haut,
## message de résultat d'action au-dessous, raccourcis en petite police en bas.
## Le HUD ne connaît PAS l'état du jeu : main.gd compose les textes.

var stats_label: Label
var msg_label: Label
var hint_label: Label
var msg_t := 0.0
var end_panel: ColorRect      # écran de fin du MVP (M5) : voile + texte centré
var end_label: Label

func _ready() -> void:
	stats_label = Label.new()
	stats_label.position = Vector2(12, 8)
	stats_label.add_theme_color_override("font_color", Color(0.85, 0.9, 0.8))
	add_child(stats_label)
	# Message de résultat d'action (sous le bloc stats, au-dessus des raccourcis)
	msg_label = Label.new()
	msg_label.position = Vector2(12, 152)   # sous le bloc stats (6 lignes depuis M2)
	msg_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.45))
	add_child(msg_label)
	# Raccourcis : petite police, ancrés en bas de l'écran (960x540)
	hint_label = Label.new()
	hint_label.add_theme_font_size_override("font_size", 9)
	hint_label.add_theme_color_override("font_color", Color(0.62, 0.68, 0.62))
	hint_label.position = Vector2(12, 522)
	add_child(hint_label)
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

func show_end(text: String) -> void:
	end_label.text = text
	end_panel.visible = true

func hide_end() -> void:
	end_panel.visible = false

func end_visible() -> bool:
	return end_panel != null and end_panel.visible

func set_stats(text: String) -> void:
	stats_label.text = text

func set_hints(text: String) -> void:
	hint_label.text = text

func flash(text: String) -> void:
	msg_t = 2.5
	msg_label.text = text

func tick(delta: float) -> void:
	if msg_t > 0.0:
		msg_t -= delta
		if msg_t <= 0.0:
			msg_label.text = ""
