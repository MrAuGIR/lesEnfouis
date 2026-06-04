# Prototype — *Les Enfouis* (Godot 4.6)

Prototype **grey-box** (formes simples, aucun art final). Objectif : prouver que le **cœur est
fun** — `creuser → récolter → revenir` — cf. [`../docs/PROTOTYPE.md`](../docs/PROTOTYPE.md).

## Lancer

Depuis la racine du dépôt :

```bash
godot --path prototype
```

(ou `~/.local/bin/godot --path prototype` si `godot` n'est pas dans le PATH)

Ouvrir dans l'éditeur Godot :

```bash
godot --editor --path prototype
```

## Contrôles

- **ZQSD** (ou WASD) ou **← / →** : se déplacer · **Espace / Z / ↑** : sauter
- **Clic gauche** : creuser la tuile visée (dans le rayon autour du héros)
- **Clic droit** : **frapper** (mêlée) dans la direction de la souris — contre les robots
- **I** : ouvrir/fermer l'**inventaire** (sac en grille de slots + stockage de base) —
  **clic** = prendre/poser/fusionner une pile, **Maj+clic** = transfert rapide sac ↔ base
- **R** : recharger la lampe (lithium) · **T** : poser une torche (bois)
- **F** : poser une **échelle** (bois) dans la colonne, des pieds vers le haut — puis **Z/S** (ou ↑/↓) pour **grimper**
- **E** : déposer à la base (si proche) / récupérer une cache (si proche)
- **Q** : retirer de la base vers le sac (raccourci ; le réglage fin se fait à l'inventaire)
- **1 / 2 / 3** (près de la base) : construire **Production** / **Atelier** / **améliorer l'outil**
- **K** : mourir (test — largue le butin dans une cache)

## État

- **Jalon 0 — mouvement & creusage** : déplacement avec gravité/collision, creusage à la souris
  avec progression + éclat de cassage, compteur de ressources (terre/roche). ✅
- **Jalon 1 — génération & lumière** : monde généré par **bruit** (relief de surface, cavités,
  filons de roche, **bunkers abandonnés** préfabriqués) ; **mécanique de lumière** : obscurité +
  **lampe frontale (casque)** = **faisceau dirigé vers la souris** + halo doux autour du corps,
  lumière du jour déclinant avec la profondeur, et **occlusion** (la lumière s'arrête aux murs). ✅
- **Jalon 1b — carburant & torches** : la **lampe frontale se vide** (autonomie limitée) et
  **faiblit** quand l'énergie est basse. Deux énergies distinctes et **deux origines** :
  on **mine du lithium** (dans la roche) pour **recharger la lampe** (`R`), et on **récupère du
  bois dans les bunkers abandonnés** (structures en béton) pour **poser des torches** (`T`,
  flamme). Le bois ne se trouve **pas** dans la terre — c'est un matériau humain à fouiller. ✅
- **Jalon 2 — sac limité, dépôt & mort** : le **sac a une capacité** (au-delà, le butin ramassé
  est perdu) ; on **dépose** à la **base** (zone verte au point de départ, `E`) pour vider le sac
  et se soigner ; **PV + dégâts de chute** ; à la **mort**, le butin transporté tombe dans une
  **cache récupérable** (`E`) sur place (façon Souls), et on **réapparaît à la base**. ✅
- **Jalon 3 — base, PNJ & craft** : près de la base, **construire** (avec le stockage) une
  **Production** (`1`) où un **PNJ génère du lithium en passif** (même quand on explore) et un
  **Atelier** (`2`) ; **améliorer l'outil de creusage** (`3`, paliers **Pierre → Fer → Acier** =
  creusage plus rapide). La boucle *expédition → dépôt → développement → repartir* est bouclée. ✅
- **Jalon 4 — bouclage & mini-objectif** : déplacement **ZQSD** (touches physiques) ; une session
  jouable assemble tout — descendre, gérer lumière/carburant, franchir une **barrière de roche
  dense** (nécessite l'**outil Fer** → retour base + atelier + amélioration), récupérer
  l'**Artefact** au fond et le **rapporter à la base** pour **gagner** (objectif suivi dans le HUD).
  Mourir en le portant le largue dans la **cache**. ✅
- **Inventaire à slots (façon Minecraft)** : le sac est une **grille de cases** ; les objets
  identiques s'**empilent** (un type = 1 slot tant que la pile n'est pas pleine), ce qui corrige
  le « sac qui se remplit trop vite ». Écran d'inventaire (`I`) avec **glisser via clic**
  (prendre/poser/fusionner une pile) et **Maj+clic** pour transférer vite **sac ↔ stockage**,
  pour enfin **choisir ce qu'on rapporte**. Le stockage de base reste illimité. ✅
- **Jalon 5a — combat mêlée** : des **robots** (grey-box rouge) patrouillent le sous-sol,
  **poursuivent** le héros à vue (avec ligne de vue) et infligent des **dégâts au contact**.
  Le héros **frappe au clic droit** (arc court vers la souris, cooldown) ; ~2 coups détruisent
  un robot, qui **lâche du lithium** (batteries). Ils sont **peu visibles dans le noir** →
  la lampe sert aussi à les repérer. *(Arme à feu + munitions = sous-étape suivante.)* 🟡
- Tout est piloté par `scripts/Game.gd` ; les **valeurs réglables** (vitesse de creusage,
  gravité, saut, portée, **rayon/portée de lumière**…) sont en haut du script.

> Prochains jalons (inventaire/extraction + mort, base/PNJ + craft) : voir
> [`../docs/PROTOTYPE.md`](../docs/PROTOTYPE.md).
