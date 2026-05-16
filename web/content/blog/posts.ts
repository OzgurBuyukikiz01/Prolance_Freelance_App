export type BlogPost = {
  slug: string;
  title: string;
  excerpt: string;
  publishedAt: string;
  author: string;
  tags: string[];
  body: string[];
};

export const blogPosts: BlogPost[] = [
  {
    slug: 'escrow-ile-guvenli-odeme',
    title: 'Escrow ile Güvenli Ödeme: Freelancer ve İşveren İçin Rehber',
    excerpt:
      'Prolance escrow modeli, ödemenin iş tamamlanana kadar güvende kalmasını sağlar. Süreç nasıl işler, taraflar ne zaman ödeme alır?',
    publishedAt: '2026-05-10',
    author: 'Prolance Ekibi',
    tags: ['escrow', 'güvenlik', 'ödeme'],
    body: [
      'Serbest çalışma dünyasında en büyük endişelerden biri ödeme güvenliğidir. İşveren, iş bitmeden parayı riske atmak istemez; freelancer ise emeğinin karşılığını alamama korkusu yaşar. Escrow (emanet) mekanizması bu iki tarafı da korur.',
      'Prolance’ta işveren, anlaşılan tutarı platform escrow hesabına yatırır. Freelancer işe başlar ve kilometre taşlarını tamamlar. Her iki taraf onay verdiğinde veya anlaşmazlık çözüldüğünde ödeme serbest bırakılır.',
      'Anlaşmazlık durumunda Prolance destek ekibi her iki tarafın kanıtlarını inceler. Mesaj geçmişi, teslim dosyaları ve iş tanımı bu süreçte kritik öneme sahiptir. Bu nedenle tüm iletişimi platform üzerinden sürdürmenizi öneririz.',
      'Escrow ödemeleri şu an simülasyon aşamasındadır; üretim ortamında lisanslı ödeme kuruluşları (PSP) ile entegre edilecektir. Güncellemeler blog ve duyurular üzerinden paylaşılacaktır.',
    ],
  },
  {
    slug: 'freelancer-verimlilik-ipuclari',
    title: 'Freelancer Verimlilik İpuçları: Daha Az Stres, Daha Çok Teslim',
    excerpt:
      'Uzaktan çalışırken odaklanmayı korumak, müşteri beklentilerini yönetmek ve escrow süreçlerine hazırlıklı olmak için pratik öneriler.',
    publishedAt: '2026-05-05',
    author: 'Ayşe Kaya',
    tags: ['freelancer', 'verimlilik', 'ipuçları'],
    body: [
      'Freelancer olarak gününüzü bloklara ayırın: sabah derin çalışma, öğleden sonra iletişim ve revizyon. Tek bir “her şey” listesi yerine proje bazlı mini listeler kullanın.',
      'Müşteriyle iş kapsamını yazılı netleştirin. Prolance teklif ve mesajlaşma alanı bu kayıtları saklar; belirsizlik anlaşmazlık riskini artırır.',
      'Escrow’a alınan işlerde teslim tarihlerini gerçekçi verin. Erken teslim güven oluşturur; gecikme durumunda müşteriyi önceden bilgilendirin.',
      'Portföyünüzü güncel tutun ve tamamlanan işlerden kısa vaka özetleri ekleyin. İşverenler karar verirken somut örnekler arar.',
    ],
  },
  {
    slug: 'prolance-platform-guncellemesi-mayis-2026',
    title: 'Prolance Platform Güncellemesi — Mayıs 2026',
    excerpt:
      'Portal deneyimi, bildirimler ve güvenlik iyileştirmeleri. Bu ay neler değişti?',
    publishedAt: '2026-05-01',
    author: 'Prolance Ürün',
    tags: ['güncelleme', 'platform', 'duyuru'],
    body: [
      'Mayıs 2026 güncellemesiyle portal ana sayfası yenilendi: aktif işler, bekleyen teklifler ve escrow durumu tek bakışta görülebilir.',
      'Bildirim merkezi gerçek zamanlı güncellemeleri destekliyor; yeni mesaj, teklif ve escrow olayları için anlık uyarılar alabilirsiniz.',
      'Güvenlik tarafında oturum yönetimi Supabase Auth ile güçlendirildi; tüm API istekleri JWT doğrulamasından geçiyor. Veritabanı erişimi Row Level Security (RLS) ile kısıtlanmış durumda.',
      'Önümüzdeki sprintlerde gerçek ödeme entegrasyonu ve gelişmiş anlaşmazlık akışı üzerinde çalışıyoruz. Geri bildirimleriniz için support@prolance.app adresine yazabilirsiniz.',
    ],
  },
];

export function getPostBySlug(slug: string): BlogPost | undefined {
  return blogPosts.find((p) => p.slug === slug);
}

export function getRelatedPosts(post: BlogPost, limit = 2): BlogPost[] {
  const scored = blogPosts
    .filter((p) => p.slug !== post.slug)
    .map((p) => ({
      post: p,
      score: p.tags.filter((t) => post.tags.includes(t)).length,
    }))
    .sort((a, b) => b.score - a.score || b.post.publishedAt.localeCompare(a.post.publishedAt));

  return scored.slice(0, limit).map((s) => s.post);
}

export function formatBlogDate(iso: string): string {
  return new Date(iso).toLocaleDateString('tr-TR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
}
