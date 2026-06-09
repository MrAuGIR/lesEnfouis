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
- [x] Validé

### Q. Qu'affiche le HUD en exploration ?
**R.** ✅ Style **terminal rétro-futuriste** (cf. [04](04-direction-artistique.md), planche HUD
validée) : **santé**, **sac/butin transporté** + capacité, **lampe/lumière** (autonomie),
**arme/outil équipé + munitions**, **profondeur/couche**, et **alertes** (danger, raid sur la
base). **Minimal et lisible** en jeu, plus décoré au Foyer/menus.
- [x] Validé

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
> 💡 *Dans le prototype* (grey-box) : un **vrai inventaire à slots** est implémenté — sac en
> **grille de cases**, objets en **piles/stacks**, écran d'inventaire (`I`) avec **clic**
> (prendre/poser/fusionner) et **Maj+clic** (transfert rapide sac ↔ stockage). La « capacité » =
> un **nombre de slots** (terre = 1 slot, pas 25). Reste à concevoir pour le jeu final :
> esthétique terminal, **hotbar**, tri auto, glisser-déposer continu, paliers d'amélioration du sac.
> 💡 *À détailler* : taille de départ du sac (nb de slots), paliers d'amélioration, durée de vie de la cache.
- [x] Validé

### Q. Comment l'interface de construction/gestion de base fonctionne-t-elle ?
**R.** ✅ **Menu de construction** puisant dans la **bibliothèque de pièces**,
**glisser-déposer des PNJ** dans les salles (façon Fallout Shelter), **vue d'ensemble** de la
base en coupe. Interface terminal cohérente avec la DA.
> 💡 *À détailler* (production) : affordances de pose des pièces, retour visuel d'affectation
> PNJ, indicateurs de production/défense par salle.
- [x] Validé

### Q. Comment le joueur apprend-il le jeu (onboarding) ?
**R.** ✅ Apprentissage **progressif** (creuser → récolter → construire une 1re pièce →
explorer plus loin), **infobulles contextuelles**, **peu de tutoriel bloquant** — on apprend
en faisant, cohérent avec le ton survie/exploration.
> 💡 *À détailler* (production) : séquence exacte des premières minutes, déclencheurs des
> infobulles, intégration narrative légère au Foyer de départ.
- [x] Validé

### Q. Quelles options d'accessibilité et de difficulté ?
**R.** ✅ **Modes de difficulté** (presets — ex. *Découverte / Normal / Survécu*) ajustant
dégâts, intensité des **raids** et rareté : la tension d'extraction reste le cœur, mais reste
**accessible au plus grand nombre**. **Socle d'accessibilité garanti dès le départ :**
- **Remap complet des touches** (essentiel, notamment AZERTY/QWERTY) ;
- **Mode daltonien** — palettes alternatives pour les couleurs d'alerte (danger/loot), clé vu
  l'usage du **rouge** dans la DA ([04](04-direction-artistique.md)) ;
- **Aides de confort** — ralentir/mettre en pause l'action, maintien vs appui, marqueurs de
  danger renforcés.
> 💡 *À étoffer* : **lisibilité du texte** (taille de police réglable, contraste renforcé) —
> souhaitable dans un monde sombre, à viser au-delà du socle ; détail des paramètres par mode
> de difficulté.
- [x] Validé

### Q. Comment fonctionne la sauvegarde (monde persistant) ?
**R.** ✅ **Auto-sauvegarde continue** : le monde et la base se sauvegardent automatiquement
(façon Minecraft/survie). **Plusieurs slots** de partie possibles.
> 💡 *À détailler* : fréquence/points d'auto-save, sauvegarde cloud ?
- [x] Validé
