# Retour n°2 — Décor de fond (assets `assets_decor.png`)

> Réponse à la livraison `assets/assets_decor.png` (atlas 3×2 RGBA :
> `bg_roche` + 2 variantes, `bg_tunnel_paroi`, `bg_tunnel_structures`, `bg_base`).
> **Merci — la qualité visuelle et la direction sont excellentes.** Mais après test technique,
> **les textures ne se répètent pas** : elles ne sont pas intégrables en l'état. Ce retour
> explique précisément le problème et le format exact attendu.

## Le problème : ce ne sont pas des textures tuilables

Le décor est **tuilé** (répété) en jeu pour couvrir un monde immense. Or les assets livrés sont
des **rendus d'aperçu**, pas des tuiles qui bouclent. Preuve : en les répétant en **3×3**
(image jointe [`retour-decor-fond-v2-preuve-tuilage.png`](retour-decor-fond-v2-preuve-tuilage.png)) :

- **Roche** : des **coutures** apparaissent aux raccords (les bords gauche/droite et haut/bas ne
  correspondent pas).
- **Base** : **ne tuile pas du tout** — c'est une **scène composée** avec une **lampe allumée
  centrée**, un cadre, des vents. Répétée, on obtient une **grille de pièces identiques**.

Autres soucis de forme : tuiles à **tailles variables** (~320 px, différentes d'une à l'autre),
**labels** posés sur le canevas, **marges/transparence** autour de chaque tuile.

## Ce qui est BON (à garder)

- Le **look**, la **palette par contexte**, l'ambiance sous la lampe : parfait.
- La couche `bg_tunnel_structures` a une **vraie transparence** (alpha) : exactement ce qu'il
  faut. C'est le bon principe — à appliquer partout.
- Les **variantes** de roche : très bien (on en veut).

## Règle d'or : une texture de fond DOIT boucler

> **Test à faire avant de livrer :** coller la tuile **3×3** (9 fois). Si on **voit la grille** ou
> une couture → ce n'est pas bon. On ne doit voir **aucun raccord** : bord **gauche = droite**,
> bord **haut = bas** (« seamless »).

Conséquence directe : **pas d'élément focal ni centré** dans une tuile de fond (pas de lampe
unique, pas de cadre au milieu). Une tuile = une **matière qui se répète** (roche, paroi,
panneaux de mur), homogène.

## Les éléments « déco » → fichiers SÉPARÉS (props)

Les jolis détails (lampe, cadre, vents, valves, tuyaux isolés…) sont géniaux, mais ils doivent
être livrés **à part**, en **PNG transparents individuels** (un par élément). On les **posera
ponctuellement** par-dessus le mur tuilé. Ainsi le mur reste répétable et la déco reste rare et
crédible. C'est **comme la couche `structures`** : même logique, étendue aux props.

## Livrables attendus (format STRICT)

Un **fichier PNG par asset** (pas d'atlas, pas de labels, pas de marge/vignette) :

| Fichier | Contenu | Format |
|---------|---------|--------|
| `bg_roche.png` (+ `_var1`, `_var2`) | matière roche, **homogène, sans élément focal** | opaque, **tuilable** |
| `bg_tunnel_paroi.png` | paroi du tunnel, matière homogène | opaque, **tuilable** |
| `bg_tunnel_structures.png` | étais/tuyaux **répartis pour boucler** (pas une scène) | **RGBA transparent**, **tuilable** |
| `bg_base.png` (+ variantes) | mur de pièce, **panneaux qui se répètent, SANS lampe centrée** | opaque, **tuilable** |
| `prop_*.png` | déco isolée : `prop_lampe`, `prop_cadre`, `prop_vent`, `prop_valve`… | **RGBA transparent**, 1 par fichier |

**Contraintes techniques :**
- **Dimensions fixes et identiques** par famille — choisir **64×64** ou **128×128** px, et **le
  dire**. Mêmes dimensions pour `bg_tunnel_paroi` et `bg_tunnel_structures` (elles se superposent).
- **Tuilable sur les 4 bords** (testé en 3×3).
- **Pixel art net, exporté à 1×** (le jeu agrandit en Nearest ×3-4) — **pas d'anti-aliasing**.
- **Pas de label, pas de cadre/marge, pas de vignette** autour de la tuile.
- **Transparence réelle** (alpha) pour `structures` et tous les `prop_*`.

> En résumé : **mêmes textures, même style — mais qui bouclent**, à **taille fixe**, **un fichier
> par asset**, et la **déco focale sortie en props transparents séparés**. Avec ça, l'intégration
> est immédiate (le moteur gère déjà fond contextuel + parallaxe).
