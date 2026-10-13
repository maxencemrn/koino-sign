import { NEXT_PUBLIC_WEBAPP_URL } from '@documenso/lib/constants/app';
import { i18n, type MessageDescriptor } from '@lingui/core';

export const appMetaTags = (title?: MessageDescriptor) => {
  const description =
    'KOINO SIGN, la plateforme de signature électronique de Koïno : devis, contrats et documents signés en ligne, en quelques clics.';

  return [
    {
      title: title ? `${i18n._(title)} - KOINO SIGN` : 'KOINO SIGN',
    },
    {
      name: 'description',
      content: description,
    },
    {
      name: 'keywords',
      content: 'KOINO SIGN, Koïno, signature électronique, signature de documents, devis, contrats',
    },
    {
      name: 'author',
      content: 'Koïno',
    },
    {
      name: 'robots',
      content: 'index, follow',
    },
    {
      property: 'og:title',
      content: 'KOINO SIGN, la signature électronique de Koïno',
    },
    {
      property: 'og:description',
      content: description,
    },
    {
      property: 'og:image',
      content: `${NEXT_PUBLIC_WEBAPP_URL()}/opengraph-image.jpg`,
    },
    {
      property: 'og:type',
      content: 'website',
    },
    {
      name: 'twitter:card',
      content: 'summary_large_image',
    },
    {
      name: 'twitter:site',
      content: '@koino',
    },
    {
      name: 'twitter:description',
      content: description,
    },
    {
      name: 'twitter:image',
      content: `${NEXT_PUBLIC_WEBAPP_URL()}/opengraph-image.jpg`,
    },
  ];
};
