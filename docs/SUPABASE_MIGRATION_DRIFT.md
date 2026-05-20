# Supabase migration geçmişi uyumsuzluğu (`db push` hatası)

## Belirti

```text
Remote migration versions not found in local migrations directory.
```

`supabase migration list` çıktısında:

- **Remote** sütununda sizin repoda **dosyası olmayan** versiyonlar,
- **Local** sütununda bu repodaki migration dosyaları uzakta **uygulanmış görünmüyor**,

aynı anda görünür. Bu, uzak veritabanının **bu repodaki `supabase/migrations/` ile aynı sırayla oluşturulmadığı** anlamına gelir.

## Ne yapmamalısınız

Emin olmadan `supabase migration repair` çalıştırmayın: uzak şema ile `schema_migrations` tablosu tutarsız kalır; ardından `db push` **“already exists”** veya eksik obje hataları verebilir.

## Seçenekler

### A) Tek seferlik SQL (push kullanmadan)

İhtiyaç duyduğunuz migration dosyasının SQL içeriğini **Supabase Dashboard → SQL Editor**’de çalıştırın veya:

```bash
supabase db query --linked -f supabase/migrations/XXXXXXXX_your_change.sql
```

`db push` kullanmadan şema güncellenir; migration history uyumsuzluğu aynı kalabilir.

### A2) Uzaktaki “yerel dosyada olmayan” migration satırlarını temizlemek

CLI şu hatayı veriyorsa: *Remote migration versions not found in local migrations directory*, uzak `schema_migrations` tablosunda repoda olmayan versiyonlar vardır. Bunları **reverted** işaretlemek için (örnek — kendi versiyon listenizi kullanın):

```bash
supabase migration repair --status reverted --linked --yes \
  VERSION1 VERSION2 ...
```

Bundan sonra `supabase migration list` yalnızca bu repodaki sürümleri gösterir; **`db push` yine de tüm yerel migration’ları sırayla uygulamaya çalışır** — tablolar zaten varsa hata alırsınız. Tam senkron için ayrı strateji (baseline veya `repair --status applied` ile eşleştirme) gerekir.

### B) Uzaktaki “yetim” versiyonları gerçekten yanlışsa (ileri seviye)

Yalnızca şunu biliyorsanız: uzaktaki kayıtlar yanlışlıkla oluştu ve veritabanı şeması **bu repodaki migration’ların sonucu ile birebir aynı**:

1. Yetim kayıtları **reverted** işaretleyin (CLI’nin önerdiği sürüm listesiyle).
2. `supabase migration list` ile durumu tekrar kontrol edin.
3. `supabase db push` — tablolar zaten varsa **hata alırsınız**. Bu durumda A veya C daha doğrudur.

### C) Uzak şema = gerçek kaynak

Uzaktaki şema doğru, repodaki migration dosyaları eski/yanlış ise:

- `supabase db pull` ile şemayı çekip migration stratejisini yeniden düzenlemek,
- veya yeni bir Supabase projesine bu repodan **temiz** `db push` yapmak,

gerekir. Bu, ekip kararı ve veri taşıma gerektirir.

### D) Eksik migration dosyalarını repoya eklemek

Uzakta uygulanmış ama repoda dosyası olmayan versiyonlar varsa, **aynı dosya adlarıyla** `supabase/migrations/` altına SQL dosyalarını ekleyin.

## Özet

| Durum | Öneri |
|--------|--------|
| Tek DDL acil lazım | A — SQL Editor veya `db query --linked` |
| Boş / test projesi | Repair + `db push` denenebilir |
| Dolu prod, migration karmaşası | C veya D — DBA / ekip |

## Google OAuth uyarıları

`GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` unset uyarıları `db push` hatasının nedeni değildir; `supabase/.env` veya shell export ile doldurabilirsiniz.
