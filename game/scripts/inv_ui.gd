class_name InvUI
extends Control
## Écran d'inventaire (grey-box) : grille du sac + casiers du stock du Foyer
## (visibles dans le Foyer). Clic : prendre / poser / fusionner ; Maj+clic :
## transfert rapide. La pile « tenue » suit le curseur.

const SLOT := 28                 # px : taille d'une case
const SLOT_PAD := 5              # px : espace entre cases
const INV_COLS := 4              # colonnes de la grille du sac

var bag: Inventory
var foyer: Foyer
var hero: Hero
var hud: Hud

var held := {}    # pile "tenue" au curseur (clic prendre/poser)

func _near_base() -> bool:
	return foyer.inside(hero.pos)

# Appelé à la fermeture : on repose la pile tenue au sac (ou au stock si au Foyer).
func drop_held() -> void:
	if held.is_empty():
		return
	var back := bag.add(int(held["type"]), int(held["count"]))
	var rest := int(held["count"]) - back
	if rest > 0 and _near_base():
		rest -= foyer.add(int(held["type"]), rest)
	if rest > 0:
		hud.flash("Inventaire plein : %d objet(s) perdu(s)" % rest)
	held = {}

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_click(event.position, event.shift_pressed)
		accept_event()

func _layout(sz: Vector2) -> Dictionary:
	var cols := INV_COLS
	var rows := int(ceil(float(Inventory.BAG_SLOTS) / float(cols)))
	var step := SLOT + SLOT_PAD
	var bag_w := cols * step - SLOT_PAD
	var bag_h := rows * step - SLOT_PAD
	var near := _near_base()
	var store_rows: int = Inventory.STORE_TYPES.size()
	var store_h := store_rows * step - SLOT_PAD
	var gap := 70
	var total_w := bag_w
	if near:
		total_w += gap + SLOT
	var ox := (sz.x - total_w) * 0.5
	var oy := (sz.y - bag_h) * 0.5
	var bag_rects := []
	for i in Inventory.BAG_SLOTS:
		var r := i / cols
		var c := i % cols
		bag_rects.append(Rect2(ox + c * step, oy + r * step, SLOT, SLOT))
	var store_rects := []
	var store_origin := Vector2.ZERO
	if near:
		var sx := ox + bag_w + gap
		var sy := (sz.y - store_h) * 0.5
		store_origin = Vector2(sx, sy)
		for i in store_rows:
			store_rects.append(Rect2(sx, sy + i * step, SLOT, SLOT))
	return {"bag": bag_rects, "store": store_rects, "near": near,
		"bag_origin": Vector2(ox, oy), "store_origin": store_origin, "bag_h": bag_h}

func _draw() -> void:
	var sz := get_size()
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, sz), Color(0, 0, 0, 0.55))
	var L := _layout(sz)
	var bo: Vector2 = L["bag_origin"]
	draw_string(font, bo + Vector2(0, -10), "SAC  (%d/%d slots)" % [bag.slots_used(), Inventory.BAG_SLOTS], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.9, 0.95, 0.85))
	var bag_rects: Array = L["bag"]
	for i in Inventory.BAG_SLOTS:
		_draw_slot(font, bag_rects[i], bag.slots[i], false)
	if bool(L["near"]):
		var so: Vector2 = L["store_origin"]
		draw_string(font, so + Vector2(0, -10), "STOCK DU FOYER", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.6, 1.0, 0.7))
		draw_string(font, so + Vector2(0, -24), "(%d/%d)" % [foyer.stored_total(), foyer.capacity()], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.55, 0.8, 0.6))
		var store_rects: Array = L["store"]
		for i in Inventory.STORE_TYPES.size():
			var rt: int = Inventory.STORE_TYPES[i]
			_draw_slot(font, store_rects[i], {"type": rt, "count": foyer.count(rt)}, false)
	else:
		var note := "Entre dans le Foyer pour acceder au stock"
		var nw := font.get_string_size(note, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		draw_string(font, Vector2((sz.x - nw) * 0.5, bo.y + float(L["bag_h"]) + 28), note, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.85, 0.8, 0.5))
	if not held.is_empty():
		var m := get_local_mouse_position()
		_draw_slot(font, Rect2(m - Vector2(SLOT * 0.5, SLOT * 0.5), Vector2(SLOT, SLOT)), held, true)
	var help := "Clic: prendre / poser / fusionner     Maj+Clic: transfert rapide sac <-> Foyer     [I] fermer"
	var hw := font.get_string_size(help, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	draw_string(font, Vector2((sz.x - hw) * 0.5, sz.y - 26), help, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.82, 0.88))

func _draw_slot(font: Font, rect: Rect2, slot: Dictionary, floating: bool) -> void:
	if not floating:
		draw_rect(rect, Color(0.12, 0.13, 0.16, 0.96))
		draw_rect(rect, Color(0.5, 0.52, 0.58), false, 1.0)
	if slot.has("type") and int(slot.get("count", 0)) > 0:
		draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), Inventory.res_color(int(slot["type"])))
		var n := str(int(slot["count"]))
		var ns := font.get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
		draw_string(font, rect.position + Vector2(rect.size.x - 3 - ns.x, rect.size.y - 3), n, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1))

func _click(p: Vector2, shift: bool) -> void:
	var L := _layout(get_size())
	var bag_rects: Array = L["bag"]
	for i in Inventory.BAG_SLOTS:
		if (bag_rects[i] as Rect2).has_point(p):
			_click_bag(i, shift)
			queue_redraw()
			return
	if bool(L["near"]):
		var store_rects: Array = L["store"]
		for i in Inventory.STORE_TYPES.size():
			if (store_rects[i] as Rect2).has_point(p):
				_click_store(int(Inventory.STORE_TYPES[i]), shift)
				queue_redraw()
				return
	# Clic dans le vide en tenant une pile → on la repose dans le sac.
	if not held.is_empty():
		var back := bag.add(int(held["type"]), int(held["count"]))
		if back > 0:
			held["count"] = int(held["count"]) - back
			if int(held["count"]) <= 0:
				held = {}
		queue_redraw()

func _click_bag(i: int, shift: bool) -> void:
	if shift:
		if not _near_base():
			hud.flash("Entre dans le Foyer pour stocker")
			return
		if bag.slots[i].has("type"):
			var moved := foyer.add(int(bag.slots[i]["type"]), int(bag.slots[i]["count"]))
			if moved <= 0:
				hud.flash("Stock du Foyer plein ! (construis un entrepot)")
				return
			bag.slots[i]["count"] = int(bag.slots[i]["count"]) - moved
			if int(bag.slots[i]["count"]) <= 0:
				bag.slots[i] = {}
		return
	if held.is_empty():
		if bag.slots[i].has("type"):
			held = bag.slots[i]
			bag.slots[i] = {}
	else:
		if bag.slots[i].is_empty():
			bag.slots[i] = held
			held = {}
		elif int(bag.slots[i]["type"]) == int(held["type"]):
			var mv: int = mini(Inventory.STACK_MAX - int(bag.slots[i]["count"]), int(held["count"]))
			bag.slots[i]["count"] = int(bag.slots[i]["count"]) + mv
			held["count"] = int(held["count"]) - mv
			if int(held["count"]) <= 0:
				held = {}
		else:
			var tmp = bag.slots[i]
			bag.slots[i] = held
			held = tmp

func _click_store(rt: int, shift: bool) -> void:
	if shift:
		var moved := bag.add(rt, foyer.count(rt))
		foyer.remove(rt, moved)
		return
	if held.is_empty():
		var take: int = mini(Inventory.STACK_MAX, foyer.count(rt))
		if take > 0:
			held = {"type": rt, "count": take}
			foyer.remove(rt, take)
	else:
		if int(held["type"]) == rt:
			var put := foyer.add(rt, int(held["count"]))
			held["count"] = int(held["count"]) - put
			if int(held["count"]) <= 0:
				held = {}
			else:
				hud.flash("Stock du Foyer plein ! (construis un entrepot)")
		else:
			hud.flash("Ce casier ne prend que: %s" % Inventory.res_name(rt))
