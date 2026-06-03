# 07 — UX / UI & Accessibilité

> Comment l'information est présentée et comment on pilote le jeu. *(Section à traiter.)*
>
> 🖥️ **Brief de concept pour le designer : [brief-concept-hud.md](../concept-art/brief-concept-hud.md)** (langage du HUD d'exploration + lisibilité dans le noir).
>
> 🖼️ **Planche livrée : [concept_hud.png](../concept-art/concept_hud.png)** ([retour](../concept-art/retour-concept-hud.md)).

---

### Q. Quel schéma de contrôles (creuser, se déplacer, combattre, gérer la base) ?
**R.** ✅ **Clavier + souris** (PC d'abord) : déplacement au clavier, **visée et creusage à
la souris** (cohérent avec la visée souris du combat), raccourcis pour outils/armes/
inventaire ; gestion de la base à la souris.
> 💡 *À détailler* : mapping précis, bascule exploration ↔ vue base. Support manette = piste post-MVP.
- [ ] Validé

### Q. Qu'affiche le HUD en exploration ?
**R.** 🟡 Proposition (style terminal rétro-futuriste, cf. [04](04-direction-artistique.md)) :
**santé**, **sac/butin transporté** + capacité, **lampe/lumière** (autonomie), **arme/outil
équipé + munitions**, **profondeur/couche**, et **alertes** (danger, raid sur la base).
Minimal et lisible.
> 💡 *À confirmer/affiner.*
- [ ] Validé

### Q. Comment gère-t-on l'inventaire et le butin ?
**R.** ✅ **Sac à capacité limitée** : place restreinte → **choisir quoi rapporter** et
**déposer au stockage** de la base. C'est le cœur de la **tension d'extraction**. Capacité
**améliorable** (meilleurs sacs/poches). À la mort, le butin tombe dans un **corps/cache
récupérable** sur place (façon Souls) : on peut repartir le chercher, au risque de remourir.
> 🎒 **Présentation visée : inventaire façon Minecraft** — **grille de slots** (objets en
> **piles/stacks**), **glisser-déposer**, éventuelle **hotbar**. La « capacité limitée » = un
> **nombre de slots** (pas un poids abstrait). Transfert sac ↔ stockage de base par
> glisser-déposer. *Écran UI dédié à briefer plus tard (cf. brief HUD : explicitement « pas
> maintenant »), sans doute au Jalon 3 avec l'UI de base.*
> 💡 *Dans le prototype*, l'inventaire est abstrait (compteur d'objets + touches E/Q) : on teste
> la **mécanique d'extraction**, pas l'ergonomie finale.
> 💡 *À détailler* : taille de départ du sac (nb de slots), paliers d'amélioration, durée de vie de la cache.
- [ ] Validé

### Q. Comment l'interface de construction/gestion de base fonctionne-t-elle ?
**R.** 🟡 Proposition : **menu de construction** puisant dans la **bibliothèque de pièces**,
**glisser-déposer des PNJ** dans les salles (façon Fallout Shelter), **vue d'ensemble** de la
base en coupe. Interface terminal cohérente avec la DA.
> 💡 *À confirmer/affiner.*
- [ ] Validé

### Q. Comment le joueur apprend-il le jeu (onboarding) ?
**R.** 🟡 Proposition : apprentissage **progressif** (creuser → récolter → construire une 1re
pièce → explorer plus loin), **infobulles contextuelles**, **peu de tutoriel bloquant**.
> 💡 *À confirmer.*
- [ ] Validé

### Q. Quelles options d'accessibilité ?
**R.** 🟡 Proposition : **remap des touches**, options de **lisibilité** (taille de texte,
contraste, daltonisme — important dans un monde sombre), réglages de **difficulté**.
> 💡 *À confirmer/étoffer.*
- [ ] Validé

### Q. Comment fonctionne la sauvegarde (monde persistant) ?
**R.** ✅ **Auto-sauvegarde continue** : le monde et la base se sauvegardent automatiquement
(façon Minecraft/survie). **Plusieurs slots** de partie possibles.
> 💡 *À détailler* : fréquence/points d'auto-save, sauvegarde cloud ?
- [ ] Validé
