# 07 — UX / UI & Accessibilité

> Comment l'information est présentée et comment on pilote le jeu. *(Section à traiter.)*

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
> 💡 *À détailler* : taille de départ du sac, paliers d'amélioration, durée de vie de la cache.
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
