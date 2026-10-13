#!/usr/bin/env bash
# Met KOINO SIGN à jour ; la base est sauvegardée d'abord, les migrations
# passent au redémarrage. Image publiée (ghcr.io) : on la retélécharge ; image
# construite sur le serveur : on récupère le code et on la reconstruit.
set -euo pipefail
cd /opt/koino-sign
./sauvegarde.sh
if grep -q '^IMAGE_KOINO_SIGN=koino-sign:local' .env && [ -f .depot ]; then
  DEPOT="$(cat .depot)"
  git -C "$DEPOT" pull --ff-only
  docker build -f "$DEPOT/docker/Dockerfile" -t koino-sign:local "$DEPOT"
else
  docker compose pull sign
fi
docker compose up -d sign
docker image prune -f >/dev/null
echo "KOINO SIGN mis à jour."
