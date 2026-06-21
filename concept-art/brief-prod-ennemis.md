# Brief de PRODUCTION — Les ennemis (sprites + animations)

> **À l'attention du / de la designer.** Le **concept** des robots est validé
> ([brief concept](brief-concept-ennemi-robot.md) · planche [`concept_enemis_robot.png`](concept_enemis_robot.png) ·
> [retour](retour-concept-ennemi-robot.md) · [look §5](LOOK-VERROUILLE.md)). Ici on demande les
> **sprites jouables animés** des ennemis présents dans le MVP. Pixel art, échelle figée (mêmes
> règles que le héros).

## 0. ⚠️ FORMAT DE REMISE — à lire en premier (ça a coincé 4× déjà)

On a reçu plusieurs fois des **planches de présentation** (image unique, éléments sur dalles/damier,
labels cuits dans l'image, tailles variables, bloom) → **inintégrable**. On veut les **FICHIERS
RÉELS**.

- **Livrer un .ZIP** de fichiers PNG, **pas** une planche unique.
- **PNG à transparence réelle (RGBA)**, fond **transparent** (pas de damier/dalle/couleur de fond,
  pas de cadre, pas de label écrit sur l'image, pas de bloom peint — le halo est géré par le moteur).
- **Pixel art net à 1×** (le jeu agrandit en Nearest ×3-4) : **aucun anti-aliasing**, pas d'upscale.
- **Toutes les frames d'un ennemi à la MÊME taille de case**, sprite **calé au même endroit** (mêmes
  pieds au même pixel) → sinon ça « saute » à l'animation.
- **Convention de nommage** claire (voir §4).

## 1. Échelle & cases (figées)

- Monde en **tuiles 16 px**. Mêmes règles que le héros (`brief-prod-heros.md`).
- **Orientation de référence : regard vers la DROITE.** Le moteur retourne pour la gauche — **ne pas
  livrer la version miroir**.
- Cases proposées par type (laisser une marge pour optique/canon/halo) :
  - petits/moyens robots → **32 × 32 px**.
  - **Lourd** (gros châssis blindé) → **48 × 48 px** (ou 48×32 si plus large que haut), pieds calés
    sur la même ligne dans chaque frame.

## 2. Les ennemis à produire (archétypes RÉELS du jeu)

Le MVP a **4 archétypes** de robots. Deux registres lisibles d'un coup d'œil (cf. bible §5) :
**solitaires délabrés = optique AMBRE vacillant** · **contrôlés militaires = optique ROUGE fixe +
emblème « N »**. Préciser le registre de chaque sprite livré (au moins le Rôdeur en version
solitaire ET contrôlée si possible).

| Archétype (code) | Rôle de combat | Lecture visuelle visée |
|------------------|----------------|------------------------|
| **Rôdeur** (`robot`) | robot de base, va au contact | châssis générique, silhouette **non-humanoïde** ; le « piéton » de la famille |
| **Fonceur** (`fonceur`) | rapide, se précipite en mêlée | léger, **agressif/penché vers l'avant**, lecture « vitesse » |
| **Tireur** (`tireur`) | tient à distance, **tir télégraphié** | **canon/optique de visée** visible ; doit pouvoir **annoncer** son tir (frame de charge) |
| **Lourd** (`lourd`) | lent, encaisse, **blindé de FACE** | gros, **plaque frontale** marquée ; **point faible = le DOS** (le jeu fait ×0,25 de face / ×1,5 de dos → la faiblesse arrière doit se **voir** : dos exposé/câbles/radiateur) |

> ⚠️ Le **Lourd** : la lecture « blindé devant / vulnérable derrière » est du **gameplay**, pas du
> décor. La face = plaque/visière fermée ; le dos = zone manifestement fragile. Doit se lire **sans
> couleur** (forme/posture).

## 3. Animations demandées (sobres — peu de frames, cf. DA)

Par archétype, minimum :

| Animation | Frames | Notes |
|-----------|:-----:|-------|
| **idle** | 2 | au repos, **optique qui luit/vacille** (la lueur s'allume = menace active) |
| **déplacement** | 4 | marche/roulement/glisse selon le châssis |
| **attaque** | 3-4 | mêlée (Rôdeur/Fonceur/Lourd) **ou** tir (Tireur) ; le Tireur a une frame de **télégraphe** (optique qui vise / canon qui s'arme) |
| **touché** | 1-2 | sursaut/flash mécanique |
| **destruction** (mort) | 3-5 | s'effondre / étincelles ; pas de gore (machine) |

> **Yeux/optique dans le noir :** en jeu, les yeux des robots **luisent** (le moteur les redessine
> par-dessus la lumière). Concevoir l'optique comme un **point focal net et isolable** (zone de
> couleur d'alerte sur silhouette sombre). Ambre = solitaire, rouge = contrôlé.

## 4. Livrables & nommage

- **ZIP** de PNG RGBA transparents, 1×, cases régulières, calage constant. Au choix :
  - **Option A** — frames individuelles : `enemy_<type>_<anim>_<NN>.png`
    (ex. `enemy_tireur_attaque_00.png`).
  - **Option B** — une sprite sheet par animation : `enemy_<type>_<anim>.png`, frames **alignées en
    ligne**, cases **strictement régulières** (pas de marge variable), + un petit `.txt`/`.json`
    (nb de frames, durée conseillée).
- `<type>` ∈ { `robot`, `fonceur`, `tireur`, `lourd` }. Indiquer le **registre** (solitaire/contrôlé)
  dans le nom ou un readme (ex. `_amber` / `_red`).
- Planche d'aperçu bienvenue **en plus**, livrable = **les fichiers**.

## 5. Lisibilité & accessibilité

- **Silhouette lisible à la vraie échelle** (~32 px) : tester **petit**.
- **Inhumain** : trancher avec le héros (chenilles/pattes/bras-outils/châssis bas), pas d'humanoïde.
- **Daltonisme** : l'état (touché, télégraphe, registre solitaire/contrôlé) ne doit pas reposer sur
  la **seule couleur** → doubler par **forme/posture/clignotement** (le moteur ajoute flash + son).
- Le robot doit **ressortir du décor industriel** (lui aussi métal/rouille) : contraste de l'optique
  lumineuse + silhouette nette.

## 6. Cadre (hors de ce lot)

Pas demandé ici : le **boss** (le Roi des Galeries / LÉVIATHAN — brief dédié plus tard), les
ennemis **humains** (pilleurs — autre brief), les variantes par couche au-delà de Foyer/Transit.
Ici = **les 4 archétypes robots du MVP, animés**.

## 7. Références

- **Horizon / NieR** (esprit) : machines lisibles, optique expressive.
- **Metro / Fallout** : métal usé, rétro-futurisme militaire.
- **Dead Cells / Hollow Knight** : anim pixel art expressive mais **sobre**.

> En résumé : **4 archétypes robots (robot/fonceur/tireur/lourd), animés (idle/déplacement/attaque/
> touché/destruction), en PNG RGBA 1× transparents, cases régulières, calage constant, regard à
> DROITE, optique = point focal (ambre solitaire / rouge contrôlé), Lourd lisible face/dos**, livré
> en **ZIP de fichiers** (pas de planche).
