# Brief de PRODUCTION — Les ROBOTS (famille machine, sprites + anims)

> **À l'attention du / de la designer.** Une des **deux familles d'ennemis** du jeu (l'autre = les
> **humains / pilleurs**, brief séparé [`brief-prod-pilleurs.md`](brief-prod-pilleurs.md)). Le
> **concept** est validé ([brief concept](brief-concept-ennemi-robot.md) ·
> [planche](concept_enemis_robot.png) · [look §5](LOOK-VERROUILLE.md)). Ici = les **sprites
> jouables** des robots. Mêmes règles techniques que le héros.
> 🖼️ Capture in-game : [`capture-robots-in-situ.png`](capture-robots-in-situ.png).

## 0. ⚠️ FORMAT DE REMISE (ça a coincé plusieurs fois)
**ZIP de FICHIERS PNG**, pas de planche. RGBA fond transparent, **1× sans anti-aliasing**, cases
régulières, sprite calé au même pixel (mêmes pieds). Pas de bloom/halo peint, pas de label.

## 1. Périmètre MVP — ⚠️ important
Dans le jeu jouable, **un seul archétype robot existe pour l'instant** :
- **Rôdeur** (`robot`) — robot de base qui va au contact, **présent UNIQUEMENT au-dessus de la
  barrière** (les profondeurs/Transit sont aux humains). C'est la **piétaille machine**.

> Les rôles **tireur** et **lourd** du MVP sont tenus par des **humains (pilleurs)** → voir leur
> brief. Les **variantes robots** (robot-tireur, robot-lourd) viendront en **lot ultérieur** : on
> ne les produit PAS maintenant. Ce lot = **le Rôdeur**, soigné.

## 2. Échelle & case
- Tuiles 16 px (rendu interne ~384×216, ×2.5, Nearest). **Case 32 × 32**, pieds calés (pivot ~16,30).
- **Regard de référence à DROITE** (le moteur retourne pour la gauche — ne pas livrer le miroir).

## 3. Identité visuelle (le cœur)
- **INHUMAIN** : silhouette **non-humanoïde** (chenilles / pattes / bras-outils / châssis bas) pour
  trancher net avec le héros fragile et les pilleurs humains.
- **Optique = point focal** : c'est la seule « expression » d'un robot ; une lueur qui s'allume =
  menace active. **Les yeux LUISENT dans le noir** (le moteur redessine la lueur par-dessus
  l'obscurité) → fournir l'optique comme **zone nette isolable**, sans peindre le halo.
- **Deux registres** (bible §5), à anticiper même si le MVP n'a que le Rôdeur :
  **solitaire délabré = optique AMBRE vacillant** (rouillé, dépareillé) ·
  **contrôlé militaire = optique ROUGE fixe + emblème « N »** (propre, coordonné). Livrer le Rôdeur
  au moins en version **solitaire ambre** (la plus fréquente en MVP), idéalement aussi en **contrôlé
  rouge**.
- Doit **ressortir du décor industriel** (métal/rouille) via le contraste de l'optique + silhouette
  nette.

## 4. Animations (sobres)
| Animation | Frames | Notes |
|-----------|:-----:|-------|
| idle | 2 | optique qui luit/vacille |
| déplacement | 4 | roulement/marche selon le châssis |
| attaque (mêlée) | 3-4 | coup au contact |
| touché | 1-2 | sursaut/flash mécanique |
| destruction (mort) | 3-5 | s'effondre / étincelles (pas de gore) |

## 5. Nommage & livrables
`enemy_robot_<anim>_<NN>.png` (ou sprite sheet/anim `enemy_robot_<anim>.png` + json frames/fps).
Préciser le registre dans le nom/readme (`_amber` / `_red`). **ZIP de fichiers**.

## 6. Accessibilité
Silhouette lisible **petit** (~32 px). **Daltonisme** : état/registre jamais par la **seule
couleur** → forme/posture/clignotement (le moteur ajoute flash + son). Ambre ≠ rouge doit aussi se
lire par le **comportement de la lueur** (vacillant vs fixe).

## 7. Références
Horizon / NieR (optique expressive) · Metro / Fallout (métal usé, militaire) · Dead Cells /
Hollow Knight (anim sobre).

> En résumé : **le Rôdeur (robot de base) animé**, 32×32, PNG RGBA 1× transparents, regard à droite,
> optique = point focal (ambre solitaire / rouge contrôlé), inhumain, **ZIP de fichiers**. Variantes
> robots et boss = lots séparés.
