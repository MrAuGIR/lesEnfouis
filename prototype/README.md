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

## Contrôles

- **A / D** ou **← / →** : se déplacer · **Espace / W / ↑** : sauter
- **Clic gauche** : creuser la tuile visée (dans le rayon autour du héros)
- **R** : recharger la lampe (lithium) · **T** : poser une torche (bois)
- **E** : déposer à la base (si proche) / récupérer une cache (si proche)
- **Q** : retirer de la base vers le sac (si proche — priorité au carburant)
- **K** : mourir (test — largue le butin dans une cache)

## État

- **Jalon 0 — mouvement & creusage** : déplacement avec gravité/collision, creusage à la souris
  avec progression + éclat de cassage, compteur de ressources (terre/roche). ✅
- **Jalon 1 — génération & lumière** : monde généré par **bruit** (relief de surface, cavités,
  filons de roche, **bunkers abandonnés** préfabriqués) ; **mécanique de lumière** : obscurité +
  **lampe frontale (casque)** = **faisceau dirigé vers la souris** + halo doux autour du corps,
  lumière du jour déclinant avec la profondeur, et **occlusion** (la lumière s'arrête aux murs). ✅
- **Jalon 1b — carburant & torches** : la **lampe frontale se vide** (autonomie limitée) et
  **faiblit** quand l'énergie est basse. Deux énergies distinctes et **deux origines** :
  on **mine du lithium** (dans la roche) pour **recharger la lampe** (`R`), et on **récupère du
  bois dans les bunkers abandonnés** (structures en béton) pour **poser des torches** (`T`,
  flamme). Le bois ne se trouve **pas** dans la terre — c'est un matériau humain à fouiller. ✅
- **Jalon 2 — sac limité, dépôt & mort** : le **sac a une capacité** (au-delà, le butin ramassé
  est perdu) ; on **dépose** à la **base** (zone verte au point de départ, `E`) pour vider le sac
  et se soigner ; **PV + dégâts de chute** ; à la **mort**, le butin transporté tombe dans une
  **cache récupérable** (`E`) sur place (façon Souls), et on **réapparaît à la base**. ✅
- Tout est piloté par `scripts/Game.gd` ; les **valeurs réglables** (vitesse de creusage,
  gravité, saut, portée, **rayon/portée de lumière**…) sont en haut du script.

> Prochains jalons (inventaire/extraction + mort, base/PNJ + craft) : voir
> [`../docs/PROTOTYPE.md`](../docs/PROTOTYPE.md).
