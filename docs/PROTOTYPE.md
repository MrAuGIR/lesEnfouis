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

- **Grey-box d'abord** : ne produire l'**art pixel final** qu'après le Jalon 4. Le **look est
  verrouillé** ([LOOK-VERROUILLE.md](../concept-art/LOOK-VERROUILLE.md)) mais n'entre **pas**
  dans le prototype — formes simples uniquement.
- Garder les **valeurs** (vitesse de creusage, capacité du sac, coûts de craft, autonomie de
  lampe) **facilement réglables** pour itérer vite (cf. tableau ci-dessous).

---

## 🚀 Kickoff — prêt à démarrer

### Décision préalable — moteur / techno
🔒 **Moteur retenu : Godot 4.** Natif Ubuntu (dev), **export Windows** en un clic (objectif
Steam), **2D de premier ordre** (`TileMap` + lumière 2D intégrés), **GDScript** rapide à itérer,
gratuit/open-source sans royalties. Le plus **simple** pour notre genre, sans compromettre la
suite.

> Contraintes qui ont guidé le choix : **2D pixel art**, monde de **tuiles destructibles**, **dev
> sous Ubuntu → cible Windows/Steam**, échelle **indie**, besoin d'**itérer vite** sur le game feel.

### Paramètres réglables (valeurs de départ à itérer)
Point de départ pour ressentir le jeu **dès le Jalon 0**, puis à ajuster au feeling. Ce ne sont
**pas** des valeurs définitives — juste un socle pour ne pas partir de zéro.

| Paramètre | Valeur de départ | Note |
|-----------|------------------|------|
| Taille de tuile | **16 px** (figé) | base du monde et du creusage |
| Temps pour creuser 1 bloc (terre, outil de base) | ~**0,4 s** | nerf du game feel — à régler en priorité |
| Roche / blocs durs | ×2 à ×3 plus lent | crée la valeur des meilleurs outils |
| Ressources par bloc miné | **1** (parfois 0-2) | bois / pierre / fer |
| Capacité du sac (départ) | **~20 emplacements** | tension d'extraction ; améliorable |
| Autonomie de la lampe | **~3 min** de marche | carburant = bois ; alerte quand bas |
| Portée du halo de lampe | **~5-6 tuiles** | le reste s'assombrit/désature |
| Durée de vie de la cache (à la mort) | **persistante** au proto | simplifie ; on testera l'expiration plus tard |
| Coût craft outil Pierre → Fer | **~10 fer + 5 bois** | premier palier de progression |
| PNJ : production passive | **1 ressource / ~30 s** | sensation de base qui « tourne » |

### Jalon 0 — découpage en tâches concrètes *(premier sprint)*
1. **Projet vide** qui ouvre une fenêtre + boucle de jeu (rendu/clavier/souris).
2. **Grille de tuiles** affichée (formes pleines, 2-3 couleurs : terre / roche / vide).
3. **Personnage** (rectangle) : déplacement clavier + **gravité/collision** simple.
4. **Creuser** : clic souris sur une tuile adjacente → la tuile disparaît (avec délai du tableau).
5. **Feedback de creusage** : petit effet (fissures/particules/son provisoire) — **le nerf du fun**.
6. **Ramassage** : la tuile minée ajoute **+1 ressource** à un compteur à l'écran.
- **DoD (fait quand)** : on creuse librement dans la grille et on accumule 2-3 ressources, et
  **creuser procure déjà une petite satisfaction** (sinon, itérer sur 4-5 avant d'avancer).

### Checklist de démarrage
- [x] **Moteur choisi** — **Godot 4.6** (cf. ci-dessus).
- [x] Dépôt/projet initialisé + lancement qui tourne — `prototype/` ([README](../prototype/README.md)).
- [x] Valeurs réglables exposées en haut de `prototype/scripts/Game.gd`.
- [ ] **Jalon 0 joué et auto-évalué** sur le fun du creusage (H1) — *à faire : playtest*.
- [ ] Décider : on continue au Jalon 1, ou on **itère** le creusage.

### Garde-fous
- **On teste UNE chose** : le fun du cœur (`creuser → récolter → revenir`). Pas de combat, pas
  d'art final, pas de contenu — tout est listé « HORS prototype » plus haut.
- **Time-box** chaque jalon : si un jalon traîne, simplifier plutôt qu'enrichir.
- Si **H1-H4 ne se valident pas**, on **itère le cœur** avant toute production — c'est le but même
  de ce prototype.
