# 03 — Personnages & Ennemis

> Qui joue-t-on, qui peuple le monde, et à quoi s'oppose-t-on ?
>
> 🧑 **Briefs de concept pour le designer :** [Le Héros](../concept-art/brief-concept-heros.md) (modules de l'avatar) · [L'ennemi Robot](../concept-art/brief-concept-ennemi-robot.md) (langage visuel + deux registres lore).
>
> 🖼️ **Planches livrées :** [héros](../concept-art/concept-hero.png) ([retour](../concept-art/retour-concept-heros.md)) · [ennemi robot](../concept-art/concept_enemis_robot.png) ([retour](../concept-art/retour-concept-ennemi-robot.md)).

---

### Q. Qui est le personnage jouable ?
**R.** ✅ Un **humain survivant**, dirigé directement (creuse, explore, récolte, combat).
**Avatar personnalisable** : choix de **cheveux, corps/tenue, couvre-chef, visage**, et un
**background** (façon Project Zomboid) donnant un **atout de départ simple** (bonus, **sans
malus**). Les **compétences progressent ensuite à l'usage** (creuser améliore le creusage,
combattre le combat, etc.) ; le background n'est qu'un **coup de pouce initial**.
> 💡 *Compétences détaillées ci-dessous* ; courbe d'XP au prototypage.
- [ ] Validé

### Q. Quels sont les backgrounds et leurs atouts ?
**R.** ✅ **8 backgrounds**, chacun un **atout de départ** (bonus seulement) :
- **Enfant des galeries** *(enfant abandonné)* — polyvalent : pas de gros bonus, **apprend un peu plus vite** (XP).
- **Mineur** — **creusage plus rapide**, outils s'usent moins.
- **Sapeur** — démarre avec des **explosifs / recette de bombes** (percer & dégâts de zone).
- **Agent de sécurité** — **+ efficacité aux armes à feu**, démarre armé.
- **Ingénieur** — **+ recettes de craft**, pièces de base moins chères/plus rapides.
- **Médecin** — **soins & consommables** (eau/nourriture) plus efficaces.
- **Contrebandier** — **+ capacité de sac** (extraction), meilleurs prix chez les marchands.
- **Spéléologue** — **meilleure vision dans le noir**, torches durent plus, + déplacement.
> 💡 *MVP* : en livrer 3-4 d'abord. *À détailler* : valeurs chiffrées des bonus.
- [ ] Validé

### Q. Quelles compétences montent à l'usage, et comment ?
**R.** ✅ **7 compétences**, chacune montant en pratiquant l'activité (façon Project Zomboid).
**Structure : niveaux 1→10**, à **bonus chiffrés progressifs** (pas de perks débloqués),
montée **lente et gratifiante** (la maîtrise est un accomplissement de long terme).
**Persistantes** (non perdues à la mort). Le background donne un **niveau de départ** dans sa
compétence.
- **Excavation** (creuser) — + vitesse de creusage, − usure des outils · *Mineur*
- **Mêlée** (corps-à-corps) — + dégâts / vitesse · *(Sapeur)*
- **Armes à feu** (tirer) — + précision, − recul, + dégâts · *Agent de sécurité*
- **Artisanat** (crafter) — − coût en matériaux, meilleure qualité · *Ingénieur*
- **Médecine** (soigner) — soins & consommables plus efficaces · *Médecin*
- **Portage** (transporter) — + capacité de sac, + vitesse en charge · *Contrebandier*
- **Exploration** (explorer / dans le noir) — + vision, + déplacement, + discrétion · *Spéléologue*

*L'**Enfant des galeries** gagne de l'**XP plus vite** partout.*
> 💡 *À détailler* : valeurs par niveau et courbe d'XP (relève de l'équilibrage/prototypage).
- [ ] Validé

### Q. Quel est le rôle des PNJ et d'où viennent-ils ?
**R.** ✅ Des **PNJ** s'affectent aux **salles de la base** et travaillent en autonomie
(production de ressources, défense des bunkers). **Recrutement par deux voies** : (1)
**survivants sauvés en exploration** (dans les bunkers/caves) et (2) **arrivées spontanées**
à une base sûre et prospère (façon Fallout Shelter).
> 💡 *À détailler* : les PNJ ont-ils des compétences/niveaux/spécialités ? Un nombre max
> (capacité d'accueil de la base) ?
- [ ] Validé

### Q. Quels sont les ennemis ?
**R.** ✅ **Uniquement deux familles** : ennemis **humains** (pillards/factions) et
**robots**, rencontrés dans les **caves et bunkers** explorés. Pas de créatures/mutants —
choix de focalisation (moins d'assets, identité claire). Les familles sont **déclinées par
zone** (variantes selon la fonction de la zone). Les **robots** apparaissent surtout dans les zones hautes (Usines + Militaire/Labos + Surface). Nuance
lore : les machines **solitaires / sans maître** (plus on s'éloigne de la surface) sont les
vestiges des **IA 'perdantes'** de la guerre, hostiles par automatisme aveugle ; les machines
**proches de / à la surface** sont **contrôlées par l'IA 'victorieuse'** (le boss final).
> 💡 *À détailler* : archétypes de comportement, différences humains vs robots, variantes par couche.
- [ ] Validé

### Q. Les bases sont-elles attaquées (raids) ? Par qui ?
**R.** ✅ Oui, **raids réguliers** : des ennemis (humains/robots) attaquent la base ; les
**PNJ affectés aux bunkers de défense** la protègent. Justifie la défense et crée des
moments de tension forts.
> 💡 *À détailler* : déclenchement des raids (temps, richesse de la base, profondeur/couche,
> proximité de la surface ?), intensité croissante, conséquences d'un raid raté (pertes,
> ressources volées, PNJ tués ?).
- [ ] Validé

### Q. Y a-t-il des boss / rencontres marquantes ?
**R.** ✅ **Un boss par zone** + le **boss final**, chacun enseignant une facette du jeu.
Les deux boss humains sont des **chefs de factions de survivants actuels** (plus de référence
d'époque) ; le design de combat est conservé :
- **🚇 Transit — « le Roi des Galeries »** (humain, chef de la faction des **pilleurs des tunnels**) : mêlée lourde, invoque des sbires par vagues, déclenche des **pièges** de l'arène. *Phase 2 : enrage.* → gestion de la foule + esquive.
- **⚙️ Usines — « le Seigneur de la Fonderie »** (humain, chef d'une **milice technophile**) : tanky en armure, charges, appelle des **fusiliers**. *Phase 2 : brise les structures → chutes & obscurité.* → ciblage prioritaire & lumière.
- **🛡️ Militaire/Labos — « LÉVIATHAN »** (automate de guerre, vestige d'une IA *perdante*) : gros **dégâts à distance** (canons, missiles), attaques de zone, **blindage à percer** (points faibles). *Phase 2 : se déchaîne.* → munitions & couverture.
- **☀️ Surface — Boss final : NAPOLÉON** (nom complet **NAPOLÉON-B32 // version 4**) — l'**IA victorieuse** qui « protège » la surface. Froide, logique, presque tragique ; **elle parle** pendant le combat (expose sa logique). **Multi-phases** : commande drones/tourelles, **gaz toxiques** omniprésents (éclairage spécial requis), puis un **noyau** à détruire. → synthèse de tout le jeu.

**Mini-boss optionnels** : quelques rencontres facultatives dans les zones (chefs de
**bandits**, **automates d'élite**…), avec du **bon loot** en récompense.
> 💡 *À détailler / confirmer* : noms & placement par zone des 2 boss humains (propositions ci-dessus), patterns précis, PV/dégâts, loot garanti de chaque boss ; liste des mini-boss.
- [ ] Validé

### Q. Y a-t-il des PNJ non hostiles hors base (marchands, autres survivants) ?
**R.** ✅ **Oui, un monde vivant** : des **marchands** (économie de l'or), des **factions
enfouies** (amicales ou hostiles selon les cas) et des **bandes de bandits** (hostiles).
Enrichit la narration, l'économie et le danger.
> 💡 *À détailler* : quelles factions, leur attitude/relations, l'intérêt de
> commercer/s'allier, et leur lien avec les ennemis humains ([voir ci-dessus](#q-quels-sont-les-ennemis-)).
- [ ] Validé
