# Brief de collecte — Production des ROBOTS (REMPLI)

> Famille **machine** (l'autre famille = humains/pilleurs, fiche séparée). Valeurs tirées du code
> (`game/`). Brief de prod : [`brief-prod-robots.md`](brief-prod-robots.md).
> 🖼️ Capture in-game : [`capture-robots-in-situ.png`](capture-robots-in-situ.png).

## 1. Général
| Champ | Valeur |
| ----- | ------ |
| Projet / moteur | **Les Enfouis** — MVP · **Godot 4.6.3** |
| Date | 2026-06-21 |

## 2. Technique
| Élément | Valeur |
| ------- | ------ |
| Résolution interne / filtre | ~384×216 (×2.5), **Nearest** |
| Tuile | 16 px |
| Case de sprite | **32 × 32** · pivot **(16, 30)**, pieds y=30 |
| Origine / Y | Haut-gauche / Y vers le bas |

## 3. Périmètre
* **1 archétype en MVP** : **Rôdeur** (`robot`, KIND_ROBOT) — robot de base au contact, **au-dessus
  de la barrière uniquement**. (Robot-tireur / robot-lourd = lots futurs ; les rôles distance/lourd
  du MVP sont des **humains**.)

## 4. Pipeline
* PNG individuels **ou** sprite sheet/anim · nommage `enemy_robot_<anim>_<NN>.png` · **ZIP de
  fichiers** (jamais une planche).

## 5. Intégration moteur
* Miroir : **moteur retourne** → livrer **regard à DROITE** uniquement.
* Lumière : halo/cône **moteur**, **bloom non**. **Optique lumineuse** = redessinée par le moteur →
  fournir l'œil comme **point focal isolable**, ne pas peindre le halo.
* Pas de visée libre / pas de bras séparés (le robot fait face au héros, flip).

## 6. Animations
idle (2) · déplacement (4) · attaque mêlée (3-4) · touché (1-2) · destruction (3-5). Sobre.

## 7. Registres (bible §5)
**solitaire = optique AMBRE vacillant** (rouillé) · **contrôlé = optique ROUGE fixe + emblème « N »**.
Livrer au moins la version **solitaire ambre** ; le registre va dans le nom/readme.

## 8. Artistique
Silhouette **INHUMAINE** (non-humanoïde), optique = point focal, ressort du décor industriel.
Priorités *(proposé)* : Lisibilité 5 · Réalisme 1 · Expressivité (optique) 4 · Détail 2.
**Daltonisme** : registre/état jamais par la seule couleur (forme + comportement de la lueur).

## 9. Validation
Frames de taille identique · pivot/pieds constants · pas d'AA · fond transparent · 1× · regard à
droite · optique isolable · **ZIP de fichiers**.

## 10. Documents joints
* [x] Cette fiche · [`brief-prod-robots.md`](brief-prod-robots.md) ·
  [`brief-concept-ennemi-robot.md`](brief-concept-ennemi-robot.md) · [`LOOK-VERROUILLE.md`](LOOK-VERROUILLE.md)
* [x] Concept : [`concept_enemis_robot.png`](concept_enemis_robot.png)
* [x] Capture in-game : [`capture-robots-in-situ.png`](capture-robots-in-situ.png)
* [ ] Sprite déjà intégré : **aucun** (grey-box)
