# 06 — Contenu & Progression

> Ce qui remplit le jeu et soutient la durée de vie : monde, ressources, construction,
> progression. *(Partiellement défini — à approfondir.)*

---

### Q. Comment est structuré le monde (couches, taille, génération) ?
**R.** ✅ Monde **en zones fonctionnelles** (parcouru **vers le haut**, surface = plus
dangereux), **généré procéduralement** à la création de la partie puis **persistant**. La
**terre/roche est creusable et générée** ; les **bunkers/abris/caves sont des salles
préfabriquées** placées dans le monde généré. Échelle visée : **3 zones jouables (+ Foyer
+ Surface), très denses** et identitaires.
> 💡 *À détailler* : taille/épaisseur d'une couche, transitions entre couches, densité des
> bunkers, part d'aléatoire dans le placement des préfabriqués.
- [ ] Validé

### Q. Quelle est l'identité de chaque zone ? (du plus profond au plus haut)
**R.** ✅ **3 zones jouables = 3 fonctions** de l'humanité enfouie (**pas** des époques),
encadrées par le **Foyer** (départ, tout en bas) et la **Surface** (climax). La menace
**monte avec l'altitude** : factions humaines en bas, machines/robots en haut — on se
**rapproche de l'IA** en remontant. Les **palettes existantes sont réaffectées** aux zones.

- **⛟ Le Foyer** *(départ, le plus profond)* — refuge des survivants actuels, zone **sûre** :
  base(s), survivants, marchands. Palette **ocres/ambre chauds** (vivant, accueillant).
- **🚇 Zone 1 — Transit / Infrastructure** — anciens tunnels, métro, canalisations, réseaux
  enfouis. Palette **gris-bleu froid**, béton, humidité. Danger faible→moyen : **factions de
  survivants / pilleurs** (*pas de robots*). Ressources : **pierre, fer, ferraille**. Récit :
  **fausse piste** — tout évoque une catastrophe **purement humaine** (la part machine est
  encore invisible). Boss : **chef de faction** (cf. [03](03-personnages-ennemis.md)).
- **⚙️ Zone 2 — Usines autonomes** — chaînes de production enfouies, métal rouillé,
  **automates** dormants/réveillés, début des **gaz de pollution**. Palette **acier/rouille +
  néon** (= planche concept existante). Danger moyen→élevé : **robots**, gaz (éclairage
  spécial requis), milices technophiles. Ressources : **fer abondant, composants**. Récit :
  **le doute** — production de guerre, automates → ce n'était pas qu'une guerre d'hommes.
  Boss : **automate de guerre** (LÉVIATHAN, cf. [03](03-personnages-ennemis.md)).
- **🛡️ Zone 3 — Complexe militaire / labos** — bunkers de commandement, laboratoires d'IA,
  archives, salles serveurs. Palette **froide/clinique + alertes rouges**. Danger élevé :
  robots avancés, défenses automatisées, gaz. Ressources : **composants, or rare, tech**.
  Récit : **la révélation** — on reconstitue la 3e Guerre mondiale, l'escalade IA/drones, la
  perte de contrôle. Boss : **gardien machine / faction** (cf. [03](03-personnages-ennemis.md)).
- **☀️ La Surface** *(climax final)* — ruines à ciel ouvert, ciel voilé de pollution. Palette
  **lumière crue/voilée, gris-jaune toxique**. Danger extrême : gaz intenses (équipement
  spécial **obligatoire**), pires robots. **Révélation finale = la fin du jeu** (douce-amère :
  la surface est perdue, mais on comprend enfin). Boss final : **NAPOLÉON**, l'IA victorieuse
  (cf. [03](03-personnages-ennemis.md)).

> 💡 *À détailler* : roster/noms exacts des boss en [03], jalons de révélation précis, look
> pixel art final de chaque zone, palette dédiée du Foyer et du Complexe militaire/labos.
- [x] Validé

### Q. Quelles ressources, et à quoi sert chacune ?
**R.** ✅ Sept ressources (façon Age of Empires), aux rôles définis :
- **Bois** → construction des pièces **et carburant des torches** (flamme — mécanique de lumière, cf. [04](04-direction-artistique.md)). **Source : structures humaines** (bunkers / bases abandonnés à fouiller) + **marchands**, et abondant en **Transit/Surface** (charpentes, ruines) — **pas** dans la terre brute (c'est un matériau manufacturé/organique).
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
- **Paliers d'outils de creusage** : **Pierre → Fer → Acier/Composants**, calqués sur les matériaux des zones (Transit → Usines → Militaire/Labos). De meilleurs outils percent les zones plus dures → **gating** de l'ascension.
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
