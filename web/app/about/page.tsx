import Link from 'next/link';
import MarketingPageShell from '@/components/marketing/MarketingPageShell';
import MarketingSiteChrome from '@/components/marketing/MarketingSiteChrome';

export const metadata = {
  title: 'Hakkımızda | Prolance',
  description:
    'Prolance, işveren ve freelancer arasında escrow korumalı güvenli iş birliği sunar.',
};

const stats = [
  { value: '10K+', label: 'Aktif kullanıcı' },
  { value: '%98', label: 'Memnuniyet oranı' },
  { value: '24/7', label: 'Escrow koruması' },
];

export default function AboutPage() {
  return (
    <MarketingSiteChrome>
      <MarketingPageShell
        eyebrow="Şirket"
        title="Hakkımızda"
        subtitle="Güvenli freelance iş birliği için buradayız."
      >
        <div className="prose prose-slate max-w-none">
          <p className="text-slate-500 text-base leading-relaxed mb-10">
            Prolance, işverenler ile serbest çalışanları escrow koruması altında
            buluşturan bir platformdur. Amacımız, her iki tarafın da adil ve
            şeffaf bir süreçte çalışmasını sağlamaktır.
          </p>

          <section className="mb-12">
            <h2 className="text-xl font-bold text-slate-800 mb-4 pb-2 border-b border-slate-100">
              Misyonumuz
            </h2>
            <p className="text-slate-600 leading-relaxed text-[15px]">
              Freelance ekonomisinde güven eksikliğini ortadan kaldırmak. Ödeme
              iş tamamlanana kadar güvende kalsın; iletişim ve teslimat tek bir
              yerde yönetilsin.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-xl font-bold text-slate-800 mb-4 pb-2 border-b border-slate-100">
              Escrow Odaklı Değer Önerisi
            </h2>
            <p className="text-slate-600 leading-relaxed text-[15px] mb-4">
              İşveren anlaşılan tutarı yatırır; freelancer güvenle çalışır. İş
              onaylandığında ödeme serbest bırakılır. Anlaşmazlıklarda tarafsız
              inceleme süreci devreye girer.
            </p>
            <ul className="text-slate-600 text-[15px] space-y-2 list-disc pl-5">
              <li>Platform içi mesajlaşma ve dosya paylaşımı</li>
              <li>Şeffaf teklif ve iş akışı</li>
              <li>Mock escrow — üretimde lisanslı PSP entegrasyonu planlanıyor</li>
            </ul>
          </section>

          <section className="mb-12">
            <h2 className="text-xl font-bold text-slate-800 mb-4 pb-2 border-b border-slate-100">
              Nasıl Çalışır?
            </h2>
            <ol className="text-slate-600 text-[15px] space-y-3 list-decimal pl-5">
              <li>İşveren iş ilanı oluşturur veya freelancer teklif verir.</li>
              <li>Taraflar anlaşır; ücret escrow hesabına alınır.</li>
              <li>Freelancer işi teslim eder; işveren onaylar.</li>
              <li>Ödeme freelancer hesabına aktarılır.</li>
            </ol>
            <p className="mt-4 text-sm">
              <Link href="/#how" className="text-indigo-600 font-medium hover:text-indigo-800">
                Detaylı süreç →
              </Link>
            </p>
          </section>

          <div className="grid sm:grid-cols-3 gap-4 mb-12">
            {stats.map((s) => (
              <div
                key={s.label}
                className="text-center p-6 rounded-2xl bg-slate-50 border border-slate-100"
              >
                <p className="text-2xl font-extrabold text-indigo-600 mb-1">{s.value}</p>
                <p className="text-slate-600 text-sm m-0">{s.label}</p>
              </div>
            ))}
          </div>

          <section className="mb-12">
            <h2 className="text-xl font-bold text-slate-800 mb-4 pb-2 border-b border-slate-100">
              Güvenlik
            </h2>
            <div className="p-5 bg-green-50 border border-green-100 rounded-2xl flex gap-4">
              <span className="text-2xl">🔒</span>
              <div>
                <p className="text-green-800 text-[15px] leading-relaxed m-0">
                  TLS 1.3 ile şifreli iletişim, AES-256 ile korunan veritabanı ve
                  Supabase Row Level Security (RLS) ile erişim kontrolü. Detaylar
                  için{' '}
                  <Link href="/privacy" className="text-indigo-600 underline font-medium">
                    Gizlilik Politikası
                  </Link>
                  .
                </p>
              </div>
            </div>
          </section>

          <section className="mb-12">
            <h2 className="text-xl font-bold text-slate-800 mb-4 pb-2 border-b border-slate-100">
              Şirket Bilgisi
            </h2>
            <p className="text-slate-600 text-[15px] leading-relaxed m-0">
              <strong className="text-slate-800">Prolance Teknoloji A.Ş.</strong>
              <br />
              İstanbul, Türkiye
            </p>
          </section>

          <div className="flex flex-wrap gap-4">
            <Link
              href="/login"
              className="inline-flex items-center px-6 py-3 rounded-xl bg-indigo-600 text-white font-semibold hover:bg-indigo-700 transition-colors no-underline"
            >
              Hemen Başla
            </Link>
            <Link
              href="/#features"
              className="inline-flex items-center px-6 py-3 rounded-xl border border-slate-200 text-slate-700 font-semibold hover:border-indigo-300 hover:text-indigo-600 transition-colors no-underline"
            >
              Özellikleri Keşfet
            </Link>
            <Link
              href="/#pricing"
              className="inline-flex items-center px-6 py-3 rounded-xl border border-slate-200 text-slate-700 font-semibold hover:border-indigo-300 hover:text-indigo-600 transition-colors no-underline"
            >
              Fiyatlandırma
            </Link>
          </div>
        </div>
      </MarketingPageShell>
    </MarketingSiteChrome>
  );
}
