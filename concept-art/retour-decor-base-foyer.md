# Demande ciblée — Mur de fond du FOYER (la base)

> **Contexte.** Les fonds **roche** et **tunnel** (paroi + structures) sont **validés et intégrés**.
> Il ne manque que le **mur intérieur de la base (le Foyer)**. Les versions précédentes étaient de
> belles **scènes** (lampe centrée, cadre, comptoir) → **elles ne se répètent pas** : inutilisables
> comme fond. Ici on veut **une matière de mur qui se duplique**, + la déco en **éléments séparés**.

## Référence demandée : Fallout Shelter (intérieur de Vault)

S'inspirer de l'**intérieur de Vault** de *Fallout Shelter* : **mur rétro-futuriste propre**,
**panneaux de métal/acier rivetés**, lignes horizontales, coins arrondis, ambiance **chaude et
habitée** (le « havre »), look 50's rétro-futuriste mais **un peu usé/sali** pour notre ton post-apo
(Metro). **Teinte chaude** (ocres/ambré, cf. palette Foyer de la bible). Pas de néons « rouge
alerte » (le rouge est réservé au danger).

## Règle ABSOLUE (les 2 livraisons précédentes ont calé là-dessus)

1. **C'est une TEXTURE qui se répète, pas une scène.** Avant de livrer : coller la tuile **3×3**
   (9 fois). On ne doit voir **aucune couture**, **aucune grille**, **aucun « point central »**.
   Bord **gauche = droite**, bord **haut = bas** (seamless).
2. **AUCUN élément focal/unique dans la tuile** : pas de lampe, pas de cadre, pas d'écran au milieu.
   La tuile = **matière homogène** (panneaux de mur rivetés) qu'on peut répéter à l'infini.

## La déco → fichiers SÉPARÉS (props), comme la couche « structures » du tunnel

Tous les jolis détails Fallout Shelter sont **bienvenus**, mais **livrés à part**, en **PNG
transparents individuels** (un par élément). On les **posera ponctuellement** par-dessus le mur.
Exemples utiles :

- `prop_lampe.png` (applique/suspension murale), `prop_ecran.png` (terminal/jauge),
- `prop_panneau_signaletique.png` (numéro de salle / picto de fonction, façon Vault-Tec),
- `prop_tuyaux.png`, `prop_vent.png` (grille d'aération), `prop_cablage.png`,
- `prop_casier.png` / `prop_etagere.png`, `prop_affiche.png` (propagande rétro, humour Fallout).

## Livrables (format STRICT)

| Fichier | Contenu | Format |
|---------|---------|--------|
| `bg_base.png` (+ 1-2 variantes) | **mur de Foyer**, panneaux rivetés chauds, **homogène** | opaque, **tuilable 4 bords** |
| `prop_*.png` | déco isolée, 1 élément par fichier | **RGBA transparent** |

**Contraintes techniques :**
- **Dimensions fixes**, carré, **128×128** ou **256×256** px (le **dire**).
- **Tuilable** (testé en 3×3) ; **pas de label, pas de marge/vignette** autour.
- **Pas d'anti-aliasing flou** : on affiche en filtre Nearest.
- **Transparence réelle** pour tous les `prop_*`.
- **Joindre l'aperçu 3×3** de `bg_base` avec la livraison (preuve que ça boucle).

> En résumé : **un mur Fallout-Shelter qui se répète sans couture** (matière, pas scène) + la
> **déco en props transparents séparés**. Avec ça l'intégration est immédiate (le moteur pose déjà
> le fond de base à l'emplacement de chaque pièce).
