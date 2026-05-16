import Link from 'next/link';

export const metadata = {
  title: 'Gizlilik Politikası | Prolance',
  description: 'Prolance olarak kişisel verilerinizi nasıl işlediğimizi öğrenin.',
};

const sections = [
  {
    id: 'collected',
    title: '1. Toplanan Veriler',
    body: [
      'Prolance, hizmet sunumu ve güvenlik amacıyla aşağıdaki kişisel verileri işler:',
      '• Kimlik bilgileri: Ad, soyad, e-posta adresi, profil fotoğrafı',
      '• Hesap bilgileri: Şifrelenmiş parola, oturum belirteçleri (JWT)',
      '• Mesajlaşma verileri: Konuşmalar ve paylaşılan dosyalar (TLS + AES-256 ile şifrelenir)',
      '• Kullanım verileri: IP adresi, cihaz tipi, sayfa görüntüleme istatistikleri',
      '• Ödeme verileri: Escrow işlem geçmişi (kart bilgisi Prolance tarafından saklanmaz; PSP tarafından işlenir)',
    ],
  },
  {
    id: 'usage',
    title: '2. Verilerin Kullanımı',
    body: [
      'Toplanan veriler aşağıdaki amaçlarla kullanılır:',
      '• Hesap oluşturma ve kimlik doğrulama',
      '• İş ilanlarının ve tekliflerin yönetimi',
      '• Escrow ve ödeme işlemlerinin gerçekleştirilmesi',
      '• Destek taleplerinizin karşılanması',
      '• Platform güvenliğinin sağlanması ve dolandırıcılığın önlenmesi',
      '• Yasal yükümlülüklerin yerine getirilmesi',
      'Verileriniz üçüncü taraflarla asla satılmaz. Veriler yalnızca hizmet altyapısı sağlayıcılarla (Supabase/AWS) veri işleme sözleşmesi kapsamında paylaşılabilir.',
    ],
  },
  {
    id: 'storage',
    title: '3. Veri Saklama',
    body: [
      'Kişisel verileriniz, hesabınız aktif olduğu sürece ve yasal saklama yükümlülükleri kapsamında tutulur.',
      'Hesabınızı kapattığınızda, kişisel verileriniz 30 gün içinde silinir; ancak yasal yükümlülükler gereği bazı kayıtlar (fatura, escrow geçmişi) zorunlu saklama süreleri boyunca arşivlenebilir.',
      'Mesajlaşma içerikleri ve dosyalar, son iletişimden itibaren 12 ay içinde otomatik olarak anonimleştirilir.',
    ],
  },
  {
    id: 'rights',
    title: '4. Haklarınız',
    body: [
      'KVKK ve GDPR kapsamında aşağıdaki haklara sahipsiniz:',
      '• Erişim hakkı: İşlenen kişisel verilerinize erişim talep edebilirsiniz.',
      '• Düzeltme hakkı: Yanlış veya eksik verilerin güncellenmesini isteyebilirsiniz.',
      '• Silme hakkı ("unutulma hakkı"): Belirli koşullar altında verilerinizin silinmesini talep edebilirsiniz.',
      '• İtiraz hakkı: Meşru menfaat gerekçesiyle gerçekleştirilen işlemlere itiraz edebilirsiniz.',
      '• Taşınabilirlik hakkı: Verilerinizin makine tarafından okunabilir bir formatta iletilmesini talep edebilirsiniz.',
      'Bu haklarınızı kullanmak için privacy@prolance.app adresine yazabilirsiniz.',
    ],
  },
  {
    id: 'cookies',
    title: '5. Çerezler',
    body: [
      'Prolance web sitesi oturum yönetimi ve kullanıcı deneyimini iyileştirme amacıyla çerezler kullanır.',
      '• Zorunlu çerezler: Kimlik doğrulama ve güvenlik (oturumu kapatmadan kaldırılamaz)',
      '• Analitik çerezler: Anonim trafik istatistikleri (opsiyonel; tarayıcınızdan devre dışı bırakabilirsiniz)',
      '• Pazarlama çerezleri: Kullanılmamaktadır',
    ],
  },
  {
    id: 'contact',
    title: '6. İletişim',
    body: [
      'Gizlilik ile ilgili sorularınız için: privacy@prolance.app',
      'Yasal bildirimler için: legal@prolance.app',
      'Posta adresi: Prolance Teknoloji A.Ş., İstanbul, Türkiye',
      'Son güncelleme: 16 Mayıs 2026',
    ],
  },
];

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-white">
      {/* Header */}
      <div className="bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 py-20 px-4">
        <div className="max-w-3xl mx-auto text-center">
          <p className="text-indigo-400 font-semibold text-sm tracking-widest uppercase mb-3">
            Hukuki Bilgi
          </p>
          <h1 className="text-4xl font-extrabold text-white mb-4">
            Gizlilik Politikası
          </h1>
          <p className="text-slate-300 text-lg">
            Son güncelleme:{' '}
            <span className="text-indigo-300 font-medium">16 Mayıs 2026</span>
          </p>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-3xl mx-auto px-4 py-14">
        <div className="prose prose-slate max-w-none">
          <p className="text-slate-500 mb-10 text-base leading-relaxed">
            Prolance olarak kişisel gizliliğinize büyük önem veriyoruz. Bu
            politika, hangi verileri topladığımızı, nasıl kullandığımızı ve
            haklarınızı açıklamaktadır.
          </p>

          {/* Security highlight */}
          <div className="mb-10 p-5 bg-green-50 border border-green-100 rounded-2xl flex gap-4">
            <span className="text-2xl">🔒</span>
            <div>
              <p className="font-semibold text-green-800 mb-1">
                Verileriniz güvende
              </p>
              <p className="text-green-700 text-sm leading-relaxed">
                Tüm iletişimler TLS 1.3 üzerinden şifrelenir. Veritabanı verileri
                AES-256 ile korunur. Erişim kontrolü Supabase Row Level Security
                (RLS) ile sağlanır.
              </p>
            </div>
          </div>

          <nav className="mb-12 p-6 bg-slate-50 rounded-2xl border border-slate-100">
            <p className="font-semibold text-slate-700 mb-3 text-sm uppercase tracking-wide">
              İçindekiler
            </p>
            <ul className="space-y-2">
              {sections.map((s) => (
                <li key={s.id}>
                  <a
                    href={`#${s.id}`}
                    className="text-indigo-600 hover:text-indigo-800 text-sm font-medium transition-colors"
                  >
                    {s.title}
                  </a>
                </li>
              ))}
            </ul>
          </nav>

          {sections.map((s) => (
            <section key={s.id} id={s.id} className="mb-12 scroll-mt-8">
              <h2 className="text-xl font-bold text-slate-800 mb-4 pb-2 border-b border-slate-100">
                {s.title}
              </h2>
              <div className="space-y-4">
                {s.body.map((para, i) => (
                  <p key={i} className="text-slate-600 leading-relaxed text-[15px]">
                    {para}
                  </p>
                ))}
              </div>
            </section>
          ))}

          <div className="mt-16 p-6 bg-indigo-50 rounded-2xl border border-indigo-100 text-center">
            <p className="text-indigo-700 font-medium mb-2">
              Gizlilik ile ilgili sorularınız mı var?
            </p>
            <p className="text-slate-600 text-sm">
              Bize{' '}
              <a
                href="mailto:privacy@prolance.app"
                className="text-indigo-600 underline hover:text-indigo-800"
              >
                privacy@prolance.app
              </a>{' '}
              adresinden ulaşabilirsiniz.
            </p>
          </div>
        </div>

        <div className="mt-12 flex items-center justify-between text-sm text-slate-400 border-t border-slate-100 pt-8">
          <Link href="/" className="hover:text-indigo-600 transition-colors">
            ← Ana Sayfaya Dön
          </Link>
          <Link href="/terms" className="hover:text-indigo-600 transition-colors">
            Kullanım Koşulları →
          </Link>
        </div>
      </div>
    </main>
  );
}
