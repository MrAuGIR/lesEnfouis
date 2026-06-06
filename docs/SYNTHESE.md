# Les Enfouis — Synthèse *(The Buried)*

> *« L'humanité s'est enterrée. À toi de remonter. »*

**Genre :** survie / construction-gestion / exploration souterraine, **monde persistant** ·
**Vue :** 2D **pixel art** en coupe · **Plateforme :** PC (premium), portage console ensuite ·
**Solo** · **Indie**.
**ADN :** Minecraft (creuser) · Fallout Shelter (base) · Metro 2033 (ton) · Age of Empires
(ressources) · + Terraria, Project Zomboid, Diablo.

## Pitch

Après une **Troisième Guerre mondiale** menée par des IA et des drones, une **IA victorieuse**
a achevé de dévaster la surface (gaz toxiques) et poussé l'humanité **sous terre**. Des
générations plus tard, on a **oublié pourquoi**. On incarne un survivant qui **creuse** un
monde fait de **zones fonctionnelles successives** pour **remonter vers la surface** — de plus en plus
dangereuse — récolter des ressources, **bâtir une base** façon Fallout Shelter, affronter
humains et robots, et **reconstituer la vérité**.

## Piliers de design

1. **Creuser & découvrir** — l'exploration libre du sous-sol, zone après zone.
2. **Bâtir son refuge** — construire et faire vivre une base sûre dans un monde hostile.
3. **Remonter sous tension** — chaque expédition vers le haut est plus risquée ; revenir vivant avec son butin est l'enjeu.

## Boucle de jeu

`Expédition (creuser · explorer · récolter · combattre) → retour à la base → développer
(pièces, PNJ, atelier, craft, amélioration) → repartir plus haut / plus loin.`

## Mécaniques clés

- **Creuser :** terrain généré procéduralement + bunkers/caves **préfabriqués** ; outils à paliers **Pierre → Fer → Acier/Composants** (gating de l'ascension).
- **Lumière :** vraie mécanique — torches (bois) ; **éclairage anti-pollution à crafter** près de la surface.
- **Combat :** temps réel, **visée souris**, mêlée **ou** arme à feu, **munitions rares** (loot + craft) ; rareté = paliers de **stats** ; **légendaires** lootées sur les **boss de zone**.
- **Extraction :** **sac limité** ; à la mort, retour à la base et **butin récupérable** sur une cache (façon Souls). Auto-sauvegarde.
- **Base (Fallout Shelter) :** bibliothèque de pièces (production des ressources, crafting, **bunker/défense**, stockage, infirmerie, dortoir) + **PNJ autonomes** ; **raids réguliers** à repousser.
- **Ressources (AoE) :** Bois (build + torches) · Lithium (recharge lampe frontale) · Pierre (build) · Fer (équipement) · Or (monnaie) · Eau & Nourriture (soin).
- **Progression :** équipement (loot/craft) + outils de creusage + **compétences du héros à l'usage**.

## Monde — 3 zones jouables + Foyer + Surface (on remonte vers la surface)

| Zone | Fonction | Menace | Boss |
|------|--------|--------|------|
| ⛟ **Foyer** | refuge (départ, le plus profond) | — (sûr) | — |
| 🚇 **Transit** | tunnels / infrastructure | Pilleurs (humains) | le Roi des Galeries |
| ⚙️ **Usines** | production autonome | Robots, milices, gaz | le Seigneur de la Fonderie |
| 🛡️ **Militaire / Labos** | commandement / IA | Robots avancés, défenses | LÉVIATHAN |
| ☀️ **Surface** | présent / catastrophe | Tout (climax) | **NAPOLÉON** *(l'IA)* |

La menace **monte** avec l'altitude : factions humaines en bas, machines/robots en haut
(on se **rapproche de l'IA** en remontant).

## Héros

Avatar **personnalisable** (cheveux, tenue, couvre-chef, visage) + **8 backgrounds** (atout de
départ) : Enfant des galeries, Mineur, Sapeur, Agent de sécurité, Ingénieur, Médecin,
Contrebandier, Spéléologue. **7 compétences** qui montent à l'usage (niveaux 1→10) :
Excavation, Mêlée, Armes à feu, Artisanat, Médecine, Portage, Exploration.

## Narration

Une **enquête en remontant le temps** : mythe oublié → fausse piste du « cycle » → doute →
reconstitution de la **3e GM + IA** → confrontation finale où **NAPOLÉON parle**. **Fin
douce-amère :** le héros rapporte la **vérité**, l'humanité **retrouve sa mémoire**, mais la
**surface reste perdue** — petite **ouverture** finale (d'autres survivants ailleurs ?).
**Ton :** sombre + humour Fallout + mystère Metro.

## Direction artistique & audio

Pixel art coloré, **palette signature par couche**, UI **rétro-futuriste / terminal**,
lumière au cœur de l'ambiance. **Audio** immersif + musique adaptative (tension au
combat/raid, chaleur à la base).

## Périmètre

**MVP = vertical slice** : prouver le cœur **creuser → récolter → base minimale →
revenir/extraire**, *sans* combat/raids/boss. **Hors périmètre initial :** multijoueur,
portage console, factions/quêtes complexes, couches au-delà de 1-2. **Risque n°1 à
prototyper :** le fun du creusage + extraction.

---
*Détail complet par section dans les fichiers `00`–`08` de ce dossier.*
