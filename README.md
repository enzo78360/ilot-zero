# Îlot Zéro

FPS battle royale qui se joue directement dans le navigateur. 20 combattants sautent sur une île, ramassent des armes, construisent et la zone se referme. La dernière équipe en vie gagne.

**Jouer :** https://enzo78360.github.io/ilot-zero/

## Modes

- **Solo, Duo, Escouade** : en duo et en escouade, un joueur à 0 PV tombe à terre et un coéquipier peut le réanimer (maintenir `E` pendant 5 s).
- **Contre les bots** : tout seul, les bots complètent les 20 places.
- **Avec des amis** : un joueur clique sur « Créer un salon » et donne le code à 4 caractères. Les autres l'entrent dans « Rejoindre ». Jusqu'à 8 joueurs, les bots complètent jusqu'à 20. En duo ou en escouade, les amis sont placés dans la même équipe.

## Commandes

| Touche | Action |
| --- | --- |
| Z Q S D (W A S D en QWERTY) | Se déplacer |
| Maj / Espace | Sprinter / sauter |
| Clic gauche / clic droit | Tirer / viser |
| 1 à 4, molette | Pioche et armes |
| E | Ramasser, maintenir pour réanimer |
| R | Recharger |
| F / C / V | Construire mur / sol / rampe |
| H | Se soigner |

## Comment marche le multijoueur

Le jeu est une seule page statique (`index.html`), sans serveur à nous. Le navigateur de l'hôte fait tourner la partie (bots, zone, dégâts). Les amis s'y connectent directement en WebRTC grâce à [PeerJS](https://peerjs.com/) et à son serveur public gratuit de mise en relation. Si l'hôte ferme sa page, la partie s'arrête pour tout le monde.

Certains réseaux (entreprise, école, certains partages de connexion 4G) bloquent les connexions directes entre navigateurs. Dans ce cas, le salon ne se rejoint pas.

Fait avec [three.js](https://threejs.org/).
