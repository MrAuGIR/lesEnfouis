extends Control
## Calque d'inventaire (grey-box). Ne contient AUCUNE logique : il délègue tout
## le dessin et les clics au noeud Game (centralisé dans Game.gd).

var game: Node = null

func _draw() -> void:
	if game:
		game.draw_inventory(self)

func _gui_input(event: InputEvent) -> void:
	if game == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		game.inventory_click(event.position, event.shift_pressed)
		accept_event()
