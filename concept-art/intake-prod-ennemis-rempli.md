# Brief de collecte — Production des sprites des ENNEMIS (REMPLI)

> Même structure que la fiche héros, adaptée aux **4 archétypes robots** du MVP. Valeurs
> techniques tirées du code (`game/`) et du look verrouillé. Champs `(proposé)` = ajustables.
> Voir aussi le brief de production : [`brief-prod-ennemis.md`](brief-prod-ennemis.md).
> 🖼️ Capture in-game jointe : [`capture-ennemis-in-situ.png`](capture-ennemis-in-situ.png)
> (les 4 archétypes en grey-box alignés, héros à gauche pour l'échelle).

## 1. Informations générales

| Champ | Valeur |
| ----- | ------ |
| Projet | **Les Enfouis** (The Buried) — MVP |
| Moteur | **Godot 4.6.3 stable** |
| Date | 2026-06-21 |

## 2. Contraintes techniques

| Élément | Valeur |
| ------- | ------ |
| Résolution interne | **~384×216** (fenêtre 960×540 ÷ zoom ×2.5) |
| Agrandissement / filtre | **×2.5**, **Nearest** |
| Taille de tuile | **16 px** |
| Origine / axe Y | Haut-gauche / Y vers le bas |

### Cases de sprite & pivot (par archétype)

| Archétype (code) | Case | Pivot (x, pieds y) |
| ---------------- | :--: | :----------------: |
| **Robot** (`robot`) | **32 × 32** | (16, 30) |
| **Pilleur/Fonceur** (`fonceur`) | **32 × 32** | (16, 30) |
| **Tireur** (`tireur`) | **32 × 32** | (16, 30) |
| **Lourd** (`lourd`) | **48 × 48** | (24, 46) |

> Toutes les frames d'un archétype à la **même case**, **pieds calés** sur la même ligne. Le Lourd
> est plus gros (gros châssis blindé) → case 48.

## 3. Pipeline d'intégration

* Format : **[x] PNG individuels** ou **[x] sprite sheet par animation** (horizontale, cases
  jointives, espacement 0).
* Nommage : `enemy_<type>_<anim>_<NN>.png` — `<type>` ∈ { robot, fonceur, tireur, lourd }.
* Métadonnées JSON facultatives (frames, fps, pivot) si sprite sheet.
* **Livraison en ZIP de fichiers** (jamais une planche de présentation).

## 4. Intégration moteur

* Miroir : **[x] le moteur retourne** (l'ennemi se tourne vers le héros) → **livrer regard à DROITE
  uniquement**.
* Lumière : halo/cône **[x] moteur**, bloom **[x] non**. **Les yeux/optique LUISENT** : le moteur
  redessine la lueur de l'œil par-dessus l'obscurité → fournir l'**optique comme zone nette isolable**
  (forme/couleur), **sans peindre le halo**.
* Le sprite inclut : **lampe/optique allumée** (point focal), pas d'effet lumineux peint autour.

## 5. Gameplay impactant les animations

* Déplacement : **marche/roulement** au sol (pas de saut/échelle pour les ennemis du MVP).
* Visée : **aucune visée libre** — l'ennemi **fait face au héros** (flip horizontal). Pas de bras
  séparés, pas de 8 directions. Le **traceur du Tireur** est dessiné par le moteur.
* Attaques : mêlée (Robot/Fonceur/Lourd) **ou** tir (Tireur, avec **frame de télégraphe** =
  optique qui vise / canon qui s'arme).
* ⚠️ **Lourd** : **blindé de FACE** (×0,25 dégâts), **vulnérable de DOS** (×1,5) → la lecture
  « plaque devant / point faible derrière » doit être **visible par la forme** (plaque/visière vs
  dos exposé), pas par la couleur.

## 6. Liste des animations (par archétype, sobres)

| Animation | Requise | Frames | FPS *(proposé)* | Notes |
| --------- | :-----: | :----: | :----: | ----- |
| idle | ☑ | 2 | 4 | optique qui luit/vacille |
| déplacement | ☑ | 4 | 10 | marche/roulement/glisse |
| attaque | ☑ | 3-4 | 12 | mêlée **ou** tir ; Tireur = frame de télégraphe |
| touché | ☑ | 1-2 | 12 | sursaut/flash mécanique |
| destruction (mort) | ☑ | 3-5 | 10 | s'effondre / étincelles (pas de gore) |

## 7. Registres & modularité

* **Deux registres lisibles d'un coup d'œil** (cf. bible §5) :
  **solitaires délabrés = optique AMBRE vacillant** · **contrôlés militaires = optique ROUGE fixe +
  emblème « N »**. Indiquer le registre dans le nom (`_amber` / `_red`) ou un readme. Au moins le
  **Rôdeur** décliné dans les deux registres si possible.
* Châssis **modulaires** (concept) : penser réutilisable, mais ce lot = **les 4 archétypes finis**.

## 8. Contraintes artistiques

| Critère | Note (1-5) *(proposé)* |
| ------- | :--: |
| Lisibilité | 5 |
| Réalisme | 1 |
| Expressivité (optique) | 4 |
| Modularité (châssis) | 3 |
| Niveau de détail | 2 *(sobre)* |

* **Éléments distinctifs obligatoires** : silhouette **INHUMAINE** (non-humanoïde : chenilles/pattes/
  bras-outils/châssis bas), **optique = point focal** (ambre solitaire / rouge contrôlé), doit
  **ressortir du décor industriel** (métal/rouille), Lourd **lisible face/dos**.
* **Daltonisme** : état (touché, télégraphe, registre) jamais par la **seule couleur** → forme/
  posture/clignotement.

## 9. Critères de validation

* [x] Frames d'un archétype de taille identique · pivot/pieds constants.
* [x] Aucun anti-aliasing · fond transparent (RGBA) · échelle 1×.
* [x] Regard à droite uniquement · optique isolable (point focal).
* [x] Nommage respecté · **ZIP de fichiers** (pas de planche).

## 10. Documents joints

* [x] Cette fiche · [`brief-prod-ennemis.md`](brief-prod-ennemis.md) ·
  [`brief-concept-ennemi-robot.md`](brief-concept-ennemi-robot.md) ·
  [`LOOK-VERROUILLE.md`](LOOK-VERROUILLE.md)
* [x] Concept validé : [`concept_enemis_robot.png`](concept_enemis_robot.png)
* [x] Capture in-game (échelle + lumière) : [`capture-ennemis-in-situ.png`](capture-ennemis-in-situ.png)
* [ ] Sprite déjà intégré : **aucun** (ennemis encore en grey-box / rectangles)
