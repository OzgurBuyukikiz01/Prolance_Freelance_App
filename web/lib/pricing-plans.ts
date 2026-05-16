export type PricingPlan = {
  id: string;
  name: string;
  price: string;
  period: string;
  description: string;
  features: string[];
  highlighted?: boolean;
  cta: string;
};

export const PRICING_PLANS: PricingPlan[] = [
  {
    id: 'free',
    name: 'Ücretsiz',
    price: '₺0',
    period: '/ ay',
    description: 'Başlamak için ideal',
    features: ['3 aktif ilan', 'Temel escrow', 'Standart destek', 'Portal erişimi'],
    cta: 'Mevcut plan',
  },
  {
    id: 'pro',
    name: 'Pro',
    price: '₺299',
    period: '/ ay',
    description: 'Aktif freelancer ve işverenler için',
    features: [
      'Sınırsız ilan',
      'Öncelikli escrow',
      'Gelişmiş teklif yönetimi',
      'E-posta desteği',
      'Takvim ve milestone',
    ],
    highlighted: true,
    cta: 'Pro\'ya geç',
  },
  {
    id: 'business',
    name: 'İşletme',
    price: '₺799',
    period: '/ ay',
    description: 'Ekipler ve ajanslar için',
    features: [
      'Pro özelliklerinin tamamı',
      'Çoklu kullanıcı (yakında)',
      'Özel hesap yöneticisi',
      'SLA garantisi',
      'API erişimi (yakında)',
    ],
    cta: 'İletişime geç',
  },
];
