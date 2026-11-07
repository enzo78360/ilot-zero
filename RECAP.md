# Îlot Zéro : récapitulatif

Mise à jour du 7 novembre 2026.

## Liens utiles

| Quoi | Où |
| --- | --- |
| Jouer (site) | https://enzo78360.github.io/ilot-zero/ |
| Site de téléchargement | https://enzo78360.github.io/ilot-zero/telecharger/ |
| Code source | https://github.com/enzo78360/ilot-zero |
| Applications Windows et Mac | https://github.com/enzo78360/ilot-zero/releases/latest |
| Base de données et comptes (Supabase) | https://supabase.com/dashboard/project/kweiabsweqxwoiiqbkpa |
| Identifiant Google (connexion) | https://console.cloud.google.com/auth/clients |
| Confidentialité | https://enzo78360.github.io/ilot-zero/confidentialite.html |
| Conditions d'utilisation | https://enzo78360.github.io/ilot-zero/conditions.html |

## Corrections de la liste du 7 novembre 2026

| Problème signalé | Ce qui a changé |
| --- | --- |
| Roues qui braquent à l'envers | Les roues avant tournent du côté où l'on tourne (aussi sur Rebeca) |
| Skin de voiture visible seulement dedans | Le skin reste sur toutes les voitures que le joueur a utilisées, vu par lui seul ; les autres voitures et les autres joueurs voient des voitures normales |
| Pas de voiture de base, Rebeca coupée, filtre « Skin » | « Voiture standard » dans l'inventaire (équipée par défaut) ; vignettes cadrées sur toute la voiture ; tous les revêtements sont des **camos** (couleurs) ; « Skin d'arme » est réservé aux futurs modèles 3D d'armes (vide pour l'instant, avec un message) |
| Camo absent sur pompe, double canon, revolver | Le camo couvre aussi l'acier et le bois des armes qui n'avaient presque pas de pièces peintes |
| Noms des armes | CZ Bren 2, HK416, UZI, MP7, INP 9, Winchester SXP, R9-0, S868, JAK-12, DLQ 33, SVD, Arbalète, PKM, Javelin, Glock 19, Revolver |
| Coffres au milieu des pièces, couvercle transparent | Coffres posés contre un mur, tournés vers la pièce, butin qui sort devant ; couvercle visible des deux côtés |
| Zone sans texture, invisible de loin | Rideau violet animé (nuages, reflets), jamais coupé par la distance d'affichage ni confondu avec le ciel ; écran qui se teinte à l'approche du bord |
| Dégâts de zone trop faibles | 2, 3, 5, 7, 10, 13 puis 18 PV/s selon la phase, et jusqu'au double si on reste dehors (30 s) |
| Cailloux qui flottent sur la montagne | Rochers posés sur le point le plus bas du terrain et inclinés comme la pente |
| Jeter son arme | Touche `A` (Q en QWERTY, modifiable) : l'arme est lancée devant, retombe, rebondit sur le sol et les murs puis se pose ; synchronisé en multijoueur |
| Trampoline qui retire l'arme | Grand saut sans planeur : on garde son arme et on peut tirer |
| Vue à la 3e personne | Retirée (touche P supprimée) |
| Échap | Ferme la grande carte, les paramètres ouverts depuis la pause, puis la pause |
| Constructions trop proches, double ligne de rampes | On vise la case devant soi ; en courant sur une rampe, la suivante prolonge la même ligne (une seule ligne, pas de matériaux gaspillés) |
| Pose impossible dans les bosses, rampes traversées | Les pièces s'enfoncent un peu dans le sol ; les rampes bloquent par-dessous et par les côtés ; une pièce posée sur soi se traverse jusqu'à en sortir (seulement celle-là) |
| Sons affreux | Sons d'armes refaits (claquement, corps, grave court, réverbération), pas plus doux, moteur plus doux, choc de voiture sourd sans tintements ; plus aucun son de coffre (colonne de lumière dorée à la place) |
| Roues dans la route, sol qui disparaît | Routes posées au-dessus du terrain affiché (il ne perce plus l'asphalte) ; chaque roue est posée sur le sol réellement affiché (0 roue enfoncée sur les 3 cartes) |
| Escaliers d'immeuble, dalle grise, armes dans les murs | Escaliers à marches en pente douce (30°), bas dégagé du mur, rambarde ; plus de dalle grise sur tout l'étage ; le butin évite murs, escaliers et rochers ; les bots prennent l'escalier pour changer d'étage |
| Collisions de voiture | Boîte à la taille réelle de chaque modèle ; on peut se dégager d'un coin coincé entre plusieurs obstacles |
| Arbres difficiles à couper | Zone de frappe autour du tronc visible, plus large et plus haute |
| Voiture qui ne tourne plus | Elle braque et accélère tant que les roues frôlent le sol (pentes, bosses) |
| Voitures des stations | Garées au hasard autour, dos à la station ou de travers, avec la place de repartir (comme toutes les voitures garées) |
| Vitres | Vitres teintées noires sur toutes les voitures et tous les skins de voiture, présents et futurs |
| Toits en pente | La hauteur suit vraiment les deux pans (plus de toit traversé au milieu ni de vol au bord) |
| Toit des miradors | Toit pyramidal solide, on peut marcher dessus et tirer dessus |
| Skins de pioche | Nouvelle catégorie « Pioche » : Hache de secours, Ancre de marine, Trident des abysses (modèles 3D) ; le camo équipé colore la pioche ; visibles par les autres joueurs |
| Balcons traversables | Dalle et garde-corps solides : on s'y poste et on tire par-dessus |

Vérification : 17 anciens tests et 40 nouveaux sur les 3 cartes, sans erreur dans la console. Pas encore publié (site et applications).

## Site de téléchargement (6 novembre 2026)

Page `telecharger/index.html` : présentation du jeu avec captures, nouveautés, téléchargements (le fichier qui correspond à l'ordinateur est mis en avant et pointe toujours vers la dernière Release publiée, lue sur GitHub), guide d'installation pas à pas pour Windows (alerte SmartScreen) et Mac (application non signée), touches, configuration conseillée et questions fréquentes. Lien depuis l'écran de connexion et l'onglet Compte du jeu (« Télécharger l'application ») et depuis Paramètres. Les captures sont dans `telecharger/img/`.

## Style cartoon et coffres (6 novembre 2026)

Objectif : un rendu « cartoon » coloré, dans l'esprit des battle royale stylisés (textures peintes à la main originales, aucune ressource copiée), et des coffres à ouvrir sur la carte. Le rendu réaliste reste disponible dans Paramètres.

| Étape | Contenu | État |
| --- | --- | --- |
| 1. Textures peintes | Herbe, terre, roche, sable, neige, asphalte, trottoir, pavés, béton, briques, crépi, bois, tôle, tuiles, ardoise dessinées en couleurs vives et formes simples | Fait : 20 textures peintes générées par le jeu (aucun fichier à télécharger, aucune ressource copiée) |
| 2. Rendu cartoon | Sol plus saturé, ciel et lumière plus francs, contours doux, réglage Cartoon / Réaliste | Fait : sol plus saturé et sans relief photo ; Paramètres → Graphismes → Style graphique (Cartoon par défaut, Réaliste garde les textures photo) |
| 3. Coffres | Coffres dorés lumineux dans les bâtiments et dehors, qui scintillent et font un son ; on les ouvre avec E pour faire sortir arme, munitions, soins et matériaux ; synchronisés en multijoueur | Fait : environ 1 bâtiment sur 3 et 12 coffres dehors (23 à 43 par carte) ; arme rare à légendaire, munitions, soin, matériaux ; tintement à moins de 12 m ; les bots les ouvrent ; ouverture synchronisée |
| 4. Vérification et publication | Tests, captures sur les 3 cartes, mise en ligne, RECAP | Fait : 17 tests sans erreur, site en ligne |

## Refonte des 3 cartes (6 novembre 2026)

Objectif : refaire l'Îlot, la Métropole et les Dunes avec un rendu réaliste (textures, relief, routes, bâtiments), assorti aux nouveaux personnages et voitures réalistes. La jouabilité ne change pas : mêmes emplacements de butin, mêmes collisions, mêmes portes et escaliers.

| Étape | Contenu | État |
| --- | --- | --- |
| 1. Textures réalistes | Textures photo Poly Haven (CC0) avec relief (normal map) et rugosité : herbe, terre, sol de forêt, roche, sable, neige, asphalte, trottoir, pavés, béton, briques, crépi, bardage bois, tôle, tuiles | Fait : 20 textures avec relief dans `textures/` (couleur 1K + relief 512 px, 8,8 Mo) |
| 2. Routes | Asphalte réaliste avec lignes et bords, trottoirs et bordures en ville, passages piétons, lampadaires, panneaux, glissières sur les ponts | Fait : asphalte photo avec relief, bandes de rive et ligne centrale, accotements en gravier, trottoirs surélevés de 15 cm avec bordures, passages piétons à chaque carrefour, lampadaires à crosse |
| 3. Bâtiments | Façades détaillées (soubassement, corniche, encadrements, appuis de fenêtre, volets, gouttières, débord de toit, balcons, enseignes), plusieurs styles (briques, crépi, bois, béton) | Fait : maisons en crépi coloré, briques ou bardage bois (crépi chaud dans le désert), volets, seuil, corniche, gouttières, toits en tuiles ou en ardoise ; immeubles en briques, béton ou crépi avec balcons vitrés ; grange en bardage ; entrepôts sur socle béton ; commerces au rez-de-chaussée des immeubles avec enseigne lumineuse et store rayé (boulangerie, pharmacie, café, épicerie, tabac, librairie, pizzeria, fleuriste, garage, bar) |
| 4. Relief et décor | Relief plus naturel, mélange des sols selon la pente et l'altitude, chemins de terre, buissons, rochers | Fait : montagne irrégulière à crêtes (au lieu du dôme lisse), taches de terre et sous-bois mêlés à l'herbe, relief des textures au sol, sable photo dans les Dunes |
| 5. Vérification et publication | Tests, captures sur les 3 cartes, mise en ligne, RECAP | Fait : 17 tests sans erreur sur les 3 cartes, voitures masquées au-delà de 180 m pour la fluidité, site en ligne |

## Ce qui a été fait

### Corrections de la liste de tests

| Problème signalé | Ce qui a changé |
| --- | --- |
| Voiture trop rapide, dégâts au conducteur | 75 km/h maximum ; les chocs et les réceptions de saut n'abîment que la voiture |
| Voitures qui traversent les constructions et le décor | Collisions précises sur toute la carrosserie, aussi à grande vitesse ; les murs résistent et s'abîment |
| Réticule qui bouge trop en marchant | Balancement réduit, presque nul en visée |
| Réserve perdue en changeant de fusil d'assaut | La réserve suit quand on échange contre une arme du même calibre |
| Peu de munitions, partie trop rapide | Réserve +50 %, caisses de munitions ×3, zone qui se referme plus lentement |
| Pas d'animations | Rechargement, sortie d'arme, sprint, réarmement du fusil de précision ; point de visée en mire métallique |
| Pioche moche et mal tenue | Nouveau modèle (bois, cuir, acier), bien tenue, vrai coup de pioche |
| Fusil à pompe qui traverse le visage en visée | Ligne de mire relevée au-dessus de la crosse |
| Bots trop forts, qui trichent | Champ de vision, temps de repérage, ouïe sans position exacte, visée qui se règle, repli pour se soigner |
| Portes, toit et étagères bleues des hangars | Étagères ouvertes hors des passages, vraie porte, fenêtres, rideaux métalliques |
| Position KO sans animation et mal placée | Joueur à terre allongé qui rampe |
| Constructions qui se désactivent | 120 bois et 30 briques au départ, bascule automatique de matériau, message quand il n'y en a plus |
| Sensibilité des viseurs | Un réglage par grossissement (mire et point rouge, ×2, ×4, ×8) |
| Version Windows et Mac | Applications de bureau (Electron), publiées dans les Releases GitHub |

### Ajouts

- **Ramassage automatique** des munitions, matériaux et soins en marchant dessus (les armes restent sur `E`).
- **Indicateur des sons** : arcs autour du réticule pour les tirs (jaune) et les pas ennemis proches (blanc), désactivable dans les paramètres.
- **Connexion Google obligatoire** pour jouer, avec un **pseudo unique** choisi à la première connexion.
- **Sauvegarde en ligne** de la progression, retrouvée sur tous les appareils.
- **Amis** : ajout par pseudo, demandes, présence en ligne, bouton **Rejoindre** pour entrer dans le salon d'un ami.
- **Salon refait** : un écran en trois blocs (joueurs, réglages de la partie, inviter des amis). L'hôte choisit le mode (Solo, Duo, Escouade), avec ou sans bots, et la difficulté ; les amis voient les réglages sans pouvoir les changer. Bouton « Copier le code ».
- **Invitations** : depuis le salon, l'hôte invite un ami en un clic ; l'ami reçoit une carte « X t'invite dans son salon » avec **Rejoindre** ou **Ignorer** (valable 5 minutes, tant que le salon est ouvert).
- **Partie sans bots** : uniquement les joueurs du salon (il faut au moins 2 équipes).
- **Listes plus rapides** : amis, staff, bannissements et codes chargés en parallèle dès la connexion, gardés en mémoire pour un affichage instantané, et rafraîchis toutes les 10 secondes dans le menu (60 secondes en partie).
- **Codes cadeaux** : coquillages ou XP, une fois par compte.
- **Touches configurables** (Paramètres, section Touches) : clique sur une action puis appuie sur la nouvelle touche ; une touche déjà prise est échangée ; bouton « Touches par défaut ». Les aides à l'écran affichent tes touches.
- **Chat textuel** : dans le salon (bloc « Chat du salon ») et en partie (touche Entrée, Échap pour fermer). 120 caractères maximum, un message par seconde. Il passe par l'hôte, entre les joueurs du salon.
- **Jeu plus fluide** : rendu environ 4 fois plus rapide (arbres et petits objets affichés selon la distance et le champ de vision, résolution plafonnée selon la qualité choisie).
- **6 nouvelles armes modélisées dans Blender** : lance-roquettes (explosion de zone, détruit les constructions), arbalète silencieuse, mitrailleuse légère, fusil à double canon, mitraillette lourde, fusil à pompe automatique. Nouvelle catégorie « Armes lourdes » dans l'armurerie.
- **Viseurs refaits** : nouveaux modèles 3D (point rouge, holographique, lunettes ×2, ×4, ×8), nouveaux réticules lumineux et lunettes plein écran redessinées.
- **Boutique agrandie** : 51 objets, dont 20 nouvelles tenues et 20 nouveaux revêtements d'armes à motifs.
- **Passe de combat, saison 2 « Abysses »** : 50 paliers, une récompense à chaque palier (10 tenues et 15 revêtements exclusifs, des coquillages sur les autres paliers). Écran refait : bandeau de saison, barre de progression, frise des 50 paliers cliquable, aperçu 3D de chaque récompense. La progression du passe repart de zéro au début de la saison ; le niveau du compte et les objets déjà gagnés sont conservés.
- **3 cartes au choix** (onglet Salon, ou réglages du salon pour l'hôte) :
  - **Îlot Zéro** : la carte d'origine, avec ses villages, maintenant reliés par des routes ;
  - **Métropole** : une grande ville en damier au centre de l'île, avec un « Quartier des Tours » (immeubles de 4 à 7 étages avec escaliers et toits accessibles), des avenues, des lampadaires et une place centrale avec fontaine ;
  - **Dunes** : un désert de sable, avec des cactus (récoltables comme du bois), des roches, une oasis et la ville de Mirage.
- **Routes et ponts** sur toutes les cartes : un réseau goudronné relie les villes, avec des ponts au-dessus de la rivière, praticables à pied et en voiture. Des voitures sont garées le long des routes.
- **Collisions plus rapides** : chaque test ne regarde plus que les objets proches, ce qui permet des villes plus grandes sans ralentir le jeu.
- **Interface refaite** : thème sombre moderne (police Inter, panneaux nets, onglets en pilule, sélecteurs segmentés pour le mode, la carte et la difficulté). En partie : armes au centre en bas, barres de vie et de bouclier graduées, ressources en pastilles, mini-carte agrandie.
- **Textures photo réalistes** (Poly Haven, licence CC0, libres d'utilisation sans attribution) : herbe du sol (grass_ground), roche (aerial_rocks_02), sable (coast_sand_01), neige (snow_02), crépi des murs (white_stucco), tôle des entrepôts (corrugated_iron) et tuiles des toits (clay_roof_tiles), dans le dossier `textures/`. Herbe refaite en vrais brins 3D (touffes de 12 brins effilés et courbés, du pied sombre à la pointe claire, qui bougent au vent) au lieu des panneaux croisés.
- **Interface plus légère** : plus de flou d'arrière-plan en jeu, et le HUD ne réécrit ses styles que lorsqu'une valeur change.
- **Onglet Compte réorganisé** : un menu à gauche (Mon compte, Amis, et pour le staff : Joueurs, Modération, Codes cadeaux, Équipe staff, Pouvoirs), une section affichée à la fois.
- **Compte du propriétaire protégé** : seul le propriétaire peut modifier son propre niveau et ses coquillages (vérifié par le serveur).
- **Corrigé** : les lunettes ×4 et ×8 n'apparaissaient pas sur les armes ; la mire de l'arbalète était cachée par le bloc arrière.
- **Voitures** : elles montent les rampes construites et roulent sur les sols construits ; les petits rebords et dénivelés ne les bloquent plus et ne les abîment plus.
- **Bots** : ils contournent les murs au lieu de foncer dedans, abandonnent un objectif où ils restent coincés, et voient et entendent moins loin (60 m, 95 m avec un fusil de précision, 55 m pour les tirs entendus).
- **Son** : réglages séparés « Effets » et « Ambiance » ; armes et voiture plus fortes que l'ambiance ; nouveau moteur (montée des rapports) et nouveau bruit de choc (coup sourd, tôle, verre).
- **Touches** : toutes modifiables (Paramètres → Touches), y compris les armes 1 à 4 et les boutons de souris (molette, boutons latéraux).
- **Indicateur de bruit avec icônes** : pas, tir, explosion, voiture, construction.
- **Reflet de lunette** : un adversaire qui te vise avec une lunette ×4 ou ×8 fait briller un reflet, plus petit de loin et jamais énorme de près, caché par les murs.
- **Paramètres « Jeu »** : portes qui s'ouvrent en marchant dedans, ramassage automatique choisi type par type (munitions, matériaux, bandages, potions, trampolines, feux de camp, armes).
- **Objets au sol** : ils tournent d'un seul bloc ; les fusils de précision au sol montrent leur lunette.
- **Inventaire avec filtres** par rareté (Commun, Rare, Épique, Légendaire, Secret) et par type (Personnage, Voiture, Camo d'arme, Skin d'arme). « Skin d'arme » regroupe les revêtements brillants ou lumineux, « Camo d'arme » les motifs.
- **Skins de voiture et rareté Secret** : premier skin **Rebeca** (sportive bleu clair, code cadeau `REBECA`). Elle n'apparaît que pour son propriétaire, sur la voiture qu'il conduit ; les autres joueurs voient une voiture normale. Les objets Secret ne sont jamais en boutique.
- **Graphismes réalistes** (modèles Sketchfab sous licence CC Attribution, auteurs cités dans Paramètres → Crédits et dans `models/CREDITS.json`) :
  - **Personnage réaliste** pour tous les joueurs et les bots : scan photo de Renderpeople, recalé sur le squelette du jeu, donc toutes les animations sont gardées. Les tenues teintent les vêtements, les chapeaux et accessoires sont réajustés à la tête.
  - **Rebeca réaliste** : vraie GT3 RS (992) de Car2022, bleu clair, logos et inscriptions de marque retirés. L'add-on de stickers marche toujours et exporte maintenant en Draco.
  - **4 voitures réalistes sur la carte** : citadine, berline, pickup, fourgon, repeints aux couleurs aléatoires du jeu.
- **Staff** : pouvoirs illimités, menu staff en partie (touche `O`), modération, codes cadeaux, gestion des membres du staff.

## Guide du staff

Toutes ces actions se font dans le jeu, onglet **Compte**, avec un compte staff : le menu de gauche a une partie **Staff** (Joueurs, Modération, Codes cadeaux, Équipe staff, Pouvoirs).

**Protection du propriétaire** : personne d'autre que le propriétaire ne peut modifier son niveau (XP) ni ses coquillages. Le serveur refuse la demande, même si elle vient d'un membre du staff. Le propriétaire ne peut pas non plus être banni ni retiré du staff.

### Ajouter ou retirer un membre du staff
Section **Membres du staff** : entre son adresse Gmail, puis clique sur **Ajouter**. Il devient staff tout de suite s'il s'est déjà connecté, sinon à sa première connexion. Le bouton **Retirer** est à côté de chaque membre. Le propriétaire ne peut pas être retiré, et personne ne peut se retirer lui-même.

### Bannir un joueur
Section **Modération** : entre son pseudo, choisis une durée libre (un nombre en minutes, heures ou jours, ou définitif) et un motif, que le joueur verra, puis clique sur **Bannir**. La liste en dessous montre les bannissements en cours avec le temps restant (« encore 2 h 15 min »), le motif, qui a banni, et un bouton **Débannir**. Un joueur banni est bloqué en moins d'une minute, même en pleine partie. Un membre du staff ne peut pas être banni.

### Voir les comptes des joueurs
Section **Comptes des joueurs** : tous les comptes, en ligne d'abord, avec recherche par pseudo. Pour chacun : en ligne ou dernière connexion, niveau, coquillages, badges Staff et Banni, et le temps de bannissement restant. Boutons **Gérer**, **Bannir** ou **Débannir**.

### Donner ou retirer de l'XP et des coquillages
Section **Joueurs**, bloc **Gérer un joueur** (ou bouton **Gérer** dans la liste) : entre le pseudo et une quantité, puis **Ajouter**, **Retirer** ou **Régler à**. Le joueur reçoit le changement dès qu'il est connecté (moins de 10 secondes dans le menu), avec une notification.

### Créer un code cadeau
Section **Codes cadeaux (staff)** : choisis un code (par exemple `NOEL2026`), la récompense (coquillages ou XP), la quantité, la durée de validité et, si tu veux, un nombre maximum d'utilisations, puis clique sur **Créer**. Les joueurs l'entrent dans la section **Code cadeau** de leur onglet Compte. La liste montre les utilisations, et le bouton **Supprimer** désactive un code.

Le menu Récompense propose aussi **Skin secret : Rebeca (voiture)**.

### Stickers de Rebeca (Blender)
1. Ouvre `models/rebeca.blend` dans Blender, puis appuie sur **N** et va dans l'onglet **Rebeca**.
2. Place le curseur 3D sur la carrosserie (**Maj + clic droit**) et clique sur **Ajouter un sticker** pour choisir une image (png, jpg ou webp). Le sticker épouse la carrosserie ; déplace-le avec G, tourne-le avec R, agrandis-le avec S.
3. Clique sur **Exporter et publier dans le jeu**. Blender exporte `models/rebeca.glb`, puis l'envoie sur GitHub (commit et push). Tous les possesseurs de Rebeca voient les stickers d'ici 1 à 5 minutes, sur le site comme dans l'application, sans nouvelle version de l'application.
4. **Exporter seulement** crée le fichier sans le publier.

### Menu staff en partie
Touche `O` : vie, munitions et matériaux illimités, super vitesse, radar des ennemis, soin complet, arme légendaire, kit, téléportation au marqueur de la carte, redéploiement en planeur. Ces pouvoirs marchent en solo et quand tu héberges le salon.

### Sans le jeu (secours)
Dans Supabase, l'**éditeur SQL** (https://supabase.com/dashboard/project/kweiabsweqxwoiiqbkpa/sql/new) permet de faire les mêmes actions, par exemple :
```sql
-- liste du staff
select email from private.staff_emails order by email;
-- ajouter un membre du staff
insert into private.staff_emails (email) values ('adresse@gmail.com');
update public.profiles set role = 'staff' where id = (select id from auth.users where lower(email) = 'adresse@gmail.com');
```

## Publier une nouvelle version

- **Site** : chaque `git push` sur `main` met le site à jour en une minute environ.
- **Applications** : changer la version dans `package.json`, puis :
  ```bash
  npm install
  npm run dist        # crée les applications Mac et Windows dans dist/
  ```
  Ensuite, crée une Release sur GitHub et dépose les 4 fichiers renommés : `IlotZero-<version>-mac-AppleSilicon.dmg`, `-mac-Intel.dmg`, `-Windows-installateur.exe` et `-Windows-portable.exe`.

## Configuration de la connexion (déjà faite)

- **Google Cloud** : client OAuth « Application Web ». Origine `https://enzo78360.github.io`, redirection `https://kweiabsweqxwoiiqbkpa.supabase.co/auth/v1/callback`. Application publiée.
- **Supabase**, Authentication, puis Providers : Google activé avec l'ID client et le code secret.
- **Supabase**, Authentication, puis URL Configuration : Site URL `https://enzo78360.github.io/ilot-zero/`, Redirect URLs `https://enzo78360.github.io/ilot-zero/**` et `http://127.0.0.1:53682/**` (pour les applications de bureau).

## État au moment de cette mise à jour

- **Site** : à jour avec tout ce qui précède.
- **Applications Windows et Mac** : Release **1.3.3** (https://github.com/enzo78360/ilot-zero/releases/tag/v1.3.3), compilée avec tout : style cartoon et coffres, correction des salons, roues et ponts, personnages et voitures réalistes, Rebeca, refonte des 3 cartes, voitures, bots, son, touches, filtres d'inventaire.
- **Base de données** : protection du compte propriétaire en place (fonctions `staff_grant` et `grant_claim`). Les codes cadeaux peuvent donner un objet (le code `REBECA` existe, sans limite d'utilisation ni de durée).
- **Voitures (1.3.2)** : les roues se posent sur la route (le ruban de route est 13 cm au-dessus du terrain) et ne s'enfoncent plus dans les pentes ; les voitures ne sont plus repoussées au milieu des ponts au-dessus de l'eau profonde (131 passages sur 132 réussis sur les 3 cartes, le dernier bloqué par une voiture garée).
- **Salons** : la 1.3.0 avait un bug qui éjectait les amis au lancement de la partie. Il est corrigé depuis la 1.3.1 et sur le site : tout le monde doit utiliser le site ou la dernière version.
- La 1.2.0 était restée en brouillon et n'a jamais été publiée.

## Limites connues

- Le jeu tourne dans le navigateur ou dans l'application : un joueur très doué peut modifier sa copie locale. Le serveur protège les comptes, le rôle staff, les bannissements, les codes et les amis, mais pas une partie solo jouée hors ligne.
- En multijoueur, l'hôte doit garder le jeu ouvert. Les pouvoirs staff (vie, munitions, objets) ne marchent que si c'est le staff qui héberge.
- Les applications ne sont pas signées : au premier lancement, clic droit, puis « Ouvrir » sur Mac ; « Exécuter quand même » sur Windows.
- L'écran de connexion Google affiche « kweiabsweqxwoiiqbkpa.supabase.co » au lieu de « Îlot Zéro ». Pour afficher le nom et un logo, il faut faire valider le branding par Google (et prouver la propriété du site dans la Search Console).
