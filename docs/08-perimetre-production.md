# 08 — Périmètre & Production

> Le garde-fou du projet : définir le **plus petit jeu jouable**, ce qui est **hors
> périmètre**, et l'ordre de construction.
>
> 🛠️ **Plan de construction concret du vertical slice (jalons & validation) :
> [PROTOTYPE.md](PROTOTYPE.md).**

---

### Q. Quelle est la définition du MVP (le plus petit jeu « jouable et fun ») ?
**R.** ✅ **Vertical slice ciblé sur le cœur** : prouver d'abord UNE boucle —
**creuser → récolter → base minimale → revenir/extraire** — **sans combat, raids ni boss**.
1 héros (personnalisation minimale), quelques ressources, une base avec production +
stockage, et la **tension d'extraction** (sac limité, butin perdu/récupérable). On n'ajoute
le combat, les raids, les factions et les couches supplémentaires qu'**une fois ce cœur
prouvé fun**.
> 💡 *Pourquoi* : c'est le risque n°1 du projet (ci-dessous). Inutile de produire le reste
> tant que creuser/extraire n'est pas satisfaisant.
- [ ] Validé

### Q. Qu'est-ce qui est explicitement HORS périmètre (au moins au début) ?
**R.** ✅ Repoussé après le premier jeu : **multijoueur / coop**, **portage console** (PC
d'abord), **toutes les couches** (se limiter à **1-2 couches** au début), et les **factions
/ quêtes complexes** (garder marchands + bandits simples). De même, combat / raids / boss
arrivent **après** le vertical slice.
- [ ] Validé

### Q. Quels sont les grands chantiers techniques/de contenu pressentis ?
**R.** 🟡 Pressentis (la techno n'est PAS choisie ici, mais ces systèmes cadrent l'effort) :
**terrain creusable en tuiles + génération procédurale** des couches, **placement de
préfabriqués** (bunkers/caves), **système de pièces de base + PNJ autonomes**, **inventaire
+ extraction** (sac limité, cache au sol), puis **combat** (visée souris, armes à rareté) et
**raids**. Contenu : assets **pixel art** par couche, bibliothèque de pièces.
> 💡 *À affiner* au moment de la production.
- [ ] Validé

### Q. Quels sont les principaux risques et hypothèses à tester en prototype ?
**R.** ✅ **Risque n°1 (à prototyper en premier) : le fun du creusage + extraction** — le
cœur « creuser / récolter / revenir avec son butin » est-il satisfaisant ? Tout le projet en
dépend, d'où le **vertical slice** ci-dessus. Autres risques à surveiller : imbrication
**action ↔ gestion de base**, **lisibilité** du monde sombre, et **charge de production** du
contenu (couches, pièces, pixel art).
- [ ] Validé

### Q. Quel modèle économique / de distribution ?
**R.** ✅ **Achat unique premium** sur **PC** (Steam/itch), sans microtransactions.
- [ ] Validé
