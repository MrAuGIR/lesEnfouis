# Prototype — *Les Enfouis* (Godot 4.6)

Prototype **grey-box** (formes simples, aucun art final). Objectif : prouver que le **cœur est
fun** — `creuser → récolter → revenir` — cf. [`../docs/PROTOTYPE.md`](../docs/PROTOTYPE.md).

## Lancer

Depuis la racine du dépôt :

```bash
godot --path prototype
```

(ou `~/.local/bin/godot --path prototype` si `godot` n'est pas dans le PATH)

Ouvrir dans l'éditeur Godot :

```bash
godot --editor --path prototype
```

## Contrôles (Jalon 0)

- **A / D** ou **← / →** : se déplacer
- **Espace / W / ↑** : sauter
- **Clic gauche** : creuser la tuile visée (dans le rayon autour du héros)

## État

- **Jalon 0 — mouvement & creusage** : monde de tuiles généré (terre/roche + cavités),
  déplacement avec gravité/collision, creusage à la souris avec progression + éclat de cassage,
  compteur de ressources (terre/roche).
- Tout est piloté par `scripts/Game.gd` ; les **valeurs réglables** (vitesse de creusage,
  gravité, saut, portée…) sont en haut du script.

> Prochains jalons (génération + lumière, inventaire/extraction, base/PNJ) : voir
> [`../docs/PROTOTYPE.md`](../docs/PROTOTYPE.md).
