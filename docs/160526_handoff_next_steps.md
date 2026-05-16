# Prolance — Handoff & Next Steps
**Tarih:** 16 Mayıs 2026  
**Durum:** Post-MVP Feature Wave tamamlandı. Proje demo-ready MVP seviyesinde.

---

## Bu Makineye Geçince Yapılacaklar

### 1. Ortamı Hazırla

```bash
# Flutter bağımlılıkları
flutter pub get

# Landing page
cd packages/landing && npm install

# Admin panel
cd packages/admin && npm install

# Supabase local başlat (Docker gerekli)
supabase start
supabase db reset   # migration + seed verisini yükle
```

### 2. Çalıştır

```bash
# Flutter uygulaması
flutter run

# Landing page (port 3001)
cd packages/landing && npm run dev

# Admin panel (port 3002)
cd packages/admin && npm run dev
```

Demo hesapları (seed.sql'den):
- `client@prolance.dev` / `demo1234`
- `freelancer@prolance.dev` / `demo1234`

---

## Tamamlanan Özellikler

### Flutter (Mobil)
- Supabase Auth (giriş, kayıt, şifre sıfırlama)
- İş ilanları listesi, filtreleme, favoriler
- İlan verme (moderation simülasyonu)
- Teklif gönderme + takip
- Mesajlaşma (Realtime, dosya/fotoğraf, hızlı yanıtlar, E2E transport şifreleme)
- Bildirimler (Realtime + overlay banner toast)
- Profil, düzenleme, ayarlar
- Değerlendirme sistemi (yıldız verme + canlı profil entegrasyonu)
- Escrow ekranı (mock)
- Destek talebi ekranı
- Boş durum ekranları (Empty States)
- Modern animasyonlar ve glassmorphic UI
- JobsProvider / AppState refactor (single responsibility)

### Backend (Supabase)
- 11 tablo: profiles, jobs, proposals, conversations, messages, escrow_transactions, reviews, notifications, tickets, admin_audit_log, job_saves
- RLS tüm tablolarda aktif
- Realtime: messages + notifications
- Storage: chat-attachments bucket
- Edge Function: escrow (release/dispute)
- Seed verisi: 2 kullanıcı, 5 iş ilanı, 1 konuşma

### Web
- Landing page (3D hero, 8 bölüm, modern SaaS tasarım)
- Web auth portal + kullanıcı hoşgeldin sayfası
- Admin panel: dashboard, kullanıcı yönetimi, ticket çözümleme, escrow uyuşmazlıkları, audit log
- Terms + Privacy sayfaları

---

## Sonraki Aşama: Platform Polish Wave

Öncelik sırasına göre:

---

### A) Sunucu Tarafı Bildirimler (Kritik)

**Sorun:** Şu an `notifications` tablosuna sadece `profile_id = auth.uid()` ile insert yapılabiliyor. Yani bir kullanıcı başkasına bildirim gönderemiyor.

**Çözüm:** Supabase DB trigger'ları ekle.

**Yapılacak:**
- `supabase/migrations/20250516000008_notification_triggers.sql` dosyası oluştur:

```sql
-- Yeni teklif geldiğinde iş sahibine bildirim gönder
CREATE OR REPLACE FUNCTION notify_job_owner_on_proposal()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.notifications (profile_id, title, body, type)
  SELECT j.client_id, 'Yeni Teklif', 'İlanınıza yeni bir teklif geldi.', 'proposal'
  FROM public.jobs j WHERE j.id = NEW.job_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_proposal_insert
AFTER INSERT ON public.proposals
FOR EACH ROW EXECUTE FUNCTION notify_job_owner_on_proposal();

-- Yeni mesaj geldiğinde karşı tarafa bildirim gönder
CREATE OR REPLACE FUNCTION notify_on_new_message()
RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN
  SELECT * INTO rec FROM public.conversations WHERE id = NEW.conversation_id;
  INSERT INTO public.notifications (profile_id, title, body, type)
  SELECT unnest(rec.participant_ids), 'Yeni Mesaj', 'Yeni bir mesajınız var.', 'message'
  WHERE unnest(rec.participant_ids) != NEW.sender_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_message_insert
AFTER INSERT ON public.messages
FOR EACH ROW EXECUTE FUNCTION notify_on_new_message();
```

- Flutter'da zaten `NotificationRepository` Realtime dinliyor — trigger eklenince otomatik çalışır.

---

### B) GoRouter Navigasyon Unifikasyonu (Mimari)

**Sorun:** Birçok ekran `Navigator.push` kullanıyor. Web'de deep link yok.

**Etkilenen ekranlar:**
- `PostJobScreen` → `Navigator.push`
- `JobDetailScreen` → `Navigator.push`
- `ChatScreen` → `Navigator.push`
- `EscrowScreen` → `Navigator.push`
- `SubmitReviewScreen` → `Navigator.push`
- `EditProfileScreen` → `Navigator.push`

**Yapılacak:**
- `app_router.dart`'a şu route'ları ekle:

```dart
GoRoute(path: '/jobs/:id', builder: (_, state) => JobDetailScreen(jobId: state.pathParameters['id']!)),
GoRoute(path: '/chat/:id', builder: (_, state) => ChatScreen(conversationId: state.pathParameters['id']!)),
GoRoute(path: '/post-job', builder: (_, __) => const PostJobScreen()),
GoRoute(path: '/escrow/:jobId', builder: (_, state) => EscrowScreen(jobId: state.pathParameters['jobId']!)),
GoRoute(path: '/review/:jobId', builder: (_, state) => SubmitReviewScreen(...)),
GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
```

- Her `Navigator.push` çağrısını `context.push('/route')` ile değiştir.

---

### C) Profil Fotoğrafı Yükleme (UX)

**Sorun:** `edit_profile_screen.dart`'ta `// TODO: Implement image picker` yorumu var. Fotoğraf değiştirme çalışmıyor.

**Yapılacak:**

1. `supabase/migrations/20250516000009_avatars_bucket.sql`:
```sql
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);

CREATE POLICY "Avatar upload" ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Avatar read" ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');
```

2. `edit_profile_screen.dart`'ta `_pickAndUploadAvatar()` metodu ekle:
```dart
Future<void> _pickAndUploadAvatar() async {
  final picker = ImagePicker();
  final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
  if (img == null || !mounted) return;
  final bytes = await img.readAsBytes();
  final uid = Supabase.instance.client.auth.currentUser!.id;
  final path = '$uid/avatar.jpg';
  await Supabase.instance.client.storage.from('avatars').uploadBinary(path, bytes,
    fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'));
  final url = Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
  // state'i güncelle
}
```

---

### D) Teklif Kabul/Ret Akışı (Ürün)

**Sorun:** İşveren teklifleri görüyor ama kabul/ret akışı yok. Kabul edilince escrow otomatik oluşturulmuyor.

**Yapılacak:**

1. `proposals` tablosuna `status` alanı ekle (eğer yoksa):
```sql
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS status text DEFAULT 'pending';
```

2. Flutter'da `job_detail_bottom_sheet.dart`'ın "Teklif" sekmesine Kabul / Ret butonları ekle.

3. Kabul butonuna basınca:
   - `proposals.status = 'accepted'` update
   - `escrow_transactions` insert (HELD)
   - Freelancer'a bildirim (trigger ile otomatik gelir — A adımı tamamlandıktan sonra)

---

### E) Storage Güvenlik Sıkılaştırması (Güvenlik)

**Sorun:** `chat-attachments` bucket'ta her authenticated kullanıcı herkese ait dosyaları görebiliyor.

**Yapılacak:**
```sql
-- Mevcut geniş policy'yi sil
DROP POLICY "Chat attachments read" ON storage.objects;

-- Conversation-aware policy (conversation participant kontrolü)
CREATE POLICY "Chat attachments read" ON storage.objects FOR SELECT
USING (
  bucket_id = 'chat-attachments' AND
  auth.uid()::text = (storage.foldername(name))[1]
  OR EXISTS (
    SELECT 1 FROM public.conversations c
    WHERE c.id::text = (storage.foldername(name))[2]
    AND auth.uid() = ANY(c.participant_ids)
  )
);
```

---

### F) Integration Testleri (Test Coverage)

**Sorun:** `integration_test/` klasöründe sadece README var.

**Yapılacak:** `integration_test/app_flow_test.dart`:
- Login flow testi
- İş ilanı görüntüleme testi
- Teklif gönderme testi
- Mesaj gönderme testi

---

### G) `AppState._feedNotifications` Konsolidasyonu (Teknik Borç)

**Sorun:** Çift bildirim sistemi var: `AppState._feedNotifications` (legacy) + `NotificationRepository` (Supabase Realtime).

**Yapılacak:**
- `AppState`'ten `_feedNotifications`, `addFeedNotification`, `markAllFeedNotificationsRead`, `removeFeedNotification` metodlarını sil.
- `JobsProvider.addJob` → `onNotify` callback yerine doğrudan `NotificationRepository`'e insert yap.
- Tüm çağıran ekranları güncelle.

---

## Dosya Yapısı Özeti

```
Prolance_Freelance_Platform_App/
├── lib/
│   ├── core/
│   │   ├── config/         supabase_config.dart
│   │   ├── models/         9 model dosyası
│   │   ├── navigation/     app_router.dart, main_nav_controller.dart
│   │   ├── repositories/   7 repository
│   │   ├── services/       auth_service.dart, payment_service.dart
│   │   ├── state/          app_state.dart (auth+theme), jobs_provider.dart
│   │   ├── theme/          app_theme.dart
│   │   └── widgets/        ortak widget'lar
│   └── features/
│       ├── auth/           login, register, forgot_password
│       ├── home/           home, favorites, my_proposals, proposal_detail
│       ├── jobs/           jobs, job_detail, submit_proposal, widgets
│       ├── messages/       messages, chat, image_preview, quick_reply
│       ├── notifications/  notifications
│       ├── onboarding/     onboarding
│       ├── payment/        escrow, escrow_status_badge, payment_widget
│       ├── post_job/       post_job
│       ├── profile/        profile, edit_profile, settings
│       ├── reviews/        submit_review
│       ├── splash/         splash
│       └── support/        support_ticket
├── packages/
│   ├── admin/              Next.js admin panel (port 3002)
│   └── landing/            Next.js landing page (port 3001)
├── supabase/
│   ├── migrations/         7 migration dosyası
│   ├── functions/escrow/   edge function
│   ├── config.toml
│   └── seed.sql
└── test/
    ├── unit/               5 unit test
    ├── widget/             2 widget test
    └── smoke/              1 smoke test
```

---

## Önemli Notlar

- **Supabase yerel URL:** `http://127.0.0.1:54321` (default)
- **Flutter dart-define:** `--dart-define=USE_SUPABASE=true` (default true)
- **Test için Supabase'i devre dışı bırak:** `--dart-define=USE_SUPABASE=false`
- **Admin panel service role key:** `.env` dosyasında, asla commit etme
- **Escrow:** Mock implementasyon — gerçek para hareketi yok
- **Paket adı:** `prolance_app` (import'larda dikkat)

---

## Öncelik Sırası (Önerilen)

1. **A — Sunucu Tarafı Bildirimler** (SQL trigger, 30 dk)
2. **C — Profil Fotoğrafı** (Flutter + Storage, 2 saat)
3. **D — Teklif Kabul/Ret Akışı** (Flutter + DB, 3 saat)
4. **B — GoRouter Unifikasyonu** (Flutter refactor, 4 saat)
5. **E — Storage Güvenlik** (SQL policy, 30 dk)
6. **F — Integration Testleri** (Flutter test, 2 saat)
7. **G — AppState Konsolidasyonu** (Flutter refactor, 2 saat)
