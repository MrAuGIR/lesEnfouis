# 04 — Direction artistique

> L'identité visuelle. Objectif : un style **pixel art coloré**, lisible en coupe 2D et
> réaliste à produire pour un indie.
>
> 🎨 **Brief prêt à confier à un designer : [BRIEF-DIRECTION-ARTISTIQUE.md](BRIEF-DIRECTION-ARTISTIQUE.md).**
>
> 🖼️ **Concept art (itérations designer) :** dossier [`concept-art/`](../concept-art/) — 1re planche
> ([couche Industrielle](../concept-art/planche-style-couche-industrielle.png)) +
> [retour structuré](../concept-art/retour-planche-01-industriel.md).

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
**R.** 🟡 Proposition : palette **colorée mais un peu désaturée/contrastée**, **éclairage à
la lampe/torche** pour le mystère (zones d'ombre marquées), et **détails décalés** (affiches
de propagande, objets rétro-futuristes façon Fallout) pour l'humour. Chaque couche pousse sa
propre teinte.
> 💡 *À confirmer/affiner.*
- [ ] Validé

### Q. Chaque couche/civilisation a-t-elle une identité visuelle distincte ?
**R.** ✅ **Oui, identité forte par couche** : palette, architecture et props distincts pour
chaque civilisation/époque. Aide à se repérer dans la verticalité et **raconte
visuellement** l'empilement des civilisations.
> 💡 *Palettes définies* par couche en [06](06-contenu-progression.md) : Antiquité = ocres
> chauds · Médiéval = gris-bleu froid · Industriel = acier/rouille + néon · Surface =
> gris-jaune toxique. Reste à produire les planches pixel art.
- [ ] Validé

### Q. Comment gérer la lumière / la visibilité sous terre ?
**R.** ✅ **Vraie mécanique de lumière** : l'obscurité limite la vision ; le héros dépend
d'une **lampe / torches** pour voir et progresser (enjeu de tension façon Metro). **Carburant
= le bois** (torches/recharges), ce qui lie creusage et lumière. **Près de la surface**, les
**gaz de pollution** imposent un **éclairage spécial à crafter** — un véritable palier de
progression.
> 💡 *À détailler* : autonomie/portée de la lampe, torches fixes posables, recette de
> l'éclairage anti-pollution.
- [ ] Validé

### Q. Approche d'animation (compatible petite équipe) ?
**R.** 🟡 Proposition (suite au choix pixel art) : **animation pixel art image par image**,
volontairement **sobre** (peu de frames par action) pour rester réaliste en production indie.
> 💡 *À confirmer.*
- [ ] Validé

### Q. Style de l'UI/HUD ?
**R.** ✅ **Rétro-futuriste / terminal** : interface type écran d'ordinateur / Pip-Boy
(Fallout) et jauges façon Metro. Renforce fortement l'univers post-apo.
> 💡 *À détailler* : déclinaison concrète du HUD en [07](07-ux-ui-accessibilite.md).
- [ ] Validé
