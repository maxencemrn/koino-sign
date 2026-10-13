import type { SVGAttributes } from 'react';

export type LogoProps = SVGAttributes<SVGSVGElement>;

/** KOINO SIGN : la marque K de Koïno (couleur du texte). */
export const BrandingLogoIcon = ({ ...props }: LogoProps) => {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="411 398 1194 1194" role="img" aria-label="KOINO SIGN" {...props}>
      <path
        fill="currentColor"
        d="M1262.81,1015.52c-9.67-12.36-10.47-29.54-1.99-42.75l343.01-561.11h-324.37l-328.14,539.18c-5.88,9.61-15.67,15.09-26.9,15.09-.14,0-.29,0-.44,0-11.42-.14-21.24-5.89-26.95-15.78l-268.4-464.96c-29.54-45.83-80.33-73.53-134.86-73.53h-82.09v1166.56h68.89c61.18,0,133.58-29.94,168.48-79.72l190.68-324.19c38.91-64.82,108.97-104.48,184.57-104.48h158.24l-293.35,508.38h715.25l-340.84-561.66-.76-1.04Z"
      />
    </svg>
  );
};
