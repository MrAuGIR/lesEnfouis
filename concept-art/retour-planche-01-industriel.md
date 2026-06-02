# Retour designer — Planche 01 : couche Industrielle

> Retour sur [`planche-style-couche-industrielle.png`](planche-style-couche-industrielle.png).
> Première itération de recherche de style (étape **concept**, pas production).
> Référence : [docs/BRIEF-DIRECTION-ARTISTIQUE.md](../docs/BRIEF-DIRECTION-ARTISTIQUE.md).

## En un mot

**Très bonne direction — on valide le cap.** La planche capte exactement l'intention :
sous-sol oppressant mais coloré et lisible, petite lumière qui s'enfonce dans le noir,
identité « Industriel » immédiatement lisible (acier/rouille + brume verdâtre de pollution).
On continue dans cette voie ; les remarques ci-dessous sont des **ajustements**, pas une
remise en cause.

## ✅ Validé (à garder tel quel)

- **Ambiance & palette de la couche Industrielle** : acier/rouille + accents néon + brume de
  pollution verdâtre = conforme et réussi. Le contraste chaud (halo de lampe) / froid hostile
  fonctionne.
- **Lumière comme sujet central** : le halo net autour du héros et l'obscurité alentour
  rendent bien la mécanique. C'est l'âme du jeu, c'est là.
- **Lisibilité gameplay** : héros repérable (silhouette + sa lumière), robot ennemi lisible
  par la forme, loot qui ressort. Conforme à la priorité n°1 du brief.
- **Tileset + légende creusable / non-creusable** : lecture claire, raccords propres. Continuer
  ainsi.
- **HUD terminal** (santé, sac, lampe, profondeur/couche) : bonne piste rétro-futuriste,
  cohérent avec le Pip-Boy / jauges Metro.
- **Encart « progression verticale »** (Surface → Industriel → Médiéval → Antiquité) : excellent
  réflexe pédagogique, à garder comme repère interne.

## 🟡 À ajuster (cette planche)

- **Brume de pollution** : valider qu'elle reste **lisible** — qu'elle ne « mange » pas le
  décor ni les ennemis. Prévoir une version *légèrement* mouvante mais qui n'obscurcit jamais
  une menace.
- **Couleurs d'alerte** : réserver l'**orange/rouge** strictement au **danger** (gaz, ennemis,
  pièges). Vérifier qu'aucun élément de décor neutre ne les emploie, sinon on dilue le signal.
- **Densité de détail du décor** : par endroits le fond est riche au point de concurrencer
  l'action. Pousser les **arrière-plans** encore un cran en retrait (désaturation / flou /
  contraste réduit) pour que le plan de jeu ressorte.
- **Échelle / taille de tuile** : la planche est superbe en illustration ; il faut confirmer
  que la **même densité tient en taille de tuile réelle** (16 ou 32 px). D'où le test ci-dessous.

## ⬜ À compléter (pour boucler l'étape concept)

Manquent encore, parmi les livrables du brief (§11) :

1. **Héros** : 1-2 propositions de design isolées (silhouette + lampe), hors décor, pour
   valider la lecture du personnage seul.
2. **Essai de résolution / taille de pixel** : un petit décor rendu en **vraie taille de tuile**
   (proposer 16 px **et** 32 px côte à côte) pour trancher la densité.
3. **Un ennemi isolé** : le robot « solitaire » présenté seul (idle + 1-2 états), pour valider
   la famille « robots ».

> Une fois ces trois points reçus et le look verrouillé, on **arrête le concept** et on passe
> aux **specs de production par lots** (sprite sheets, animations, dimensions) — pas avant.

## Prochaine planche suggérée

- **Le héros isolé** (priorité), + l'**essai de taille de tuile**.
- Optionnel : une **2e couche** très différente (ex. **Antiquité**, ocres chauds) pour vérifier
  que l'identité par couche tient bien d'une couche à l'autre.
