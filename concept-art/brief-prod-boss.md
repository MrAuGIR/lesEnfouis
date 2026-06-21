# Brief de PRODUCTION — Le BOSS : le ROI DES GALERIES (sprites + anims)

> **À l'attention du / de la designer.** Le **boss du MVP** : **le Roi des Galeries**, **chef humain
> de la faction des pilleurs** des tunnels. Il trône dans un **TERMINAL scellé** au bout de l'axe de
> métro inférieur ; les portes se referment derrière le héros — le combat va au bout. Pixel art,
> mêmes règles techniques que le héros, mais **personnage imposant et unique**.
> 🖼️ Capture in-game : [`capture-boss-in-situ.png`](capture-boss-in-situ.png) (le Roi + 2 sbires +
> héros pour l'échelle).

## 0. ⚠️ FORMAT DE REMISE
**ZIP de FICHIERS PNG**, pas de planche. RGBA transparent, **1× sans anti-aliasing**, cases
régulières, pieds calés au même pixel. Pas de halo/vapeur/bloom peint (effets = moteur), pas de label.

## 1. Qui il est (lore figé)
Un **humain démesuré**, **roi-brute** des pilleurs : **couronné**, **pourpre/royal**, brutal mais
charismatique (humour Fallout, menace Metro). Il doit se lire **humain de la même faction que les
pilleurs** (cohérence) mais **boss** : plus **grand**, plus **orné** (couronne, trophées, plaques),
**imposant**. Vu de profil, **regard de référence à DROITE**.

## 2. Échelle & case
- Tuiles 16 px. **Hitbox de jeu ≈ 20 × 26 px** (un peu plus grand que le héros) — mais le **sprite
  peut/doit DÉBORDER** pour l'imposer : **case 64 × 64 px** (ou 48×64), héros **centré**, **pieds
  calés** sur la même ligne (ex. y=60 dans une case 64), couronne/épaules qui dépassent vers le haut.
- **Regard à DROITE** (le moteur retourne — pas de miroir livré).

## 3. Pattern de combat → ce que les anims doivent porter
(Le combat est déjà codé ; les sprites l'habillent.)
- **Phase 1** : il **traque** (marche d'approche) → **télégraphe** (~0,8 s d'arrêt, se ramasse) →
  **CHARGE** en ligne droite (esquive verticale) → parfois **FRAPPE AU SOL** (slam) qui fait
  **pleuvoir des gravats** (les gravats/ondes sont dessinés par le moteur).
- **Vagues de sbires** aux paliers de PV (75/50/25 %) : il **invoque** (un geste d'appel est un plus).
- **Phase 2 — ENRAGE à 50 %** : **plus vite, plus fort**, **jets de vapeur** périodiques (la vapeur
  est moteur, mais prévoir une **variante visuelle enragé** : posture/teinte plus agressive, yeux/
  couronne qui rougeoient).
- **Vaincu** : il **lâche la CHARGE DE PERÇAGE** (l'objet-clé qui ouvre la barrière) → anim de
  **mort** lisible (s'effondre).

## 4. Animations demandées
| Animation | Frames | Notes |
|-----------|:-----:|-------|
| idle / trône | 2-3 | menaçant, en attente (portes scellées) |
| marche (traque) | 4 | approche lourde |
| télégraphe | 2 | se ramasse avant la charge (lecture « ! » imminente) |
| charge | 2 | lancé en ligne droite |
| frappe au sol (slam) | 3-4 | impact (le moteur ajoute l'onde/gravats) |
| invocation | 2-3 | geste d'appel des sbires *(optionnel mais bienvenu)* |
| enrage (variante) | — | **set d'idle/charge enragé** ou overlay (yeux/couronne rougeoyants, posture) |
| touché | 1-2 | sursaut/flash |
| mort | 4-6 | s'effondre, lâche la charge de perçage |

## 5. Nommage & livrables
`boss_roi_<anim>_<NN>.png` (ou sprite sheet/anim + json). Variante enragé suffixée `_enrage`.
**ZIP de fichiers**.

## 6. Accessibilité
Silhouette **unique et imposante**, lisible même petite. **Daltonisme** : phase enrage / télégraphe
ne reposent **pas sur la seule couleur** → posture/forme (le moteur ajoute « ! », jauge, vapeur, son).

## 7. Sbires
Les sbires du Roi = **pilleurs normaux** (voir [`brief-prod-pilleurs.md`](brief-prod-pilleurs.md)) →
**rien à produire ici**.

## 8. Références
Fallout (chef de faction haut en couleur) · Metro (seigneur de tunnel) · boss pixel art lisibles
(Dead Cells) — imposant mais **télégraphie claire**.

> En résumé : **le Roi des Galeries**, gros humain couronné pourpre, case **64×64** (déborde la
> hitbox ~20×26), anims idle/marche/télégraphe/charge/slam/(invocation)/enrage/touché/mort, PNG
> RGBA 1× transparents, regard à droite, **ZIP de fichiers**. Sbires = pilleurs (lot séparé).
