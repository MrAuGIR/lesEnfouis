# Brief de concept — L'ennemi Robot

> **À l'attention du / de la designer.** Brief ciblé pour concevoir la **famille d'ennemis
> robots**. Étape **concept** : trouver le **langage visuel de la menace mécanique** + la
> lisibilité, **pas** les sprite sheets finaux.
> S'appuie sur le [brief de direction artistique](../docs/BRIEF-DIRECTION-ARTISTIQUE.md) et la
> [section 03 du GDD](../docs/03-personnages-ennemis.md).
> Style : **pixel art coloré, classique**, vue **2D de côté (en coupe)**.

## 1. Qui ils sont

Une des **deux seules familles d'ennemis** du jeu (avec les humains). Des **machines de guerre**
héritées de la 3e Guerre mondiale, croisées surtout dans les **couches hautes** (**Industriel**
puis **Surface**). Pas de mutants, pas de créatures : la menace est **mécanique, froide, sans
émotion**. Ils doivent faire ressentir **l'inhumain** — l'inverse exact du héros fragile.

## 2. Deux statuts lore = deux registres visuels

C'est le **cœur du brief**. Les robots se lisent en **deux groupes**, et on doit les distinguer
d'un coup d'œil :

| Statut | Où | Lore | Lecture visuelle visée |
|--------|----|------|------------------------|
| **Solitaires / sans maître** | plus on s'éloigne de la surface (couches profondes du domaine robot) | vestiges des IA **« perdantes »** de la guerre, hostiles par **automatisme aveugle** | **délabrés, dépareillés, rouillés**, mouvements erratiques, « zombie mécanique » qui ne sait plus pourquoi il tue |
| **Contrôlés** | proches de / à la surface | pilotés par l'IA **« victorieuse »** (le boss **NAPOLÉON**) | **propres, cohérents, coordonnés**, un **œil/optique signature commune**, finition militaire, presque élégants |

> 💡 Idéalement, une **marque visuelle partagée** (forme d'optique, couleur de « regard »,
> emblème) identifie les robots **contrôlés** comme appartenant tous à la même IA. Les
> **solitaires** n'ont pas cette cohérence : chacun est un assemblage unique et abîmé.

## 3. Intention de design

- **Menace lisible par la forme** (cf. brief DA) : avant même de comprendre le type, on doit
  lire « danger mécanique ».
- **Inhumain** : privilégier des **silhouettes non-humanoïdes ou déformées** (chenilles, pattes,
  bras-outils, châssis bas) pour trancher avec le héros et les ennemis humains.
- **L'œil / l'optique** comme point focal expressif : c'est souvent la seule « expression » d'un
  robot — une lueur qui s'allume = la menace s'active.
- **Échelle indie** : penser **familles modulaires** (un châssis réutilisable + variantes
  d'armement/dégâts) plutôt que des dizaines de designs uniques.

## 4. Lisibilité gameplay (priorité absolue)

- **Couleurs d'alerte (orange/rouge)** réservées au danger : parfaites pour les **optiques, les
  voyants, les zones d'attaque** des robots — à ne pas gaspiller sur le décor.
- Le robot doit **ressortir du décor industriel** (lui aussi métal/rouille) : jouer sur le
  **contraste de l'œil lumineux** et une silhouette nette pour ne pas le « noyer » dans le fond.
- **Télégraphie** : prévoir que les attaques pourront être **annoncées visuellement** (l'optique
  vise, un canon s'arme) — laisser de la place pour ces signaux.

## 5. Pistes d'archétypes (à explorer, pas exhaustif)

Pour cadrer sans figer — proposer **2-3 archétypes** qui couvrent les rôles de combat :
- **Rôdeur / sentinelle** — rapide, corps-à-corps, se précipite ; idéal en version **solitaire délabrée**.
- **Tireur / tourelle mobile** — tient à distance, tir à annoncer ; cohérent avec « munitions &
  couverture » du gameplay.
- **Lourd / blindé** — lent, encaisse, **points faibles à percer** ; bon candidat en version
  **contrôlée** militaire.

> 🏭 **Lien boss :** le boss de la couche Industrielle, **LÉVIATHAN**, est un **gros automate de
> guerre** (vestige d'une IA *perdante*). Les robots solitaires peuvent en partager le **langage
> visuel** (même origine), comme une « piétaille » annonçant le boss. *(Le boss lui-même fera
> l'objet d'un brief dédié — pas ici.)*

## 6. Références utiles

- **Horizon / NieR** (esprit, pas le rendu) — machines lisibles, optique expressive.
- **Metro / Fallout** — métal usé, rétro-futurisme militaire, ambiance post-apo.
- **Robots de SF classiques** — l'œil unique lumineux comme signal de menace.

## 7. Livrables attendus de cette étape

1. **2-3 archétypes** de robots (silhouettes + optique), sur fond neutre **et** en situation dans
   le décor industriel sombre (valider le contraste).
2. **La distinction « solitaire délabré » vs « contrôlé militaire »** illustrée clairement (au
   moins un exemple de chaque, idéalement le **même rôle** décliné dans les deux registres).
3. La **marque visuelle commune** des robots contrôlés (forme/couleur d'optique signature).

> ❌ **Pas demandé maintenant :** sprite sheets d'animation complets, tous les états d'attaque,
> les variantes par couche, le boss LÉVIATHAN. On verrouille **le langage visuel + les deux
> registres + la lisibilité** d'abord ; le reste viendra par lots.
