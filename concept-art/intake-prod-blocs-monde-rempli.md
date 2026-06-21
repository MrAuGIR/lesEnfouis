# Brief de collecte — Production des BLOCS DU MONDE (tileset, REMPLI)

> Fiche d'intake adaptée aux **tuiles statiques** (pas d'animation ni de pivot ; ici ce sont le
> **tuilage**, la **lecture creusable/non** et la **transparence** qui comptent). Valeurs tirées du
> code (`game/scripts/tile_art.gd`, `world_grid.gd`). Voir le brief de prod :
> [`brief-prod-blocs-monde.md`](brief-prod-blocs-monde.md).
> 🖼️ Capture in-game jointe : [`capture-blocs-monde-in-situ.png`](capture-blocs-monde-in-situ.png)
> (bande témoin de tous les types + échelle/passerelle, dans la lumière de la grotte).

## 1. Informations générales

| Champ | Valeur |
| ----- | ------ |
| Projet | **Les Enfouis** — MVP · Moteur **Godot 4.6.3** |
| Date | 2026-06-21 |
| Couches concernées | **Foyer / Transit** (les autres déclineront le même tileset par re-teinte) |

## 2. Contraintes techniques

| Élément | Valeur |
| ------- | ------ |
| Résolution interne | ~384×216 (×2.5), **filtre Nearest** |
| **Taille d'une tuile** | **16 × 16 px** (figée) |
| Taille de fichier | **exactement 16 × 16 px, à 1×** |
| Origine / grille | Haut-gauche, alignée sur la grille 16 (pas de pivot, pas de sous-pixel) |
| Format | **PNG RGBA** |

## 3. Pipeline d'intégration

* **PNG individuels**, **un fichier par tuile**, nommés `tile_<nom>.png` (voir §6).
* Pas de métadonnées requises (les ids sont gérés côté code).
* **ZIP de fichiers** (jamais une planche/contact-sheet).

## 4. Intégration moteur

* **Pas de miroir** (les tuiles ne sont pas retournées).
* **Lumière GPU ponctuelle** : la tuile n'embarque **aucune lumière cuite** ; elle doit **rendre du
  volume sous un éclairage de côté** → prévoir un **micro-relief / léger biseau** (bords haut-gauche
  un peu clairs, bas-droite un peu sombres) qui sépare visuellement les tuiles. **Pas de bloom.**
* **Opacité :** les blocs pleins = **opaques bord à bord** (alpha 255). **Seules** l'échelle et la
  passerelle ont de la **vraie transparence** (voir §6).

## 5. Tuilage & lecture (remplace « animations »)

* **Sans couture** : chaque bloc plein doit se **répéter en damier 3×3 sans joint visible** (le monde
  en est pavé). Fournir une **preuve 3×3** par bloc.
* **Règle de lecture n°1** : distinguer d'un coup d'œil **creusable** vs **NON creusable**.
* **Minerais = la FORME distingue, pas la couleur** (daltonisme) : lithium = **cristaux ANGULAIRES**,
  fer = **nodules RONDS**, bois = **grain vertical + nœud**.

## 6. Liste des tuiles à produire (ids réels du jeu)

| Fichier | Tuile | Catégorie | Contrainte de lecture |
| ------- | ----- | --------- | --------------------- |
| `tile_dirt.png` | terre | creusable | brun chaud granuleux, « tendre » |
| `tile_rock.png` | roche | creusable | gris froid, fissures, « dur » |
| `tile_wood.png` | bois | ressource | grain **vertical** + nœud |
| `tile_lithium.png` | lithium | minerai | **cristaux angulaires** dans la gangue |
| `tile_iron.png` | fer | minerai | **nodules ronds** dans la gangue |
| `tile_wall.png` | mur béton | **non creusable** | appareil de blocs à joints = « bâti » |
| `tile_hardrock.png` | roche dure | **barrière INDESTRUCTIBLE** | **striations diagonales serrées**, tranche avec la roche |
| `tile_crate.png` | caisse | objet | planches + **croix de renfort** + cadre, « fermé » |
| `tile_crate_open.png` | caisse vidée | objet | couvercle **ouvert**, intérieur sombre, « vide » |
| `tile_boss_door.png` | porte du Roi | objet | métal rouillé, **vantaux + chevrons + rivets** (forme, pas que le rouge) |
| `tile_ladder.png` | échelle | **transparent** | 2 montants + barreaux, **transparent entre**, empilable sans couture |
| `tile_passerelle.png` | passerelle | sol | **planches horizontales**, **pas de bord vertical** (raccord continu G/D) |

## 7. Variantes (optionnel, bienvenu)

* Si la répétition se voit : `tile_rock_a/b/c.png`, `tile_dirt_a/b/c.png` (mêmes contraintes,
  interchangeables). Autotiling = phase ultérieure.

## 8. Contraintes artistiques

| Critère | Note (1-5) *(proposé)* |
| ------- | :--: |
| Lisibilité (creusable/non, minerais) | 5 |
| Raccord sans couture | 5 |
| Réalisme | 1 |
| Niveau de détail | 2 |

* Palettes : **Foyer** ocres/ambré chauds · **Transit** gris-bleu froid/béton. Concevoir les blocs
  neutres pour supporter une **re-teinte par couche**.
* **Daltonisme** : aucune tuile distinguée par la **seule couleur**.

## 9. Critères de validation

* [x] Chaque fichier exactement **16×16**, **1×**, **aucun anti-aliasing**, RGBA.
* [x] Blocs pleins **opaques & tuilables** (preuve **3×3** fournie) ; échelle/passerelle
  **transparentes** comme spécifié.
* [x] Minerais distincts **par la forme** ; creusable/non lisible d'un coup d'œil.
* [x] Nommage respecté · **ZIP de fichiers** (pas de planche).

## 10. Documents joints

* [x] Cette fiche · [`brief-prod-blocs-monde.md`](brief-prod-blocs-monde.md) ·
  [`LOOK-VERROUILLE.md`](LOOK-VERROUILLE.md)
* [x] Capture in-game (bande témoin, échelle + lumière) :
  [`capture-blocs-monde-in-situ.png`](capture-blocs-monde-in-situ.png)
* [x] Référence de lecture : les placeholders code (`game/scripts/tile_art.gd`) respectent déjà
  toutes les contraintes de forme — l'art fini doit faire **au moins aussi lisible**, en plus joli.
