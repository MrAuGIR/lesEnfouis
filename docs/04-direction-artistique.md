# 04 — Direction artistique

> L'identité visuelle. Objectif : un style **pixel art coloré**, lisible en coupe 2D et
> réaliste à produire pour un indie.
>
> 🎨 **Brief prêt à confier à un designer : [BRIEF-DIRECTION-ARTISTIQUE.md](BRIEF-DIRECTION-ARTISTIQUE.md).**
>
> 🔒 **LOOK VERROUILLÉ — bible visuelle de référence : [LOOK-VERROUILLE.md](../concept-art/LOOK-VERROUILLE.md).**
>
> 🖼️ **Concept art (planches livrées) :** dossier [`concept-art/`](../concept-art/) —
> [Industrielle](../concept-art/planche-style-couche-industrielle.png) ·
> [héros](../concept-art/concept-hero.png) · [robot](../concept-art/concept_enemis_robot.png) ·
> [HUD](../concept-art/concept_hud.png) (+ retours).

---

### Q. Quel est le style visuel précis (cartoon coloré : vectoriel ou pixel art ?) ?
**R.** ✅ **Pixel art classique**, coloré, en 2D vue en coupe. Choix naturel pour un monde
de **blocs/tuiles creusables** (cf. Terraria/Minecraft) : lisible, nostalgique et
économique à produire.
> 🔒 **Échelle figée — tuiles 16 px.** Le **héros mesure ~2 tuiles (~30-32 px)**. Ce réglage
> (éprouvé par Terraria) donne un **creusage fin et précis** (risque n°1 du projet), garde les
> **4 modules de l'avatar lisibles**, et reste économique en assets. La **tuile de 32 px est
> écartée** : elle réduirait le héros à ~1 tuile et casserait la lisibilité de la
> personnalisation. *Résolution interne indépendante* : dessiner en 16 px et afficher en ×3/×4
> (ex. rendu interne ~480×270 → 1080p, soit ~30×17 tuiles à l'écran).
- [x] Validé

### Q. Comment traduire le ton (sombre + humour Fallout + mystère Metro) en image ?
**R.** ✅ **Validé par le concept art.** Palette **colorée mais un peu désaturée/contrastée**,
**éclairage à la lampe/torche** pour le mystère (zones d'ombre marquées), et **détails décalés**
(affiches de propagande, objets rétro-futuristes façon Fallout) pour l'humour. Chaque couche
pousse sa propre teinte.
> 🔒 Confirmé par les planches [Industriel](../concept-art/planche-style-couche-industrielle.png),
> [héros](../concept-art/concept-hero.png) et [robot](../concept-art/concept_enemis_robot.png).
- [x] Validé

### Q. Chaque zone a-t-elle une identité visuelle distincte ?
**R.** ✅ **Oui, identité forte par zone** : palette, architecture et props distincts pour
chaque **fonction** (transit, usines, militaire/labos…). Aide à se repérer dans la
verticalité et **raconte visuellement** la progression vers la surface.
> 🔒 *Palettes réaffectées* aux zones en [06](06-contenu-progression.md) : Foyer = ocres/ambre
> chauds · Transit = gris-bleu froid · Usines = acier/rouille + néon · Militaire/Labos =
> froid/clinique + alertes rouges · Surface = gris-jaune toxique. **Validé** sur la zone
> Usines (planche de référence « Industrielle ») ; les autres zones déclinent la même grammaire.
- [x] Validé

### Q. Comment gérer la lumière / la visibilité sous terre ?
**R.** ✅ **Vraie mécanique de lumière** : l'obscurité limite la vision ; le héros dépend
d'une **lampe / torches** pour voir et progresser (enjeu de tension façon Metro). **Deux sources,
deux carburants** : la **lampe frontale (électrique) → lithium** (minerai miné dans la roche) ;
les **torches posables (flamme) → bois**. **Près de la surface**, les
**gaz de pollution** imposent un **éclairage spécial à crafter** — un véritable palier de
progression.
> 🔒 **Direction figée** : lampe **frontale (casque)** retenue pour le héros (mains libres).
> *À régler au prototype* (valeurs) : autonomie/portée de la lampe, torches fixes posables,
> recette de l'éclairage anti-pollution.
- [x] Validé

### Q. Approche d'animation (compatible petite équipe) ?
**R.** ✅ **Confirmé** : **animation pixel art image par image**, volontairement **sobre** (peu
de frames par action) pour rester réaliste en production indie.
> 🔒 Direction validée. *Les sprite sheets d'animation se briefent par lots **après** le
> prototype (grey-box d'abord).*
> 📝 *Intentions remontées au playtest du proto J5a (à intégrer aux briefs d'anim production) :*
> *— **coup de mêlée** = **arc de cercle orienté** vers la direction visée (feedback « sabre »*
> *façon Zelda), pas le simple cercle placeholder actuel ;*
> *— **ennemis (robot)** : l'**orientation visuelle face au joueur** quand ils sont en alerte*
> *(le gameplay le fait déjà : détection → poursuite ; reste l'anim idle/marche/attaque + le flip).*
- [x] Validé

### Q. Style de l'UI/HUD ?
**R.** ✅ **Rétro-futuriste / terminal** : interface type écran d'ordinateur / Pip-Boy
(Fallout) et jauges façon Metro. Renforce fortement l'univers post-apo.
> 🔒 **Validé par la planche [HUD](../concept-art/concept_hud.png)** ([retour](../concept-art/retour-concept-hud.md)).
> Point à régler : différencier le **rouge d'alerte UI** du **rouge de menace** (optique robot /
> danger). Déclinaison en [07](07-ux-ui-accessibilite.md).
- [x] Validé
