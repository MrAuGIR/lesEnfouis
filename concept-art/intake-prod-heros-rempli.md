# Brief de collecte — Production des sprites du héros (REMPLI)

> Valeurs **techniques** tirées du code (`game/`) et du look verrouillé
> ([LOOK-VERROUILLE.md](LOOK-VERROUILLE.md)). Les champs marqués **`(proposé)`** sont des
> conventions raisonnables, à confirmer/ajuster par le référent. Aucune décision de gameplay
> nouvelle n'a été inventée : tout découle de la bible et du proto jouable.

---

## 1. Informations générales

| Champ               | Valeur |
| ------------------- | ------ |
| Nom du projet       | **Les Enfouis** (The Buried) — MVP |
| Version du brief    | 1.0 |
| Date                | 2026-06-21 |
| Référent technique  | `À DÉCIDER` (porteur du projet) |
| Référent artistique | `À DÉCIDER` |

### Moteur de jeu

* [x] **Godot** (version **4.6.3 stable**)

---

## 2. Contraintes techniques

### Résolution

| Élément                  | Valeur |
| ------------------------ | ------ |
| Résolution interne       | **~384 × 216** (fenêtre 960×540 ÷ zoom caméra ×2.5 ; cible bible ~480×270) |
| Facteur d'agrandissement | **×2.5** (zoom caméra ; affichage typique ×3/×4) |
| Filtrage                 | **Nearest** (`default_texture_filter=0`) |

### Coordonnées

* Origine des sprites : **[x] Haut gauche** (convention Godot)
* Axe Y : **[x] Positif vers le bas**

### Grille

| Élément                     | Valeur |
| --------------------------- | ------ |
| Taille d'une tuile          | **16 px** |
| Taille d'une case de sprite | **32 × 32 px** |

### Pivot du personnage

| Élément             | Valeur |
| ------------------- | ------ |
| Pivot X             | **16** (centré horizontalement) |
| Pivot Y             | **30** (sur les pieds) |
| Ligne des pieds (Y) | **30** |

> Hitbox réelle du héros = **12 × 28 px** (collision). Le **corps** fait donc ~12-14 px de large
> et ~28 px de haut ; le **casque + lampe frontale** peuvent dépasser de 1-2 px vers le haut →
> hauteur visuelle totale **~30-32 px** dans la case 32×32. Pieds calés à **y=30** sur **toutes**
> les frames.

---

## 3. Pipeline d'intégration

### Format des sprites

* [x] **PNG individuels** (préféré) **ou** [x] sprite sheet par animation (au choix du designer)

Si sprite sheet :

* [x] **Horizontale** (frames alignées en ligne)

| Paramètre               | Valeur |
| ----------------------- | ------ |
| Espacement entre frames | **0 px** (cases strictement jointives 32×32) |
| Marges externes         | **0 px** |

### Métadonnées

* [x] **JSON** (si sprite sheet ; facultatif pour PNG individuels bien nommés)

```json
{
  "animation": "marche",
  "frameWidth": 32,
  "frameHeight": 32,
  "frames": 6,
  "fps": 10,
  "pivot": [16, 30]
}
```

### Convention de nommage

```text
hero_<anim>_<NN>.png      ex. hero_marche_00.png … hero_marche_05.png
```

> `<anim>` ∈ { idle, marche, saut_montee, saut_chute, echelle, creuse, melee, tir, touche, mort }.

---

## 4. Intégration moteur

### Gestion du miroir

* Le moteur retourne automatiquement les sprites : **[x] Oui** (flip horizontal selon le signe de
  la visée : regard droite si `aim.x ≥ 0`, gauche sinon).
* → **[x] Produire uniquement les versions DROITE** (ne pas livrer le miroir gauche).

### Gestion de la lumière

| Effet         | Oui | Non |
| ------------- | :-: | :-: |
| Halo          | **[x]** | |
| Cône lumineux | **[x]** | |
| Bloom         | | **[x]** |

> Le **halo** et le **cône de lampe** sont gérés par le moteur (PointLight2D + CanvasModulate, la
> lampe pivote vers la souris). **Pas de bloom** post-process.

Le sprite doit inclure :

* [x] **Lampe allumée uniquement** (la lampe frontale sur le casque, allumée/lumineuse comme
  point chaud) — **ne PAS peindre le halo ni le faisceau** (moteur).
* [x] **Reflet lumineux minimal** acceptable (accent chaud sur la tête).

---

## 5. Gameplay impactant les animations

### Déplacements

* [x] Marcher
* [x] *(grimper à l'échelle — voir anim « échelle »)*
* [ ] Courir · [ ] S'accroupir · [ ] Ramper · [ ] Nager · [ ] Glisser → **non implémentés**
* *Saut* : oui (anims saut montée/chute).

### Visée

* [x] **Visée libre à la souris** (mêlée = arc orienté vers la souris ; tir = hitscan 360° vers la
  souris).

> ⚠️ **Mais côté sprite, simplicité voulue :**
> * Le corps pivote : **Non** — uniquement un **flip horizontal** (droite/gauche) selon `aim.x`.
> * Les bras sont séparés du corps : **Non** (pas de couche bras rotative au MVP).
> * La direction réelle de la lampe et le traceur de tir sont **dessinés par le moteur**, pas par
>   le sprite. Le designer n'a donc **ni 8 directions ni bras séparés** à produire — juste le
>   héros de profil (regard droite).

### Outils et armes

* [x] **Pioche** (anim « creuse ») · [x] **Arme à feu** (anim « tir ») · [x] **Arme de mêlée**
  (anim « melee », arc orienté).
* Changement visuel de tenue selon l'équipement : **Aucun au MVP** (l'outil/arme est suggéré par
  l'anim, pas par un set de sprites distinct).

---

## 6. Liste des animations

| Animation        | Requise | Frames | FPS *(proposé)* | Notes |
| ---------------- | :-----: | :----: | :----: | ----- |
| idle             | ☑ | 2-3 | 4 | respiration légère, lampe allumée |
| marche           | ☑ | 4-6 | 10 | cycle au sol |
| course           | ☐ | — | — | non implémenté |
| saut (montée)    | ☑ | 1-2 | 8 | impulsion / montée |
| saut (chute)     | ☑ | 1-2 | 8 | descente |
| échelle          | ☑ | 2-4 | 8 | profil/dos, mains alternées |
| creuse           | ☑ | 3-4 | 12 | coup d'outil vers la tuile visée |
| attaque mêlée    | ☑ | 3-4 | 14 | **arc de cercle orienté** (feedback « sabre ») |
| tir              | ☑ | 2-3 | 12 | recul léger + flash court |
| touché           | ☑ | 1-2 | 12 | sursaut/flash |
| mort             | ☑ | 3-5 | 10 | chute au sol |

> Frames « indicatives » du brief de production — le designer peut ajuster légèrement en gardant le
> principe **sobre** (peu de frames). FPS = proposition d'intégration, ajustable.

---

## 7. Architecture modulaire (phase 2)

* Le personnage sera composé de couches : **[x] Oui** — **mais en phase 2**. Ce 1ᵉʳ lot = **héros de
  base unique, complet**. Concevoir toutefois la base pour que des calques se superposent plus tard
  **au même pixel près** (mêmes cases 32×32, même pivot 16,30).

| Couche *(ordre d'affichage proposé, 1 = derrière)* | Ordre |
| ------------------ | :---: |
| Sac à dos          | 1 |
| Corps / tenue      | 2 |
| Visage             | 3 |
| Cheveux            | 4 |
| Couvre-chef        | 5 *(doit gérer la lampe frontale ou prévoir un fallback)* |
| Accessoire main    | 6 *(devant)* |

---

## 8. Contraintes artistiques

### Taille cible

| Élément                        | Valeur |
| ------------------------------ | ------ |
| Hauteur approximative du héros | **~30-32 px** (corps ~28, casque/lampe inclus), pieds à y=30 |

### Références visuelles

```text
- concept-art/concept-hero.png (concept validé du héros)
- Metro 2033 / Fallout : survivant bricolé, lampe frontale, ton post-apo
- Dead Cells / Hollow Knight : lisibilité de silhouette, anim pixel art sobre
```

### Priorités *(proposé, d'après la bible)*

| Critère          | Note (1-5) |
| ---------------- | :--------: |
| Lisibilité       | **5** |
| Réalisme         | **1** *(pixel art stylisé, pas réaliste)* |
| Expressivité     | **4** |
| Modularité       | **4** *(avatar modulaire prévu phase 2)* |
| Niveau de détail | **2** *(volontairement sobre)* |

### Éléments distinctifs obligatoires

```text
- LAMPE FRONTALE sur le casque = signature (point chaud, repérable dans le noir).
- Survivant ORDINAIRE, fragile, BRICOLÉ (équipement de récup, pas un soldat).
- Palette désaturée + accent CHAUD de la lampe.
- Silhouette unique lisible à ~32 px (tester petit), regard de référence vers la DROITE.
- Daltonisme (porteur du projet) : un état (touché, etc.) ne doit pas reposer sur la seule
  couleur → doubler par forme/posture (le moteur ajoute déjà flash + son).
```

---

## 9. Critères de validation

* [x] Toutes les frames ont exactement la même taille (**32×32**).
* [x] Le pivot est identique sur toutes les frames (**16, 30**).
* [x] Les pieds restent alignés (**y=30**).
* [x] Aucun anti-aliasing.
* [x] Fond transparent (RGBA).
* [x] Sprites à l'échelle **1×**.
* [x] Nommage respecté.
* [x] Format de livraison conforme (**ZIP de fichiers**, pas de planche de présentation).

---

## 10. Documents à joindre

* [x] Ce document complété
* [x] GDD / extraits : `docs/04-direction-artistique.md`, `concept-art/LOOK-VERROUILLE.md`,
  `concept-art/brief-prod-heros.md`
* [x] Captures d'écran du jeu : *à fournir (héros grey-box en situation)*
* [x] Références visuelles : `concept-art/concept-hero.png`
* [ ] Exemple de sprite déjà intégré : **aucun** (le héros est encore en grey-box / rectangle — ce
  lot est le premier sprite réel)
* [x] Contraintes spécifiques du moteur : voir §2 et §4 (Godot 4.6, Nearest, flip moteur, lumière
  GPU)
* [x] Exemple de JSON : voir §3
