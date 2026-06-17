# Les Enfouis *(The Buried)*

> *« L'humanité s'est enterrée. À toi de remonter. »*

Jeu de **survie, construction et exploration souterraine en 2D** (vue en coupe).
Après l'apocalypse, l'humanité s'est enfouie sous terre. On dirige un survivant qui
**creuse** le sol pour explorer, **récolte** des ressources, **affronte** humains et
robots, et **bâtit** des bases façon *Fallout Shelter* — avec pour but de **remonter
vers la surface**, de plus en plus dangereuse.

> 🚧 **État : MVP en grey-box.** Mécaniques jouables (creuser, bases & PNJ, caravane,
> raids, boss, audio), formes simples — l'art final viendra dans une passe dédiée.

Références d'ambiance : Minecraft (creuser) · Fallout Shelter (base/PNJ) · Metro 2033 (ton).

---

## Démarrage express

**Prérequis : [Godot Engine 4.6.3 stable](https://godotengine.org/download)** (build
standard, *pas* la version .NET). C'est la **seule** dépendance — du GDScript pur, aucun
build.

```bash
git clone git@github.com:MrAuGIR/lesEnfouis.git
godot --path lesEnfouis/game        # ouvre le projet dans l'éditeur, puis ▶ (F5)
```

Le projet Godot jouable est dans **`game/`** (scène `res://main.tscn`).

### Contrôles essentiels

| | | | |
|---|---|---|---|
| **ZQSD/WASD** se déplacer | **Espace** sauter | **Clic G** creuser | **Clic D** attaquer/tirer |
| **E** action contextuelle | **B** construire | **I** inventaire | **X**/molette changer d'arme |

👉 **Liste complète des touches et guide complet : [docs/DEVELOPPEUR.md](docs/DEVELOPPEUR.md).**

---

## Documentation

- 🛠️ **[Guide développeur](docs/DEVELOPPEUR.md)** — installer, lancer, tester, contribuer.
- 📖 **[Game Design Document](docs/README.md)** — vision, mécaniques, univers, contenu (GDD complet).
- 📄 **[Synthèse une page](docs/SYNTHESE.md)** · 🎨 **[Direction artistique](docs/BRIEF-DIRECTION-ARTISTIQUE.md)**

---

## Contribuer

Les contributions sont les bienvenues. Avant de coder, lire le
**[guide développeur](docs/DEVELOPPEUR.md)** : il décrit la structure du code, comment
vérifier une modif, et les **contraintes du projet** (grey-box d'abord, lisibilité
**non-colorée** car le porteur du projet est daltonien, claviers via touches physiques,
langue française). Travailler sur une **branche** dédiée puis ouvrir une **Pull Request**.
