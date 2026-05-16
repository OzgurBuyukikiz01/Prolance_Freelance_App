import Link from 'next/link';
import MarketingPageShell from '@/components/marketing/MarketingPageShell';
import MarketingSiteChrome from '@/components/marketing/MarketingSiteChrome';
import ContactForm from './ContactForm';

export const metadata = {
  title: 'İletişim | Prolance',
  description: 'Prolance destek, gizlilik ve yasal iletişim kanalları.',
};

const emails = [
  {
    label: 'Genel Destek',
    address: 'support@prolance.app',
    description: 'Teknik sorular, hesap ve platform desteği',
  },
  {
    label: 'Gizlilik',
    address: 'privacy@prolance.app',
    description: 'KVKK, veri talepleri ve gizlilik soruları',
  },
  {
    label: 'Yasal',
    address: 'legal@prolance.app',
    description: 'Sözleşmeler ve resmi bildirimler',
  },
];

export default function ContactPage() {
  return (
    <MarketingSiteChrome>
      <MarketingPageShell
        eyebrow="Şirket"
        title="İletişim"
        subtitle="Size yardımcı olmaktan memnuniyet duyarız."
      >
        <div className="prose prose-slate max-w-none">
          <div className="grid sm:grid-cols-3 gap-4 mb-12">
            {emails.map((item) => (
              <a
                key={item.address}
                href={`mailto:${item.address}`}
                className="block p-5 rounded-2xl border border-slate-100 bg-slate-50 hover:border-indigo-200 hover:bg-indigo-50/50 transition-colors no-underline"
              >
                <p className="text-sm font-semibold text-slate-800 mb-1">{item.label}</p>
                <p className="text-indigo-600 text-sm font-medium mb-2">{item.address}</p>
                <p className="text-slate-500 text-xs leading-relaxed m-0">{item.description}</p>
              </a>
            ))}
          </div>

          <div className="mb-12 p-6 rounded-2xl border border-slate-100 bg-white">
            <h2 className="text-lg font-bold text-slate-800 mb-2">Posta Adresi</h2>
            <p className="text-slate-600 text-[15px] leading-relaxed m-0">
              Prolance Teknoloji A.Ş.
              <br />
              Maslak Mah. Büyükdere Cad. No: 255
              <br />
              Sarıyer / İstanbul 34398, Türkiye
            </p>
          </div>

          <div className="mb-12 p-5 rounded-2xl border border-indigo-100 bg-indigo-50/80">
            <p className="text-indigo-900 text-sm font-semibold m-0 mb-1">Yanıt süresi</p>
            <p className="text-slate-600 text-sm m-0 leading-relaxed">
              Destek taleplerine iş günlerinde ortalama <strong>24 saat</strong> içinde dönüş
              yapıyoruz. Acil güvenlik bildirimleri önceliklidir.
            </p>
          </div>

          <div className="mb-8 p-5 bg-amber-50 border border-amber-100 rounded-2xl">
            <p className="text-amber-900 text-sm leading-relaxed m-0">
              Hesabınız varsa portal üzerinden destek talebi açabilirsiniz.{' '}
              <Link href="/login" className="text-indigo-600 font-medium underline hover:text-indigo-800">
                Giriş yapın
              </Link>{' '}
              veya{' '}
              <Link href="/portal" className="text-indigo-600 font-medium underline hover:text-indigo-800">
                portala gidin
              </Link>
              .
            </p>
          </div>

          <h2 className="text-xl font-bold text-slate-800 mb-6">Bize Yazın</h2>
          <ContactForm />
        </div>
      </MarketingPageShell>
    </MarketingSiteChrome>
  );
}
