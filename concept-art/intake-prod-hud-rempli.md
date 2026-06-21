# Brief de collecte — Production du HUD (REMPLI)

> Habillage de l'**interface en jeu** (déjà jouable en grey-box, layout aux 4 coins). Valeurs tirées
> du code (`game/scripts/hud.gd`, M7). Brief de prod : [`brief-prod-hud.md`](brief-prod-hud.md).
> 🖼️ Capture in-game (HUD réel) : [`capture-hud-in-situ.png`](capture-hud-in-situ.png).

## 1. Général
| Champ | Valeur |
| ----- | ------ |
| Projet / moteur | **Les Enfouis** — MVP · **Godot 4.6.3** |
| Date | 2026-06-21 |
| Style | Terminal rétro-futuriste (Pip-Boy + jauges Metro) |

## 2. Technique
| Élément | Valeur |
| ------- | ------ |
| Rendu cible | **~480×270 → 1080p** (UI dessinée à l'échelle écran, **non** affectée par le zoom caméra ×2.5) |
| Filtre | **Nearest** |
| Format | **PNG RGBA**, 1×, **sans anti-aliasing**, dimensions en pixels entiers |
| Panneaux | **9-slice friendly** (bords/coins réguliers, centre répétable) |

## 3. Pipeline
PNG **séparés par élément** (pas de maquette aplatie) · nommage `hud_*` (voir §6) · **ZIP de
fichiers**. Maquette assemblée 480×270 bienvenue **en plus** (aperçu), livrable = **les pièces**.

## 4. Contraintes non négociables
* **Périphérie uniquement** (centre = action + halo de lampe). Layout aux **4 coins + 2 centres**.
* **Orange/rouge = DANGER seulement.** Passe **« rouge sur rouge »** : différencier rouge d'**alerte
  UI** du rouge de **menace** (optique robot) par **forme/clignotement**.
* **Daltonisme** : aucune info par la seule couleur → chaque ressource = **pastille + NOM + nombre** ;
  jauge basse = couleur **+** forme/clignotement.

## 5. Zones du HUD (déjà codées — à habiller) cf. capture
| Zone | Contenu actuel |
| ---- | -------------- |
| Haut-gauche | état monde : Raid / Caravane / PNJ |
| Haut-centre | **objectif** (« LE FOYER ») + **bandeau d'alerte pulsé** (gaz prioritaire sinon raid) |
| Droite | **Sac** + **Stock** (pastilles ressource) |
| Bas-gauche | barres **PV** + **Lampe** + ligne arme / anti-gaz / outil / torches |
| Bas-centre | **invite contextuelle** verte (« [E] … ») |
| Bas | aide condensée (rappels touches) |

## 6. Éléments à livrer (PNG séparés)
* **Cadres/panneaux** 9-slice : `hud_panel_frame.png` (+ coins/bords si besoin).
* **Jauges** : `hud_gauge_hp.png`, `hud_gauge_lamp.png` (+ états **critique** / **presque vide**).
* **Bandeau d'alerte** : `hud_alert_banner.png` + 3 états (**gaz**, **raid ALERTE**, **raid ACTIF**).
* **Invite** : `hud_prompt.png` (cadre discret translucide).
* **Icônes** : `hud_icon_{raid,caravane,pnj,arme,antigaz,outil,torche}.png`.
* **Pastilles ressource** (16×16, distinctes **par la forme**, lisibles en gris) :
  `hud_pip_{bois,roche,fer,lithium,munitions}.png`.
* **Typo monospace** (au moins les chiffres) ou réf. de fonte bitmap libre.
* **Overlay terminal** (scanlines/grain) **subtil, séparé** : `hud_scanlines.png` (optionnel).

## 7. Hors lot
Inventaire détaillé, menu de construction (Fallout-Shelter), écran de troc, écran-titre/fin, menus →
écrans dédiés, **briefs séparés**. Ici = **HUD permanent d'exploration**.

## 8. Validation
PNG RGBA 1× sans AA · périphérique · rouge réservé au danger (UI ≠ menace) · ressources lisibles en
gris (pastille + nom + nombre) · panneaux 9-slice · **ZIP de fichiers** (pas de maquette aplatie).

## 9. Documents joints
* [x] Cette fiche · [`brief-prod-hud.md`](brief-prod-hud.md) · [`brief-concept-hud.md`](brief-concept-hud.md) ·
  [`LOOK-VERROUILLE.md`](LOOK-VERROUILLE.md)
* [x] Concept : [`concept_hud.png`](concept_hud.png)
* [x] Capture in-game (HUD réel à habiller) : [`capture-hud-in-situ.png`](capture-hud-in-situ.png)
