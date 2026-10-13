/**
 * KOINO SIGN est une version modifiée de Documenso, sous licence AGPL-3.0 :
 * l'article 13 de la licence impose d'offrir le code source à toute personne
 * qui utilise le service en ligne. Cette mention le fait sur chaque page.
 */
export const SourceCodeNotice = () => {
  return (
    <p className="py-4 text-center text-muted-foreground/70 text-xs print:hidden">
      KOINO SIGN, basé sur{' '}
      <a
        href="https://github.com/documenso/documenso"
        target="_blank"
        rel="noopener noreferrer"
        className="underline-offset-2 hover:underline"
      >
        Documenso
      </a>{' '}
      (AGPL-3.0) ·{' '}
      <a
        href="https://github.com/maxencemrn/koino-sign"
        target="_blank"
        rel="noopener noreferrer"
        className="underline-offset-2 hover:underline"
      >
        Code source
      </a>
    </p>
  );
};
