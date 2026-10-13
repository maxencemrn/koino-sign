#!/usr/bin/env bash
# Donne le rôle administrateur de KOINO SIGN à un compte existant.
#   sudo /opt/koino-sign/rendre-admin.sh prenom.nom@koino.fr
set -euo pipefail
EMAIL="${1:?usage : rendre-admin.sh email}"
case "$EMAIL" in *"'"*) echo "adresse invalide"; exit 1;; esac
cd /opt/koino-sign
docker compose exec -T base psql -U koino_sign -d koino_sign -v ON_ERROR_STOP=1 \
  -c "UPDATE \"User\" SET roles = ARRAY['ADMIN','USER']::\"Role\"[] WHERE lower(email) = lower('$EMAIL');"
