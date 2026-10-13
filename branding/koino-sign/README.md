# Identité KOINO SIGN

- `koino-sign-logo.svg` : logo horizontal (marque K et « KOÏNO » en encre `#151106`, « SIGN » en violet Koïno `#6d00d7`), dessiné dans le même style géométrique que le logo Koïno.
- `koino-sign-logo-blanc.svg` : version pour fond sombre (« SIGN » en `#b9a6ff`).
- `koino-sign-icon.svg` : icône (K blanc sur carré violet), source des favicons.

Fichiers générés à partir de ces sources (sharp) :
`apps/remix/public/{favicon*,apple-touch-icon,android-chrome-*,opengraph-image}`,
`apps/remix/public/static/logo.png` (certificats et journaux d'audit PDF),
`packages/email/static/logo.png` (emails), `packages/assets/*`.
Le logo de l'interface est le composant `apps/remix/app/components/general/branding-logo.tsx`.
