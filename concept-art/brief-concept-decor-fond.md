# Brief de concept — Le décor de fond (arrière-plans en retrait)

> **À l'attention du / de la designer.** Brief ciblé pour concevoir les **arrière-plans**
> du monde en coupe — la couche **derrière les tuiles**, visible dans les tunnels, les
> cavernes creusées et les pièces de la base. Étape **concept + assets tuilables** : trouver
> le **langage des fonds** par contexte, livrable sous forme de **textures qui se répètent
> sans couture**. S'appuie sur le [brief de direction artistique](../docs/BRIEF-DIRECTION-ARTISTIQUE.md)
> (§4 palettes, §5 lumière, §6 lisibilité) et le [look verrouillé](LOOK-VERROUILLE.md).
> Style : **pixel art**, échelle figée **tuiles 16 px / rendu interne ~480×270 (×3-4)**.
>
> 🧪 **État actuel :** des fonds **placeholders générés par code** existent déjà en jeu
> (paroi rocheuse, structures de tunnel, mur de base) avec un système de **parallaxe** et de
> **bascule selon le contexte**. Ce brief sert à les **remplacer par de vrais assets**. Les
> placeholders donnent la cible fonctionnelle ; le designer apporte la qualité visuelle.

## 1. Intention

Donner de la **profondeur** au monde 2D en coupe sans jamais voler la vedette à l'action.
Le fond, c'est le **lointain en retrait** : ce que la lampe **devine** dans le noir derrière
le premier plan. Il doit renforcer l'**oppression souterraine** (« petite lumière qui
s'enfonce ») et **raconter le lieu** (roche brute / infrastructure / havre habité), tout en
restant **discret, désaturé et sombre**.

## 2. Contrainte n°1 — ne pas concurrencer l'action ni la lisibilité

Le gameplay repose sur **l'obscurité + le halo de lampe** et sur la lecture du **premier plan**
(tuiles creusables, ennemis, loot). Le fond ne doit **jamais** :
- être **clair, saturé ou contrasté** → il reste **sombre et désaturé**, en **retrait** ;
- utiliser les **couleurs d'alerte (orange/rouge vifs)** réservées au **danger** ;
- contenir des **détails fins très contrastés** qui se liraient comme des éléments
  interactifs (loot, ennemis) → le fond est **flou de lecture**, l'œil va au premier plan ;
- **scintiller** ou créer des **motifs répétitifs marquants** (cf. §4).

> Le fond est **éclairé par la lampe** comme le reste (il s'assombrit loin du joueur). Le
> concevoir pour **bien rendre sous un éclairage ponctuel** (volumes doux, pas d'aplats morts).

## 3. Trois contextes à couvrir (langage par lieu)

Le fond **change selon où se trouve le joueur**. Trois familles à concevoir :

| Contexte | Quand | Intention visuelle |
|----------|-------|--------------------|
| **Roche brute** | quand on **creuse** (galeries naturelles, cavernes) | paroi de **roche** en retrait : strates, fissures, irrégularités **organiques** — minéral, brut, sans main humaine |
| **Tunnel d'infrastructure** | dans la **couche Transit** (anciens tunnels/métro) | roche **+ ouvrages humains** : **étais/soutènements**, **tuyaux**, conduits, traces de béton — abandonné, fonctionnel, rouillé |
| **Intérieur de base (le Foyer)** | dans les **pièces** construites | **mur fini, habité, chaud** : panneaux, tôles/béton assemblés, câblage, petites touches de vie — le **havre** par contraste |

> 💡 **Palette par couche.** Au-delà de ces 3 familles, chaque **couche** du jeu a sa teinte
> signature (cf. brief DA §4 : Foyer ocres/ambré chauds · Transit gris-bleu froid · Usines
> acier/rouille + néon · Militaire/Labos froid clinique · Surface gris-jaune toxique). Le fond
> de chaque couche **décline** la même grammaire dans **sa** palette. Prioriser **Transit**
> (zone du MVP) + **Foyer**, prévoir l'extension aux autres.

## 4. Contrainte n°2 — tuilage SANS « blocs collés »

Les fonds sont **répétés (tuilés)** pour couvrir de grandes surfaces. Le piège, c'est l'effet
**« carreaux collés les uns aux autres »** (grille, motif qui boucle visiblement). À éviter
absolument :
- **textures sans couture** (seamless) : les bords haut/bas et gauche/droite se **raccordent**
  parfaitement ;
- **période de répétition longue** : viser des tuiles **grandes** (suggestion : multiples de
  16 px, ex. **48×48 à 96×96**) plutôt que 16×16 ;
- **pas de features régulières alignées sur la grille** (évite la lecture « cases ») ; pour un
  mur de panneaux, préférer des **panneaux verticaux de largeurs irrégulières**, joints
  discrets, **détails épars** (rivets, taches) **non périodiques** ;
- fournir **2-3 variantes** par fond (ou une planche d'éléments à recombiner) pour casser la
  répétition.

## 5. Profondeur & parallaxe (penser en couches)

Le moteur fait défiler le fond **plus lentement** que le premier plan (parallaxe **douce**).
Pour ça, livrer le fond **en couches séparées** quand c'est pertinent :
1. **Couche paroi** (la plus lointaine) : opaque, tuilable — la roche / le mur de base.
2. **Couche structures** (intermédiaire, **tunnels** surtout) : **PNG à fond transparent**,
   tuilable — étais, tuyaux, ruines, qui se posent **par-dessus** la paroi.
3. *(option)* éléments **ponctuels** non tuilés (grosses ruines, machines) à semer à la main.

> Garder un **écart de profondeur faible** entre couches (la parallaxe est volontairement
> subtile). Les couches transparentes doivent rester lisibles **superposées** à n'importe
> quelle paroi.

## 6. Lisibilité & accessibilité

- **Tester à la vraie échelle** (rendu interne ~480×270) **et sous la lampe** (pas seulement en
  grand et en plein jour) : le fond doit rester **lisible mais en retrait**.
- **Daltonisme** (porteur du projet) : ne pas faire reposer une distinction utile sur la **seule
  couleur** — différencier les contextes aussi par la **texture / les formes** (roche organique
  vs ouvrages droits vs panneaux finis).
- **Cohérence** avec le premier plan : le fond est une **version plus sombre/floue** du même
  monde, pas un autre style.

## 7. Références utiles

- **Terraria** — fonds de grotte/couches tuilés, lisibilité du premier plan préservée.
- **Dead Cells** — arrière-plans pixel art en profondeur, désaturés, parallaxe.
- **Hollow Knight** — gestion noir/profondeur, fonds évocateurs et discrets.
- **Metro 2033** — tunnels, infrastructure abandonnée, oppression.
- **Fallout (abris)** — intérieurs habités rétro-futuristes (pour le **Foyer**).

## 8. Livrables attendus de cette étape

1. **Roche brute** : 1 paroi **tuilable sans couture** (+ 1-2 variantes), à la vraie échelle.
2. **Tunnel (Transit)** : la **paroi** de la couche + une **couche structures transparente**
   tuilable (étais/tuyaux), montrées **superposées**.
3. **Intérieur de base (Foyer)** : 1 mur **tuilable**, **chaud/habité**, **sans effet grille**.
4. **1 mise en situation** par contexte : le fond **derrière un bout de premier plan**, **sous
   la lampe** (réutiliser une scène façon planche Industrielle) pour valider le retrait.
5. **La grammaire** : la liste des éléments épars réutilisables (rivets, fissures, taches,
   tuyaux…) pour casser la répétition.

> ❌ **Pas demandé maintenant :** les fonds de **toutes** les couches (on verrouille d'abord
> Transit + Foyer + roche), les éléments ponctuels scénarisés (grosses ruines/machines), les
> animations de fond (gaz, gouttes…). Ils viendront par lots ensuite.

## 9. Format de remise (technique)

- **PNG**, palette indexée ou RGBA ; **transparence** pour les couches de structures.
- **Tuilable sans couture** sur les 4 bords ; indiquer la **taille de tuile** de chaque asset.
- **Pixel art net** (pas d'anti-aliasing flou) — le jeu affiche en filtre **Nearest**.
- Couches **séparées** (paroi / structures) en fichiers distincts.
- Respecter l'échelle **16 px** ; livrer **à 1×** (le jeu agrandit en ×3-4).
