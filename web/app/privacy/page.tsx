import Link from 'next/link';
import LegalFooterNav from '@/components/marketing/LegalFooterNav';
import LegalSections, { type LegalSection } from '@/components/marketing/LegalSections';
import MarketingPageShell from '@/components/marketing/MarketingPageShell';
import MarketingSiteChrome from '@/components/marketing/MarketingSiteChrome';

export const metadata = {
  title: 'Gizlilik Politikası | Prolance',
  description: 'Prolance olarak kişisel verilerinizi nasıl işlediğimizi öğrenin.',
};

const sections: LegalSection[] = [
  {
    id: 'controller',
    title: '1. Veri Sorumlusu',
    body: [
      'Veri Sorumlusu: Prolance Teknoloji A.Ş.',
      'Adres: Maslak Mah. Büyükdere Cad. No: 255, Sarıyer / İstanbul 34398, Türkiye',
      'İletişim: privacy@prolance.app',
      'Prolance, 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında veri sorumlusu sıfatıyla hareket eder.',
    ],
  },
  {
    id: 'collected',
    title: '2. Toplanan Veriler',
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
    title: '3. Verilerin Kullanımı',
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
    title: '4. Veri Saklama',
    body: [
      'Kişisel verileriniz, hesabınız aktif olduğu sürece ve yasal saklama yükümlülükleri kapsamında tutulur.',
      'Hesabınızı kapattığınızda, kişisel verileriniz 30 gün içinde silinir; ancak yasal yükümlülükler gereği bazı kayıtlar (fatura, escrow geçmişi) zorunlu saklama süreleri boyunca arşivlenebilir.',
      'Mesajlaşma içerikleri ve dosyalar, son iletişimden itibaren 12 ay içinde otomatik olarak anonimleştirilir.',
    ],
  },
  {
    id: 'rights',
    title: '5. Haklarınız',
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
    title: '6. Çerezler',
    body: [
      'Prolance web sitesi oturum yönetimi ve kullanıcı deneyimini iyileştirme amacıyla çerezler kullanır.',
      '• Zorunlu çerezler: Kimlik doğrulama ve güvenlik (oturumu kapatmadan kaldırılamaz)',
      '• Analitik çerezler: Anonim trafik istatistikleri (opsiyonel; tarayıcınızdan devre dışı bırakabilirsiniz)',
      '• Pazarlama çerezleri: Kullanılmamaktadır',
      'Detaylı bilgi için Çerez Politikası sayfamıza bakınız.',
    ],
  },
  {
    id: 'contact',
    title: '7. İletişim',
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
    <MarketingSiteChrome>
    <MarketingPageShell
      eyebrow="Hukuki Bilgi"
      title="Gizlilik Politikası"
      subtitle={
        <>
          Son güncelleme:{' '}
          <span className="text-indigo-300 font-medium">16 Mayıs 2026</span>
        </>
      }
      footerNav={<LegalFooterNav current="privacy" />}
    >
      <LegalSections
        sections={sections}
        intro={
          <p className="text-slate-500 mb-10 text-base leading-relaxed">
            Prolance olarak kişisel gizliliğinize büyük önem veriyoruz. Bu politika,
            hangi verileri topladığımızı, nasıl kullandığımızı ve haklarınızı
            açıklamaktadır.
          </p>
        }
        highlight={
          <div className="mb-10 p-5 bg-green-50 border border-green-100 rounded-2xl flex gap-4">
            <span className="text-2xl">🔒</span>
            <div>
              <p className="font-semibold text-green-800 mb-1">Verileriniz güvende</p>
              <p className="text-green-700 text-sm leading-relaxed">
                Tüm iletişimler TLS 1.3 üzerinden şifrelenir. Veritabanı verileri
                AES-256 ile korunur. Erişim kontrolü Supabase Row Level Security
                (RLS) ile sağlanır.
              </p>
            </div>
          </div>
        }
        footer={
          <>
            <p className="text-slate-600 text-sm mb-6 -mt-4">
              Çerez kullanımı hakkında ayrıntılı bilgi için{' '}
              <Link
                href="/cookies"
                className="text-indigo-600 underline hover:text-indigo-800 font-medium"
              >
                Çerez Politikası
              </Link>{' '}
              sayfamızı ziyaret edin.
            </p>
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
          </>
        }
      />
    </MarketingPageShell>
    </MarketingSiteChrome>
  );
}
