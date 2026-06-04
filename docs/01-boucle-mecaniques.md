# 01 — Boucle de jeu & Mécaniques

> Le cœur du jeu : ce que le joueur **fait**, minute après minute. Section la plus importante.

---

### Q. Quel est le modèle de contrôle (qui dirige-t-on) ?
**R.** ✅ On incarne **un héros** (humain survivant) qu'on déplace directement : il creuse,
explore, récolte et combat. En parallèle, des **PNJ autonomes** sont affectés aux salles
de la base et travaillent automatiquement (production, défense).
> 💡 *Conséquence* : le jeu mêle **action directe** (le héros) et **gestion légère** (les PNJ/la base).
- [ ] Validé

### Q. À quoi ressemble la boucle de gameplay principale ?
**R.** 🟡 Proposition à valider :
`Depuis la base → creuser/explorer le sous-sol vers le haut → récolter des ressources & affronter les dangers → revenir à la base avec le butin → investir (construire des pièces, affecter des PNJ, crafter de l'équipement) → repartir plus loin / plus haut`.
> 💡 *À confirmer* : c'est la boucle « expédition → retour → développement → expédition ».
> ✅ **Validée en prototype (juin 2026)** : la boucle complète est jouable et jugée **fun**
> (cf. risque n°1 levé, [08](08-perimetre-production.md)). Le combat/les dangers restent à
> ajouter en production.
- [x] Validé (cœur prouvé en prototype ; combat à venir)

### Q. Comment fonctionne le creusage / l'exploration ?
**R.** ✅ Le héros **creuse façon Minecraft** dans une **terre/roche creusable**, mais les
**bunkers, abris et caves** sont des **salles fixes** (conçues/préfabriquées) que l'on
découvre. On peut poser de **petits abris-relais** de bas niveau pour se reposer et
sécuriser un chemin.
> 🪜 **Déplacement vertical — échelles (mécanique clé).** Le jeu est **vertical** (on remonte du
> bas vers le haut, en alternant **cavernes** et **passages à creuser**). Pour éviter les
> escaliers à rallonge, le joueur **construit des échelles** (en **bois**) qu'il **pose dans une
> colonne** et **grimpe** (monter/descendre). Indispensable au confort de remontée. *(Validé en
> prototype : pose verticale au bois + escalade.)*
> 💡 *À détailler plus tard* : règles de creusage (tout est-il creusable ? blocs à poser ?
> outils requis ?), gravité/effondrements, génération de la carte, autres aides de mobilité.
- [ ] Validé

### Q. Que se passe-t-il quand le héros meurt ?
**R.** ✅ Mort → **retour à la base** ; le **butin transporté** tombe dans un **corps/cache
récupérable** à l'endroit de la mort (façon Souls) — on peut repartir le chercher, au risque
de remourir. La base, ses améliorations et les PNJ **restent**. C'est le cœur de la tension
d'**extraction** (façon Metro).
> 💡 *À détailler* : la cache persiste-t-elle indéfiniment ? pénalité de soin/temps au respawn ?
- [ ] Validé

### Q. Comment fonctionnent les ressources ?
**R.** ✅ Panel façon Age of Empires : **eau, nourriture, bois, lithium, fer, pierre, or**. Elles
servent au **craft, à la construction et au soin** — **pas** d'entretien vital d'une
population (les PNJ ne meurent pas de faim). Produites par les pièces de base (avec PNJ) et
récoltées en exploration.
> 💡 *À déterminer* : usage précis de chaque ressource (l'or = monnaie/échange ? le bois =
> construction ? le fer = équipement ?). Voir [06](06-contenu-progression.md).
- [ ] Validé

### Q. Comment fonctionne la base (construction & gestion) ?
**R.** ✅ Bâtie **dans le même monde 2D, en coupe**, à partir d'une **bibliothèque de
pièces** (façon Fallout Shelter) : pièces de **production** (eau, nourriture, bois, fer,
pierre, or), pièce de **crafting**, pièces **bunker** de défense. On **affecte des PNJ**
aux salles pour produire ou défendre. **Plusieurs bases** possibles.
> 💡 *À déterminer* : d'où viennent les PNJ (recrutement) ? Les bases sont-elles attaquées
> (raids) ? Coût/déblocage des pièces ? Voir [03](03-personnages-ennemis.md) et [06](06-contenu-progression.md).
- [ ] Validé

### Q. Comment fonctionne le combat ?
**R.** ✅ Combat **temps réel**, au choix **corps-à-corps** ou **arme à feu** (deux familles
d'armes), avec **visée à la souris** (la position de la souris donne la direction du coup/
tir). **Munitions limitées et précieuses** — la survie prime (Metro) — obtenues par **loot +
craft**. **Rareté** : ordinaire / rare / **légendaire**, où les paliers améliorent surtout
les **stats** (dégâts, cadence, précision) ; les **légendaires** (arme **ou** équipement)
tombent uniquement sur les **boss de couche**. Seuls les **outils de creusage s'usent** —
les armes ne se dégradent pas.
> 💡 *À détailler* : liste d'armes mêlée & feu, valeurs des paliers, recette/coût des
> munitions, équilibre mêlée vs distance. Outils & craft : [06](06-contenu-progression.md).
- [ ] Validé

### Q. Comment le héros / le joueur progresse-t-il dans le temps ?
**R.** ⬜ À déterminer.
> 💡 *Pistes* : meilleur équipement crafté (outils de creusage, armes, armure), pièces de
> base plus avancées, déblocage de technologies, montée en puissance pour atteindre les
> couches supérieures dangereuses. À structurer en [06](06-contenu-progression.md).
- [ ] À déterminer

### Q. Quelle est la principale source de tension et de récompense ?
**R.** 🟡 Proposition : **tension** = monter vers la surface (danger croissant) + risque de
perdre son butin en mourant ; **récompense** = ressources rares, technologies anciennes des
couches, et l'extension/sécurisation de sa base.
> 💡 *À confirmer/affiner.*
- [ ] Validé
