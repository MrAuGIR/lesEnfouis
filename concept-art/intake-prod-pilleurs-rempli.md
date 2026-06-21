# Brief de collecte — Production des PILLEURS (humains, REMPLI)

> Famille **humaine** (pilleurs des tunnels, faction du Roi des Galeries). Valeurs tirées du code.
> Brief de prod : [`brief-prod-pilleurs.md`](brief-prod-pilleurs.md).
> 🖼️ Capture in-game : [`capture-pilleurs-in-situ.png`](capture-pilleurs-in-situ.png).

## 1. Général
| Champ | Valeur |
| ----- | ------ |
| Projet / moteur | **Les Enfouis** — MVP · **Godot 4.6.3** |
| Date | 2026-06-21 |

## 2. Technique — cases & pivots par archétype
| Archétype (code) | Case | Pivot (x, pieds) |
| ---------------- | :--: | :--------------: |
| Fonceur (`fonceur`) | **32 × 32** | (16, 30) |
| Tireur (`tireur`) | **32 × 32** | (16, 30) |
| Lourd (`lourd`) | **48 × 48** | (24, 46) |

Résolution interne ~384×216 (×2.5), **Nearest** · tuile 16 px · origine haut-gauche, Y vers le bas.

## 3. Pipeline
PNG individuels **ou** sprite sheet/anim · `enemy_<type>_<anim>_<NN>.png` · **ZIP de fichiers**.

## 4. Intégration moteur
* Miroir : **moteur retourne** → **regard à DROITE** uniquement.
* Lumière : halo/cône **moteur**, **bloom non** ; pas d'effet peint. Traceur du tireur = moteur.
* Pas de visée libre / bras séparés (l'ennemi fait face au héros, flip).

## 5. Gameplay → animations
* Déplacement : marche au sol. Attaques : **mêlée** (fonceur/lourd) **ou tir** (tireur, **frame de
  télégraphe**).
* ⚠️ **Lourd blindé de FACE** (×0,25), **vulnérable de DOS** (×1,5) → lecture face/dos **par la
  forme** (plaque/visière devant ; dos exposé : sangles/sac/nuque). **Sans couleur.**

## 6. Liste des animations
idle (2) · marche (4) · attaque (3-4, mêlée ou tir+télégraphe) · touché (1-2) · mort (3-5). Sobre.

## 7. Cohérence de faction
Une **marque commune** (brassard/insigne/palette pilleurs) relie les 3, déclinée par rôle :
fonceur = **cuir**, tireur = **treillis olive**, lourd = **acier**.

## 8. Artistique
Priorités *(proposé)* : Lisibilité 5 · Réalisme 2 · Expressivité 3 · Détail 2.
Distinctifs : se lisent **humains** (≠ robots) mais **clairement ennemis** (tenue de faction, armes) ;
Lourd face/dos. **Daltonisme** : rôle/état jamais par la seule couleur.

## 9. Validation
Frames de taille identique par archétype · pivot/pieds constants · pas d'AA · fond transparent · 1× ·
regard à droite · **ZIP de fichiers** (pas de planche).

## 10. Documents joints
* [x] Cette fiche · [`brief-prod-pilleurs.md`](brief-prod-pilleurs.md) · [`LOOK-VERROUILLE.md`](LOOK-VERROUILLE.md)
* [x] Capture in-game : [`capture-pilleurs-in-situ.png`](capture-pilleurs-in-situ.png)
* [ ] Sprite déjà intégré : **aucun** (grey-box)
