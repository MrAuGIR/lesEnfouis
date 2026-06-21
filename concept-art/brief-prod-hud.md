# Brief de PRODUCTION — Le HUD (habillage de l'interface en jeu)

> **À l'attention du / de la designer.** Le **concept** du HUD est validé
> ([brief concept](brief-concept-hud.md) · planche [`concept_hud.png`](concept_hud.png) ·
> [retour](retour-concept-hud.md) · [look §6](LOOK-VERROUILLE.md)). Le HUD est **déjà en place et
> jouable** (grey-box dessiné par code, layout aux 4 coins). Ici on demande les **éléments
> graphiques d'habillage** pour remplacer le grey-box : cadres, jauges, icônes, pastilles, typo.
> Style **terminal rétro-futuriste** (Pip-Boy + jauges Metro).

## 0. ⚠️ FORMAT DE REMISE — à lire en premier (ça a coincé 4× déjà)

On a reçu plusieurs fois des **planches de présentation** (image unique, éléments sur dalles/damier,
labels cuits, tailles variables) → **inintégrable**. On veut des **FICHIERS RÉELS, découpés**.

- **Livrer un .ZIP** de fichiers PNG **séparés** (un par élément), **pas** une maquette aplatie.
- **PNG RGBA, fond transparent** (pas de damier/cadre/label autour de chaque pièce).
- **Pixel art net à 1×** pensé pour le **rendu interne ~480×270** (agrandi ×3-4 en Nearest) :
  **aucun anti-aliasing**, dimensions en pixels entiers.
- Les **cadres/panneaux** doivent être **9-slice friendly** : bords/coins réguliers, centre
  répétable → fournir la pièce **avec ses marges de slice** indiquées (ou des coins/bords séparés).
- Une **maquette d'aperçu** (tout assemblé, à 480×270, par-dessus une scène sombre) est bienvenue
  **en plus** — mais le livrable = **les pièces découpées**.

## 1. Contraintes non négociables (lisibilité = gameplay)

- **Périphérie uniquement.** Le centre de l'écran = action + halo de lampe. Le HUD vit **aux 4
  coins / bords**, jamais au centre.
- **Couleurs d'alerte (orange/rouge) = DANGER uniquement** (gaz, raid, PV critique). Jamais pour de
  l'info neutre. ⚠️ Passe **« rouge sur rouge »** demandée : le rouge d'**alerte UI** doit se
  distinguer du rouge de **menace** (optique robot) — jouer sur forme/clignotement, pas juste la
  teinte.
- **Daltonisme** (porteur du projet) : **aucune info par la seule couleur**. Chaque ressource =
  **pastille + NOM écrit + nombre** (le texte est TOUJOURS là). Jauge basse = couleur **+** forme/
  clignotement.
- **Lisible petit** : tester à la **vraie échelle** (480×270), pas seulement en grand.
- Léger **fond/contour** discret derrière les éléments pour rester lisible sur fonds variés
  (sombre, brume verdâtre, néon).

## 2. Layout actuel (déjà codé — habiller ces zones)

Le HUD est organisé en **4 coins + 2 centres** (cf. `game/scripts/hud.gd`). Fournir l'habillage de
chaque zone :

| Zone | Contenu actuel | Pièces graphiques attendues |
|------|----------------|------------------------------|
| **Haut-gauche** | état du monde : Raid / Caravane / PNJ | petit **panneau-terminal** + icônes (raid, caravane, PNJ) |
| **Haut-centre** | **objectif** + **bandeau d'alerte pulsé** (gaz prioritaire, sinon raid) | **bandeau d'alerte** (cadre + fond), états gaz / raid ALERTE / raid ACTIF |
| **Droite** | **Sac** + **Stock** (ressources) | **pastilles de ressource** (voir §3) + panneau de fond |
| **Bas-gauche** | barres **PV** + **Lampe** + ligne arme / anti-gaz / outil / torches | **2 jauges** (PV, Lampe) + **icônes** arme à feu, anti-gaz, outil (pioche), torche |
| **Bas-centre** | **invite contextuelle** verte (« [E] … ») | **étiquette d'invite** (cadre discret, fond translucide) |
| **Bas** | aide condensée (rappels touches) | optionnel : petit fond/contour |

## 3. Pastilles de ressource (élément central — daltonien)

Le jeu affiche les ressources en **pastille colorée + NOM + nombre**. Fournir une **icône/pastille
16×16** (ou 12×12) **par ressource**, distinctes **par la FORME autant que la couleur** :

- **bois** · **roche** · **fer** · **lithium** · **munitions** (+ prévoir extensible).

> Chaque pastille doit rester reconnaissable **en niveaux de gris** (silhouette/motif propre), car
> le nom écrit double déjà la couleur mais l'icône ne doit pas être un simple rond coloré.

## 4. Jauges & états clés à livrer

- **Jauge PV** : pleine → vide, + **état critique** (pulsation/forme d'alerte, pas qu'un rouge).
- **Jauge Lampe / autonomie** (ressource de survie clé) : niveau + **alerte « presque vide »**.
- **Bandeau d'alerte** : 3 états distincts visuellement — **gaz**, **raid ALERTE** (compte à
  rebours), **raid ACTIF**.
- (Profondeur/couche : petit indicateur Foyer→Surface, si tu veux le proposer.)

## 5. Grammaire visuelle commune

- **Typo monospace / à chiffres** (vieil ordi de survie) — fournir au moins les **chiffres** et un
  jeu de glyphes lisibles, ou indiquer une fonte bitmap libre compatible.
- **Effet terminal** (scanlines/grain, lueur phosphore) **subtil** — jamais au point de masquer
  l'info. Le fournir en **overlay séparé** (optionnel, activable), pas cuit dans chaque pièce.
- **Cadres/coins** réutilisables (9-slice) pour tous les panneaux.

## 6. Nommage & livrables

- ZIP de PNG RGBA 1× : ex. `hud_panel_frame.png` (9-slice), `hud_gauge_hp.png`,
  `hud_gauge_lamp.png`, `hud_alert_banner.png` (+ états), `hud_prompt.png`,
  `hud_icon_<nom>.png` (raid/caravane/pnj/arme/antigaz/outil/torche),
  `hud_pip_<ressource>.png` (bois/roche/fer/lithium/munitions), `hud_scanlines.png` (overlay),
  `hud_font_*` (ou réf. de fonte).
- Maquette assemblée 480×270 **en plus** (aperçu), livrable = **les pièces**.

## 7. Cadre (hors de ce lot)

Pas demandé ici : l'**inventaire détaillé**, le **menu de construction** (Fallout-Shelter), les
écrans de **troc**, l'**écran-titre / écran de fin**, les **menus**. Ce sont des écrans dédiés
(briefs séparés). Ici = **uniquement l'habillage du HUD permanent d'exploration**.

## 8. Références

- **Fallout — Pip-Boy** : terminal, phosphore, cadran d'état.
- **Metro 2033** : jauges diégétiques, UI minimale et tendue.
- **Dead Cells / Hollow Knight** : HUD pixel art discret, périphérique, lisible.

> En résumé : **les pièces découpées du HUD aux 4 coins** (cadres 9-slice, jauges PV/Lampe + états,
> bandeau d'alerte gaz/raid, pastilles de ressource lisibles en gris, icônes, typo monospace,
> overlay scanlines optionnel), **PNG RGBA 1× pour rendu 480×270, périphérique, rouge réservé au
> danger, aucune info par la seule couleur**, livré en **ZIP de fichiers** (pas de maquette aplatie).
