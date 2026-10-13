# Installer KOINO SIGN sur un serveur

KOINO SIGN tourne sur un seul serveur avec Docker : l'application, sa base
PostgreSQL, le convertisseur Word/HTML → PDF (Gotenberg) et Caddy pour le HTTPS.
L'image de l'application vient de `ghcr.io/maxencemrn/koino-sign` (construite
par GitHub Actions, voir `ci/koino-sign-image.yml`) ; tant qu'elle n'y est pas,
`installer.sh` la construit sur le serveur à partir de ce dépôt.

## 1. Le serveur

- Un VPS Ubuntu 24.04 (ou Debian 12), **2 vCPU / 4 Go de RAM / 40 Go de disque**
  (Hetzner CX22, OVH VPS, Scaleway…). 2 Go suffisent pour tourner, 4 Go donnent
  de la marge à LibreOffice et Chromium pendant les conversions.
- Accès SSH par clé.
- Ports 80 et 443 ouverts.

## 2. Le domaine

Créer un enregistrement DNS **A** `sign.koino.fr` → adresse IPv4 du serveur
(et **AAAA** si le serveur a une IPv6). Caddy obtient le certificat HTTPS tout
seul dès que le domaine pointe sur le serveur.

## 3. L'installation (5 minutes)

Sur le serveur :

```bash
git clone --depth 1 -b koino https://github.com/maxencemrn/koino-sign.git
sudo bash koino-sign/deploy/koino-sign/installer.sh
```

Le script demande le domaine, l'adresse d'envoi des emails et la **clé API
Resend** (domaine koino.fr déjà vérifié chez Resend). Il génère lui-même les
autres secrets et le certificat de signature, dans `/opt/koino-sign/.env`
(droits 600, jamais dans le dépôt). Il programme aussi une sauvegarde de la base
chaque nuit à 3 h 30 (`/opt/koino-sign/sauvegardes`, 14 jours).

## 4. Le premier compte

1. Ouvrir https://sign.koino.fr et créer un compte avec une adresse @koino.fr
   (seul ce domaine peut créer un compte).
2. Le rendre administrateur : `sudo /opt/koino-sign/rendre-admin.sh prenom@koino.fr`
3. Dans KOINO SIGN, créer l'équipe **Koïno**, puis dans ses réglages :
   - **Jetons d'API** : créer un jeton pour l'outil Koïno ;
   - **Webhooks** : `https://admin.koino.fr/api/signature/webhook`, événements
     document envoyé, ouvert, signé, terminé, refusé, annulé, avec un secret.
   - **Image de marque** : logo KOINO SIGN et couleur `#6d00d7` (pages de
     signature et emails des signataires).

## 5. Brancher l'outil Koïno (admin.koino.fr)

Variables d'environnement Vercel du projet `koino-pricing` :

| Variable | Valeur |
| --- | --- |
| `KOINO_SIGN_URL` | `https://sign.koino.fr` |
| `KOINO_SIGN_API_TOKEN` | le jeton d'API de l'équipe Koïno |
| `KOINO_SIGN_WEBHOOK_SECRET` | le secret du webhook |
| `KOINO_SIGN_CONVERSION_UTILISATEUR` | `CONVERSION_UTILISATEUR` de `/opt/koino-sign/.env` |
| `KOINO_SIGN_CONVERSION_MOT_DE_PASSE` | `CONVERSION_MOT_DE_PASSE` de `/opt/koino-sign/.env` |

Dès que ces variables existent, les nouveaux envois en signature partent par
KOINO SIGN ; les documents déjà envoyés par SignRequest continuent d'être suivis
par SignRequest jusqu'à leur signature.

## Exploitation

| Besoin | Commande (sur le serveur) |
| --- | --- |
| Mettre à jour (nouvelle image) | `sudo /opt/koino-sign/mettre-a-jour.sh` |
| Sauvegarder maintenant | `sudo /opt/koino-sign/sauvegarde.sh` |
| Journaux | `cd /opt/koino-sign && sudo docker compose logs -f sign` |
| Restaurer une sauvegarde | `gunzip -c sauvegardes/FICHIER.sql.gz \| sudo docker compose exec -T base psql -U koino_sign -d koino_sign` |

Copier régulièrement `/opt/koino-sign/sauvegardes` et `/opt/koino-sign/.env`
hors du serveur : sans `.env`, les documents chiffrés ne se relisent plus.

## Licence

KOINO SIGN est un fork de [Documenso](https://github.com/documenso/documenso),
sous licence AGPL-3.0 : le code source modifié est publié dans ce dépôt et
chaque page de l'application y renvoie (« Code source »). `packages/ee` reste
sous la licence Enterprise de Documenso et n'est pas utilisé.
