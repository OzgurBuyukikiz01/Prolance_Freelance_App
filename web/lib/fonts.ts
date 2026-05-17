import { Plus_Jakarta_Sans } from 'next/font/google';

/** Primary UI font — latin-ext covers Turkish (ğ, ş, ı, İ, ö, ü, ç). */
export const fontSans = Plus_Jakarta_Sans({
  subsets: ['latin', 'latin-ext'],
  variable: '--font-sans',
  display: 'swap',
  adjustFontFallback: true,
  weight: ['400', '500', '600', '700', '800'],
});
