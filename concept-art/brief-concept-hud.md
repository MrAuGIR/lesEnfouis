# Brief de concept — Le HUD (interface en jeu)

> ✅ **Réponse du designer reçue :** planche [`concept_hud.png`](concept_hud.png) +
> [retour structuré](retour-concept-hud.md). À surveiller : **rouge sur rouge** (alerte UI vs
> optique robot / danger). Densité (tout permanent vs contextuel) tranchable au prototype.
>
> **À l'attention du / de la designer.** Brief ciblé pour concevoir le **HUD d'exploration**
> (l'affichage permanent pendant qu'on creuse/explore/combat). Étape **concept** : trouver le
> **langage d'interface** + la hiérarchie d'information, **pas** les écrans finaux ni les menus.
> S'appuie sur le [brief de direction artistique](../docs/BRIEF-DIRECTION-ARTISTIQUE.md) (§7) et
> la [section 07 du GDD](../docs/07-ux-ui-accessibilite.md).
> Style : **pixel art**, échelle figée **tuiles 16 px / rendu interne ~480×270 (×3-4)**.

## 1. Intention

Une interface **rétro-futuriste / terminal** : on lit le monde à travers un **vieil écran
d'ordinateur de survie** (façon **Pip-Boy** Fallout + jauges **Metro**). Elle doit renforcer
l'univers post-apo **sans gêner le jeu** : **minimale et lisible en exploration**, on peut la
décorer davantage dans les menus/au Foyer (hors de ce brief).

## 2. Contrainte n°1 — ne pas tuer la lisibilité du monde sombre

Le gameplay repose sur **l'obscurité + le halo de lampe**. Le HUD ne doit **jamais** :
- éclaircir/encombrer le centre de l'écran (réservé à l'action et au halo) → **infos en
  périphérie** (coins/bords) ;
- réutiliser les **couleurs d'alerte (orange/rouge)** pour de l'info neutre — elles sont
  **réservées au danger** (cf. brief DA) ;
- rester **lisible** par-dessus des fonds variés (sombres, brume verdâtre, néon industriel) →
  prévoir un léger **fond/contour** discret derrière les éléments.

## 3. Informations à afficher (exploration)

Hiérarchisées par importance. À traiter **comme un terminal** (chiffres, jauges, petites icônes).

| Priorité | Élément | Détail |
|----------|---------|--------|
| **Vitale** | **Santé** | jauge claire ; état critique = pulsation/alerte |
| **Vitale** | **Lampe / autonomie** | la ressource de survie clé — niveau de carburant (bois), alerte quand bas |
| **Haute** | **Arme / outil équipé** | icône de l'équipement actif + **munitions** (rares → toujours visibles) |
| **Haute** | **Sac / butin** | remplissage + **capacité** (cœur de la tension d'extraction → lisible d'un coup d'œil) |
| **Moyenne** | **Profondeur / couche** | où l'on est dans la verticalité (Foyer → Surface) |
| **Contextuelle** | **Alertes** | **danger** (ennemi/gaz) et **raid sur la base** — apparaît au besoin, couleur d'alerte |

> 💡 Penser aussi à de petits **feedbacks contextuels** (ressource ramassée, sac plein, lampe
> presque vide) — discrets, façon notifications de terminal.

## 3 bis. Hors de ce brief (pour cadrer)

Pas demandé ici : l'**inventaire détaillé**, le **menu de construction de base** (glisser-déposer
de PNJ façon Fallout Shelter), les **menus/écran-titre**, le **dialogue marchands**. Ils
viendront dans des briefs d'écrans dédiés. Ici = **uniquement le HUD permanent d'exploration**.

## 4. Lisibilité & accessibilité (à prévoir dès le concept)

- **Lisible à l'échelle de jeu** (rendu interne ~480×270) : tester les éléments à leur **vraie
  taille**, pas seulement en grand.
- **Daltonisme** : ne jamais coder une info **par la seule couleur** (jauge basse = couleur **+**
  forme/clignotement). Important dans un monde sombre.
- **Taille de texte / contraste** : prévoir que le HUD supporte une option « gros texte / fort
  contraste ».

## 5. Touche d'ambiance (sans nuire à la lisibilité)

- Effet **écran de terminal** léger : scanlines/grain **discrets**, lueur de phosphore — **subtil**,
  jamais au point de fatiguer ou de masquer l'info.
- Typo **monospace / à chiffres** crédible pour un vieil ordinateur de survie.
- Petites **imperfections** (statique, glitch léger lors d'une alerte) pour le cachet post-apo.

## 6. Références utiles

- **Fallout — Pip-Boy** : terminal, monochrome phosphore, cadran d'état.
- **Metro 2033** : jauges diégétiques, minimalisme tendu, peu d'UI à l'écran.
- **Dead Cells / Hollow Knight** : HUD pixel art discret, périphérique, lisible.

## 7. Livrables attendus de cette étape

1. **1 maquette de HUD d'exploration** complète, **à la vraie échelle** (~480×270), montrant
   tous les éléments du §3 en situation **par-dessus le décor sombre** (réutiliser une scène de
   la planche Industrielle).
2. **Le détail de 2-3 états clés** : **santé critique**, **lampe presque vide**, **alerte de
   danger/raid** (pour valider le langage d'alerte).
3. **La grammaire visuelle** : jauges, icônes, typo, fond/contour — quelques éléments isolés
   réutilisables.

> ❌ **Pas demandé maintenant :** les menus complets, l'inventaire, l'UI de construction de base,
> l'écran-titre, l'animation fine des transitions. On verrouille d'abord **le langage du HUD
> d'exploration + sa lisibilité** ; les écrans viendront par lots ensuite.
