export type FooterLink = {
  label: string;
  href: string;
};

export const FOOTER_LINK_GROUPS = {
  Ürün: [
    { label: 'Özellikler', href: '/#features' },
    { label: 'Nasıl Çalışır', href: '/#how' },
    { label: 'Fiyatlandırma', href: '/#pricing' },
  ],
  Şirket: [
    { label: 'Hakkımızda', href: '/about' },
    { label: 'Blog', href: '/blog' },
    { label: 'İletişim', href: '/contact' },
  ],
  Hukuk: [
    { label: 'Gizlilik Politikası', href: '/privacy' },
    { label: 'Kullanım Koşulları', href: '/terms' },
    { label: 'Çerez Politikası', href: '/cookies' },
  ],
} as const satisfies Record<string, readonly FooterLink[]>;

/** Social icons in footer use placeholder href until profiles are live. */
export const FOOTER_SOCIAL_PLACEHOLDER_HREFS = ['#'] as const;

export const FOOTER_STATIC_ROUTES = [
  '/about',
  '/blog',
  '/contact',
  '/cookies',
  '/privacy',
  '/terms',
  '/#features',
  '/#how',
  '/#pricing',
] as const;

export function getAllFooterNavLinks(): FooterLink[] {
  return Object.values(FOOTER_LINK_GROUPS).flatMap((group) => [...group]);
}

export function getAllFooterNavHrefs(): string[] {
  return getAllFooterNavLinks().map((link) => link.href);
}
