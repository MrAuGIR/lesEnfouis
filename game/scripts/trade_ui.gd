class_name TradeUI
extends Control
## Écran de troc avec la caravane (grey-box) : la liste des offres, cliquer une
## offre l'exécute depuis le stock du Foyer. Les munitions vont droit à l'arme.

const PANEL_W := 460.0
const ROW_H := 30.0

var foyer: Foyer
var caravan: Caravan
var combat: Combat
var hud: Hud
var audio: Audio          # branché par main.gd : SFX de troc

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_click(event.position)
		accept_event()

func _panel_rect() -> Rect2:
	var sz := get_size()
	var h := 84.0 + Caravan.OFFERS.size() * ROW_H
	return Rect2((sz.x - PANEL_W) * 0.5, (sz.y - h) * 0.5, PANEL_W, h)

func _row_rect(i: int) -> Rect2:
	var p := _panel_rect()
	return Rect2(p.position.x + 12, p.position.y + 40 + i * ROW_H, PANEL_W - 24, ROW_H - 5)

func _draw() -> void:
	var sz := get_size()
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, sz), Color(0, 0, 0, 0.55))
	var p := _panel_rect()
	draw_rect(p, Color(0.12, 0.10, 0.08, 0.97))
	draw_rect(p, Color(0.62, 0.5, 0.34), false, 1.0)
	draw_string(font, p.position + Vector2(14, 26), "CARAVANE — TROC (repart dans %d s)" % maxi(0, int(caravan.stay_t)),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.95, 0.85, 0.6))
	for i in Caravan.OFFERS.size():
		var r := _row_rect(i)
		var ok := caravan.can_trade(i)
		draw_rect(r, Color(0.18, 0.16, 0.13, 0.9))
		draw_rect(r, Color(0.5, 0.44, 0.34, 0.8), false, 1.0)
		var col := Color(1, 1, 1) if ok else Color(0.55, 0.55, 0.55)
		draw_string(font, r.position + Vector2(8, 17), Caravan.offer_text(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
	draw_string(font, Vector2(p.position.x + 14, p.end.y - 12),
		"Clic : echanger (depuis le stock du Foyer)     [E] / [Echap] fermer",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.68, 0.6))

func _click(p: Vector2) -> void:
	for i in Caravan.OFFERS.size():
		if _row_rect(i).has_point(p):
			if not caravan.can_trade(i):
				hud.flash("Troc impossible : stock insuffisant (ou plus de place)")
				if audio != null:
					audio.play("invalid")
				return
			var ammo := caravan.trade(i)
			if ammo > 0:
				combat.ammo += ammo
			hud.flash("Troc effectue : %s" % Caravan.offer_text(i))
			if audio != null:
				audio.play("trade")
			queue_redraw()
			return
