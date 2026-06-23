<div align="center">

# ⛏️ Les Enfouis
#### *The Buried*

***« L'humanité s'est enterrée. À toi de remonter. »***

Survie · construction · exploration souterraine en **2D, vue en coupe**

[![Godot](https://img.shields.io/badge/Godot-4.6.3-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org/download) [![GDScript](https://img.shields.io/badge/GDScript-pur,_z%C3%A9ro_build-355570?logo=godotengine&logoColor=white)](docs/DEVELOPPEUR.md) [![Licence](https://img.shields.io/badge/Licence-MIT-3fb950)](LICENSE) ![État](https://img.shields.io/badge/%C3%A9tat-MVP_jouable_%C2%B7_passe_pixel--art-e3742f)

</div>

---

Après l'apocalypse, l'humanité s'est enfouie sous terre. Tu diriges un survivant qui **creuse** le
sol pour explorer, **récolte** des ressources, **affronte** humains et robots, et **bâtit** des bases
façon *Fallout Shelter* — avec un seul cap : **remonter vers la surface**, de plus en plus dangereuse.

🎬 **Inspirations** — Minecraft *(creuser)* · Fallout Shelter *(base & PNJ)* · Metro 2033 *(ton)*

> 🚧 **État : MVP jouable, passe pixel-art en cours.** Mécaniques complètes (creuser, bases & PNJ,
> caravane, raids, boss, audio) ; l'art pixel est bien intégré (tileset, héros, ennemis, boss,
> décors de fond, HUD terminal) — quelques lots et finitions restent à venir.

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

---

## Licence

Code distribué sous licence **[MIT](LICENSE)**.

> ℹ️ Les **assets graphiques** (`game/art/`) ont été produits avec l'aide d'un outil de génération
> par IA pendant la passe pixel-art. Leur statut juridique peut différer de celui du code ; en cas
> de réutilisation des images, vérifie ce point de ton côté.
