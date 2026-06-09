# Document d'étude — Game Design Document (GDD)

> **Phase d'étude / conception.** Ce dossier rassemble toutes les décisions de design
> nécessaires pour pouvoir, ensuite, construire le jeu. On ne choisit **pas** de
> technologie ici : on fige le **concept**, les **graphismes**, l'**histoire**, les
> **mécaniques**, le **contenu** et le **périmètre**.

> ⚙️ **Document vivant, construit par interview.** Les réponses proviennent des entretiens
> avec le porteur du projet. `✅` = répondu/confirmé · `⬜ À déterminer` = question encore
> ouverte. L'étude est « close » quand il ne reste plus de question structurante ouverte.

## Titre : **Les Enfouis** *(version internationale : The Buried)*

> *« L'humanité s'est enterrée. À toi de remonter. »*

> 📄 **Synthèse d'une page (pitch & vue d'ensemble) : [SYNTHESE.md](SYNTHESE.md)**
> · 🛠️ **Plan de prototype (vertical slice) : [PROTOTYPE.md](PROTOTYPE.md)**
> · 🎨 **Brief de direction artistique : [BRIEF-DIRECTION-ARTISTIQUE.md](BRIEF-DIRECTION-ARTISTIQUE.md)**
> · 🔒 **Look verrouillé (bible visuelle) : [LOOK-VERROUILLE.md](../concept-art/LOOK-VERROUILLE.md)**
> · 🖼️ **Concept art : [`concept-art/`](../concept-art/)** — planches : [Industrielle](../concept-art/planche-style-couche-industrielle.png) · [héros](../concept-art/concept-hero.png) · [robot](../concept-art/concept_enemis_robot.png) · [HUD](../concept-art/concept_hud.png) (+ retours)

## Pitch (état actuel)

> **Un jeu de survie, de construction et d'exploration souterraine en 2D (vue en coupe).
> L'humanité s'est enfouie sous terre après l'apocalypse. On dirige un survivant qui
> creuse le sol pour explorer un monde fait de zones fonctionnelles successives, récolte des
> ressources, affronte humains et robots, et bâtit des bases façon Fallout Shelter — avec
> pour objectif de remonter vers la surface, de plus en plus dangereuse.**

## DNA du projet (confirmé)

| Axe | Choix |
|-----|-------|
| Genre | **Survie / Construction-gestion / Exploration** — monde **persistant** (pas rogue-lite) |
| Vue | 2D vue de côté, **en coupe** souterraine |
| Direction artistique | Cartoon coloré *(style précis à déterminer)* |
| Boucle | Creuser & explorer le sous-sol, récolter, combattre, bâtir/gérer des bases |
| Objectif | **Remonter vers la surface** (danger croissant vers le haut) |
| Modèle d'échec | Mort → retour base, **perte du butin transporté** (extraction façon Metro) |
| Contrôle | **Un héros** dirigé directement + **PNJ autonomes** affectés aux salles |
| Ambition | Indie / petite équipe |
| Références | Minecraft (creuser) · Fallout Shelter (base/pièces/PNJ) · Metro 2033 (ton) · Age of Empires (ressources) |

## Sections & avancement

| # | Section | Fichier | Statut |
|---|---------|---------|--------|
| 00 | Vision & Concept | [00-vision-concept.md](00-vision-concept.md) | ✅ Validé |
| 01 | Boucle de jeu & Mécaniques | [01-boucle-mecaniques.md](01-boucle-mecaniques.md) | ✅ Validé |
| 02 | Univers & Narration | [02-univers-narration.md](02-univers-narration.md) | ✅ Validé |
| 03 | Personnages & Ennemis | [03-personnages-ennemis.md](03-personnages-ennemis.md) | ✅ Validé |
| 04 | Direction artistique | [04-direction-artistique.md](04-direction-artistique.md) | ✅ Validé |
| 05 | Audio | [05-audio.md](05-audio.md) | ✅ Validé |
| 06 | Contenu & Progression | [06-contenu-progression.md](06-contenu-progression.md) | ✅ Validé |
| 07 | UX / UI & Accessibilité | [07-ux-ui-accessibilite.md](07-ux-ui-accessibilite.md) | ✅ Validé |
| 08 | Périmètre & Production | [08-perimetre-production.md](08-perimetre-production.md) | ✅ Validé |

> **État de l'étude : GDD INTÉGRALEMENT VALIDÉ** (9 sections, toutes les cases `- [x] Validé`
> cochées en interview — juin 2026). **Titre et tagline trouvés** (*Les Enfouis*). Ne restent
> que des points de **détail** marqués `À détailler` dans les fichiers (raffinements de
> production / équilibrage). Le **risque n°1 (fun creuser/extraire) est levé** au prototype, et
> le **vertical slice** est jouable. **Prochaine étape : production du MVP** = *Foyer + 1 zone
> (Transit) + son boss* (cf. [08](08-perimetre-production.md) et [06](06-contenu-progression.md)).

## Glossaire (termes du projet)

- **Les zones (ou couches)** — strates fonctionnelles successives du sous-sol (transit, usines, militaire/labos…) ; plus on monte, plus c'est dangereux.
- **La base** — abri bâti dans le décor en coupe, à partir d'une bibliothèque de pièces (production, crafting, défense).
- **Les abris-relais** — petits abris de bas niveau posés en exploration pour se reposer/sécuriser un chemin.
- **Le butin** — ressources/objets transportés par le héros, perdus en cas de mort hors base.
