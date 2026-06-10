class_name RoomUI
extends Control
## Écran de cellule du Foyer (grey-box), ouvert par [E] dans une cellule :
##  - cellule VIDE → menu de construction (liste des pièces + coûts) ;
##  - pièce à postes → affectation façon Fallout Shelter : les postes à gauche,
##    cliquer un poste libre déroule la liste des PNJ (affectation / nom / stats),
##    cliquer un PNJ l'affecte, cliquer un PNJ en poste le retire.

const PANEL_W := 480.0
const ROW_H := 34.0
const MODE_BUILD := 0
const MODE_ASSIGN := 1

var foyer: Foyer
var pop: Population
var hud: Hud

var mode := MODE_BUILD
var cell := -1
var picking := false   # la liste des PNJ est dépliée (choix pour un poste)

func open_build(c: int) -> void:
	mode = MODE_BUILD
	cell = c
	picking = false
	visible = true
	queue_redraw()

func open_assign(c: int) -> void:
	mode = MODE_ASSIGN
	cell = c
	picking = false
	visible = true
	queue_redraw()

func close() -> void:
	visible = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_click(event.position)
		accept_event()

# --- Disposition -------------------------------------------------------------------
func _room_type() -> int:
	return int(foyer.cells[cell]["room"])

func _row_count() -> int:
	if mode == MODE_BUILD:
		return Foyer.ROOM_NAMES.size()
	var n: int = Foyer.ROOM_SLOTS[_room_type()]
	if picking:
		n += 1 + pop.npcs.size()   # ligne d'en-tête + un PNJ par ligne
	return n

func _panel_rect() -> Rect2:
	var sz := get_size()
	var h := 84.0 + _row_count() * ROW_H
	return Rect2((sz.x - PANEL_W) * 0.5, (sz.y - h) * 0.5, PANEL_W, h)

func _row_rect(i: int) -> Rect2:
	var p := _panel_rect()
	return Rect2(p.position.x + 12, p.position.y + 40 + i * ROW_H, PANEL_W - 24, ROW_H - 5)

# --- Dessin ---------------------------------------------------------------------
func _draw() -> void:
	if cell < 0:
		return
	var sz := get_size()
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, sz), Color(0, 0, 0, 0.55))
	var p := _panel_rect()
	draw_rect(p, Color(0.10, 0.11, 0.14, 0.97))
	draw_rect(p, Color(0.5, 0.52, 0.58), false, 1.0)
	var title := "CELLULE VIDE — construire une piece (clic)"
	if mode == MODE_ASSIGN:
		var slots: int = Foyer.ROOM_SLOTS[_room_type()]
		title = "%s — postes %d/%d" % [String(Foyer.ROOM_NAMES[_room_type()]).to_upper(),
			pop.assigned_to(cell).size(), slots]
	draw_string(font, p.position + Vector2(14, 26), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.92, 0.95, 0.85))
	if mode == MODE_BUILD:
		_draw_build(font)
	else:
		_draw_assign(font)
	var foot := "[E] / [Echap] fermer"
	draw_string(font, Vector2(p.position.x + 14, p.end.y - 12), foot, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.72, 0.78))

func _draw_build(font: Font) -> void:
	for i in Foyer.ROOM_NAMES.size():
		var r := _row_rect(i)
		var ok := foyer.can_pay(Foyer.ROOM_COSTS[i])
		draw_rect(r, Color(0.16, 0.18, 0.22, 0.9))
		draw_rect(r, Color(0.45, 0.48, 0.54, 0.8), false, 1.0)
		var main := "%s   —   %s" % [Foyer.ROOM_NAMES[i], _cost_text(Foyer.ROOM_COSTS[i])]
		var col := Color(1, 1, 1) if ok else Color(0.55, 0.55, 0.55)
		draw_string(font, r.position + Vector2(8, 14), main, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(font, r.position + Vector2(8, 26), String(Foyer.ROOM_NOTES[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.62, 0.68, 0.66))

func _draw_assign(font: Font) -> void:
	var slots: int = Foyer.ROOM_SLOTS[_room_type()]
	var assigned := pop.assigned_to(cell)
	for i in slots:
		var r := _row_rect(i)
		draw_rect(r, Color(0.16, 0.18, 0.22, 0.9))
		draw_rect(r, Color(0.45, 0.48, 0.54, 0.8), false, 1.0)
		if i < assigned.size():
			var npc: Dictionary = pop.npcs[assigned[i]]
			draw_string(font, r.position + Vector2(8, 19), "Poste %d :  %s    (Travail %d / Garde %d)    [clic : retirer]" % \
				[i + 1, npc["name"], int(npc["travail"]), int(npc["garde"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.85, 0.95, 0.85))
		else:
			draw_string(font, r.position + Vector2(8, 19), "Poste %d :  + affecter un PNJ (clic)" % (i + 1),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.65, 0.7, 0.75))
	if picking:
		var hr := _row_rect(slots)
		var head := "Choisir un PNJ :" if not pop.npcs.is_empty() else "Aucun PNJ au Foyer (construis un dortoir, ils arrivent seuls)"
		draw_string(font, hr.position + Vector2(2, 19), head, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.8, 0.5))
		for j in pop.npcs.size():
			var r := _row_rect(slots + 1 + j)
			var npc: Dictionary = pop.npcs[j]
			var c := int(npc["cell"])
			var where := "libre" if c < 0 else String(Foyer.ROOM_NAMES[int(foyer.cells[c]["room"])])
			draw_rect(r, Color(0.13, 0.15, 0.19, 0.9))
			draw_rect(r, Color(0.4, 0.42, 0.48, 0.7), false, 1.0)
			var col := Color(0.95, 0.95, 0.95) if c != cell else Color(0.55, 0.75, 0.55)
			draw_string(font, r.position + Vector2(8, 19), "%s    Travail %d / Garde %d    [%s]" % \
				[npc["name"], int(npc["travail"]), int(npc["garde"]), where], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)

func _cost_text(cost: Dictionary) -> String:
	var parts := []
	for t in cost:
		parts.append("%d %s" % [int(cost[t]), Inventory.res_name(int(t))])
	return " + ".join(parts)

# --- Clics ----------------------------------------------------------------------
func _click(p: Vector2) -> void:
	if mode == MODE_BUILD:
		for i in Foyer.ROOM_NAMES.size():
			if _row_rect(i).has_point(p):
				_click_build(i)
				return
	else:
		var slots: int = Foyer.ROOM_SLOTS[_room_type()]
		for i in slots:
			if _row_rect(i).has_point(p):
				_click_slot(i)
				return
		if picking:
			for j in pop.npcs.size():
				if _row_rect(slots + 1 + j).has_point(p):
					_click_npc(j)
					return

func _click_build(i: int) -> void:
	if not foyer.can_pay(Foyer.ROOM_COSTS[i]):
		hud.flash("Pas assez en stock : il faut %s" % _cost_text(Foyer.ROOM_COSTS[i]))
		return
	foyer.build(cell, i)
	hud.flash("%s : construit ! (%s)" % [Foyer.ROOM_NAMES[i], Foyer.ROOM_NOTES[i]])
	close()

func _click_slot(i: int) -> void:
	var assigned := pop.assigned_to(cell)
	if i < assigned.size():
		hud.flash("%s quitte son poste" % pop.npcs[assigned[i]]["name"])
		pop.unassign(assigned[i])
		picking = false
	else:
		picking = true
	queue_redraw()

func _click_npc(j: int) -> void:
	if int(pop.npcs[j]["cell"]) == cell:
		hud.flash("%s travaille deja ici" % pop.npcs[j]["name"])
		return
	if pop.assigned_to(cell).size() >= int(Foyer.ROOM_SLOTS[_room_type()]):
		hud.flash("Tous les postes sont occupes")
		return
	pop.assign(j, cell)
	hud.flash("%s est affecte(e) : %s" % [pop.npcs[j]["name"], Foyer.ROOM_NAMES[_room_type()]])
	picking = false
	queue_redraw()
