# Îlot Zéro

FPS battle royale qui se joue directement dans le navigateur. 20 combattants sautent sur une île, ramassent des armes, construisent et la zone se referme. La dernière équipe en vie gagne.

**Jouer :** https://enzo78360.github.io/ilot-zero/

## Modes

- **Solo, Duo, Escouade** : en duo et en escouade, un joueur à 0 PV tombe à terre et un coéquipier peut le réanimer (maintenir `E` pendant 5 s).
- **Contre les bots** : tout seul, les bots complètent les 20 places.
- **Avec des amis** : un joueur clique sur « Créer un salon » et donne le code à 4 caractères. Les autres l'entrent dans « Rejoindre ». Jusqu'à 8 joueurs, les bots complètent jusqu'à 20. En duo ou en escouade, les amis sont placés dans la même équipe.

## Menu

Le menu est organisé en onglets : **Salon** (jouer seul ou avec des amis), **Inventaire** (équiper tenues et revêtements), **Boutique**, **Passe de combat** (saison 2 « Abysses » : une récompense à chaque palier) et **Paramètres** (sensibilité de la souris, sensibilité en visée et sensibilité propre à chaque viseur : mire et point rouge, ×2, ×4, ×8, inversion de l'axe vertical, champ de vision, préréglages graphiques Bas à Ultra, ombres, distance d'affichage, herbe, eau avec reflets, échelle de rendu, volume, compteur d'images par seconde). Les paramètres sont aussi accessibles en jeu depuis la pause (Échap).

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
- **16 armes en 6 catégories** : fusil d'assaut et carabine ; mitraillette, mitraillette compacte et mitraillette lourde ; fusil à pompe, fusil tactique, fusil à double canon et fusil à pompe automatique ; fusil de précision, fusil de tireur d'élite et arbalète silencieuse ; **armes lourdes** (mitrailleuse légère de 80 balles, lance-roquettes à explosion de zone qui détruit les constructions) ; pistolet et revolver.
- **Armurerie** : choisis une catégorie, une arme, puis les accessoires de chaque emplacement (viseur point rouge, holographique, lunettes ×2, ×4 et ×8, silencieux, compensateur, frein de bouche, choke, poignées, chargeurs étendus ou rapides). Ils modifient les statistiques et apparaissent sur l'arme. La visée se fait réellement dans le viseur. Certains se débloquent en montant de niveau.
- **Largages de ravitaillement** : toutes les 80 s environ, une caisse descend en parachute dans la zone, avec une fumée rouge et un losange orange sur la carte. Elle contient une arme légendaire et du matériel rare.
- **Défis du jour** : trois objectifs par jour dans le Salon (éliminations, dégâts, conduite, récolte…), qui rapportent de l'XP.
- **Ambiances** : chaque partie se joue de jour, au matin dans la brume ou au coucher du soleil, avec vent, vagues près des côtes et chants d'oiseaux.
- **Île agrandie** (×1,5) : 11 lieux dont la grande **Cité Zéro**, avec des **immeubles à étage** (escalier intérieur et toit-terrasse), des **stations-service** et des **entrepôts**.
- **Voitures** : des voitures sont garées près des lieux-dits et des stations-service. Monte avec `E`, la caméra passe à la troisième personne. Elles roulent jusqu'à 75 km/h, suivent le relief et piquent du nez en fin de saut. Les chocs et les réceptions abîment la voiture, pas le conducteur. Elles écrasent les adversaires, s'arrêtent contre les murs et les constructions (qu'elles abîment à grande vitesse) et explosent sous les tirs.
- **Munitions** : chaque arme a sa réserve. Si tu échanges une arme contre une autre du même calibre (par exemple deux fusils d'assaut), la réserve suit. Les caisses de munitions remplissent trois chargeurs par arme.
- **Bots** : ils ont un champ de vision, mettent un instant à te repérer (plus longtemps de loin ou accroupi), entendent les tirs sans connaître ta position exacte, visent moins bien en début d'échange et reculent pour se soigner.
- **Bornes de rappel** : un coéquipier éliminé laisse une carte de rappel pendant 90 s. Ramasse-la et maintiens `E` à une borne (carré vert sur la carte) pour le faire revenir.
- **Ramassage automatique** : marcher sur des munitions, des matériaux ou des soins les ramasse. Les armes se prennent avec `E`.
- **Indicateur des sons** : des arcs autour du réticule montrent d'où viennent les tirs (jaune) et les pas ennemis proches (blanc). Désactivable dans les paramètres.
- **Trampolines** et **feux de camp** (3 PV par seconde pendant 30 s) se trouvent par terre et se posent avec `T` et `B`.

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
| P | Basculer entre vue à la 1re et à la 3e personne |
| Clic molette | Placer un marqueur visible par ton équipe (12 s) |
| E | Ramasser, maintenir pour réanimer ou rappeler, monter dans une voiture ou en sortir, ouvrir ou fermer une porte |
| Z/Q/S/D ou W/A/S/D en voiture | Accélérer, tourner, freiner et reculer ; Espace = frein à main |
| R | Recharger |
| F / C / V | Construire mur / sol / rampe |
| G (ou clic droit en construction) | Changer de matériau |
| T / B | Poser un trampoline / un feu de camp |
| H | Se soigner |
| O | Menu staff (comptes staff uniquement) |

## Version de bureau (Windows et macOS)

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
