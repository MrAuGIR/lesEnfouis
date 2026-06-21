# Brief de collecte — Production du DÉCOR DE FOND (arrière-plans, REMPLI)

> Fiche d'intake adaptée aux **fonds tuilables** (arrière-plans dessinés DERRIÈRE les tuiles du
> monde, éclairés par la lampe). Pas d'animation. L'enjeu = **tuiler sans couture** + **pas
> d'élément focal centré**. Reprend les leçons des retours décor v1/v2/v3
> ([retour](retour-decor-fond.md) · [v2](retour-decor-fond-v2.md) · [base](retour-decor-base-foyer.md))
> et le concept [`brief-concept-decor-fond.md`](brief-concept-decor-fond.md).
> 🖼️ Capture in-game jointe : [`capture-decor-fond-in-situ.png`](capture-decor-fond-in-situ.png)
> (montage des 3 contextes : base / tunnel / roche, dans la lumière du jeu).

## 1. Informations générales

| Champ | Valeur |
| ----- | ------ |
| Projet | **Les Enfouis** — MVP · Moteur **Godot 4.6.3** |
| Date | 2026-06-21 |

## 2. Contraintes techniques

| Élément | Valeur |
| ------- | ------ |
| Résolution interne | ~384×216 (×2.5), **filtre Nearest** |
| Taille de tuile (monde) | 16 px (rappel d'échelle) |
| **Taille des fonds** | **carrés en puissance de 2 : 128×128 ou 256×256** (dimensions FIXES par asset) |
| Format | **PNG** — **RGB opaque** pour les parois, **RGBA** pour les couches « structures » en surimpression |
| Mode de rendu | **texture_repeat** (tuilage), dessiné **derrière** les tuiles, **éclairé** par la lampe GPU |

> État actuel (placeholders adaptés en jeu, à remplacer) : `bg_roche.png` 256² RGB ·
> `bg_tunnel_paroi.png` 256² RGB · `bg_tunnel_structures.png` 256² **RGBA** ·
> `bg_base.png` 128² RGB. Garder ces **mêmes dimensions/role** facilite le remplacement direct.

## 3. Pipeline d'intégration

* **PNG individuels**, **un fichier par asset/couche**, nommés `bg_<contexte>[_<couche>].png` (§6).
* **ZIP de fichiers** — surtout **PAS** une planche/aperçu aplati (c'est ce qui a coincé 3× sur le
  décor : rendus d'aperçu, tailles variables, scène à lampe centrée non tuilable).
* **Aucun label, cadre, marge ni vignette** dans l'image : juste la texture, bord à bord.

## 4. Intégration moteur

* **Pas de miroir.** **Pas de parallaxe** actuellement : les fonds sont **ancrés au monde** (la
  caméra suit le héros). Concevoir des textures **neutres et homogènes** (pas de point de focus qui
  « défile »).
* **Éclairage GPU** : le fond est révélé par le halo de lampe → prévoir du **volume** mais rester
  **désaturé / en retrait** (ne pas concurrencer l'action au premier plan).
* **Couche « structures »** (tuyaux, étais, ventilation…) = **PNG RGBA séparé**, posé EN SURIMPRESSION
  sur la paroi → vraie transparence, éléments épars.

## 5. Tuilage & composition (remplace « animations ») — POINTS DURS

* **Tuilage sans couture obligatoire** : chaque paroi doit **boucler en 3×3 sans joint visible**.
  **Fournir la preuve 3×3** par asset (c'est le critère qui a recalé les v1/v2/v3).
* **PAS d'élément focal centré** (pas de « scène à lampe au milieu » qui se répète en grille). La
  paroi = **matière homogène**. Toute **déco focale** (panneau, affiche, gros tuyau, lampe murale) =
  **prop PNG transparent SÉPARÉ** (placé ponctuellement par le moteur), **pas** peint dans la texture
  qui boucle.
* **Dimensions fixes** par asset (128 ou 256), **à 1×**, sans anti-aliasing.

## 6. Les fonds à produire (3 contextes du MVP)

| Fichier | Contexte | Type | Contenu visé |
| ------- | -------- | ---- | ------------ |
| `bg_roche.png` | profondeurs | **RGB opaque, seamless** | paroi de **roche nue**, gris froid, strates discontinues |
| `bg_tunnel_paroi.png` | Transit | **RGB opaque, seamless** | paroi de **tunnel/béton** humide, gris-bleu |
| `bg_tunnel_structures.png` | Transit | **RGBA overlay** | étais / tuyaux / ventilation **épars**, transparence réelle |
| `bg_base.png` | Foyer (havre) | **RGB opaque, seamless** | **mur Fallout-Shelter** : panneaux métal rivetés **chauds**, homogène (PAS une scène) |

> Variantes bienvenues (si la répétition se voit) : `bg_roche_var1/var2.png` (mêmes dims).
> **Props focaux** (déco du Foyer : lampe, écran, panneau « Vault », casier, affiche…) = **lot de
> PNG RGBA transparents séparés** (voir aussi `assets/base_foyer_props.png` qu'il faut livrer en
> **fichiers RGBA**, pas en planche sur damier).

## 7. Contraintes artistiques

| Critère | Note (1-5) *(proposé)* |
| ------- | :--: |
| Raccord sans couture | 5 |
| Homogénéité (pas de focal centré) | 5 |
| Lisibilité du premier plan préservée (fond en retrait) | 5 |
| Niveau de détail | 2-3 |

* Palettes signatures : **Foyer** chaud/ambré · **Transit** gris-bleu froid · **roche** gris neutre.
* Le fond reste **désaturé / en retrait** ; **couleurs d'alerte (orange/rouge) interdites** dans le
  décor neutre.

## 8. Critères de validation

* [x] Chaque paroi **boucle en 3×3 sans couture** (preuve fournie).
* [x] **Aucun élément focal centré** dans une texture qui boucle (déco focale = props séparés).
* [x] Dimensions **fixes** (128/256), **1×**, **sans AA**, sans label/marge.
* [x] Couche « structures » en **RGBA** ; parois en **RGB opaque**.
* [x] **ZIP de fichiers** (pas de planche d'aperçu).

## 9. Documents joints

* [x] Cette fiche · [`brief-concept-decor-fond.md`](brief-concept-decor-fond.md) · retours
  [v1](retour-decor-fond.md) · [v2](retour-decor-fond-v2.md) · [base](retour-decor-base-foyer.md)
* [x] Capture in-game (3 contextes, échelle + lumière) :
  [`capture-decor-fond-in-situ.png`](capture-decor-fond-in-situ.png) (+ détails
  [base](capture-decor-base-in-situ.png) · [tunnel](capture-decor-tunnel-in-situ.png) ·
  [roche](capture-decor-roche-in-situ.png))
* [x] Placeholders actuels à remplacer : `game/art/decor/*.png` (dimensions/roles ci-dessus)
