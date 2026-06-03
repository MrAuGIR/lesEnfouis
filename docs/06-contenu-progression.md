# 06 — Contenu & Progression

> Ce qui remplit le jeu et soutient la durée de vie : monde, ressources, construction,
> progression. *(Partiellement défini — à approfondir.)*

---

### Q. Comment est structuré le monde (couches, taille, génération) ?
**R.** ✅ Monde **en couches** de civilisations (parcouru **vers le haut**, surface = plus
dangereux), **généré procéduralement** à la création de la partie puis **persistant**. La
**terre/roche est creusable et générée** ; les **bunkers/abris/caves sont des salles
préfabriquées** placées dans le monde généré. Échelle visée : **3-4 couches, très denses**
et identitaires.
> 💡 *À détailler* : taille/épaisseur d'une couche, transitions entre couches, densité des
> bunkers, part d'aléatoire dans le placement des préfabriqués.
- [ ] Validé

### Q. Quelle est l'identité de chaque couche ? (du plus profond au plus haut)
**R.** ✅ **3 couches = 3 époques de notre histoire** (profond = ancien → on remonte le
temps), encadrées par le **Foyer** (départ, tout en bas — l'humanité actuelle a foré sous
l'Histoire) et la **Surface** (climax). La menace **monte avec l'altitude** : humains/
factions en bas, robots en haut.

- **⛟ Le Foyer** *(départ, le plus profond)* — refuge moderne, zone **sûre** : base(s),
  survivants, marchands. Lumineux et vivant.
- **🏺 Couche 1 — Antiquité** — cités/temples enfouis, colonnes, aqueducs, mosaïques.
  Palette **ocres/dorés chauds**. Danger faible→moyen : pilleurs de ruines, pièges (*pas de
  robots*). Ressources : **pierre & or** (trésors). Révélation : l'humanité s'est **déjà
  enterrée par le passé** (un **écho troublant** — en réalité une fausse piste : la catastrophe récente est unique). Boss : gardien de temple / chef des pilleurs.
- **🏰 Couche 2 — Médiéval** — catacombes, châteaux enfouis, cryptes, vitraux brisés.
  Palette **gris-bleu froid**, pierre, mousse. Danger moyen : **factions** humaines
  retranchées, bandits mieux armés. Ressources : **fer** (forges), bois, pierre. Révélation :
  une civilisation enterrée pour fuir un fléau (écho au présent). Boss : seigneur souterrain & sa milice.
- **⚙️ Couche 3 — Industrielle / moderne** — usines enfouies, métal rouillé, machines
  mortes, **automates de guerre**, début des **gaz de pollution**. Palette **acier/rouille +
  néon**. Danger élevé : **robots**, gaz (éclairage spécial requis), milices technophiles.
  Ressources : **fer** abondant, composants, or rare. Révélation : la **cause directe** de la
  catastrophe — la **guerre des machines** qui a ravagé la surface. Boss : grosse machine de guerre / robot majeur.
- **☀️ La Surface** *(climax final)* — ruines à ciel ouvert, ciel voilé de pollution,
  vestiges de la dernière civilisation. Palette **lumière crue/voilée, gris-jaune toxique**.
  Danger extrême : gaz intenses (équipement spécial **obligatoire**), pires robots,
  environnement. **Révélation finale = la fin du jeu** (douce-amère : la surface est perdue, mais on comprend
enfin). Boss final : **l'IA** qui contrôle les robots de surface.

> 💡 *À détailler* : noms des boss, la **cause exacte** de la catastrophe (couche 3 /
> surface), les jalons de révélation précis, et le look pixel art final de chaque couche.
- [ ] Validé

### Q. Quelles ressources, et à quoi sert chacune ?
**R.** ✅ Sept ressources (façon Age of Empires), aux rôles définis :
- **Bois** → construction des pièces **et carburant des torches** (flamme — mécanique de lumière, cf. [04](04-direction-artistique.md)). **Source : structures humaines** (bunkers / bases abandonnés à fouiller) + **marchands**, et abondant en **Médiéval/Surface** (charpentes, ruines, arbres) — **pas** dans la terre brute (c'est un matériau manufacturé/organique).
- **Lithium** → **recharge de la lampe frontale** (électrique), **miné dans la roche**. La lumière portée par le héros n'est donc pas au feu mais à la pile — cohérent avec le casque.
> 🧭 **Règle lisible** : on obtient les **minerais** (pierre, fer, lithium) en **creusant** ; les **matériaux manufacturés** (bois, équipement) en **fouillant des structures** ou via le **commerce**. Deux activités, deux récompenses.
- **Pierre** → construction et amélioration des **pièces de base**.
- **Fer** → **armes, outils et armures** (équipement).
- **Or** → **monnaie / échange** (commerce — implique des marchands, cf. [03](03-personnages-ennemis.md)).
- **Eau** & **Nourriture** → **soin / consommables** (santé du héros).
> 💡 *À détailler* : sources de chaque ressource (pièce de production dédiée + récolte en
> exploration), coûts, rareté selon la couche.
- [ ] Validé

### Q. Quelles pièces dans la bibliothèque de construction de base ?
**R.** ✅ Pièces confirmées : **production** (eau, nourriture, bois, fer, pierre, or),
**crafting**, **bunker/défense**, **stockage/entrepôt** (déposer le butin — clé pour
l'extraction), **infirmerie** (soin du héros et des PNJ), **dortoir/quartiers** (loge les
PNJ, fixe la capacité d'accueil). Pas de salle générateur (la lumière repose sur le
bois/les torches, pas sur l'électricité).
> 💡 *À détailler* : niveaux d'amélioration des pièces, coûts, prérequis de déblocage.
- [ ] Validé

### Q. Comment fonctionne le craft / l'équipement ?
**R.** ✅ **Loot ET craft combinés** :
- **Loot** : les **armes** (ordinaire/rare) se trouvent dans les bunkers/sur les ennemis ; les **légendaires** (arme **ou** équipement) tombent uniquement sur les **boss de couche**.
- **Craft** (à l'atelier de la base) : **outils de creusage**, **armures**, **munitions**, **éclairage anti-pollution**, **consommables**.

**Système :**
- **Paliers d'outils de creusage** : **Pierre → Fer → Acier/Composants**, calqués sur les matériaux des couches (Antiquité → Médiéval → Industriel). De meilleurs outils percent les couches plus dures → **gating** de l'ascension.
- **Recettes** débloquées via l'**amélioration de l'atelier** (pièce de crafting) : un **atelier à paliers** qu'on améliore avec des ressources pour fabriquer les objets avancés.
- **Amélioration de l'équipement** : on peut **faire monter un outil/une armure d'un palier** avec des matériaux (pas seulement remplacer).
- **Rareté = paliers de stats** (pas d'affixes aléatoires). Seuls les **outils de creusage s'usent** (réparer/remplacer ; le Mineur les use moins).
> 💡 *À détailler* : valeurs chiffrées (dégâts, coûts, durabilité), liste des recettes par
> palier d'atelier, matériaux exacts de chaque palier d'outil.
- [ ] Validé

### Q. Quelle est la courbe de progression (qu'est-ce qui se débloque, dans quel ordre) ?
**R.** ✅ Progression à **double verrou** pour monter vers les couches supérieures : (1) un
**meilleur équipement** (armes/armure looté ou crafté) pour **survivre** au danger
croissant, ET (2) de **meilleurs outils de creusage** pour **percer** certaines couches/
blocs plus durs (façon Minecraft : pioches de niveaux croissants). S'y ajoute une **progression des
compétences du héros à l'usage** (creuser, combat, craft, soin…), amorcée par le background
choisi (cf. [03](03-personnages-ennemis.md)). La difficulté monte vers la surface.
> 💡 *À détailler* : paliers d'outils (quels matériaux/niveaux ?), arbre de craft/techno,
> quels blocs/couches exigent quel outil, déblocage des pièces de base avancées.
- [ ] Validé

### Q. Quel volume de contenu / quelle durée de vie vise-t-on ? (et le MVP)
**R.** ⬜ À déterminer.
> 💡 *À cadrer en [08](08-perimetre-production.md)* : nombre de couches, de pièces, de types
> d'ennemis et d'objets pour un premier jeu jouable.
- [ ] À déterminer
