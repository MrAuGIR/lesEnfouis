# Brief de concept — Le Héros (avatar joueur)

> ✅ **Réponse du designer reçue :** planche [`concept-hero.png`](concept-hero.png) +
> [retour structuré](retour-concept-heros.md). **Décisions figées :** lampe frontale (casque)
> comme source de lumière · **héros ~2 tuiles (~30-32 px) en grille 16 px**.
>
> **À l'attention du / de la designer.** Brief ciblé pour concevoir le **personnage jouable**.
> Étape **concept** : on cherche le **bon design + la lisibilité**, pas les sprite sheets finaux.
> S'appuie sur le [brief de direction artistique](../docs/BRIEF-DIRECTION-ARTISTIQUE.md) (style,
> palette, lumière) et la [section 03 du GDD](../docs/03-personnages-ennemis.md).
> Style : **pixel art coloré, classique**, vue **2D de côté (en coupe)**.

## 1. Qui est-il

Un **humain survivant** ordinaire, dirigé directement par le joueur. Il **creuse, explore,
récolte, combat** et **porte sa propre lumière** dans un sous-sol noir. Ce n'est **pas** un
héros surpuissant : un civil débrouillard, équipé de bric et de broc post-apo. Il doit inspirer
**l'attachement et la fragilité**, pas la puissance.

## 2. Intention de design

- **Silhouette unique et reconnaissable** au premier coup d'œil, même petit et dans le noir.
- **Toujours repérable grâce à sa lumière** (lampe/torche) : c'est sa signature visuelle (cf. la
  priorité « lisibilité » du brief DA).
- Allure **fonctionnelle / débrouille** : équipement bricolé, sac de portage visible, outil à la
  main. On doit lire « survivant qui creuse », pas « soldat d'élite ».
- **Neutre et lisible de base**, pour servir de support à la **personnalisation** (ci-dessous).

## 3. Personnalisation (avatar modulaire — important)

Le héros est **customisable** : le design doit être pensé **en couches superposables**, pas comme
un personnage figé. **4 emplacements** à concevoir comme des modules interchangeables :

| Emplacement | Rôle | À explorer |
|-------------|------|-----------|
| **Cheveux** | Identité | quelques coupes (courts, longs, attachés, crâne rasé…) |
| **Visage** | Identité | quelques variations (traits, peau, expression neutre) |
| **Corps / tenue** | Silhouette principale | combinaison, manteau rapiécé, tenue d'ouvrier… |
| **Couvre-chef** | Accent | casque de mineur (avec lampe !), capuche, bonnet, rien |

> ⚠️ **Contrainte clé :** ces modules doivent **se superposer proprement** sur **une même base
> de corps** (mêmes points d'ancrage), pour combiner les choix sans tout redessiner. Penser
> « système », pas « illustration ».

> 💡 La **source de lumière** (lampe frontale / torche tenue) peut être liée au **couvre-chef**
> (casque de mineur) ou portée à la main — à proposer. C'est l'élément le plus identitaire.

## 4. Lisibilité (priorité absolue)

- Le héros + son **halo de lumière coloré chaud** doivent **trancher** sur le décor sombre et
  désaturé.
- **Forme claire** : on distingue tête / corps / outil même à petite taille.
- Ne pas employer les **couleurs d'alerte (orange/rouge vif)** sur le héros — réservées au danger.
- Bonne lecture **de dos et de profil** (déplacement 2D de côté).

## 5. Ce qu'il fait (à garder en tête, pas à animer maintenant)

Repère pour que le design **supporte ces actions** plus tard : **se déplacer**, **creuser** (outil
en main, geste répété), **porter** (sac qui se remplit), **se battre** (mêlée + arme à feu, visée
souris), **éclairer**. Le design ne doit pas empêcher de lire ces poses.

> *Les compétences (Excavation, Mêlée, Armes à feu…) montent à l'usage mais ne changent **pas**
> l'apparence : inutile de prévoir des paliers visuels de niveau.*

## 6. Optionnel — clin d'œil aux backgrounds

Le héros démarre avec un **background** (Mineur, Médecin, Sapeur, Spéléologue…) donnant un bonus.
**Pas besoin de 8 designs distincts.** Si inspirant, proposer **1-2 variantes de départ**
suggérant le métier via un **accessoire** (casque de mineur, sacoche de médecin…) — réutilisant
le système de modules du §3. Sinon, **un seul héros de référence suffit** pour cette étape.

## 7. Références utiles

- **Don't Starve / Hollow Knight** — silhouette forte, lisible dans l'ombre.
- **Metro 2033** — lampe frontale, équipement bricolé, survivant fragile.
- **Fallout** — débrouille post-apo, accessoires rétro-futuristes (sans copier).

## 8. Livrables attendus de cette étape

1. **1-2 propositions de héros de référence** (silhouette + tenue + lumière), de **face/profil**,
   sur fond neutre **et** une mise en situation dans le décor sombre (pour valider le contraste).
2. **1 planche des modules** : quelques **cheveux / visages / tenues / couvre-chefs**
   interchangeables sur la même base.
3. La **source de lumière** clairement traitée (frontale casque vs torche en main — proposer).

> ❌ **Pas demandé maintenant :** sprite sheets d'animation complets, tous les états de combat,
> les 8 backgrounds dessinés. On verrouille **le design + la lisibilité + le système de modules**
> d'abord ; les animations et déclinaisons viendront ensuite, par lots.
