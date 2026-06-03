# Retour designer — Concept du HUD

> Retour sur [`concept_hud.png`](concept_hud.png).
> Réponse au [brief de concept du HUD](brief-concept-hud.md) (étape **concept**).

## En un mot

**Très bon — la planche répond au brief, on valide le langage du HUD.** Style terminal
rétro-futuriste, infos en périphérie, hiérarchie respectée, **états clés** détaillés et
**grammaire visuelle** (jauges/icônes/typo/cadres) fournie. Quelques **points à surveiller**
(surtout le risque de **rouge sur rouge**) et 1 décision légère, sinon c'est prêt à figer.

## ✅ Validé (à garder tel quel)

- **Style terminal** rétro-futuriste (écran de survie, phosphore, cadres) : pile dans la DA
  (Pip-Boy + jauges Metro). L'ambiance renforce l'univers sans écraser l'image.
- **Implantation périphérique** : infos dans les coins/bords, **centre laissé à l'action et au
  halo** — la contrainte n°1 du brief est respectée.
- **Hiérarchie d'info** complète et bien rangée : **santé**, **lampe/autonomie**, **arme+outil
  + munitions**, **sac/butin + capacité**, **profondeur/couche**, **alertes**. Tout y est.
- **États clés** détaillés (santé critique, lampe presque vide, alerte danger, raid en cours) :
  exactement les états demandés → le langage d'alerte est posé.
- **Feedbacks contextuels** (ex. « +6 fer ramassé », soin « +12 ») discrets, façon notifications
  de terminal : bonne idée, conforme au brief.
- **Grammaire visuelle** réutilisable (jauges, icônes, **typo monospace**, conteneurs, effets) :
  parfait pour décliner le reste de l'UI plus tard.

## 🟡 À surveiller / ajuster (mineur)

- **⚠️ Rouge sur rouge (le point le plus important).** Le HUD utilise le **rouge** pour les
  alertes ; or l'**optique des robots contrôlés** est aussi **rouge fixe**, et le **danger**
  (gaz/pièges) doit rester en rouge. Risque de **confusion en plein combat**. → Vérifier qu'on
  distingue *alerte d'interface* et *menace du monde* : par ex. réserver au HUD un **rouge
  encadré/clignotant** propre, ou jouer sur la position (alertes toujours au même endroit).
- **Lisibilité à la vraie échelle** : valider la planche au **rendu interne ~480×270** (pas
  seulement en grand) — surtout la typo et les petites icônes de munitions.
- **Accessibilité (rappel brief)** : confirmer que chaque info critique a un **double codage**
  (couleur **+** forme/clignotement), jamais la couleur seule (daltonisme + monde sombre).
- **Effet terminal** (scanlines/grain) : garder **subtil** — vérifier qu'il ne fatigue pas sur
  une longue session ni ne masque l'info.

## 🟠 Décision légère (à toi de voir)

- **Densité du HUD : tout permanent, ou certains éléments contextuels ?** Aujourd'hui plusieurs
  jauges sont toujours affichées. On peut **alléger** en rendant certaines infos
  **contextuelles** (ex. la **profondeur/couche** n'apparaît qu'au changement de couche ; le
  **sac** se met en avant quand il se remplit/est presque plein). → Tout permanent (plus
  d'info, plus chargé) **vs** cœur permanent + reste contextuel (plus épuré, plus immersif).
  *Tranchable plus tard au prototype, quand on jouera vraiment.*

## ⬜ Suite

1. (Optionnel) trancher la **densité** ci-dessus — ou la repousser au prototype.
2. Demander au designer la **passe rouge sur rouge** (différencier alerte d'UI vs menace).
3. **Tous les briefs de concept ont leur planche** (Industriel, héros, robot, HUD) : on peut
   **clore l'étape concept art** et passer à la suite (verrouillage du look → prototype gameplay
   en grey-box, cf. [PROTOTYPE.md](../docs/PROTOTYPE.md)). Les **assets de production** (sprite
   sheets, animations, déclinaisons) se briefent **ensuite, par lots**.
