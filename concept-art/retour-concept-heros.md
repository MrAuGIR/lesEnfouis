# Retour designer — Concept du Héros

> Retour sur [`concept-hero.png`](concept-hero.png).
> Réponse au [brief de concept du héros](brief-concept-heros.md) (étape **concept**).

## En un mot

**Excellent — la planche répond à tout le brief, on valide le héros.** Survivant fragile et
bricolé, silhouette lisible, lampe comme signature, **système de modules** clairement posé, et
même la **question d'échelle tranchée**. Il ne reste qu'**une décision de design** à prendre
(source de lumière A vs B) et 2-3 confirmations mineures.

## ✅ Validé (à garder tel quel)

- **Direction du personnage** : « survivant ordinaire » fragile et débrouille, exactement
  l'intention. Trois vues (face / profil / dos) fournies — parfait pour la suite.
- **Système de personnalisation modulaire** : les **4 emplacements** (cheveux / visages /
  corps-tenues / couvre-chefs) + la planche d'**exemples de combinaisons** prouvent que les
  modules se superposent sur une **base commune**. C'était le point clé du brief : réussi.
- **Lisibilité dans l'obscurité** : les vues « large dans le noir » et « zoom dans la lumière »
  + la légende (héros-lumière / décor / danger) valident le contraste. Le code couleur de
  danger est respecté (réservé à l'alerte).
- **Variantes de départ (backgrounds)** par **accessoires uniquement** (Mineur, Médecin,
  Sapeur, Spéléologue), **sans changer l'apparence majeure** : exactement la consigne — coût
  de production maîtrisé.
- **Échelle ~28-32 px** proposée avec mise en situation : **répond aussi au point d'échelle**
  resté ouvert sur la planche Industrielle. Très bien.
- **Palettes** (héros & lumière / décor industriel) fournies : cohérentes avec la DA.

## ✅ Décision tranchée — Source de lumière

- **Retenu : Proposition A — lampe frontale (casque).** Le héros a les **mains libres**
  (outil/arme), la lumière **suit le regard**, et l'identité « mineur » est affirmée.
- **Conséquence à intégrer** (cf. §🟡) : la lampe étant **liée au couvre-chef**, tous les
  couvre-chefs doivent gérer la lampe **ou** prévoir un fallback (le casque de mineur reste la
  référence ; capuche/bonnet = lampe intégrée ou petite frontale).
- La **Proposition B (torche à la main)** est écartée comme source principale (peut rester un
  **dépannage d'urgence** si besoin plus tard — non prioritaire).

## 🟡 À confirmer / ajuster (mineur)

- ~~**Verrouiller l'échelle**~~ ✅ **Figé : grille de tuiles 16 px, héros ~2 tuiles (~30-32 px).**
  Verrouillé dans la DA ([04](../docs/04-direction-artistique.md)) — base de tous les sprites/tilesets.
- **Cohérence lumière ↔ couvre-chef** : si on retient A (frontale), s'assurer que **tous** les
  couvre-chefs (capuche, bonnet…) gèrent la lampe, ou prévoir un fallback.
- **Lisibilité du dos** : vérifier que la silhouette de dos reste aussi reconnaissable que la
  face une fois en mouvement dans le noir (pour les phases d'éloignement).

## ⬜ Suite (après ta décision)

Une fois la source de lumière tranchée et l'échelle verrouillée :
1. **Figer le héros de référence** (proposition retenue, vue de base).
2. Le designer peut passer au **brief suivant** : [l'ennemi robot](brief-concept-ennemi-robot.md)
   ou le **HUD terminal**.
3. Les **animations** du héros (marche, creuser, combat…) ne seront briefées qu'**ensuite**, par
   lots, après validation du prototype gameplay.
