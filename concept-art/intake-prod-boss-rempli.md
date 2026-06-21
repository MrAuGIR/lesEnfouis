# Brief de collecte — Production du BOSS (le Roi des Galeries, REMPLI)

> Boss du MVP : **le Roi des Galeries** (humain, chef des pilleurs). Valeurs tirées du code
> (`game/scripts/boss.gd`, `enemy_crew.gd`). Brief de prod : [`brief-prod-boss.md`](brief-prod-boss.md).
> 🖼️ Capture in-game : [`capture-boss-in-situ.png`](capture-boss-in-situ.png).

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
| **Hitbox de jeu** | ≈ **20 × 26 px** |
| **Case de sprite** | **64 × 64** (le sprite **déborde** la hitbox pour imposer le boss) · pivot **(32, 60)**, pieds y=60 |
| Origine / Y | Haut-gauche / Y vers le bas |

## 3. Pipeline
PNG individuels **ou** sprite sheet/anim · `boss_roi_<anim>_<NN>.png` (variante `_enrage`) · **ZIP de
fichiers** (jamais une planche).

## 4. Intégration moteur
* Miroir : **moteur retourne** → **regard à DROITE** uniquement.
* Lumière : halo/cône **moteur**, **bloom non**. **Effets dessinés par le moteur** (à NE PAS
  peindre) : onde/**gravats** du slam, **jets de vapeur** de l'enrage, « ! » de télégraphe, **jauge
  de PV** d'arène, lueurs.
* Le boss vit dans la liste des ennemis (`crew.list`, flag « boss ») mais est **piloté par
  `boss.gd`** : il fait face au héros (flip), pas de visée libre.

## 5. Gameplay → animations (pattern déjà codé)
Traque → **télégraphe** (~0,8 s) → **charge** ligne droite → **slam** (gravats) ; **vagues de
sbires** à 75/50/25 % PV ; **ENRAGE à 50 %** (plus vite/fort + vapeur) ; vaincu → lâche la **charge
de perçage**.

| Animation | Frames | Notes |
| --------- | :----: | ----- |
| idle / trône | 2-3 | en attente, menaçant |
| marche (traque) | 4 | approche lourde |
| télégraphe | 2 | se ramasse avant la charge |
| charge | 2 | lancé droit |
| slam (frappe sol) | 3-4 | impact (onde/gravats = moteur) |
| invocation | 2-3 | geste d'appel *(optionnel)* |
| enrage (variante) | — | idle/charge enragés ou overlay (couronne/yeux rougeoyants) |
| touché | 1-2 | sursaut/flash |
| mort | 4-6 | s'effondre, lâche la charge de perçage |

## 6. Artistique
**Humain démesuré, couronné, pourpre/royal**, **même faction que les pilleurs** mais **boss**
(plus grand, plus orné, imposant). Priorités *(proposé)* : Lisibilité 5 · Expressivité 4 ·
Imposance/silhouette 5 · Réalisme 2 · Détail 3.
**Daltonisme** : enrage/télégraphe lisibles par **posture/forme**, pas la seule couleur (le moteur
double avec « ! », jauge, vapeur, son).

## 7. Sbires
= **pilleurs normaux** ([`brief-prod-pilleurs.md`](brief-prod-pilleurs.md)) → **rien à produire ici**.

## 8. Validation
Frames de taille identique (64×64) · pivot/pieds constants · pas d'AA · fond transparent · 1× ·
regard à droite · effets non peints (moteur) · **ZIP de fichiers**.

## 9. Documents joints
* [x] Cette fiche · [`brief-prod-boss.md`](brief-prod-boss.md) · [`LOOK-VERROUILLE.md`](LOOK-VERROUILLE.md)
* [x] Capture in-game : [`capture-boss-in-situ.png`](capture-boss-in-situ.png)
* [ ] Sprite déjà intégré : **aucun** (grey-box pourpre + couronne dessinée par le moteur)
