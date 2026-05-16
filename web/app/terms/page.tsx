import LegalFooterNav from '@/components/marketing/LegalFooterNav';
import LegalSections, { type LegalSection } from '@/components/marketing/LegalSections';
import MarketingPageShell from '@/components/marketing/MarketingPageShell';
import MarketingSiteChrome from '@/components/marketing/MarketingSiteChrome';

export const metadata = {
  title: 'Kullanım Koşulları | Prolance',
  description: 'Prolance platformunu kullanmadan önce lütfen Kullanım Koşullarımızı okuyun.',
};

const sections: LegalSection[] = [
  {
    id: 'general',
    title: '1. Genel Hükümler',
    body: [
      'Bu Kullanım Koşulları ("Koşullar"), Prolance uygulaması ve web sitesi ("Platform") üzerinden sunulan hizmetleri düzenler. Platformu kullanarak bu Koşulları kabul etmiş sayılırsınız.',
      'Prolance, işverenler ile serbest çalışanları (freelancer) bir araya getiren bir aracı platform hizmetidir. Prolance, taraflar arasındaki iş ilişkisinin bir parçası değildir.',
      '18 yaşın altındaki bireyler Platformu kullanamaz. Bir kurum adına kaydoluyorsanız, ilgili kurumu temsil etmeye yetkili olduğunuzu beyan etmiş sayılırsınız.',
    ],
  },
  {
    id: 'account',
    title: '2. Hesap ve Güvenlik',
    body: [
      'Kayıt sırasında doğru ve güncel bilgi sağlamanız zorunludur. Yanlış bilgi nedeniyle oluşan zararlardan Prolance sorumlu tutulamaz.',
      'Hesap güvenliğiniz sizin sorumluluğunuzdadır. Şifrenizi kimseyle paylaşmayınız. Hesabınızın yetkisiz kullanımını fark ettiğinizde derhal bize bildirmelisiniz.',
      'Hesabınızı başkasına devredemez veya satamaz, başka bir kullanıcının kimliğini taklit edemezsiniz.',
    ],
  },
  {
    id: 'escrow',
    title: '3. Escrow & Ödeme',
    body: [
      'Prolance, işverenler ve freelancerlar arasındaki anlaşmazlıkları azaltmak amacıyla bir escrow mekanizması sunar. İşveren, anlaşılan ücreti Prolance escrow hesabına yatırır; iş tamamlandığında veya her iki taraf onay verdiğinde ödeme serbest bırakılır.',
      'Escrow ödemeleri mock (simülasyon) aşamasındadır. Üretim ortamında lisanslı ödeme hizmet sağlayıcıları (PSP) üzerinden gerçekleştirilecektir.',
      'Anlaşmazlık durumunda Prolance yönetim ekibi durumu inceleyerek bağlayıcı bir karar verebilir. Bu süreç, her iki tarafın bilgi sunmasına olanak tanır.',
      'Platform komisyonu (platform fee) aktif abonelik planına göre değişebilir. Güncel komisyon oranları Fiyatlandırma sayfasında yer almaktadır.',
    ],
  },
  {
    id: 'prohibited',
    title: '4. Yasaklı İçerik ve Davranışlar',
    body: [
      'Aşağıdaki eylemler kesinlikle yasaktır ve hesabınızın kalıcı olarak kapatılmasına yol açabilir:',
      '• Platform dışı ödeme yapmak veya almak amacıyla anlaşmak',
      '• Sahte değerlendirme veya yorum oluşturmak',
      '• İzinsiz ticari mesaj (spam) göndermek',
      '• Yasa dışı, müstehcen veya nefret içerikli materyalleri paylaşmak',
      '• Başka bir kullanıcının kişisel verilerini izinsiz toplamak veya kullanmak',
    ],
  },
  {
    id: 'ip',
    title: '5. Fikri Mülkiyet',
    body: [
      'Platforma yüklediğiniz tüm içerik (portföy, proje çıktıları, mesajlar) üzerindeki haklar size aittir. Prolance, bu içerikleri yalnızca hizmet sunumu kapsamında kullanır.',
      'Teslim edilen iş çıktısının telif haklarının devri, işveren ile freelancer arasında imzalanan sözleşmeye tabidir. Prolance bu devrin tarafı değildir.',
      "Prolance markası, logosu ve tasarımları Prolance'ın mülkiyetindedir; izinsiz kullanılamaz.",
    ],
  },
  {
    id: 'liability',
    title: '6. Sorumluluk Sınırı',
    body: [
      'Prolance, kullanıcılar arasındaki işlemlerden, teslim edilen çıktıların kalitesinden veya üçüncü taraf hizmet sağlayıcılardan kaynaklanan zararlardan sorumlu değildir.',
      'Platformun kesintisiz veya hatasız çalışacağı garanti edilmez. Bakım, güvenlik yamaları veya mücbir sebepler nedeniyle hizmet geçici olarak kesilebilir.',
      "Yasal azami sınırlar dahilinde, Prolance'ın herhangi bir kullanıcıya karşı toplam yükümlülüğü, son 12 ayda kullanıcının ödediği platform ücretiyle sınırlıdır.",
    ],
  },
  {
    id: 'changes',
    title: '7. Değişiklikler',
    body: [
      'Bu Koşulları zaman zaman güncelleyebiliriz. Önemli değişiklikler e-posta veya platform bildirimi aracılığıyla duyurulur.',
      'Değişiklik sonrasında Platformu kullanmaya devam etmeniz, güncellenmiş Koşulları kabul ettiğiniz anlamına gelir.',
      'Son güncelleme tarihi: 16 Mayıs 2026',
    ],
  },
];

export default function TermsPage() {
  return (
    <MarketingSiteChrome>
    <MarketingPageShell
      eyebrow="Hukuki Bilgi"
      title="Kullanım Koşulları"
      subtitle={
        <>
          Son güncelleme:{' '}
          <span className="text-indigo-300 font-medium">16 Mayıs 2026</span>
        </>
      }
      footerNav={<LegalFooterNav current="terms" />}
    >
      <LegalSections
        sections={sections}
        intro={
          <p className="text-slate-500 mb-10 text-base leading-relaxed">
            Prolance platformunu kullanmadan önce lütfen aşağıdaki kullanım
            koşullarını dikkatlice okuyunuz. Platforma erişerek veya hesap
            oluşturarak bu koşulları kabul etmiş sayılırsınız.
          </p>
        }
        footer={
          <div className="mt-16 p-6 bg-indigo-50 rounded-2xl border border-indigo-100 text-center">
            <p className="text-indigo-700 font-medium mb-2">Sorularınız mı var?</p>
            <p className="text-slate-600 text-sm">
              Bize{' '}
              <a
                href="mailto:legal@prolance.app"
                className="text-indigo-600 underline hover:text-indigo-800"
              >
                legal@prolance.app
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
