# Îlot Zéro : récapitulatif

Mise à jour du 12 novembre 2026 (soir).

## Liens utiles

| Quoi | Où |
| --- | --- |
| Jouer (site) | https://enzo78360.github.io/ilot-zero/ |
| Code source | https://github.com/enzo78360/ilot-zero |
| Applications Windows et Mac | https://github.com/enzo78360/ilot-zero/releases/latest |
| Base de données et comptes (Supabase) | https://supabase.com/dashboard/project/kweiabsweqxwoiiqbkpa |
| Identifiant Google (connexion) | https://console.cloud.google.com/auth/clients |
| Confidentialité | https://enzo78360.github.io/ilot-zero/confidentialite.html |
| Conditions d'utilisation | https://enzo78360.github.io/ilot-zero/conditions.html |

## Encore plus d'outils de modération (12 novembre 2026)

| Ajout | Détail |
| --- | --- |
| Expulser de sa partie | Le joueur revient au menu en 10 s (1 min s'il est en pleine partie) avec le motif ; s'il héberge un salon public, celui-ci est retiré |
| Refuser un pseudo | Le joueur doit choisir un nouveau pseudo (avertissement avec le motif) ; l'ancien ne peut plus être pris par personne. Les mots interdits (liste de base et AutoMod) sont refusés dans les pseudos, vérifié par le serveur |
| Fiche joueur | Compte, en ligne et salon, niveau et coquillages, bannissement et exclusion en cours, avertissements (lus ou non), signalements reçus, notes internes du staff (ajout, suppression), nombre d'actions ; raccourcis vers Modérer, Journal et Inventaire |
| Annonce à tous | Bandeau en bas du menu et message en partie, pour 1 h, 6 h, 1 jour, 7 jours ou sans fin |
| Mode maintenance | Seul le staff peut jouer ; les autres voient « Maintenance en cours » et le message (ceux en partie reviennent au menu) ; la page se rouvre seule à la fin |
| Salons publics | Liste des parties rapides ouvertes avec Fermer et Expulser l'hôte |
| Signalements | Bouton Tout vider |
| Permissions | 6 nouveaux pouvoirs réglables : expulser, refuser un pseudo, notes, annonce, maintenance, salons publics. Tout est noté au journal |

Base : `supabase/moderation_tools.sql`. Vérification : en base en tant que propriétaire puis joueur (transaction annulée : expulsion lue une seule fois, ancien pseudo et pseudo injurieux refusés, pseudo normal accepté) ; dans le jeu, fiche, outils, annonce, expulsion en pleine partie, maintenance puis fin, pseudo refusé, aucune erreur.

## Pouvoirs du staff dans les permissions (12 novembre 2026)

| Demande | Ce qui a changé |
| --- | --- |
| Accorder ou non les pouvoirs du menu `O` (vie infinie…) | Le tableau Permissions a une deuxième partie : Vie illimitée, Munitions, Matériaux, Super vitesse, Radar, Soin complet, Arme légendaire, Kit, Aller au marqueur, Redéployer en planeur, Coquillages illimités et XP illimitée, chacun réglable (Assistant et plus, Modérateur et plus, Admin seulement). Un pouvoir non accordé disparaît du menu `O` et de l'Espace staff et ne marche plus même s'il était activé. Par défaut, tous restent permis à tout le staff, comme avant |

Base : `supabase/moderation_powers.sql`. Vérification : Assistant sans Vie illimitée, sans Arme légendaire et sans Coquillages illimités : ces pouvoirs sont coupés, masqués et refusés en partie ; les autres restent ; aucune erreur.

## Permissions réglables et inventaire des joueurs (12 novembre 2026)

| Demande | Ce qui a changé |
| --- | --- |
| Journal et AutoMod vides au clic | Les deux panneaux restaient masqués : ils s'affichent maintenant pour le staff et se chargent à l'ouverture de la section |
| Choisir soi-même ce que chaque rang peut faire | Nouvelle section **Permissions** : pour chacun des 12 pouvoirs (avertir, exclure jusqu'à 1 h, exclure plus longtemps, signalements, journal, bannir, AutoMod, liste des joueurs, inventaire, coquillages et XP, codes, gestion du staff), un choix « Assistant et plus », « Modérateur et plus » ou « Admin seulement ». Seul le propriétaire modifie le tableau ; le serveur vérifie chaque action selon ce tableau ; le changement est noté au journal. L'interface n'affiche que les boutons permis |
| Gérer l'inventaire des joueurs | Section Joueurs → **Inventaire d'un joueur** (ou bouton Inventaire dans la liste) : ses skins, camos, pioches, voitures et emotes, avec Retirer, et une liste de tous les objets pour Donner. Les dons et retraits en attente sont signalés. Le joueur les reçoit dès qu'il est connecté, avec un message ; un objet équipé qu'on lui retire est remplacé par celui de base. La tenue staff ne peut pas être donnée. Chaque don et retrait est noté au journal |

Base : `supabase/moderation_perms.sql`. Vérification : en base en tant que propriétaire puis joueur (transaction annulée) ; dans le jeu, clic sur Journal, AutoMod, Permissions, Inventaire, don et retrait livrés au joueur, aucune erreur.

## Modération façon Discord (12 novembre 2026)

| Demande | Ce qui a changé |
| --- | --- |
| Rangs du staff | Assistant, Modérateur, Admin. Assistant : avertir, exclure du chat jusqu'à 1 h, traiter les signalements, lire le journal. Modérateur : en plus exclure jusqu'à 7 jours, bannir, débannir, régler l'AutoMod. Admin : en plus gérer le staff et les rangs, cadeaux et codes. On n'agit jamais sur un rang égal ou supérieur ; le propriétaire est toujours Admin et lui seul nomme les Admins. Les membres du staff déjà en place sont Admin (à ajuster dans Compte → Équipe staff) ; un nouveau membre arrive Assistant |
| Exclusion temporaire et avertissements | Exclure du chat 5 min, 15 min, 1 h, 6 h, 1 jour ou 7 jours : le joueur continue de jouer mais ne peut plus écrire nulle part (son jeu refuse, et l'hôte du salon ignore ses messages, vérifié toutes les 20 s). Avertissement avec motif : le joueur le voit dans une fenêtre en ouvrant le menu. Bouton Historique par joueur |
| Journal de modération | Avertissements, exclusions, bannissements, débannissements, signalements traités, staff ajouté ou retiré, rangs, AutoMod, cadeaux et codes : qui, quoi, à qui, quand et pourquoi, filtrable par pseudo |
| AutoMod réglable | Mots interdits en plus (variantes c0nn4rd et lettres espacées comprises), liens retirés ou non, majuscules adoucies ou non, anti-spam réglable (nombre de messages, durée, répétitions, durée du silence), mode lent. Chargé par chaque joueur et par l'hôte |

Base : `supabase/moderation.sql` (tables d'exclusions, d'avertissements et de journal, rangs, fonctions vérifiées par le serveur). Vérification : fonctions testées en base en tant que propriétaire puis en tant que joueur (refus corrects), dans une transaction annulée ; interface et chat testés dans le jeu (rangs Assistant et Admin, exclusion, mode lent, anti-spam, mot ajouté filtré même espacé, avertissement affiché), aucune erreur. Publié : site à jour et Release 2.2.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v2.2.0).

## Sixième liste et Forteresse (12 novembre 2026)

| Demande | Ce qui a changé |
| --- | --- |
| Soins : la potion passait avant les bandages | Tant qu'il manque de la vie et qu'il reste des bandages, `H` prend un bandage ; la potion de bouclier ensuite. Infecté (mode Zombies) : la potion d'abord, puisqu'elle guérit |
| Zombies déséquilibrés | Zombie Soldat 7,3 m/s (marche 6,4, sprint 9,4), zombie normal 3,9 m/s (avant 9,2 et 4,4). Le coup part avec un élan de 0,4 s : il rate si on s'est écarté, si on est derrière lui, et environ 1 fois sur 4 de toute façon (plus souvent si on court). Dégâts 10 (Soldat 13) au lieu de 20, 9 aux voitures au lieu de 30, 40 aux constructions au lieu de 55. Coincé contre un mur : il calcule un chemin autour (cases de 1 m) au lieu de pousser ; toujours bloqué 20 s sans être vu : il réapparaît ailleurs. Joueur perché : il prend les rampes construites comme des escaliers (sinon il casse le pied de la tour) |
| Zombies qui traversent les sols posés dans les escaliers | Une pièce au-dessus de la tête bloque maintenant comme un plafond, pour tout le monde : on ne monte plus l'escalier à travers, on ne saute plus au travers, et plus de téléportation au bord de la pièce |
| Arme jetée qui apparaît 2 m plus loin, impossible à rattraper | L'arme tourne autour de son centre (et plus de sa crosse) et, en se posant, remonte en douceur à sa hauteur au lieu de sauter. On peut la ramasser en l'air |
| Karambit | Nouvelle garde : avant-bras à l'horizontale, anneau au-dessus du poing, griffe visible sous la main. Coup : on arme vers la droite puis balayage horizontal vers la gauche, lame en premier. Le camo équipé colore maintenant la lame, le manche, l'anneau et les flancs (seul le fil reste violet) |
| INP 9 : la mire métallique masquait le point rouge | Le point rouge de l'INP 9 est posé sur une rehausse : le guidon ne gêne plus (holographique et mire inchangés) |
| Coffres devant les portes | Plus aucun coffre à moins de 2,4 m d'une porte |
| Accroupi puis sprint | Maj en avançant relève tout seul et fait sprinter |
| Rechargement automatique qui passait à l'arme suivante | Le rechargement automatique ne vise que l'arme qui s'est vidée ; changer d'arme l'annule, la nouvelle arme ne recharge pas toute seule |
| Eau profonde | Quand on n'a plus pied, on nage la tête hors de l'eau (vitesse divisée par 2), bots et zombies aussi ; on ne marche plus au fond. Caméra sous l'eau : vue bleu sombre, surface visible par-dessous |
| Une seule carte fixe | Le relief, les routes, les rivières, les bâtiments et l'emplacement des coffres viennent toujours de la même graine (4242, choisie parmi 12 îles générées : 12 lieux, 82 bâtiments, ville, désert, rivière et montagne centrale). Seuls le butin, le contenu des coffres et les largages changent à chaque partie |
| La Forteresse | Sommet de la montagne aplani à 30 m ; forteresse de métal de 44 × 44 m : enceinte de 7 m avec créneaux, bandeau lumineux mauve, 4 tours d'angle de 11 m et 4 portes. Dedans, un labyrinthe de 25 salles (5 × 5, toujours le même) avec toits et plafonniers, 2 à 3 objets par salle et des coffres (environ 45 objets, 7 à 10 coffres). Au pied du versant sud, un parking creusé de 44 × 16 m (piliers, marquages, 4 voitures), relié à l'est et à l'ouest par une route asphaltée jusqu'au réseau ; deux grands escaliers de 37 m partent du parking et débouchent dans la forteresse. Sur la carte : enceinte, parking, escaliers et routes. Une équipe de bots sur quatre atterrit devant ses portes |
| Leviers, orbe et seringue | Salle des leviers (coin nord-ouest du labyrinthe) : 5 leviers sur panneaux jaunes, chacun pour soi (ce qu'un coéquipier actionne reste baissé pour toi), voyant vert quand il est actionné. Salle centrale : grande boule sur un socle ; les 5 leviers actionnés, elle s'allume en mauve avec des éclairs et le bouton devant donne la **seringue de survie**. Touche `Y` (modifiable) : injection en 2 s, vue en 1re personne (l'avant-bras monte, l'aiguille entre, le piston descend), bouclier et vie au maximum (guérit aussi l'infection), recharge 60 s. Avec la seringue prête, on tombe à terre au lieu de mourir, même en solo, et on se relève avec ; à terre on peut toujours être achevé. Perdue à la mort, à reprendre au bouton. Indicateur violet sous la barre d'infection. Synchronisé en multijoueur |

Vérification : banc de test navigateur sur l'île fixe : leviers puis orbe puis seringue, mise à terre puis injection (relevé à 100/100, recharge de 60 s, mort normale pendant la recharge), même chose par messages réseau simulés côté hôte ; escaliers d'immeuble (6) et de la forteresse gravis ; sol posé dans un escalier : on reste dessous ; zombie derrière une maison : 10 cas sur 10 rejoignent le joueur (2,5 à 12 s) ; zombie qui monte une rampe construite jusqu'au joueur ; 30 zombies autour d'un joueur immobile : 25 coups portés, 83 ratés en 18 s ; Battle royale de 45 s avec bots ; aucune erreur dans la console. Le code a aussi été relu par un relecteur séparé (fenêtres redevenues infranchissables, bras des leviers, zombies qui changent de cible, synchronisation de la seringue corrigés). Publié : site à jour et Release 2.1.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v2.1.0).

## Emotes, salon, modération du chat, tenue staff (11 novembre 2026)

| Demande | Ce qui a changé |
| --- | --- |
| Emotes à débloquer | 9 nouvelles emotes animées dans Blender sur le squelette du personnage (`models/emotes_anim.glb`, source `models/staff_emotes.blend`) : Applaudir, Salut militaire, Pas impressionné (bras croisés), Flexions, Fou rire, Victoire, Vague, Guitare imaginaire, Feu d'artifice. Avec Salut, Danse et Danse robot (offertes) : 12 emotes. Boutique : Applaudir 300, Salut militaire 500, Pas impressionné 600, Fou rire 900, Vague 1 100, Guitare imaginaire 1 600. Nouveau **Gacha Fête** (en tête de la liste des Gachas) : Feu d'artifice (légendaire, exclusif, fusées colorées au-dessus du joueur), Victoire et Flexions (exclusives), les 6 emotes de la boutique et le camo Arc-en-ciel. Nouveau type « Emote » dans l'Inventaire et la Boutique, aperçu animé, vignettes. Roue d'emotes : maintenir N, viser à la souris (ou 1 à 6), relâcher ; jusqu'à 6 emotes choisies dans l'Inventaire (« Ajouter à la roue »). Visibles par les autres en multijoueur ; les bots en font aussi |
| Salon comme dans les grands battle royale | Salon en plein écran : les personnages de tous les joueurs (jusqu'à 8 affichés) avec leur tenue, sur des socles lumineux, le sien au centre en orange, pseudo et « Hôte » au-dessus. Code, infos, joueurs et invitations à gauche, réglages et chat à droite, emotes et bouton de lancement en bas. Les emotes jouées dans le salon sont vues par tout le monde |
| Modération du chat | Insultes masquées (français et anglais, y compris déguisées : c0nn4rd, lettres espacées), liens retirés, majuscules adoucies, lettres répétées réduites. Anti-spam appliqué par l'hôte : plus de 4 messages en 6 s ou le même message 3 fois → réduit au silence 30 s. L'hôte peut rendre un joueur muet (liste des joueurs). Chaque joueur peut masquer quelqu'un ou signaler un message (au survol, dans le chat du salon). Signalements visibles par le staff dans Compte → Modération, avec « Bannir 1 h » et « Traité » (`supabase/chat_reports.sql`) |
| Tenue réservée au staff | « Staff de l'Îlot » modélisée dans Blender (`models/staff.glb`) : casque audio avec micro et visière lumineuse, cape noire et or avec emblème, insigne doré sur la poitrine, brassard ; tenue noire, gants dorés. Rareté « Staff ». Ajoutée automatiquement aux comptes staff, retirée des autres, jamais en boutique ni dans un Gacha |

Vérification : menus (8 onglets), achat d'une emote, tirage du Gacha Fête, roue d'emotes et Feu d'artifice en partie, salon à 2 (tenues, emotes vues par l'autre, chat filtré, spam bloqué), partie en ligne à 2 (emote de l'invité vue par l'hôte, chat en jeu), Battle royale et Zombies, sans erreur dans la console. 3 minutes de partie en escouade avec tirs, constructions et emotes sans erreur. Publié : site à jour et Release 2.0.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v2.0.0).

## Salons de 25 joueurs (11 novembre 2026)

| Demande | Ce qui a changé |
| --- | --- |
| Jouer à 25 joueurs, hôte compris | Salons et parties rapides jusqu'à 25 vrais joueurs (avant : 8). Battle royale : toujours 20 combattants au minimum, les bots complètent ; à plus de 20 vrais joueurs il n'y a plus de bots (25 joueurs = 25 combattants, 13 duos ou 7 escouades). Zombies : 25 joueurs contre 30 zombies. Pour ménager la connexion de l'hôte : 15 envois par seconde jusqu'à 8 joueurs, 12 jusqu'à 16, 10 au-delà ; dans un salon très rempli, les personnages à plus de 180 m d'un joueur (hors son équipe) ne lui sont envoyés qu'un envoi sur trois. Base : limite des salons publics passée à 25 (`supabase/matchmaking_25.sql`) |

Mesures à 25 joueurs (24 joueurs simulés + l'hôte, dispersés sur l'île) : envoi de l'hôte 390 Ko/s en Battle royale (~3 Mbit/s) et 570 Ko/s en Zombies (~4,6 Mbit/s, contre 1 430 Ko/s sans le tri par distance). L'hôte a donc besoin d'une connexion montante d'au moins 5 à 10 Mbit/s (fibre conseillée). Vérifié : 26e joueur refusé (« salon complet »), 25 joueurs dans le bus, 7 escouades, et chez un vrai joueur connecté au milieu de 23 joueurs simulés en Zombies, les 55 personnages à moins de 4 m de leur vraie position, aucune erreur. Publié : site à jour et Release 1.9.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v1.9.0).

## Bus volant (11 novembre 2026)

| Demande | Ce qui a changé |
| --- | --- |
| Un bus qui nous emmène sur la carte au lieu de sauter directement | Chaque partie (Battle royale et Zombies, solo ou en salon) commence dans un **bus volant** modèle maison : car orange et crème à vitres teintées, quatre rotors carénés sur bras, phares, bandeau « ÎLOT ZÉRO · LIGNE 0 », vrombissement des rotors. Il traverse l'île en ligne droite dans une direction différente à chaque partie, à 112 m, en environ 26 s. Vue de derrière le bus (la souris tourne autour). Les portes s'ouvrent au-dessus de la côte : `Espace` pour sauter (planeur comme avant), éjection automatique avant qu'il ne quitte l'île. Trajet en pointillés et icône du bus sur la mini-carte et la grande carte. Les bots sautent au-dessus de l'endroit où ils veulent atterrir, et ceux de l'équipe d'un vrai joueur sautent juste après lui. Dans le bus : impossible de tirer, d'être touché ou d'être visé (zombies compris). La zone attend que tout le monde soit sorti (son rideau est caché pendant le vol). En mode Zombies, seuls les vrais joueurs sont dans le bus. Synchronisé en multijoueur (trajet choisi par l'hôte) |

Vérification : partie solo (20 combattants dans le bus, saut, tous au sol à la fin du trajet, zone qui démarre après) ; salon à 2 en Duo et en Zombies (l'invité voit le bus, saute, l'hôte le voit en planeur, aussi après une relance), aucune erreur dans la console. Publié : site à jour et Release 1.8.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v1.8.0).

## Matchmaking (11 novembre 2026)

| Demande | Ce qui a changé |
| --- | --- |
| Un système de matchmaking | Bouton « Partie rapide en ligne » sous « Jouer » : cherche une partie publique du jeu et du mode choisis (Battle royale ou Zombies ; Solo, Duo ou Escouade), rejoint la plus remplie, sinon en ouvre une. Salon public : réglages verrouillés (bots normaux), compte à rebours de 45 s puis lancement automatique (5 s dès qu'il y a 8 joueurs), bouton « Lancer maintenant » pour l'hôte, les bots complètent. Deux joueurs qui cherchent en même temps se regroupent dans le même salon en quelques secondes. Salon complet, déjà lancé ou fermé : on passe au suivant tout seul. Les amis peuvent toujours entrer avec le code. Base : table `mm_lobbies` et fonction `mm_find` (`supabase/matchmaking.sql`), chaque joueur ne peut créer ou effacer que son propre salon ; un salon qui ne donne plus de nouvelles depuis 15 s n'est plus proposé |

Vérification : règles d'accès testées sur la base (on ne trouve pas son propre salon, un autre joueur le trouve, il ne peut pas l'effacer) ; deux onglets reliés par PeerJS : recherche puis entrée dans le salon, recherche simultanée regroupée, lancement automatique en mode Zombies (2 joueurs, 30 zombies), salon retiré de la liste au lancement. Publié : site à jour et Release 1.7.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v1.7.0).

## Cinquième liste (10 novembre 2026)

| Demande | Ce qui a changé |
| --- | --- |
| Une seule carte | Îlot Zéro regroupe la ville (Quartier des Tours), les villages, les forêts et une zone désert (environ un quart de l'île, ville de Mirage, cactus, sable et roche ocre). Le choix de carte est retiré |
| Routes | Quadrillage de routes droites nord-sud et est-ouest (72 m), terrain aplani sous la route : plate en travers, pente douce seulement dans le sens de la marche. Un seul réseau relié à la ville, aucune impasse (vérifié sur 5 îles : 0 impasse, 0 bâtiment touché). Levée de terre dans les zones basses, pont droit au-dessus de l'eau. Bâtiments à plus de 9,5 m de l'axe des routes ; les entrepôts trop larges ne sont plus dans les pâtés de la ville |
| Gacha | Liste de Gachas (cartes avec l'image du skin principal et la progression). Nouveau **Gacha Zombie Soldat** : 9 objets de boutique (dont le skin Zombie) et le Zombie Soldat, légendaire, exclusif |
| Skins zombies | **Zombie** (boutique, épique, 1 400) : peau gris-vert marbrée avec plaies, vêtements en lambeaux (trous, bords effilochés, crasse, sang). Remplace « Zombie des marais » (même objet : ceux qui l'avaient le gardent). **Zombie Soldat** : uniforme camouflage déchiré, casque, gilet, sac |
| Karambit | Nouveau modèle : vraie lame en griffe creusée, dos crénelé, fil violet lumineux, manche galbé avec creux pour les doigts, anneau pour l'index. Tenu en prise inversée (anneau au-dessus du poing, lame sous le petit doigt), coup en diagonale |
| Constructions | Grille invisible rétablie : hauteurs par pas de 4 m (comme les cases au sol), toutes les pièces s'alignent. Une pièce doit toucher le sol, un bâtiment ou une pièce qui tient ; quand une pièce casse, celles qui ne tiennent plus à rien s'écroulent (aussi pour les bots et en multijoueur) |
| Mode Zombies | Nouveau jeu (Salon : Battle royale / Zombies), seul ou en salon, équipes de 1, 2 ou 4. 30 zombies impossibles à retirer, 10 Zombies Soldats aussi rapides qu'un joueur, les autres plus lents. Ils savent où sont les joueurs, contournent les murs, passent par les portes et sautent par les fenêtres, montent rampes et escaliers, cassent les constructions (et font tomber celui qui est perché), dévient un peu quand on leur tire dessus. Coup de pioche normal (20), infection 1 fois sur 5 : 60 s pour boire une potion de bouclier (soigne l'infection, sans bouclier, même à pleine vie ; non cumulable). Réapparition 3 s après la mort, ailleurs, avec un objet lâché (munitions, potion, bois, brique, métal, trampoline, feu de camp ou bandage). Pas de zone ; fin quand plus aucun joueur n'est en vie ; écran de fin avec le temps de survie |
| Zombies modélisés dans Blender | Nouvelles animations sur le squelette du personnage (`models/zombie_anim.glb`) : marche titubante voûtée bras tendus et pied qui traîne, course penchée bras en avant (Zombie Soldat), attente qui se balance tête penchée, attaque bras levés puis abattus. Pièces modélisées (`models/zombies.glb`, source `models/zombies.blend`) : casque militaire (bosse, filet de camouflage, bande avec pansement, jugulaire), gilet tactique moulé sur le torse (plaques, ceinture, bretelles, 3 poches à chargeurs), plaques d'identité, lambeaux de vêtement à la taille, côtes à vif, morsure au cou. Grognements de zombies synthétisés (au loin, et cri à chaque attaque). Les joueurs qui portent ces skins ont les mêmes pièces |
| Fluidité (site et applications) | Mesuré au profileur : 48 → 60 images/s en Battle royale et 40 → 60 en Zombies sur le Mac de test ; appels de dessin 1 737 → 999 (Zombies 2 332 → 1 466), triangles 2,46 M → 0,89 M. Décor figé (plus de recalcul de 12 000 matrices à chaque image), décor fusionné par matériau et par zone de 64 m (ce qui est hors champ ou hors de l'ombre n'est plus dessiné), arbres détaillés seulement à moins de 65 m (arbre simplifié au-delà), personnages hors champ non dessinés et animés moins souvent au-delà de 60 m, ombres des personnages à moins de 45 m, pioches et armes regroupées par matériau, particules sans nouveau matériau à chaque impact, reflets de l'eau recalculés une image sur trois, ombres une image sur deux (sauf Ultra), voitures affichées jusqu'à 120 m, butin sans ombre et butin des zombies qui disparaît après 90 s. Nouveau réglage « Résolution dynamique » (activé) : baisse un peu la netteté si les images ralentissent. Application : carte graphique dédiée et accélération GPU forcées |

Les points « souris détachée », « Gacha Karambit » et « escaliers » de la même liste étaient déjà corrigés dans la 1.5.0.

Vérification : banc de test Electron (génération sur 5 îles, constructions, Gacha, Karambit, mode Zombies solo et duo, Battle royale), sans erreur dans la console. Publié : site à jour et Release 1.6.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v1.6.0).

## Corrections de la liste du 9 novembre 2026

| Problème signalé | Ce qui a changé |
| --- | --- |
| Souris qui se détache du viseur, plus de pause, rechargement obligatoire | Un refus passager du navigateur (clic trop rapide après Échap, Alt+Tab…) coupait pour toujours le contrôle de la souris. Maintenant la pause s'affiche et un clic rend le contrôle ; si la souris est libérée sans prévenir, la pause apparaît d'elle-même |
| Gacha | Nouvel onglet « Gacha » : skin exclusif présenté en grand, liste des 10 objets avec ce qui est obtenu et la chance de chacun ; tirage à 1 000 coquillages, 9 objets de boutique à chance égale (11 %) et le skin principal plus rare (3,2 % au départ) ; jamais un objet déjà obtenu ou acheté ; bouton gris « Gacha terminé » quand tout est obtenu. Premier Gacha : Karambit (skin de pioche, modèle 3D) |
| Escaliers traversés par en dessous, coffres et armes sur les escaliers | L'escalier bloque comme un bloc plein (dessous et côtés) ; on monte toujours normalement. Coffres et butin à plus de 1,3 m de l'escalier, en bas comme sur le palier du haut (0 objet près d'un escalier sur les 3 cartes) |

Publié : site à jour et Release 1.5.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v1.5.0).

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

Vérification : 17 anciens tests et 40 nouveaux sur les 3 cartes, sans erreur dans la console. Publié : site à jour et Release 1.4.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v1.4.0).

## Site de téléchargement (retiré le 7 novembre 2026)

La page de présentation et de téléchargement a été retirée de GitHub. Une copie autonome (images intégrées) est dans `~/Downloads/ilot-zero-telechargement.html`. Les liens « Télécharger l'application » du jeu mènent maintenant à la dernière Release GitHub.

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
- **Applications Windows et Mac** : Release **1.6.0** (https://github.com/enzo78360/ilot-zero/releases/tag/v1.6.0) ; avant : 1.5.0, 1.4.0 (https://github.com/enzo78360/ilot-zero/releases/tag/v1.4.0), avec les corrections du 7 novembre, et avant cela : style cartoon et coffres, correction des salons, roues et ponts, personnages et voitures réalistes, Rebeca, refonte des 3 cartes, voitures, bots, son, touches, filtres d'inventaire.
- **Base de données** : protection du compte propriétaire en place (fonctions `staff_grant` et `grant_claim`). Les codes cadeaux peuvent donner un objet (le code `REBECA` existe, sans limite d'utilisation ni de durée).
- **Voitures (1.3.2)** : les roues se posent sur la route (le ruban de route est 13 cm au-dessus du terrain) et ne s'enfoncent plus dans les pentes ; les voitures ne sont plus repoussées au milieu des ponts au-dessus de l'eau profonde (131 passages sur 132 réussis sur les 3 cartes, le dernier bloqué par une voiture garée).
- **Salons** : la 1.3.0 avait un bug qui éjectait les amis au lancement de la partie. Il est corrigé depuis la 1.3.1 et sur le site : tout le monde doit utiliser le site ou la dernière version.
- La 1.2.0 était restée en brouillon et n'a jamais été publiée.

## Limites connues

- Le jeu tourne dans le navigateur ou dans l'application : un joueur très doué peut modifier sa copie locale. Le serveur protège les comptes, le rôle staff, les bannissements, les codes et les amis, mais pas une partie solo jouée hors ligne.
- En multijoueur, l'hôte doit garder le jeu ouvert. Les pouvoirs staff (vie, munitions, objets) ne marchent que si c'est le staff qui héberge.
- Les applications ne sont pas signées : au premier lancement, clic droit, puis « Ouvrir » sur Mac ; « Exécuter quand même » sur Windows.
- L'écran de connexion Google affiche « kweiabsweqxwoiiqbkpa.supabase.co » au lieu de « Îlot Zéro ». Pour afficher le nom et un logo, il faut faire valider le branding par Google (et prouver la propriété du site dans la Search Console).
