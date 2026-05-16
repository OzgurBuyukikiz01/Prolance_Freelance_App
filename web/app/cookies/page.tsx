import LegalFooterNav from '@/components/marketing/LegalFooterNav';
import LegalSections, { type LegalSection } from '@/components/marketing/LegalSections';
import MarketingPageShell from '@/components/marketing/MarketingPageShell';
import MarketingSiteChrome from '@/components/marketing/MarketingSiteChrome';

export const metadata = {
  title: 'Çerez Politikası | Prolance',
  description: 'Prolance web sitesinde kullanılan çerezler ve benzeri teknolojiler hakkında bilgi.',
};

const sections: LegalSection[] = [
  {
    id: 'overview',
    title: '1. Genel Bakış',
    body: [
      'Bu Çerez Politikası, Prolance web sitesi ve portalında çerezler ile benzer depolama teknolojilerinin nasıl kullanıldığını açıklar.',
      'Zorunlu çerezler olmadan oturum açma ve güvenlik işlevleri çalışmaz. Opsiyonel çerezleri tarayıcı ayarlarınızdan yönetebilirsiniz.',
    ],
  },
  {
    id: 'types',
    title: '2. Kullanılan Çerez Türleri',
    body: [
      'Aşağıdaki tablo, Prolance’ta kullanılan veya planlanan çerez kategorilerini özetler:',
      '| Çerez / depolama | Amaç | Süre | Zorunlu |',
      '| sb-*-auth-token (Supabase) | Oturum ve kimlik doğrulama | Oturum / yenileme | Evet |',
      '| sb-*-auth-token-code-verifier | OAuth PKCE akışı | Kısa süreli | Evet |',
      '| prolance-consent | Çerez tercih kaydı (gelecek) | 12 ay | Hayır |',
      '| _ga / _gid (Google Analytics) | Şu an kullanılmıyor | — | Hayır |',
      'Pazarlama veya hedefleme amaçlı üçüncü taraf çerezleri kullanılmamaktadır.',
    ],
  },
  {
    id: 'required',
    title: '3. Zorunlu Çerezler',
    body: [
      'Kimlik doğrulama çerezleri Supabase Auth altyapısı tarafından ayarlanır. Giriş yaptığınızda oturumunuzun güvenli şekilde tanınması için gereklidir.',
      'Bu çerezler şifrelenmiş JWT belirteçleri içerir; Prolance parolanızı çerez içinde saklamaz.',
      'Zorunlu çerezleri devre dışı bırakırsanız portal ve yönetim paneline erişemezsiniz.',
    ],
  },
  {
    id: 'analytics',
    title: '4. Analitik Çerezler',
    body: [
      'Şu an için üçüncü taraf analitik çerezleri (Google Analytics, Mixpanel vb.) aktif olarak kullanılmamaktadır.',
      'Gelecekte anonim trafik ölçümü eklenirse bu politika güncellenecek ve — yasal gereklilikler dahilinde — onay mekanizması sunulacaktır.',
      'Sunucu günlükleri (IP, user-agent) güvenlik ve hata ayıklama amacıyla sınırlı süre saklanabilir; bu kayıtlar pazarlama profili oluşturmak için kullanılmaz.',
    ],
  },
  {
    id: 'marketing',
    title: '5. Pazarlama Çerezleri',
    body: [
      'Prolance, reklam ağları veya yeniden hedefleme (retargeting) amaçlı çerezler kullanmaz.',
      'Sosyal medya paylaşım düğmeleri üzerinden üçüncü taraf izleme yapılmaz.',
    ],
  },
  {
    id: 'manage',
    title: '6. Çerezleri Yönetme',
    body: [
      'Tarayıcınızın gizlilik veya çerez ayarlarından mevcut çerezleri silebilir veya engelleyebilirsiniz.',
      'Chrome: Ayarlar → Gizlilik ve güvenlik → Çerezler ve diğer site verileri',
      'Safari: Tercihler → Gizlilik → Web sitesi verilerini yönet',
      'Firefox: Ayarlar → Gizlilik ve Güvenlik → Çerezler ve Site Verileri',
      'Oturumu kapatmak için portal üzerindeki çıkış düğmesini kullanmanız önerilir; bu işlem auth çerezlerini geçersiz kılar.',
    ],
  },
  {
    id: 'storage',
    title: '7. localStorage ve Benzeri Depolama',
    body: [
      'Bazı arayüz tercihleri (ör. tema, son ziyaret edilen sayfa) tarayıcı localStorage alanında saklanabilir. Bu veriler kişisel kimlik bilgisi içermez.',
      'localStorage verilerini tarayıcı geliştirici araçları veya site verilerini temizleme seçeneği ile silebilirsiniz.',
    ],
  },
  {
    id: 'contact',
    title: '8. İletişim',
    body: [
      'Çerez politikası ile ilgili sorular: privacy@prolance.app',
      'Son güncelleme: 16 Mayıs 2026',
    ],
  },
];

export default function CookiesPage() {
  return (
    <MarketingSiteChrome>
    <MarketingPageShell
      eyebrow="Hukuki Bilgi"
      title="Çerez Politikası"
      subtitle={
        <>
          Son güncelleme:{' '}
          <span className="text-indigo-300 font-medium">16 Mayıs 2026</span>
        </>
      }
      footerNav={<LegalFooterNav current="cookies" />}
    >
      <LegalSections
        sections={sections}
        intro={
          <p className="text-slate-500 mb-10 text-base leading-relaxed">
            Prolance, yalnızca hizmet sunumu ve güvenlik için gerekli çerezleri
            kullanır. Bu sayfa hangi çerezlerin neden kullanıldığını ve nasıl
            yönetebileceğinizi açıklar.
          </p>
        }
        footer={
          <div className="mt-16 p-6 bg-indigo-50 rounded-2xl border border-indigo-100 text-center">
            <p className="text-indigo-700 font-medium mb-2">Sorularınız mı var?</p>
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
        }
      />
    </MarketingPageShell>
    </MarketingSiteChrome>
  );
}
