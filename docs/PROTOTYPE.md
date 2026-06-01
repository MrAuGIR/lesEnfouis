# Plan de prototype — Vertical slice *(Les Enfouis)*

> Concrétisation de la [section 08](08-perimetre-production.md). **Objectif unique : prouver
> que le cœur du jeu est fun** — `creuser → récolter → base minimale → revenir/extraire` —
> **sans** combat, raids ni boss. C'est le **risque n°1** du projet : tant qu'il n'est pas
> levé, on ne produit rien d'autre.
>
> *Plan agnostique de techno (on ne choisit pas de moteur ici) : on décrit les systèmes et
> features à construire, dans l'ordre, avec un critère de validation par jalon. Tout est en
> **grey-box** (formes simples) ; l'art pixel final n'arrive qu'après la preuve du fun.*

## Périmètre du vertical slice

**DANS le prototype**
- 1 **héros contrôlable** : déplacement + **creuser** (visée souris).
- **Terrain creusable généré** sur **1 couche**, avec quelques **cavités/bunkers préfabriqués** placés.
- **Mécanique de lumière** : obscurité + lampe/**torches** (carburant = bois).
- **3 ressources** suffisent (ex. **bois, pierre, fer**).
- **Sac à capacité limitée** + **dépôt** au stockage.
- **Mort** : retour base + **cache récupérable** sur place.
- **Base minimale** : 2-3 pièces (**stockage**, **1 production**, **atelier**) + **1 PNJ** affectable.
- **Craft basique** : 1 amélioration d'outil (**Pierre → Fer**) + recharge de torches.

**HORS prototype** (ajouté seulement si le fun est prouvé) : combat, ennemis, raids, boss,
factions, marchands, narration, couches supplémentaires, backgrounds/compétences complets,
gaz/surface, bases multiples.

## Jalons (ordre de construction)

### Jalon 0 — Mouvement & creusage *(game feel)*
Un personnage se déplace dans un monde de tuiles et **creuse** des blocs (terrain
destructible) ; les blocs minés deviennent des ressources dans un sac. Aucun art final.
- **But :** le creusage est-il **satisfaisant** (réactivité, feedback, vitesse) ?
- **Fait quand :** on creuse librement et on accumule 2-3 ressources.

### Jalon 1 — Génération du monde + lumière
Génération procédurale d'**une couche** (terre/roche creusable) avec quelques **préfabriqués**
placés. **Lumière** : l'obscurité limite la vision ; torches/lampe consommant du **bois**.
- **But :** explorer un sous-sol sombre est-il **lisible et tendu** ?
- **Fait quand :** un monde généré est explorable et l'obscurité oblige à gérer la lumière.

### Jalon 2 — Inventaire limité + extraction + mort
**Sac limité**, **dépôt** au stockage, **mort** = retour base + **cache récupérable** à
l'endroit de la mort.
- **But :** la **tension d'extraction** (rapporter son butin) fonctionne-t-elle ?
- **Fait quand :** mourir loin de la base crée un vrai dilemme (retourner chercher, ou non).

### Jalon 3 — Base minimale + PNJ + craft
Construire 2-3 **pièces** (stockage, 1 production, atelier) ; **affecter un PNJ** à la
production (génère une ressource passivement) ; **crafter** un meilleur outil (Pierre → Fer)
et recharger les torches.
- **But :** la boucle **expédition → retour → développement → repartir** donne-t-elle envie ?
- **Fait quand :** on bâtit, on produit, on crafte un outil, et on **sent une progression**.

### Jalon 4 — Bouclage & test du fun *(slice jouable)*
Assembler le tout en une **session de ~15-20 min** : Foyer → explorer/creuser → récolter →
gérer le sac → rentrer → déposer → améliorer base + outil → repartir **plus profond**. Ajouter
un **mini-objectif** (ex. atteindre une zone qui exige l'outil en fer).
- **But :** est-ce **fun sans combat** ? Le risque n°1 est-il **levé** ?
- **Fait quand :** un testeur joue 15-20 min avec plaisir et veut « **encore un aller-retour** ».

## Hypothèses à valider (critères de réussite)

| # | Hypothèse | Validé par |
|---|-----------|------------|
| H1 | Creuser & récolter est satisfaisant en soi | Jalon 0 / 4 |
| H2 | Le sac limité + la cache créent des décisions intéressantes | Jalon 2 / 4 |
| H3 | La boucle base ↔ expédition donne envie de continuer | Jalon 3 / 4 |
| H4 | Le sous-sol sombre reste lisible | Jalon 1 / 4 |

→ **Si H1-H4 sont validées, le projet est dé-risqué** : on passe à la production (combat,
art final, contenu). Sinon, on **itère** sur le cœur avant d'aller plus loin.

## Après le prototype (ordre indicatif d'enrichissement)

1. **Combat** (mêlée + arme à feu, visée souris) + premiers ennemis.
2. **Raids** sur la base + pièces **bunker/défense**.
3. **1 boss de couche** + **loot légendaire**.
4. **2e couche** : transition + identité visuelle propre.
5. **Backgrounds** + **compétences à l'usage**.
6. **Narration** : journaux, PNJ/marchands, amorce de l'arc de révélation.
7. Puis : couches restantes, factions/bandits, surface + NAPOLÉON, fin.

## Notes de production

- **Grey-box d'abord** : ne produire l'**art pixel final** qu'après le Jalon 4.
- Garder les **valeurs** (vitesse de creusage, capacité du sac, coûts de craft, autonomie de
  lampe) **facilement réglables** pour itérer vite.
- La **techno n'est pas choisie ici** ; ce plan liste des systèmes, pas des outils.
