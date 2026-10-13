#!/usr/bin/env bash
# Sauvegarde la base de KOINO SIGN (documents compris) ; garde 14 jours.
set -euo pipefail
cd /opt/koino-sign
FICHIER="sauvegardes/koino-sign-$(date +%Y-%m-%d-%H%M).sql.gz"
docker compose exec -T base pg_dump -U koino_sign -d koino_sign --no-owner | gzip > "$FICHIER"
find sauvegardes -name 'koino-sign-*.sql.gz' -mtime +14 -delete
echo "$(date -Is) sauvegarde $FICHIER ($(du -h "$FICHIER" | cut -f1))"
