# Îlot Zéro

FPS battle royale qui se joue directement dans le navigateur. 20 combattants sautent sur une île, ramassent des armes, construisent et la zone se referme. La dernière équipe en vie gagne.

**Jouer :** https://enzo78360.github.io/ilot-zero/

## Modes

- **Bus volant** : chaque partie commence dans un bus volant à rotors qui traverse l'île en ligne droite (trajet en pointillés sur la carte). Les portes s'ouvrent au-dessus de la côte : `Espace` pour sauter, éjection automatique avant qu'il ne quitte l'île. Les bots sautent au-dessus de l'endroit où ils veulent atterrir ; la zone attend que tout le monde soit sorti. En mode Zombies, seuls les vrais joueurs sont dans le bus.
- **Solo, Duo, Escouade** : en duo et en escouade, un joueur à 0 PV tombe à terre et un coéquipier peut le réanimer (maintenir `E` pendant 5 s).
- **Contre les bots** : tout seul, les bots complètent les 20 places.
- **Zombies** : en solo ou dans un salon, par équipes de 1, 2 ou 4. Seuls les vrais joueurs sautent en planeur ; 30 zombies (dont 10 Zombies Soldats aussi rapides qu'un joueur) les traquent partout, cassent les constructions, prennent rampes, escaliers, portes et fenêtres, et reviennent 3 s après leur mort ailleurs sur l'île en lâchant un objet. Un coup sur 5 infecte : il faut boire une potion de bouclier dans les 60 s (elle soigne l'infection au lieu de donner du bouclier), sinon c'est la mort. Pas de zone : le but est de survivre le plus longtemps ; les autres équipes peuvent coopérer ou se tirer dessus.
- **Partie rapide en ligne** : rejoint automatiquement une partie publique du même jeu et du même mode (Battle royale ou Zombies, Solo, Duo ou Escouade), ou en ouvre une si aucune n'attend. Lancement automatique au bout de 45 s, ou 5 s après que le salon est plein (25 joueurs) ; les bots complètent. Les inconnus d'un même duo ou d'une même escouade jouent ensemble.
- **Avec des amis** : un joueur clique sur « Créer un salon » et donne le code à 4 caractères. Les autres l'entrent dans « Rejoindre ». Jusqu'à 25 joueurs (hôte compris), les bots complètent jusqu'à 20 combattants. En duo ou en escouade, les amis sont placés dans la même équipe.

## Menu

Le menu est organisé en onglets : **Salon** (jouer seul ou avec des amis), **Inventaire** (équiper tenues et revêtements), **Boutique**, **Gacha** (liste de Gachas au choix ; tirages à 1 000 coquillages : 9 objets de la boutique et un skin principal légendaire plus rare, sans doublon : Gacha Karambit, skin de pioche, et Gacha Zombie Soldat, tenue), **Passe de combat** (saison 2 « Abysses » : une récompense à chaque palier) et **Paramètres** (sensibilité de la souris, sensibilité en visée et sensibilité propre à chaque viseur : mire et point rouge, ×2, ×4, ×8, inversion de l'axe vertical, champ de vision, préréglages graphiques Bas à Ultra, résolution dynamique, ombres, distance d'affichage, herbe, eau avec reflets, échelle de rendu, volume, compteur d'images par seconde). Les paramètres sont aussi accessibles en jeu depuis la pause (Échap).

## Compte, amis et sauvegarde en ligne

- **Connexion obligatoire** : pour jouer, on se connecte avec son compte Google, puis on choisit un **pseudo unique** (3 à 14 caractères). C'est le nom affiché en jeu et dans les salons.
- **Sauvegarde en ligne** : la progression (niveau, XP, coquillages, tenues, revêtements, accessoires) est enregistrée sur le compte et suit sur tous les appareils, y compris dans la version de bureau.
- **Amis** (onglet **Compte**) : ajouter quelqu'un avec son pseudo, accepter ou refuser les demandes (un badge sur l'onglet indique les demandes reçues), voir qui est en ligne et **rejoindre en un clic** le salon d'un ami qui héberge.
- **Chat** : dans le salon et en partie (touche Entrée).
- **Touches configurables** : Paramètres, section Touches.
- **Codes cadeaux** (onglet **Compte**) : un code donne des coquillages ou de l'XP. Chaque code ne s'utilise qu'une fois par compte et peut avoir une date d'expiration et un nombre d'utilisations limité.

Les données sont stockées dans [Supabase](https://supabase.com/) (serveurs à Paris). Chaque joueur ne peut lire et modifier que son propre profil.

### Staff

Un compte staff voit en plus, dans l'onglet **Compte** :
- l'**Espace staff** : coquillages illimités, XP illimitée, vie, munitions et matériaux illimités ;
- les **Comptes des joueurs** : liste avec recherche, en ligne ou non, niveau, coquillages, bannissement en cours ;
- **Gérer un joueur** : ajouter, retirer ou régler ses coquillages et son XP ;
- la **Modération** : bannir un joueur par son pseudo pour une durée libre (minutes, heures, jours) ou définitivement avec un motif, et le débannir. Un joueur banni voit la date de fin et le motif, et ne peut plus jouer ni sauvegarder. Un membre du staff ne peut pas être banni ;
- les **Codes cadeaux** : créer un code (coquillages ou XP, durée de validité, utilisations maximum), suivre ses utilisations, le supprimer ;
- les **Membres du staff** : ajouter une adresse Gmail ou retirer un membre. Le propriétaire ne peut pas être retiré, et personne ne peut se retirer lui-même.

En partie, la touche `O` ouvre le **menu staff** : vie, munitions et matériaux illimités, super vitesse, radar des ennemis sur la carte, soin complet, arme légendaire, kit de soins, téléportation au marqueur et redéploiement en planeur. Ces pouvoirs marchent en solo et quand le staff héberge le salon (chez un ami, seuls la vitesse, le radar et la téléportation marchent).

Toutes les vérifications (rôle staff, bannissements, codes, amis) sont faites par le serveur : un joueur ne peut pas se donner le rôle staff, ni utiliser un code deux fois.

## Progression

- **Niveaux** : chaque partie rapporte de l'XP (éliminations, mises à terre, réanimations, rappels, récolte, temps de survie, classement). 1 000 XP par niveau.
- **Passe de combat** : 50 paliers. Chaque palier donne 100 coquillages, ou une tenue ou un revêtement exclusif (paliers 5, 10, 20, 25, 30, 40, 45, 50).
- **Boutique** : 51 objets. Les coquillages servent à acheter des tenues de personnage et des revêtements d'armes à motifs. Le **casier** sert à équiper ce que tu possèdes. Tes amis voient ta tenue en multijoueur.
- La progression est enregistrée sur ton compte (voir plus haut) et aussi dans le navigateur.

## En partie

- **L'île** : relief avec collines, le Mont Zéro au centre, une rivière, des plages et 6 lieux nommés (villages, port, ferme…) avec maisons à fenêtres, granges, tours de guet et conteneurs. La carte change à chaque partie.

- **Matériaux** : bois (arbres), brique (rochers), métal (épaves de voitures). Le métal tient le plus longtemps.
- **Une seule île** : Îlot Zéro, avec la ville du Quartier des Tours, des villages, des forêts, une rivière et une zone désert (ville de Mirage, cactus). Routes droites en quadrillage, plates en travers, toutes reliées, sans impasse et sans traverser de bâtiment ; ponts au-dessus de l'eau.
- **Rendu réaliste** : textures photo avec relief (Poly Haven, CC0), routes avec marquages, trottoirs, passages piétons et lampadaires, façades variées (briques, crépi, bois, béton) avec balcons et commerces, montagne à crêtes. Personnage réaliste pour tous les joueurs et 4 voitures réalistes (modèles Sketchfab sous licence CC Attribution, auteurs cités dans Paramètres → Crédits).
- **Style cartoon** (par défaut) : textures peintes à la main aux couleurs vives ; le rendu réaliste reste disponible dans Paramètres → Graphismes → Style graphique.
- **Coffres** : coffres dorés posés contre les murs des bâtiments et dehors, signalés par une colonne de lumière dorée (sans son) ; on les ouvre avec `E` pour obtenir, devant le coffre, une arme rare à légendaire, des munitions, un soin et des matériaux.
- **Skins de voiture** : la **Voiture standard** est là par défaut ; le skin secret **Rebeca** (code cadeau) n'est visible que par son propriétaire, sur toutes les voitures qu'il a utilisées pendant la partie ; les autres joueurs et les voitures non utilisées restent normales. Toutes les voitures ont des vitres teintées noires.
- **Skins de pioche** : ils changent le modèle 3D de la pioche (Hache de secours, Ancre de marine, Trident des abysses) ; le camo d'arme équipé colore la pioche. Les **camos d'arme** changent les couleurs des armes ; les **skins d'arme** (modèle 3D) arriveront plus tard.
- **16 armes en 6 catégories** : fusils d'assaut CZ Bren 2 et HK416 ; mitraillettes UZI, MP7 et INP 9 ; fusils à pompe Winchester SXP, R9-0, S868 (double canon) et JAK-12 (automatique) ; précision DLQ 33, SVD et Arbalète silencieuse ; **armes lourdes** (mitrailleuse PKM de 80 balles, Javelin à explosion de zone qui détruit les constructions) ; Glock 19 et Revolver.
- **Armurerie** : choisis une catégorie, une arme, puis les accessoires de chaque emplacement (viseur point rouge, holographique, lunettes ×2, ×4 et ×8, silencieux, compensateur, frein de bouche, choke, poignées, chargeurs étendus ou rapides). Ils modifient les statistiques et apparaissent sur l'arme. La visée se fait réellement dans le viseur. Certains se débloquent en montant de niveau.
- **Largages de ravitaillement** : toutes les 80 s environ, une caisse descend en parachute dans la zone, avec une fumée rouge et un losange orange sur la carte. Elle contient une arme légendaire et du matériel rare.
- **Défis du jour** : trois objectifs par jour dans le Salon (éliminations, dégâts, conduite, récolte…), qui rapportent de l'XP.
- **Ambiances** : chaque partie se joue de jour, au matin dans la brume ou au coucher du soleil, avec vent, vagues près des côtes et chants d'oiseaux.
- **Île agrandie** (×1,5) : 11 lieux dont la grande **Cité Zéro**, avec des **immeubles à étage** (escalier intérieur et toit-terrasse), des **stations-service** et des **entrepôts**.
- **Voitures** : des voitures sont garées près des lieux-dits et des stations-service. Monte avec `E`, la caméra passe derrière la voiture. Elles roulent jusqu'à 75 km/h, suivent le relief et piquent du nez en fin de saut. Les chocs et les réceptions abîment la voiture, pas le conducteur. Elles écrasent les adversaires, s'arrêtent contre les murs et les constructions (qu'elles abîment à grande vitesse) et explosent sous les tirs.
- **Munitions** : chaque arme a sa réserve. Si tu échanges une arme contre une autre du même calibre (par exemple deux fusils d'assaut), la réserve suit. Les caisses de munitions remplissent trois chargeurs par arme.
- **Bots** : ils ont un champ de vision, mettent un instant à te repérer (plus longtemps de loin ou accroupi), entendent les tirs sans connaître ta position exacte, visent moins bien en début d'échange et reculent pour se soigner.
- **Bornes de rappel** : un coéquipier éliminé laisse une carte de rappel pendant 90 s. Ramasse-la et maintiens `E` à une borne (carré vert sur la carte) pour le faire revenir.
- **Ramassage automatique** : marcher sur des munitions, des matériaux ou des soins les ramasse. Les armes se prennent avec `E`.
- **Indicateur des sons** : des arcs autour du réticule montrent d'où viennent les tirs (jaune) et les pas ennemis proches (blanc). Désactivable dans les paramètres.
- **Trampolines** (grand saut, on garde son arme en main) et **feux de camp** (3 PV par seconde pendant 30 s) se trouvent par terre et se posent avec `T` et `B`.
- **Zone** : un rideau violet animé, bien visible de loin comme de près ; l'écran se teinte quand on approche du bord. Les dégâts augmentent à chaque phase et plus on reste dehors (jusqu'au double après 30 s).
- **Constructions** : on vise la case devant soi (plus besoin d'aller au bout de son sol), les rampes posées en courant forment une seule ligne, les pièces s'enfoncent un peu dans les bosses du terrain, les rampes sont solides vues de dessous, et une pièce posée sur soi se traverse le temps d'en sortir (pratique pour escalader).

## Commandes

| Touche | Action |
| --- | --- |
| Z Q S D (W A S D en QWERTY) | Se déplacer |
| Maj / Espace | Sprinter / sauter |
| Clic gauche / clic droit | Tirer / viser |
| 1 à 4, molette | Pioche et armes |
| X | S'accroupir (plus précis, plus discret) ; en plein sprint : glissade |
| Espace face à un obstacle | Escalader (murets, caisses, conteneurs jusqu'à 2,8 m) |
| M | Grande carte (clic pour poser un marqueur d'équipe) |
| N | Emote : salut, danse, danse robot (appuyer à nouveau pour changer) |
| Clic molette | Placer un marqueur visible par ton équipe (12 s) |
| E | Ramasser, maintenir pour réanimer ou rappeler, monter dans une voiture ou en sortir, ouvrir ou fermer une porte |
| Z/Q/S/D ou W/A/S/D en voiture | Accélérer, tourner, freiner et reculer ; Espace = frein à main |
| R | Recharger |
| A (Q en QWERTY) | Jeter son arme (elle part devant soi et retombe au sol) |
| Échap | Pause ; ferme aussi la grande carte, les paramètres ouverts depuis la pause et la pause elle-même |
| F / C / V | Construire mur / sol / rampe |
| G (ou clic droit en construction) | Changer de matériau |
| T / B | Poser un trampoline / un feu de camp |
| H | Se soigner |
| O | Menu staff (comptes staff uniquement) |

## Version de bureau (Windows et macOS)

Téléchargement : https://github.com/enzo78360/ilot-zero/releases/latest


Le jeu peut être empaqueté en application avec [Electron](https://www.electronjs.org/). Les bibliothèques (three.js, PeerJS, décodeur Draco) sont dans `vendor/`, donc le jeu solo marche hors ligne. Le multijoueur a toujours besoin d'Internet.

```bash
npm install
npm start            # lancer la version de bureau
npm run dist:mac     # dist/ : .dmg et .zip (Apple Silicon et Intel)
npm run dist:win     # dist/ : installateur .exe et version portable
```

Les applications ne sont pas signées. Sur macOS, au premier lancement : clic droit sur l'app, puis « Ouvrir ». Sur Windows, SmartScreen peut demander « Informations complémentaires », puis « Exécuter quand même ». `F11` passe en plein écran.

## Comment marche le multijoueur

Le jeu est une seule page statique (`index.html`), sans serveur à nous. Le navigateur de l'hôte fait tourner la partie (bots, zone, dégâts). Les amis s'y connectent directement en WebRTC grâce à [PeerJS](https://peerjs.com/) et à son serveur public gratuit de mise en relation. Si l'hôte ferme sa page, la partie s'arrête pour tout le monde.

Certains réseaux (entreprise, école, certains partages de connexion 4G) bloquent les connexions directes entre navigateurs. Dans ce cas, le salon ne se rejoint pas.

Fait avec [three.js](https://threejs.org/).
