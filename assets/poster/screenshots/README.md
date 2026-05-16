# Poster için ekran görüntüleri

Bitirme posterinde **6 adet** uygulama ekran görüntüsü kullanılacak. Görselleri mümkünse **yüksek çözünürlükte PNG** olarak bu klasöre kaydedin.

## Önerilen dosya adları

| Dosya | İçerik |
|--------|--------|
| `01_onboarding.png` | Onboarding (ilk veya orta slayt) |
| `02_home.png` | Ana sayfa — önerilen işler, eşleşme yüzdesi görünür olsun |
| `03_jobs.png` | İş listesi / filtreler |
| `04_job_detail.png` | İlan detayı |
| `05_proposal.png` | Teklif gönderme ekranı |
| `06_messages_or_profile.png` | Mesajlar listesi veya profil (tercihen mesajlar) |

## Uygulamada nasıl yakalanır?

1. Makinenizde Flutter kurulu olmalı: `flutter doctor`
2. Proje kökünde: `flutter run` (tercihen gerçek cihaz veya emülatör)
3. Demo giriş bilgileri (uygulamada tanımlıysa) veya kayıt akışı ile **Ana sayfa**ya ulaşın
4. Her ekranda işletim sisteminin veya emülatörün ekran görüntüsü aracını kullanın (Windows: **Win+Shift+S** veya Android Studio **Screenshot**)

### Rota ipuçları (`lib/main.dart`)

- Onboarding: `/onboarding`
- Giriş sonrası ana uygulama: `/home` (`MainNavigationScreen` — alt sekmeden Jobs, Messages, Profile)

Tam yönlendirme, uygulamanızın güncel akışına göre değişebilir; yukarıdaki 6 görsel türünü doldurmanız yeterlidir.

## ChatGPT / tasarım aracı

Tasarımda yerleştirirken sıra: 1 → 6 (poster grid soldan sağa, üstten alta).

**Not:** CI veya bu repoda otomatik ekran yakalama tanımlı değildir; görselleri yerelde üretmeniz gerekir.
