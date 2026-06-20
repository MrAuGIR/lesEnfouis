# Retour — Décor de fond (planche du designer)

> Réponse à la planche [`resultat_designer_decor_fond.png`](resultat_designer_decor_fond.png),
> en regard du [brief](brief-concept-decor-fond.md). **Verdict : direction validée ✅** — la
> planche couvre tout le brief et la qualité est là. Il reste à livrer les **assets de
> production** (fichiers exploitables en jeu), car la planche est un **concept aplati**.

## Ce qui est validé (à garder tel quel)

- **3 contextes** bien différenciés : roche brute (organique), tunnel (ouvrages humains),
  intérieur de base (chaud, habité). La distinction passe par la **texture/forme**, pas que la
  couleur → ✔ accessibilité daltonien.
- **Tuilage sans couture** : les aperçus 5×5 ne montrent pas d'effet « blocs collés ». ✔
- **Couches séparées pour le tunnel** : paroi **+** couche structures « transparente » +
  superposition. ✔ (exactement ce qu'il faut pour la parallaxe).
- **Variantes** par contexte, **grammaire d'éléments réutilisables**, **palette par zone**,
  **mises en situation sous la lampe** (le retrait/lisibilité est respecté). ✔
- Tuiles **64×64** : bon choix (dans la fourchette du brief).

## Ce qu'il manque pour intégrer en jeu (= livrable de production)

La planche est **une image unique, RGB (sans canal alpha)**. Pour brancher ça dans le moteur,
il faut les **fichiers source séparés** (cf. §9 du brief). À fournir :

1. **Roche brute** — `bg_roche.png` (tuile **64×64**, tuilable sans couture) + 1-2 variantes
   (`bg_roche_var1.png`…).
2. **Tunnel** — `bg_tunnel_paroi.png` (64×64, opaque, tuilable) **et**
   `bg_tunnel_structures.png` (64×64, **PNG RGBA à vraie transparence**, tuilable) — la couche
   structures **séparée**, pas aplatie sur la paroi.
3. **Base / Foyer** — `bg_base.png` (64×64, tuilable) + variantes.
4. *(optionnel)* les **éléments épars** de la grammaire (tuyaux, fissures, taches…) en PNG
   transparents, si on veut les semer à la main plus tard.

**Contraintes de remise :**
- **Pixel art net**, exporté **à 1×** (le jeu agrandit en Nearest ×3-4) — pas d'anti-aliasing.
- **Tuilable sur les 4 bords** ; **indiquer la taille exacte** de chaque tuile.
- **Une couche = un fichier** (paroi / structures séparées).
- Transparence **réelle** (alpha) pour les structures et les éléments épars.

## Détails mineurs à confirmer (pas bloquant)

- Garder les **alertes (rouge/orange vif)** hors du décor (réservées au danger). Vérifier que les
  lampes/néons du fond de base restent **chauds mais pas “rouge alerte”**.
- Densité des **structures de tunnel** : viser une répétition discrète une fois **assombrie par la
  lampe** (tester à la vraie échelle ~480×270).

> 🔧 **Côté intégration (nous) :** le moteur a déjà le système — fond **contextuel** (roche /
> tunnel / base), **parallaxe douce** et **fondu** entre contextes. Dès qu'on a les fichiers
> ci-dessus, on remplace les placeholders générés par code (`TileArt.bg_*`) par le chargement de
> ces PNG, sans toucher au reste.
