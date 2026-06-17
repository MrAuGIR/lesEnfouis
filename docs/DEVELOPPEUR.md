# Guide développeur — Les Enfouis

> Tout ce qu'il faut pour **installer, lancer et contribuer** au jeu. Le projet est en
> phase **MVP grey-box** (formes simples, pas d'art final) : on valide les mécaniques
> avant de produire les assets. Pour le *concept* du jeu, voir le [GDD](README.md).

---

## 1. Prérequis

| Dépendance | Version | Notes |
|------------|---------|-------|
| **Godot Engine** | **4.6.3 stable** (build standard, *pas* la version .NET/C#) | Seule dépendance du projet. |
| Git | n'importe laquelle | Pour cloner le dépôt. |

**Il n'y a aucune autre dépendance** : le jeu est écrit en **GDScript pur**, sans
gestionnaire de paquets (npm/pip…) ni étape de compilation. Pas de build : on ouvre et on joue.

### Installer Godot 4.6.3

- Télécharger sur <https://godotengine.org/download> (ou les *releases* GitHub de Godot)
  la version **4.6.3 stable**, build standard.
- C'est un exécutable autonome (aucune installation système requise). Exemple sous Linux :

  ```bash
  # exemple : binaire rangé dans ~/.local/share/godot et lié dans le PATH
  mkdir -p ~/.local/share/godot ~/.local/bin
  # … déplacer Godot_v4.6.3-stable_linux.x86_64 dans ~/.local/share/godot/ …
  ln -s ~/.local/share/godot/Godot_v4.6.3-stable_linux.x86_64 ~/.local/bin/godot
  godot --version    # doit afficher 4.6.3.stable…
  ```

  Sous Windows/macOS, lancer simplement l'exécutable téléchargé.

> ⚠️ **Rester sur la 4.6.x.** Le projet déclare `config/features=PackedStringArray("4.6")`.
> Une version majeure différente (4.5, 5.x) peut casser l'import ou des API.

---

## 2. Récupérer le projet

```bash
git clone git@github.com:MrAuGIR/lesEnfouis.git
cd lesEnfouis
```

Le **projet Godot jouable est dans `game/`** (et non à la racine). Le dossier `.godot/`
(caches d'import, propres à ta machine) est **ignoré par git** — il se régénère tout seul.

---

## 3. Lancer le jeu

### a) Depuis l'éditeur Godot (recommandé pour développer)

1. Lancer Godot → **Importer / Open** → choisir `game/project.godot`.
2. Au premier ouvrir, Godot importe les ressources (quelques secondes).
3. Bouton **▶ (Play)** ou `F5`.

### b) En ligne de commande (lancement rapide)

```bash
# Depuis la racine du dépôt :
godot --path game                 # ouvre l'éditeur sur le projet
godot --path game --import        # (ré)importe les ressources sans ouvrir l'éditeur
```

Pour **jouer directement** la scène principale (`res://main.tscn`), lancer le projet
depuis l'éditeur, ou en CLI selon ta version. Le point d'entrée est défini dans
`game/project.godot` (`run/main_scene="res://main.tscn"`).

---

## 4. Contrôles

> Le jeu lit la **position physique** des touches (`is_physical_key_pressed`) : le bloc
> **WASD** fonctionne quelle que soit la disposition. Sur clavier **AZERTY**, ce bloc
> tombe naturellement sur **ZQSD** — c'est pour ça que le HUD affiche `[ZQSD]`.

| Touche | Action |
|--------|--------|
| **ZQSD** / **WASD** / flèches | Se déplacer (← →), monter/descendre échelles |
| **Espace** / **W** (haut) | Sauter |
| **Clic gauche** | Creuser le bloc visé |
| **Clic droit** (maintenu) | Attaquer (mêlée) / tirer (arme à feu) |
| **X** ou **molette** | Changer d'arme (mêlée ↔ arme à feu) |
| **I** | Ouvrir/fermer l'inventaire (sac) |
| **B** | Construire une pièce (mode placement) |
| **F** | Poser une échelle (bois) |
| **G** | Poser une passerelle (bois) |
| **R** | Recharger la lampe (lithium) |
| **T** | Poser une torche (bois) |
| **M** | Activer/désactiver l'anti-gaz |
| **E** | Action **contextuelle** : troquer, fouiller/recycler une caisse, affecter des PNJ, déposer/retirer au stock, ouvrir les portes du boss… |
| **3** | (à l'atelier) Améliorer l'outil de creusage |
| **4** | (à l'atelier) Crafter une cartouche anti-gaz |
| **Échap** | Fermer un écran / annuler le placement |
| **K** | *(debug)* Mort de test |

---

## 5. Structure du projet

```
lesEnfouis/
├── README.md            ← présentation + démarrage express
├── docs/                ← Game Design Document (GDD) + ce guide
│   ├── README.md            (index du GDD)
│   ├── DEVELOPPEUR.md       (ce fichier)
│   ├── 00-…08-*.md          (sections de design validées)
│   └── SYNTHESE / PROTOTYPE / BRIEF-DIRECTION-ARTISTIQUE
├── concept-art/         ← planches & bible visuelle
├── game/                ← ⭐ LE PROJET GODOT JOUABLE (MVP)
│   ├── project.godot
│   ├── main.tscn            (scène principale)
│   └── scripts/             (tout le code, GDScript)
└── prototype/           ← prototype historique (archive, non maintenu)
```

### Modules de `game/scripts/` (20 fichiers)

`main.gd` **orchestre** tout : il crée les systèmes, route les entrées clavier/souris et
fait tourner la boucle. La logique vit dans des modules dédiés (la plupart sont des
`RefCounted` sans nœud, pilotés par `main`) :

| Fichier | Rôle |
|---------|------|
| `main.gd` | Orchestration : boucle de jeu, entrées, création/branchement des systèmes |
| `world_grid.gd` | Le monde en tuiles : génération, types de tuiles, creusage, arène du boss |
| `world_view.gd` | Rendu du monde (tuiles) |
| `hero.gd` | Le héros : déplacement/saut, PV, lampe, gaz & anti-gaz |
| `light_field.gd` | Champ de lumière *logique* (ce qui est visible) |
| `lights.gd` | Éclairage *rendu* : halo de lampe, torches, lueurs, salles |
| `inventory.gd` | Le sac + définition des ressources (types, noms, couleurs) |
| `foyer.gd` | La base à pièces : construction, stock, **production des salles de minage** |
| `population.gd` | Les PNJ : arrivées, affectation aux postes, blessés |
| `caravan.gd` | La caravane marchande : offres et troc |
| `enemy_crew.gd` | Les ennemis (robots, pilleurs) : spawn, patrouilles, IA |
| `combat.gd` | Armes du héros (mêlée, arme à feu) + butin des ennemis |
| `raids.gd` | Les raids : vagues d'assaillants sur le Foyer |
| `boss.gd` | Le Roi des Galeries : combat de boss, arène, charge de perçage |
| `marker_view.gd` | Marqueurs/feedbacks à l'échelle du monde (creusage, flashs, indices) |
| `hud.gd` | Interface écran (HUD 4 coins) : ressources, alertes, invite contextuelle |
| `inv_ui.gd` | Écran d'inventaire (slots, glisser-déposer) |
| `room_ui.gd` | Écrans de pièce : construire / affecter des PNJ / panneau de stock |
| `trade_ui.gd` | Écran de troc avec la caravane |
| `audio.gd` | SFX **synthétisés en mémoire** (gameplay, alertes, UI) — voir §7 |

**HUD** : `main` ne donne aucune référence d'état au HUD ; il lui **pousse un dictionnaire**
complet chaque frame (`hud.set_state({...})`). Le HUD ne fait que dessiner.

---

## 6. Tester / vérifier une modif

Il n'y a pas (encore) de suite de tests formelle ; on s'appuie sur deux techniques.

### Smoke test headless (détecter erreurs/plantages)

Lance le jeu **sans fenêtre** quelques centaines de frames et vérifie qu'aucune erreur
ne sort :

```bash
godot --headless --path game --quit-after 300 2>&1 | grep -iE "error|script" ; echo done
```

`--quit-after N` quitte après N frames. Rien entre la commande et `done` = aucune erreur.

### Test logique ponctuel (`SceneTree`)

Pour vérifier une règle de jeu sans interface, on écrit un script temporaire et on le lance
avec `--script` :

```bash
cat > game/test_x.gd <<'EOF'
extends SceneTree
func _init():
    var f = Foyer.new(WorldGrid.new())
    # … asserts/print …
    print("RESULT OK")
    quit()
EOF
godot --headless --path game --script res://test_x.gd
rm -f game/test_x.gd game/test_x.gd.uid     # ne pas committer les tests jetables
```

### Après avoir ajouté un script `class_name`

Lance **un import** pour que Godot enregistre la nouvelle classe globale, sinon les autres
scripts ne la voient pas :

```bash
godot --headless --path game --import
```

> 🔊 Remarque : en `--headless`, le pilote audio est muet — pour **entendre** les SFX,
> il faut lancer le jeu avec une fenêtre (éditeur ou build).

---

## 7. Conventions & contraintes du projet

Ces choix sont **structurants** — merci de les respecter dans une contribution.

- **Grey-box d'abord.** Le MVP utilise des formes/couleurs simples dessinées au code. **Pas
  d'art final** (sprites, pixel-art) pour l'instant : c'est une passe dédiée prévue plus tard.
- **Lisibilité non-colorée (accessibilité).** Le porteur du projet est **daltonien** : une
  information ne doit **jamais** reposer sur la seule couleur. Toujours **doubler** par du
  texte, une forme, une position ou un son. Ex. : les ressources du HUD = pastille + **nom +
  nombre** ; les alertes audio ont chacune un **timbre distinct**.
- **Claviers.** Lire les touches de gameplay via `is_physical_key_pressed` /
  `physical_keycode` (le projet est développé en **AZERTY**), pour que ça marche sur toutes
  les dispositions.
- **Audio.** Les sons sont des **placeholders synthétisés** (`audio.gd`, aucun fichier
  externe). Pour ajouter un son d'événement : appeler `audio.play("nom")` côté `main`/module.
- **Langue.** Code, commentaires et UI sont en **français**.

### Style de commit

Les messages suivent un préfixe `[domaine][jalon]`, par ex. :

```
[mvp][m6] equilibrage des ressources
[mvp][m7] refonte du hud
[audio] mise en place de sons declenches par les actions/alertes
```

### Workflow contribution (proposé)

1. **Forker** / créer une **branche** dédiée (`feat/…`, `fix/…`) — ne pas pousser sur `main`.
2. Vérifier la modif : smoke test headless OK, et import si nouvelle classe.
3. Ouvrir une **Pull Request** vers `main` avec une description claire de ce qui change.
4. Garder le périmètre d'une PR resserré (une fonctionnalité / un correctif).

---

## 8. Dépannage rapide

| Symptôme | Cause probable / solution |
|----------|---------------------------|
| « Class … not found » au lancement | Lancer `godot --headless --path game --import` (enregistre les `class_name`). |
| Le projet ne s'ouvre pas / erreurs d'API | Mauvaise version de Godot → installer **4.6.3 stable** (build standard, pas .NET). |
| Écran noir / rien ne s'affiche | Vérifier qu'on ouvre bien `game/project.godot` (et pas la racine du dépôt). |
| Pas de son | Normal en `--headless` ; lancer avec une fenêtre pour entendre les SFX. |
| Modifs d'import bizarres dans git | `.godot/` est ignoré ; ne pas le committer. |
