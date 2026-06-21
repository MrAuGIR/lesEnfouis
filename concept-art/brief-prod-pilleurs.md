# Brief de PRODUCTION — Les PILLEURS (humains, sprites + anims)

> **À l'attention du / de la designer.** La **famille humaine** d'ennemis : les **pilleurs des
> tunnels** (faction du **Roi des Galeries**). Ils tiennent le **Transit** (gardiens de stations,
> patrouilles) et mènent les **raids** sur le Foyer. L'autre famille = les **robots** (brief
> séparé). Pixel art, mêmes règles techniques que le héros.
> 🖼️ Capture in-game : [`capture-pilleurs-in-situ.png`](capture-pilleurs-in-situ.png).

## 0. ⚠️ FORMAT DE REMISE
**ZIP de FICHIERS PNG**, pas de planche. RGBA transparent, **1× sans anti-aliasing**, cases
régulières, pieds calés au même pixel. Pas de halo/bloom peint, pas de label.

## 1. Qui ils sont
Des **survivants hostiles**, humains comme le héros mais **organisés et armés** — pillards
post-apo (ton Fallout/Metro). Ils doivent se lire **humains** (≠ robots inhumains) tout en étant
**clairement des ennemis** (tenue de faction, armes). Vus **de profil** (regard à DROITE).

## 2. Échelle, cases & pivots
- Tuiles 16 px (rendu interne ~384×216, ×2.5, Nearest).

| Archétype (code) | Rôle | Case | Pivot (x, pieds) |
|------------------|------|:----:|:----------------:|
| **Fonceur** (`fonceur`) | rusher mêlée, **cuir** | 32 × 32 | (16, 30) |
| **Tireur** (`tireur`) | distance, **treillis olive**, tir télégraphié | 32 × 32 | (16, 30) |
| **Lourd** (`lourd`) | blindé **acier**, lent, encaisse | 48 × 48 | (24, 46) |

- **Regard de référence à DROITE** (le moteur retourne — pas de miroir livré).

## 3. Les 3 archétypes (lecture visuelle)
- **Fonceur** — léger, **agressif/penché en avant**, **cuir** brun ; lecture « vitesse / corps-à-
  corps ». Arme de mêlée bricolée.
- **Tireur** — **treillis olive**, arme à feu visible ; doit pouvoir **annoncer son tir** (frame de
  télégraphe : épaule/canon qui se cale) ; recule au combat.
- **Lourd** — gros, **plaques d'acier**, casque/visière ; **blindé de FACE** (le jeu fait ×0,25 de
  face / ×1,5 de **dos**) → la **lecture face/dos est du gameplay** : devant = plaque/visière
  fermée, **dos = zone manifestement fragile** (sangles, sac, nuque exposée). Doit se lire **sans
  couleur** (forme/posture).

> **Cohérence de faction** : une **marque commune** (couleur de brassard, insigne, palette de la
> faction des pilleurs) relie les 3 → on lit « même bande ». À décliner par rôle.

## 4. Animations (sobres)
| Animation | Frames | Notes |
|-----------|:-----:|-------|
| idle | 2 | au repos, en garde |
| marche | 4 | déplacement au sol |
| attaque | 3-4 | **mêlée** (fonceur/lourd, arc) **ou tir** (tireur, recul + flash) ; tireur = frame de **télégraphe** |
| touché | 1-2 | sursaut/flash |
| mort | 3-5 | chute au sol |

## 5. Nommage & livrables
`enemy_<type>_<anim>_<NN>.png`, `<type>` ∈ { fonceur, tireur, lourd } (ou sprite sheet/anim + json).
**ZIP de fichiers**.

## 6. Accessibilité
Lisibles **petit** (~32 px). **Daltonisme** : rôle/état/face-dos jamais par la **seule couleur** →
silhouette/posture/insigne. Le traceur du tireur est dessiné par le moteur (ne pas le peindre).

## 7. Références
Fallout (pillards rétro-futuristes) · Metro (factions de tunnel) · Dead Cells / Hollow Knight
(silhouette + anim sobre).

> En résumé : **3 pilleurs humains (fonceur/tireur/lourd) animés**, 32/48, PNG RGBA 1×
> transparents, regard à droite, marque de faction commune, **Lourd lisible face/dos**, **ZIP de
> fichiers**.
