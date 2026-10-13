#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Installe KOINO SIGN sur un serveur Ubuntu/Debian neuf. À lancer en root :
#   sudo bash installer.sh
# Ce que fait le script :
#   1. installe Docker s'il manque ;
#   2. copie la pile dans /opt/koino-sign ;
#   3. crée .env : secrets générés sur place, certificat de signature .p12,
#      clé Resend demandée (jamais affichée) ;
#   4. démarre la pile (HTTPS automatique) ;
#   5. programme la sauvegarde quotidienne de la base.
# Relançable : un .env existant n'est jamais écrasé.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

ICI="$(cd "$(dirname "$0")" && pwd)"
DOSSIER=/opt/koino-sign

[ "$(id -u)" -eq 0 ] || { echo "À lancer en root : sudo bash installer.sh"; exit 1; }

echo "1/5 · Docker"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi
docker compose version >/dev/null

echo "2/5 · Fichiers dans $DOSSIER"
mkdir -p "$DOSSIER/sauvegardes"
for f in docker-compose.yml Caddyfile sauvegarde.sh mettre-a-jour.sh rendre-admin.sh; do
  install -m 0644 "$ICI/$f" "$DOSSIER/$f"
done
chmod +x "$DOSSIER"/*.sh
cd "$DOSSIER"

echo "3/5 · Configuration (.env)"
if [ -f .env ]; then
  echo "    .env existe déjà : conservé."
else
  read -rp "    Domaine de KOINO SIGN [sign.koino.fr] : " DOMAINE
  DOMAINE="${DOMAINE:-sign.koino.fr}"
  read -rp "    Adresse d'envoi des emails [sign@koino.fr] : " EMAIL_EXPEDITEUR
  EMAIL_EXPEDITEUR="${EMAIL_EXPEDITEUR:-sign@koino.fr}"
  read -rsp "    Clé API Resend (domaine koino.fr vérifié) : " RESEND_API_KEY; echo
  [ -n "$RESEND_API_KEY" ] || { echo "Clé Resend requise."; exit 1; }

  secret() { openssl rand -hex "$1"; }
  SIGNATURE_PHRASE="$(secret 24)"
  # le cachet des PDF signés : certificat auto-signé « KOINO SIGN », 10 ans
  TMP="$(mktemp -d)"
  openssl genrsa -out "$TMP/cle.pem" 3072 2>/dev/null
  openssl req -new -x509 -key "$TMP/cle.pem" -out "$TMP/cert.pem" -days 3650 \
    -subj "/C=FR/L=Paris/O=Koino SAS/CN=KOINO SIGN" 2>/dev/null
  openssl pkcs12 -export -out "$TMP/cert.p12" -inkey "$TMP/cle.pem" -in "$TMP/cert.pem" \
    -name "KOINO SIGN" -passout "pass:$SIGNATURE_PHRASE"
  SIGNATURE_CERTIFICAT_BASE64="$(base64 -w0 "$TMP/cert.p12")"
  rm -rf "$TMP"

  umask 077
  cat > .env <<ENV
# KOINO SIGN — généré par installer.sh le $(date -u +%Y-%m-%dT%H:%MZ). NE PAS PARTAGER.
DOMAINE=$DOMAINE
EMAIL_EXPEDITEUR=$EMAIL_EXPEDITEUR
EMAIL_SUPPORT=contact@koino.fr
DOMAINES_AUTORISES=koino.fr
RESEND_API_KEY=$RESEND_API_KEY
NEXTAUTH_SECRET=$(secret 32)
NEXT_PRIVATE_ENCRYPTION_KEY=$(secret 32)
NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY=$(secret 32)
POSTGRES_PASSWORD=$(secret 24)
CONVERSION_UTILISATEUR=koino
CONVERSION_MOT_DE_PASSE=$(secret 24)
SIGNATURE_PHRASE=$SIGNATURE_PHRASE
SIGNATURE_CERTIFICAT_BASE64=$SIGNATURE_CERTIFICAT_BASE64
ENV
  chmod 600 .env
  echo "    .env créé (droits 600)."
fi

echo "4/5 · Image et démarrage"
# l'image publiée par GitHub Actions ; à défaut, construite ici depuis le dépôt
if grep -q '^IMAGE_KOINO_SIGN=koino-sign:local' .env && docker image inspect koino-sign:local >/dev/null 2>&1; then
  echo "    Image déjà construite sur ce serveur : conservée (mise à jour : mettre-a-jour.sh)."
elif ! docker compose pull sign 2>/dev/null; then
  echo "    Image ghcr.io indisponible : construction sur ce serveur (15 à 30 min)."
  RACINE="$(cd "$ICI/../.." && pwd)"
  # la construction demande de la mémoire : 4 Go de swap si le serveur en manque
  if [ "$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)" -lt 7000 ] && ! swapon --show | grep -q /swapfile-koino; then
    fallocate -l 4G /swapfile-koino && chmod 600 /swapfile-koino && mkswap /swapfile-koino >/dev/null && swapon /swapfile-koino
  fi
  docker build -f "$RACINE/docker/Dockerfile" -t koino-sign:local "$RACINE"
  grep -q '^IMAGE_KOINO_SIGN=' .env || echo "IMAGE_KOINO_SIGN=koino-sign:local" >> .env
  echo "$RACINE" > .depot
fi
docker compose pull caddy base conversion
docker compose up -d
DOMAINE="$(grep '^DOMAINE=' .env | cut -d= -f2-)"
for i in $(seq 1 60); do
  if curl -fsS -o /dev/null "https://$DOMAINE/signin" 2>/dev/null; then
    echo "    KOINO SIGN répond sur https://$DOMAINE"; break
  fi
  [ "$i" -eq 60 ] && echo "    Pas encore de réponse en HTTPS : le DNS de $DOMAINE pointe-t-il bien sur ce serveur ? (docker compose logs caddy sign)"
  sleep 5
done

echo "5/5 · Sauvegarde quotidienne (3 h 30)"
echo "30 3 * * * root $DOSSIER/sauvegarde.sh >> $DOSSIER/sauvegardes/journal.log 2>&1" > /etc/cron.d/koino-sign
chmod 644 /etc/cron.d/koino-sign

cat <<FIN

KOINO SIGN est installé dans $DOSSIER.
Suite (voir README.md) :
  1. Ouvre https://$DOMAINE et crée ton compte (adresse @koino.fr).
  2. Rends-le administrateur :  sudo $DOSSIER/rendre-admin.sh ton.email@koino.fr
  3. Dans KOINO SIGN : équipe Koïno → Réglages → Jetons d'API (pour l'outil Koïno)
     et Webhooks (https://admin.koino.fr/api/signature/webhook).
  4. Pour l'outil Koïno, le convertisseur : https://$DOMAINE/convertisseur
     identifiant et mot de passe : lignes CONVERSION_* de $DOSSIER/.env
FIN
