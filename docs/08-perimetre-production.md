# 08 — Périmètre & Production

> Le garde-fou du projet : définir le **plus petit jeu jouable**, ce qui est **hors
> périmètre**, et l'ordre de construction.
>
> 🛠️ **Plan de construction concret du vertical slice (jalons & validation) :
> [PROTOTYPE.md](PROTOTYPE.md).**

---

### Q. Quelle est la définition du MVP (le plus petit jeu « jouable et fun ») ?
**R.** ✅ **Deux jalons à ne pas confondre :**

1. **Prototype / vertical slice** *(preuve de risque — FAIT)* : prouver UNE boucle —
   **creuser → récolter → base minimale → revenir/extraire** — **sans combat, raids ni boss**.
   1 héros, quelques ressources, base production + stockage, tension d'extraction (sac limité,
   butin perdu/récupérable). **Ce n'est pas le jeu complet**, c'est la levée du risque n°1
   (ci-dessous). ✅ **Réalisé** (grey-box, juin 2026).
2. **MVP = premier jeu complet jouable** : **le Foyer + 1 zone complète (Transit) + son boss**
   (le Roi des Galeries). La **boucle entière de bout en bout sur une zone** : creuser/explorer,
   récolter, bâtir & faire vivre la base (pièces, PNJ, craft, paliers d'outils), **raids**,
   **ennemis humains** et **boss de zone**, mort/extraction. C'est le plus petit périmètre
   *réellement jouable et vendable*. *(cf. [06](06-contenu-progression.md).)*

Les zones **Usines / Militaire-Labos / Surface** et leurs boss arrivent **après le MVP**, par lots.
> 💡 *Pourquoi cet ordre* : le risque n°1 (fun creuser/extraire) se prouve **avant** de
> produire combat & contenu. Maintenant qu'il est levé, on bâtit le MVP 1-zone.
- [x] Validé

### Q. Qu'est-ce qui est explicitement HORS périmètre (au moins au début) ?
**R.** ✅ Repoussé après le premier jeu (MVP) : **multijoueur / coop**, **portage console** (PC
d'abord), **les zones au-delà de Transit** (Usines / Militaire-Labos / Surface = post-MVP), et
les **factions / quêtes complexes** (garder marchands + bandits simples). Le **MVP se limite à
1 zone jouable (Transit) + son boss** ; combat / raids / boss au-delà arrivent **par lots
ensuite**. Le **prototype/vertical slice**, lui, excluait déjà combat/raids/boss (preuve du cœur).
- [x] Validé

### Q. Quels sont les grands chantiers techniques/de contenu pressentis ?
**R.** ✅ Pressentis (la techno n'est PAS choisie ici, mais ces systèmes cadrent l'effort) :
**terrain creusable en tuiles + génération procédurale** des couches, **placement de
préfabriqués** (bunkers/caves), **système de pièces de base + PNJ autonomes**, **inventaire
+ extraction** (sac limité, cache au sol), puis **combat** (visée souris, armes à rareté) et
**raids**. Contenu : assets **pixel art** par couche, bibliothèque de pièces.
> 💡 *À affiner* au moment de la production.
- [x] Validé

### Q. Quels sont les principaux risques et hypothèses à tester en prototype ?
**R.** ✅ **Risque n°1 (à prototyper en premier) : le fun du creusage + extraction** — le
cœur « creuser / récolter / revenir avec son butin » est-il satisfaisant ? Tout le projet en
dépend, d'où le **vertical slice** ci-dessus. Autres risques à surveiller : imbrication
**action ↔ gestion de base**, **lisibilité** du monde sombre, et **charge de production** du
contenu (couches, pièces, pixel art).
> ✅ **RISQUE N°1 LEVÉ (prototype, juin 2026).** Vertical slice jouable de bout en bout
> (creuser → lumière/carburant → sac limité → extraction/mort-cache → base/PNJ/craft →
> objectif Artefact). Verdict joueur : **« creuser et extraire est plus fun »** une fois
> l'**inventaire à slots** (piles + transfert choisi sac↔base) en place — c'était le frein
> ergonomique. Feu vert pour la **production** (combat, contenu, art final).
- [x] Validé

### Q. Quel modèle économique / de distribution ?
**R.** ✅ **Achat unique premium** sur **PC** (Steam/itch), **sans microtransactions**. Pas
de DLC engagé pour l'instant (extensions de contenu = piste éventuelle post-lancement, non figée).
- [x] Validé
