# 🔒 Look verrouillé — *Les Enfouis* (bible visuelle v1)

> **Source de vérité de l'identité visuelle**, figée à l'issue de l'étape concept art (4 planches
> validées). Tout asset de production doit s'y conformer. Détail gameplay dans le GDD (`docs/`),
> briefs par élément dans ce dossier.
>
> *« Verrouillé » = ne change plus sans décision explicite. Les valeurs chiffrées (vitesses,
> autonomies…) restent réglables et se calent au prototype.*

## 1. Fondamentaux (figés)

| Élément | Décision verrouillée |
|---------|----------------------|
| **Style** | Pixel art **classique, coloré** (pas de vectoriel) |
| **Vue** | 2D **en coupe** souterraine |
| **Échelle** | **Tuiles 16 px** · héros **~2 tuiles (~30-32 px)** |
| **Résolution interne** | ~**480×270**, affichée en **×3/×4** (→ 1080p, ~30×17 tuiles à l'écran) |
| **Animation** | Pixel art **image par image**, **sobre** (peu de frames) |
| **Lumière** | **Vraie mécanique** : obscurité + **halo** autour du héros |
| **UI/HUD** | **Terminal rétro-futuriste** (Pip-Boy + jauges Metro), périphérique |

## 2. Identité par couche (palettes signatures)

De bas (ancien, sûr) en haut (récent, mortel) :

| Couche | Palette / ambiance |
|--------|--------------------|
| ⛟ **Foyer** | Chaud, lumineux, vivant (le havre) |
| 🏺 **Antiquité** | Ocres / dorés chauds, terre cuite, braseros |
| 🏰 **Médiéval** | Gris-bleu froid, pierre, mousse, torches |
| ⚙️ **Industriel** | Acier / rouille + accents néon, début de **brume de pollution** *(planche de référence)* |
| ☀️ **Surface** | Lumière crue voilée, gris-jaune toxique |

> **Règle :** la planche Industrielle fixe la **grammaire** ; les autres couches la déclinent
> avec leur palette. La **brume de pollution** = traitement signature (teinte malsaine, mouvante),
> croissant vers le haut.

## 3. Lisibilité (priorité absolue — règles fermes)

- **Centre de l'écran** = action + halo de lampe. **HUD en périphérie**, jamais au centre.
- **Couleurs d'alerte (orange/rouge)** = **danger uniquement**, jamais le décor neutre.
- **Arrière-plans** désaturés / en retrait.
- **Double codage** accessibilité : info critique = couleur **+** forme/clignotement (daltonisme).
- Tester tout élément à la **vraie échelle** (~480×270), pas seulement en grand.

## 4. Héros (verrouillé)

- Survivant **ordinaire, fragile, bricolé** ; toujours repérable par sa **lumière**.
- **Avatar modulaire** : 4 emplacements superposables sur une base commune — **cheveux ·
  visage · corps/tenue · couvre-chef**.
- **Source de lumière : lampe frontale (casque)** → mains libres. *(Tous les couvre-chefs
  doivent gérer la lampe ou prévoir un fallback.)*
- **Backgrounds** suggérés **par accessoires uniquement** (pas de refonte d'apparence).
- *Réf. : [brief héros](brief-concept-heros.md) · [planche](concept-hero.png) · [retour](retour-concept-heros.md).*

## 5. Ennemis robots (verrouillé)

- **Inhumains** (silhouettes non-humanoïdes), **châssis modulaires** réutilisables.
- **Deux registres lisibles d'un coup d'œil** :
  - **Solitaires / sans maître** — délabrés, dépareillés, rouillés · **optique = ambre vacillant**.
  - **Contrôlés (IA victorieuse)** — propres, militaires, coordonnés · **optique = rouge fixe** +
    **emblème « N » / œil NAPOLÉON** (marque commune).
- **Narration :** l'emblème est visible comme **indice**, mais **on ne nomme jamais « NAPOLÉON »
  avant le climax** (Surface).
- *Réf. : [brief robot](brief-concept-ennemi-robot.md) · [planche](concept_enemis_robot.png) · [retour](retour-concept-ennemi-robot.md).*

## 6. HUD (verrouillé)

- **Terminal rétro-futuriste**, périphérique, minimal en jeu.
- Affiche : **santé · lampe/autonomie · arme+outil+munitions · sac/capacité · profondeur/couche
  · alertes**. États clés : santé critique, lampe vide, alerte/raid.
- **Effet écran** (scanlines/grain) **subtil**. Typo **monospace**.
- *Réf. : [brief HUD](brief-concept-hud.md) · [planche](concept_hud.png) · [retour](retour-concept-hud.md).*

## 7. ⏳ Ajustements en attente (designer, prochaine passe)

1. **Robot** : repasser l'optique des **solitaires en ambre vacillant** (la planche met du rouge
   aux deux).
2. **HUD** : **passe « rouge sur rouge »** — différencier le rouge d'**alerte UI** du rouge de
   **menace** (optique robot / danger).

> Ces deux points n'empêchent pas de démarrer le prototype (grey-box) : ils concernent l'art
> final, qui vient **après** la preuve du fun.

## 8. Ce qui n'est PAS encore figé (volontairement)

- **Sprite sheets & animations finales** (se briefent par lots après le prototype).
- **Planches des couches** Foyer / Antiquité / Médiéval / Surface (Industriel sert de référence).
- **Valeurs chiffrées** (vitesse de creusage, autonomie de lampe, capacité du sac, coûts de
  craft) → se calent au **prototype**.
