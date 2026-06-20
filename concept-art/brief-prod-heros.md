# Brief de PRODUCTION — Le Héros (sprites + animations)

> **À l'attention du / de la designer.** Le **concept** du héros est déjà validé
> ([brief concept](brief-concept-heros.md) · planche [`concept-hero.png`](concept-hero.png) ·
> [retour](retour-concept-heros.md) · [look verrouillé §4](LOOK-VERROUILLE.md)). Ici on demande les
> **assets jouables** : les sprites animés du héros, prêts à intégrer. Pixel art, échelle figée.

## 0. ⚠️ FORMAT DE REMISE — à lire en premier (ça a coincé sur le décor)

Sur le décor, on a reçu 3× des **planches de présentation** (image unique, props sur damier, tailles
variables) → **inintégrable**. Pour le héros, on a besoin des **FICHIERS RÉELS**, pas d'une planche.

- **Livrer un .ZIP** contenant les fichiers (PNG), **pas** une image-planche unique.
- **PNG à transparence réelle (RGBA)**, fond **transparent** (pas de damier dessiné, pas de couleur
  de fond, pas de vignette, pas de cadre, pas de label écrit sur l'image).
- **Pixel art net, à 1×** (le jeu agrandit en Nearest ×3-4) : **aucun anti-aliasing**, pas d'upscale.
- **Toutes les frames à la MÊME taille de case** (voir §2), le héros **calé au même endroit** dans
  chaque case (mêmes pieds au même pixel) → sinon ça « saute » à l'animation.
- **Convention de nommage** claire (voir §4).
- Une **planche d'aperçu** (contact sheet) est la bienvenue **en plus**, mais le livrable = **les
  fichiers**.

## 1. Le héros (rappel du look verrouillé)

Survivant **ordinaire, fragile, bricolé**, post-apo. **Repérable par sa lumière** : il porte une
**lampe frontale (sur le casque)** → mains libres, halo autour de lui. Vu **de côté** (2D coupe).
Ton : sombre, humour Fallout / mystère Metro. Palette plutôt désaturée + l'accent **chaud de la
lampe**.

## 2. Échelle & taille de case (figées)

- Monde en **tuiles 16 px**. Héros **~2 tuiles de haut (~30-32 px)**.
- **Case de sprite fixe : 32 × 32 px** (laisse une marge pour outil/halo). **Toutes** les frames en
  **32×32**, héros centré horizontalement, **pieds posés sur la même ligne** (ex. y=30) dans chaque
  frame.
- Orientation de référence : **regard vers la DROITE**. (Le moteur retourne pour la gauche — ne pas
  livrer la version miroir.)

## 3. Animations demandées (sobres — peu de frames, cf. DA)

Pixel art **image par image**, volontairement **sobre**. Frames indicatives (à ajuster) :

| Animation | Frames | Notes |
|-----------|:-----:|-------|
| **idle** | 2-3 | respiration légère, lampe allumée |
| **marche** | 4-6 | cycle de marche au sol |
| **saut** | 2 | montée / chute (1 frame chacune suffit) |
| **échelle** (grimpe) | 2-4 | de dos/profil, mains alternées |
| **creuse** | 3-4 | coup d'outil vers la tuile visée |
| **attaque mêlée** | 3-4 | **arc de cercle orienté** (feedback « sabre », cf. note GDD) |
| **tir** (arme à feu) | 2-3 | recul léger + flash court |
| **touché** | 1-2 | sursaut/flash |
| **mort** | 3-5 | chute au sol |

> La **source de lumière** (lampe frontale) doit rester cohérente sur toutes les frames (même
> position relative à la tête). Le **halo** lui-même est géré par le moteur — ne pas le peindre.

## 4. Livrables & nommage

Au choix (préciser lequel), du plus simple au plus pratique :

- **Option A — frames individuelles** : un PNG par frame, nommé
  `hero_<anim>_<NN>.png` (ex. `hero_marche_00.png` … `hero_marche_05.png`), **32×32**, transparent.
- **Option B — une sprite sheet par animation** : `hero_<anim>.png`, frames **alignées en ligne**,
  **cases 32×32 strictes et régulières** (pas de marge/espacement variable), transparent + un petit
  `.txt`/`.json` indiquant le nombre de frames et la durée conseillée.

Dans les deux cas : **ZIP**, RGBA, 1×, fond transparent, héros calé pareil dans chaque case.

## 5. Avatar modulaire (cf. bible §4) — phase 2, à anticiper

À terme, l'avatar est **modulaire** : 4 emplacements superposables sur une **base commune** —
**cheveux · visage · corps/tenue · couvre-chef** (les couvre-chefs doivent gérer la lampe ou prévoir
un fallback). **Pour ce 1er lot, livrer d'abord le HÉROS DE BASE complet** (un seul personnage,
toutes les anims du §3). Concevoir toutefois la base pour que les **calques se superposent plus tard
au même pixel près** (mêmes cases 32×32, même pivot). Les jeux de modules viendront en **lot
séparé**.

## 6. Lisibilité & accessibilité

- **Silhouette unique et lisible** à la vraie échelle (~32 px) : tester **petit**, pas seulement en
  grand.
- Toujours **repérable par la lampe** (l'accent chaud sur la tête/le faisceau).
- **Daltonisme** (porteur du projet) : une info d'état (touché, etc.) ne doit pas reposer sur la
  **seule couleur** → la doubler par une **forme/posture** (le moteur ajoute déjà flash + son).
- Cohérence avec le décor déjà produit (roche/tunnel/Foyer) : même niveau de détail pixel art.

## 7. Références

- **Dead Cells / Hollow Knight** : lisibilité de silhouette, anim pixel art expressive mais sobre.
- **Metro / Fallout** : survivant bricolé, lampe, ton post-apo.
- Note GDD : coup de mêlée = **arc orienté** vers la cible (pas un simple cercle).

> En résumé : **héros de base 32×32, toutes les anims du §3, en fichiers PNG RGBA 1× transparents,
> cases régulières, calage constant, livré en ZIP** (pas de planche). Le modulaire et les variantes
> viendront ensuite.
