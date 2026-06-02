# Brief de direction artistique — *Les Enfouis* (The Buried)

> **À l'attention du / de la designer (concept artist).** Ce document décrit l'**intention
> visuelle** du jeu. Objectif de cette étape : des **explorations de style** (mood board +
> quelques concepts clés), **pas** des assets finaux. La techno n'est pas fixée ; raisonne en
> **pixel art 2D**.
>
> Détail gameplay complet dans le GDD (`docs/`), notamment [04-direction-artistique.md](04-direction-artistique.md).
>
> 🖼️ **Itérations du designer :** dossier [`concept-art/`](../concept-art/) —
> [couche Industrielle](../concept-art/planche-style-couche-industrielle.png)
> ([retour](../concept-art/retour-planche-01-industriel.md)) ·
> [héros](../concept-art/concept-hero.png)
> ([retour](../concept-art/retour-concept-heros.md)).
>
> 🧑 **Briefs de concept (par élément) :** [Le Héros](../concept-art/brief-concept-heros.md) ·
> [L'ennemi Robot](../concept-art/brief-concept-ennemi-robot.md) ·
> [Le HUD](../concept-art/brief-concept-hud.md).

## 1. Le projet en bref

Jeu de **survie / construction / exploration souterraine** en **2D vue en coupe**. Après une
3e Guerre mondiale achevée par une IA, l'humanité s'est **enfouie**. On creuse un monde fait de
**couches de civilisations** pour **remonter vers la surface** (de plus en plus dangereuse).
**Ton :** sombre post-apo, **humour à la Fallout**, **mystère à la Metro 2033**.
**Références jeu :** Minecraft, Fallout Shelter, Metro 2033, Terraria.

## 2. Intention visuelle

Faire ressentir la **petite lumière qui s'enfonce dans le noir** : un sous-sol oppressant mais
**coloré et lisible**, où chaque couche raconte une **époque** différente. L'image doit être
**chaleureuse par contraste** (la base, la lampe) au milieu d'un monde hostile.

## 3. Style

- **Pixel art coloré, classique** (contours lisibles, formes claires). *Pas* de vectoriel.
- **Niveau de détail :** personnages et ennemis **très lisibles** ; décors plus stylisés.
- **Animation :** pixel art **image par image**, volontairement **sobre** (peu de frames par action) — cohérent avec une équipe indie.
- **Résolution / taille de tuile :** 🔒 **figé — tuiles 16 px**, héros **~2 tuiles (~30-32 px)** (creusage fin + modules de l'avatar lisibles). Résolution interne en ×3/×4 (ex. ~480×270 → 1080p).
- **Monde en tuiles destructibles :** les tilesets doivent **se raccorder proprement** et distinguer d'un coup d'œil **bloc creusable vs non-creusable**.

## 4. Palette & identité par couche

Une **palette signature par couche** (on doit savoir où l'on est d'un coup d'œil). De bas
(ancien, sûr) en haut (récent, mortel) :

| Couche | Époque | Palette / ambiance |
|--------|--------|--------------------|
| ⛟ **Foyer** | Moderne (refuge) | Chaud, **lumineux, vivant** (le havre) |
| 🏺 **Antiquité** | la plus ancienne | **Ocres / dorés chauds**, terre cuite, braseros |
| 🏰 **Médiéval** | — | **Gris-bleu froid**, pierre, mousse, torches |
| ⚙️ **Industriel** | — | **Acier / rouille + accents néon**, début de **brume de pollution** |
| ☀️ **Surface** | Présent / catastrophe | **Lumière crue voilée, gris-jaune toxique** (contraste violent) |

> La **brume / les gaz de pollution** : traitement visuel **signature**, reconnaissable
> partout (teinte malsaine, légèrement mouvante), de plus en plus présent vers le haut.

## 5. Lumière (essentiel — c'est une mécanique)

Le sous-sol est **sombre** : la lumière n'est pas que de l'ambiance, c'est du **gameplay**.
- Le héros porte sa **propre lumière** (lampe/torches) → halo net autour de lui, le reste
  s'assombrit/désature.
- Concevoir les décors pour **bien rendre sous un éclairage ponctuel** (volumes, ombres).
- La lumière = **outil de lisibilité** principal (cf. §6) et vecteur d'angoisse/mystère.

## 6. Lisibilité gameplay (priorité absolue)

- **Héros :** silhouette unique + **source de lumière colorée** → toujours repérable.
- **Ennemis :** lecture de la menace **par la forme** ; familles humains / robots distinctes.
- **Danger** (pièges, gaz, ennemis) : **couleurs d'alerte réservées** (orange/rouge), jamais utilisées pour le décor neutre.
- **Loot / interactifs :** scintillent ou ne se révèlent qu'à la lampe → ressortent du décor.
- **Arrière-plans** désaturés / en retrait pour ne pas concurrencer l'action.

## 7. UI / HUD

- Style **rétro-futuriste / terminal** : écran d'ordinateur, **Pip-Boy** (Fallout), jauges **Metro**.
- Lisible et **minimal en jeu**, plus décoré au Foyer/menus.
- Éléments à prévoir (maquette) : **santé**, **sac/butin** + capacité, **lampe** (autonomie),
  **arme/outil + munitions**, **profondeur/couche**, **alertes** (danger, raid).

## 8. Ton & détails narratifs (à parsemer)

- **Humour Fallout :** affiches de **propagande**, objets **rétro-futuristes** décalés, slogans d'époque.
- **Mystère Metro :** ruines évocatrices, traces d'une catastrophe, atmosphère feutrée.
- Chaque couche = une **époque** : l'architecture et les props doivent la raconter (temples antiques, cryptes médiévales, usines & automates rouillés).

## 9. Références (pour le mood board)

- **Terraria / Dead Cells** — pixel art, monde de blocs, lisibilité.
- **Hollow Knight** — gestion de la lumière et de l'obscurité.
- **Don't Starve** — ton « joli mais hostile », silhouette.
- **Fallout** — UI Pip-Boy, humour, props rétro-futuristes.
- **Metro 2033** — atmosphère, oppression, mystère.

## 10. Contraintes

- **2D vue en coupe**, monde en **tuiles creusables** (raccord + lecture creusable/non).
- **Tilesets & props modulaires par couche** (réutilisables → variété à coût maîtrisé).
- Échelle **indie** : viser l'impact maximal avec un volume d'assets maîtrisé.

## 11. Livrables attendus de cette 1re étape (concept, pas production)

1. **1 planche de mood board / recherche de style** (la direction générale).
2. **1 essai de résolution / taille de pixel** (1-2 options) sur un petit décor.
3. **Le héros** : 1-2 propositions de design (silhouette + lampe).
4. **1 couche** au choix (suggestion : **Industriel**, la plus typée) : un décor d'ambiance.
5. **1 ennemi** (ex. un robot « solitaire »).
6. **1 maquette de HUD** (terminal).

> ❌ **Pas demandé maintenant :** sprite sheets finaux, toutes les animations, la liste
> exhaustive d'assets. On verrouille d'abord **le look** ; les specs de production viendront
> ensuite, par lots, après validation du concept et du prototype gameplay.
