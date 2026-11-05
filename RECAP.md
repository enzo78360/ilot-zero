# Îlot Zéro : récapitulatif

Mise à jour du 5 novembre 2026.

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
- **Codes cadeaux** : coquillages ou XP, une fois par compte.
- **Staff** : pouvoirs illimités, menu staff en partie (touche `O`), modération, codes cadeaux, gestion des membres du staff.

## Guide du staff

Toutes ces actions se font dans le jeu, onglet **Compte**, avec un compte staff.

### Ajouter ou retirer un membre du staff
Section **Membres du staff** : entre son adresse Gmail, puis clique sur **Ajouter**. Il devient staff tout de suite s'il s'est déjà connecté, sinon à sa première connexion. Le bouton **Retirer** est à côté de chaque membre. Le propriétaire ne peut pas être retiré, et personne ne peut se retirer lui-même.

### Bannir un joueur
Section **Modération** : entre son pseudo, choisis la durée (1 h, 24 h, 7 jours, 30 jours ou définitif) et un motif, que le joueur verra, puis clique sur **Bannir**. La liste en dessous montre les bannissements en cours, avec un bouton **Débannir**. Un joueur banni est bloqué en moins d'une minute, même en pleine partie. Un membre du staff ne peut pas être banni.

### Créer un code cadeau
Section **Codes cadeaux (staff)** : choisis un code (par exemple `NOEL2026`), la récompense (coquillages ou XP), la quantité, la durée de validité et, si tu veux, un nombre maximum d'utilisations, puis clique sur **Créer**. Les joueurs l'entrent dans la section **Code cadeau** de leur onglet Compte. La liste montre les utilisations, et le bouton **Supprimer** désactive un code.

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
  Ensuite, crée une Release sur GitHub et dépose les fichiers `.dmg` et `.exe`.

## Configuration de la connexion (déjà faite)

- **Google Cloud** : client OAuth « Application Web ». Origine `https://enzo78360.github.io`, redirection `https://kweiabsweqxwoiiqbkpa.supabase.co/auth/v1/callback`. Application publiée.
- **Supabase**, Authentication, puis Providers : Google activé avec l'ID client et le code secret.
- **Supabase**, Authentication, puis URL Configuration : Site URL `https://enzo78360.github.io/ilot-zero/`, Redirect URLs `https://enzo78360.github.io/ilot-zero/**` et `http://127.0.0.1:53682/**` (pour les applications de bureau).

## Limites connues

- Le jeu tourne dans le navigateur ou dans l'application : un joueur très doué peut modifier sa copie locale. Le serveur protège les comptes, le rôle staff, les bannissements, les codes et les amis, mais pas une partie solo jouée hors ligne.
- En multijoueur, l'hôte doit garder le jeu ouvert. Les pouvoirs staff (vie, munitions, objets) ne marchent que si c'est le staff qui héberge.
- Les applications ne sont pas signées : au premier lancement, clic droit, puis « Ouvrir » sur Mac ; « Exécuter quand même » sur Windows.
- L'écran de connexion Google affiche « kweiabsweqxwoiiqbkpa.supabase.co » au lieu de « Îlot Zéro ». Pour afficher le nom et un logo, il faut faire valider le branding par Google (et prouver la propriété du site dans la Search Console).
