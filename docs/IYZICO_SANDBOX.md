# iyzico sandbox — demo bakiye (Checkout Form)

Bu akış **yalnızca sandbox** içindir (`IYZICO_URI` varsayılanı `https://sandbox-api.iyzipay.com`). Canlı anahtar kullanmayın.

## Akış

1. Flutter, oturum JWT ile **`iyzico-init-checkout`** çağırır → `npm:iyzipay` ile Checkout Form initialize → `paymentPageUrl` döner.
2. Kullanıcı ödeme sayfasını tamamlar → iyzico **`iyzico-checkout-callback`** URL’sine `token` ile POST eder.
3. Callback Edge fonksiyonu `checkoutForm.retrieve` ile sonucu alır; `paymentStatus === SUCCESS` ise `profiles.demo_balance_cents` güncellenir.

### Flutter (demo) zaman çizelgesi

Ödeme yüzeyi (WebView / harici sekme) **iyzico dönüşü** görülünce tetiklenir: URL’de Supabase **`iyzico-checkout-callback`** veya uygulama **`io.prolance.app://iyzico-result`** algılandığında **2 saniye** beklenir, ardından ödeme sekmesi/WebView kapatılır. **Bundan sonra** tam ekran spinner **5 saniye**, ardından bilgi kartı **4 saniye**, sonrasında **30 saniyeye kadar** arka planda bakiye kontrolü (başarıda SnackBar). Web’de banka sekmesi otomatik algılanamadığı için **“Ödemeyi tamamladım”** düğmesi ile aynı tetikleyici kullanılır.

Bu zamanlama ürün demosu içindir; gerçek kart akışında iyzico sayfasında daha uzun süre kalınması normaldir.

Anahtarlar yalnızca **Edge Function secrets** içinde tutulur.

## Sizin yapmanız gerekenler

### 1. Veritabanı

Migration: `supabase/migrations/20250520180000_iyzico_demo_checkouts.sql`

```bash
supabase db query --linked -f supabase/migrations/20250520180000_iyzico_demo_checkouts.sql
```

(`db push` migration drift varsa bkz. `docs/SUPABASE_MIGRATION_DRIFT.md`.)

### 2. Secrets (hosted)

```bash
supabase secrets set IYZICO_API_KEY="sandbox-..."
supabase secrets set IYZICO_SECRET_KEY="sandbox-..."
# opsiyonel:
supabase secrets set IYZICO_URI="https://sandbox-api.iyzipay.com"
```

### 3. Deploy

```bash
supabase functions deploy iyzico-init-checkout
supabase functions deploy iyzico-checkout-callback --no-verify-jwt
```

`config.toml`: callback için **`verify_jwt = false`** (iyzico sunucu POST’u JWT taşımaz).

### 4. Callback URL

iyzico panelinde / initialize isteğinde kullanılan adres otomatik olarak:

`{SUPABASE_URL}/functions/v1/iyzico-checkout-callback`

şeklindedir (Edge içinde `SUPABASE_URL` ile oluşturulur).

### 5. Cep POS anahtarları

Standart **Checkout Form** entegrasyonu `IYZICO_API_KEY` / `IYZICO_SECRET_KEY` (sandbox- önekli çift) kullanır.  
Verdiğiniz **Cep POS** anahtarları ayrı bir ürün hattıdır; şu anki kodda kullanılmıyor. İleride Cep POS API’si eklenirse `IYZICO_CEP_POS_*` secret’ları bağlanabilir.

### 6. Test kartları

[iyzico sandbox test kartları](https://docs.iyzico.com/en/getting-started/preliminaries/live-vs-sandbox) dokümanından seçin.

## Sorun giderme

- **`iyzico_not_configured`**: Secret’lar eksik.
- **Edge’de `iyzipay` / `fs` hatası**: Supabase Edge sürümüne göre `npm:iyzipay` uyumsuzluğu olursa dokümana issue notu ekleyin; alternatif olarak ham REST + `IYZWSv2` imzası gerekir.
