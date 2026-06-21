# Valeurs gameplay — référence pour l'intégration (designer ⇄ dev)

> **But** : couper court aux allers-retours. Toutes les valeurs ci-dessous sont
> **extraites du code** (`game/scripts/enemy_crew.gd` et `game/scripts/boss.gd`),
> pas inventées. Quand une variable de fiche d'intégration ne correspond pas 1:1
> au code, c'est signalé explicitement.

## Conventions

- **Unités** : le code est en **px/s**. **1 tuile = 16 px** (`WorldGrid.TILE`, figé dans la DA).
  Les portées sont données en tuiles **et** en px.
- **Référence héros** (pour calibrer les vitesses) : `MOVE_SPEED = 98 px/s`, `MAX_HP = 100`.
- **Attaque « contact »** : les fonceurs / lourds / robots frappent au **contact**
  (recouvrement des boîtes AABB) — il n'y a **pas** de portée d'attaque ; mettre
  `ATTACK_RANGE = 0` et compter sur la taille de la boîte.
- **Accessibilité (daltonisme)** : aucun rôle ne doit être lisible par la seule
  couleur — silhouette / posture / point faible visibles sans couleur.

## Ennemis

| Type | KIND | `MOVE_SPEED` (px/s) | en poursuite ×1.5 | `ATTACK_RANGE` | `ATTACK_COOLDOWN` | `HEALTH` | dégâts contact | boîte (demi) |
|---|---:|---:|---:|---|---:|---:|---:|---|
| **robot**   | 0 | 42.0 | 63.0 | contact (AABB) | 0.8 s | 60.0  | 12.0 | (6, 7) → 12×14 px |
| **fonceur** | 1 | 48.0 | 72.0 | contact (AABB) | 0.8 s | 50.0  | 10.0 | (5, 10) → 10×20 px |
| **tireur**  | 2 | 40.0 | (garde ses distances) | 11 t = 176 px (hitscan) | 1.6 s | 40.0 | 8.0 | (5, 10) → 10×20 px |
| **lourd**   | 3 | 20.0 | 30.0 | contact (AABB) | 0.8 s | 220.0 | 24.0 | (8, 12) → 16×24 px |

### Comportements à connaître pour l'anim / la lisibilité

- **Détection** : 9 tuiles (144 px) **avec ligne de vue**. En-deçà → poursuite (la
  marche doit lire **deux cadences** : patrouille vs poursuite ×1.5).
- **Tireur** : recule sous **5,5 tuiles (88 px)**, tire entre 5,5 et 11 tuiles,
  cooldown **1,6 s**, **30 % de tirs ratés** (grey-box). Posture de tir = télégraphe
  clé. Ne charge pas (pas de ×1.5).
- **Lourd** : **blindé de FACE (×0.25 dégâts reçus)**, **vulnérable de DOS (×1.5)**.
  → le **dos exposé** (sac, sangles, nuque) doit être lisible **sans couleur** :
  c'est le point faible jouable, priorité art.
- **Robot** : population de la **surface / zone de gaz** (au-dessus de la barrière),
  pas dans le Transit. Patrouille → poursuite, demi-tour aux murs et aux bords de vide.

### Blocs prêts à coller

```gdscript
# robot
const MOVE_SPEED = 42.0       # px/s (×1.5 = 63 en poursuite)
const ATTACK_RANGE = 0.0      # contact AABB
const ATTACK_COOLDOWN = 0.8
const HEALTH = 60.0

# fonceur
const MOVE_SPEED = 48.0       # px/s (×1.5 = 72 en poursuite)
const ATTACK_RANGE = 0.0
const ATTACK_COOLDOWN = 0.8
const HEALTH = 50.0

# tireur
const MOVE_SPEED = 40.0
const ATTACK_RANGE = 176.0    # 11 tuiles, tir hitscan ; recule sous 88 px (5,5 t)
const ATTACK_COOLDOWN = 1.6
const HEALTH = 40.0

# lourd  (blindé de face ×0.25 / dos ×1.5)
const MOVE_SPEED = 20.0
const ATTACK_RANGE = 0.0
const ATTACK_COOLDOWN = 0.8
const HEALTH = 220.0
```

## Boss — Roi des Galeries (KIND 4)

| Variable | Valeur | Note |
|---|---:|---|
| `HEALTH` | 550.0 | |
| `SPEED_NORMAL` | 34.0 px/s | |
| `SPEED_ENRAGE` | 45.9 px/s | 34 × 1.35 (enrage à 50 % PV) |
| `TELEGRAPH_TIME` | 0.8 s | **0.55 s en enrage** |
| `CHARGE_DISTANCE` | — | pas fixe : voir note |
| `SLAM_COOLDOWN` | — | pas isolé : voir note |
| dégâts contact | 18.0 | |
| dégâts charge | 26.0 | |
| dégâts slam | 14.0 | onde au ras du sol, 3 tuiles |
| enrage dégâts | ×1.25 | |

- **`CHARGE_DISTANCE`** : pas de distance fixe. Charge à **215 px/s**, plafond **1,6 s**
  → **max ~344 px (~21 tuiles)**. S'arrête plus tôt sur un mur ou ~28 px après avoir
  dépassé le héros. (anim `charge` = boucle 2 frames @ 80 ms : OK, c'est une course.)
- **`SLAM_COOLDOWN`** : pas de cooldown isolé. Cycle après un slam : récupération
  **0,9 s** → marche d'approche **1,1–2,0 s** → télégraphe **0,8 s** → charge → slam.
  **Cadence effective entre deux slams ≈ 3–5 s.**
- **Vagues de sbires** aux paliers **75 / 50 / 25 % PV** : 2 fonceurs + 1 tireur
  (pilleurs normaux, ancrés au centre de l'arène).
- **Enrage à 50 %** : jets de vapeur périodiques au sol (effet moteur — **à ne pas dessiner**).

### Alignement anim ↔ code à valider côté art

- `telegraphe` = 2 frames × 400 ms = **800 ms** ⇒ colle pile à `TELEGRAPH_TIME` (0,8 s). ✔
- ⚠️ **En enrage la fenêtre tombe à 0,55 s** : l'anim sera jouée **accélérée / tronquée**.
  À confirmer qu'elle reste lisible compressée.

### Bloc prêt à coller

```gdscript
const SPEED_NORMAL = 34.0     # px/s
const SPEED_ENRAGE = 45.9     # 34 × 1.35 (enrage à 50 % PV)
const TELEGRAPH_TIME = 0.8    # s  (0.55 s en enrage)
const CHARGE_DISTANCE = 344.0 # max ; charge réelle = 215 px/s plafonnée à 1,6 s
const SLAM_COOLDOWN = 3.0     # indicatif : cadence effective 3–5 s (recover+stalk+telegraph)
```

---

**Source** : `game/scripts/enemy_crew.gd` (`K_HP`, `K_SPEED`, `K_DMG`, `K_HALF`,
`ENEMY_*`, `SHOOT_*`, `LOURD_*`) et `game/scripts/boss.gd` (`*_SPEED`, `TELEGRAPH_*`,
`CHARGE_*`, `SLAM_*`, `ENRAGE_*`, `WAVE_*`). En cas de doute, **le code fait foi** —
mettre cette fiche à jour si une constante change.
