# Brief de PRODUCTION — Les blocs du monde (tileset 16 px)

> **À l'attention du / de la designer.** On demande ici les **tuiles jouables** du monde
> destructible : les blocs qu'on creuse, les minerais, les structures. Le **look** est déjà
> verrouillé ([bible §1-3](LOOK-VERROUILLE.md), [DA §3-6](../docs/BRIEF-DIRECTION-ARTISTIQUE.md)).
> Pixel art classique coloré, **vue 2D en coupe**, échelle figée. Ces tuiles existent déjà en
> **placeholder généré par code** (`game/scripts/tile_art.gd`) : ce brief sert à les remplacer par
> de l'art fini **en gardant exactement leurs contraintes de lecture**.

## 0. ⚠️ FORMAT DE REMISE — à lire en premier (ça a coincé 4× sur le décor et le héros)

On a reçu plusieurs fois des **planches de présentation** (image unique, éléments sur damier/dalles,
labels écrits dans l'image, tailles variables, bloom) → **inintégrable**. On a besoin des **FICHIERS
RÉELS**, pas d'une planche d'aperçu.

- **Livrer un .ZIP** de fichiers PNG, **un fichier par tuile** (voir §4 pour le nommage).
- **PNG exactement 16 × 16 px, à 1×** (le jeu agrandit en Nearest ×3-4). **Aucun anti-aliasing**,
  pas d'upscale, pas de bloom, **pas de dalle/damier/cadre/label** dessiné autour.
- **RGBA.** Les blocs pleins = **opaques bord à bord** (alpha 255 partout). Seules l'échelle et la
  passerelle ont de la **vraie transparence** (voir §3).
- **Tuilage sans couture** : chaque bloc plein doit pouvoir se **répéter en damier 3×3 sans joint
  visible** (le monde en est pavé). Fournir une **preuve 3×3** par bloc dans l'aperçu.
- Une **planche d'aperçu** (contact sheet) est bienvenue **en plus**, mais le livrable = **les
  fichiers PNG 16×16**.

## 1. Échelle & contraintes (figées)

- Monde en **tuiles 16 px** strictes. Rendu interne ~480×270, agrandi ×3/×4 → **lisible petit**.
- Éclairage **ponctuel** (halo de lampe dans le noir) : les tuiles doivent **rendre du volume sous
  une lumière de côté** (léger biseau / micro-relief), sans dépendre d'une couleur d'ambiance.
- **Daltonisme** (porteur du projet) : une tuile ne doit JAMAIS se distinguer **par la seule
  couleur** → la **FORME** porte l'info (cf. minerais §3). Toujours doubler couleur + motif.
- **Règle de lecture n°1 :** on doit distinguer d'un coup d'œil **creusable** vs **NON creusable**.

## 2. Palette par couche (rappel)

Le tileset livré ici = couches **Foyer / Transit** (les premières du jeu). Palettes signatures :
**Foyer** = ocres/ambré chauds, lumineux ; **Transit** = gris-bleu froid, béton, humidité. Les
couches plus hautes (Usines acier+rouille+néon, Surface gris-jaune toxique) **déclineront** le même
tileset plus tard — concevoir les blocs neutres pour supporter une **re-teinte par couche**.

## 3. Les tuiles à produire (liste exacte du jeu)

Chaque ligne = un fichier. Les contraintes de **forme** ne sont pas négociables (gameplay +
accessibilité) ; le rendu est libre dans ce cadre.

### Terrain creusable
| Tuile | Rôle | Contrainte de lecture |
|-------|------|------------------------|
| **terre** (`dirt`) | sol meuble, se creuse vite | brun chaud, granuleux, cailloux épars ; lecture « tendre » |
| **roche** (`rock`) | sol dur, se creuse lentement | gris froid, fissures ; lecture « dur » (≠ terre au 1er coup d'œil) |

### Minerais (gangue de roche + inclusion — la FORME distingue, pas la couleur)
| Tuile | Rôle | Contrainte de FORME (daltonisme) |
|-------|------|----------------------------------|
| **bois** (`wood`) | étai/ressource bois | **grain vertical** + nœud ; teinte bois chaud |
| **lithium** (`lithium`) | minerai rare (craft avancé) | **cristaux ANGULAIRES** (losanges/facettes) dans la gangue |
| **fer** (`iron`) | minerai métal (outils/défense) | **nodules RONDS** (≠ cristaux anguleux du lithium) dans la gangue |

> ⚠️ Lithium **anguleux** vs fer **rond** = la distinction se fait à la FORME même en niveaux de
> gris. Ne pas casser cette règle.

### NON creusable (doit se lire « infranchissable / bâti »)
| Tuile | Rôle | Contrainte de lecture |
|-------|------|------------------------|
| **mur béton** (`wall`) | mur de bâti/bunker | **appareil de blocs** à joints (mortier sombre) = « construit », pas naturel |
| **roche dure** (`hardrock`) | **barrière INDESTRUCTIBLE** (gate de progression) | **striations diagonales serrées** = signal fort « on ne creuse pas ça » ; doit trancher avec la roche normale |

### Structures & objets (cadre marqué = « objet », pas un bloc naturel)
| Tuile | Rôle | Contrainte de lecture |
|-------|------|------------------------|
| **caisse** (`crate`) | coffre à fouiller [E] | planches + **croix de renfort** + cadre net ; lecture « contenant fermé » |
| **caisse vidée** (`crate_open`) | coffre déjà fouillé | couvercle **ouvert**, intérieur sombre, bois terni ; lecture « vide » sans ambiguïté |
| **porte du Roi** (`boss_door`) | portes scellées du boss | métal rouillé, **vantaux + chevrons + rivets** ; danger doublé par la FORME (chevrons/rivets), pas que le rouge |

### Connecteurs — ⚠️ VRAIE transparence requise
| Tuile | Rôle | Contrainte technique |
|-------|------|----------------------|
| **échelle** (`ladder`) | grimper (verticale) | **2 montants + barreaux**, **transparent entre les montants** (le décor de fond doit rester visible au travers) ; doit pouvoir s'empiler verticalement sans couture |
| **passerelle** (`passerelle`) | sol/plancher horizontal | **planches horizontales**, **pas de bord vertical** (raccord continu à gauche/droite) ; alpha possible mais lecture « on marche dessus » |

> Ces deux tuiles se **croisent** en jeu (la passerelle passe devant l'échelle) : concevoir pour
> qu'une bande de passerelle posée par-dessus l'échelle reste lisible.

## 4. Nommage & livrables

- ZIP de PNG **16×16**, un par tuile, nommés : `tile_dirt.png`, `tile_rock.png`, `tile_wood.png`,
  `tile_lithium.png`, `tile_iron.png`, `tile_wall.png`, `tile_hardrock.png`, `tile_crate.png`,
  `tile_crate_open.png`, `tile_boss_door.png`, `tile_ladder.png`, `tile_passerelle.png`.
- **Variantes optionnelles** (bienvenues, si la répétition se voit) : `tile_rock_a/b/c.png`,
  `tile_dirt_a/b/c.png` — mêmes contraintes, interchangeables.
- Aperçu en plus : une planche montrant chaque bloc **+ son test de tuilage 3×3**.

## 5. Référence d'état (placeholders actuels)

Les placeholders code dans `tile_art.gd` respectent déjà toutes les contraintes de forme
ci-dessus (biseau, joints, cristaux anguleux / nodules ronds, striations de la hardrock,
transparence échelle/passerelle). Ils peuvent servir de **référence de lecture** : l'art fini doit
faire **au moins aussi lisible**, en plus joli.

## 6. Références

- **Terraria / Dead Cells** : tilesets pixel art qui se raccordent, lecture creusable/non.
- **Metro / Fallout** : béton humide, métal rouillé, bois bricolé post-apo.

> En résumé : **12 tuiles 16×16, 1× sans AA, RGBA, blocs pleins opaques & tuilables (preuve 3×3),
> échelle/passerelle transparentes, la FORME distingue les minerais et le creusable/non**, livré en
> **ZIP de fichiers** (pas de planche).
