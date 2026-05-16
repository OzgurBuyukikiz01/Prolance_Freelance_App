# ChatGPT — Bitirme posteri ve tanıtım afişi promptları (Prolance)

Bu dosya, OSTİM Teknik Üniversitesi Yazılım Mühendisliği bitirme duyurusundaki **zorunlu poster içeriğine** uygun olarak hazırlanmıştır. Duyuru metninde olmayan başlıklar (sunum süresi, tarihler, değerlendirme yüzdeleri) promptlara **eklenmemiştir**.

**Önce doldurun:** [poster-bilgileri-sablon.txt](poster-bilgileri-sablon.txt)

**Ekran görüntüleri:** [assets/poster/screenshots/README.md](../assets/poster/screenshots/README.md)

---

## Prompt 1 — 70×100 cm bitirme posteri

Aşağıdaki metni **tek parça** olarak ChatGPT’ye yapıştırın. Görsel üretim kullanıyorsanız, çıktı metin ağırlıklı olursa: *"Şimdi bu plana göre 70×100 cm tek poster görseli üret"* veya tasarım aracı için *"Canva/Figma katman listesi ver"* deyin.

`[PROJE_YÖNETİM_ARACI]`, `[DANIŞMAN_ADI]` vb. yerlerde kendi değerlerinizi yazın veya önce aşağıdaki kod bloğunu düzenleyip öyle yapıştırın.

```
Görev: OSTİM Teknik Üniversitesi Yazılım Mühendisliği Bölümü bitirme projesi için TEK SAYFALIK akademik poster tasarımı üret.

Ölçü ve format (zorunlu):
- Boyut: 70 cm genişlik × 100 cm yükseklik (dikey poster).
- Tek sayfa, baskıya uygun, yüksek çözünürlük, okunaklı tipografi.
- Tasarım: temiz, sade, etkili; akademik ama modern.

Dışına çıkma: Aşağıda listelenen bölümler ve bilgiler dışında yeni başlık, değerlendirme kriteri, sunum süresi, tarih veya üniversite duyurusu metni EKLEME.

Posterde mutlaka olacak bölümler (sırayla, dengeli yerleşim):

1) ÜST BANT
- Proje başlığı: "Prolance — Serbest Çalışan Eşleştirme Platformu (Mobil MVP)"
- Alt satır: OSTİM Teknik Üniversitesi | Yazılım Mühendisliği Bölümü | Bitirme Projesi

2) PROBLEM TANIMI (kısa madde veya 3–4 cümle)
- Küçük işletmeler ve bireysel müşteriler uygun freelancer bulmakta zorlanıyor.
- Freelancer'lar ilgili projelere hızlı ve beceri uyumlu şekilde ulaşamıyor.
- Mevcut süreçler parçalı; beceri uyumu ve teklif süreci tek platformda yönetilmiyor.

3) PROJE HEDEFLERİ (madde işaretli, 4–6 madde)
- Freelancer ve proje sahibini tek mobil platformda buluşturmak.
- Beceri tabanlı iş önerisi ve eşleşme yüzdesi sunmak.
- Çok adımlı ilan oluşturma ve teklif gönderme akışı sağlamak.
- Mesajlaşma ve profil/portföy yönetimi ile iş birliğini desteklemek.
- Çalışan bir MVP ile temel kullanıcı senaryolarını göstermek.
- İleride güvenli ödeme (escrow) ve bulut backend entegrasyonuna altyapı hazırlamak.

4) YAZILIM MODELİ — GENEL DİYAGRAMLAR
- Bağlam diyagramı (basit kutu çizimi):
  [Freelancer / Proje Sahibi Kullanıcıları] → [Prolance Mobil Uygulama (Flutter)] → [Yerel Veri Katmanı: SharedPreferences + JSON] → [Planlanan: Supabase, Stripe]
- İsteğe bağlı ikinci küçük şema: Ana modüller — Onboarding, Jobs, Proposals, Messages, Profile, Settings.

5) YAZILIM EKRAN GÖRÜNTÜLERİ
- 6 kutulu grid: Onboarding, Ana Sayfa (önerilen işler + match %), İş Listesi, İlan Detayı, Teklif Gönderme, Mesajlar/Profil.
- Not: Ekran görüntülerini kullanıcı yükleyecek; şimdilik düzen için numaralı placeholder kutuları bırak: "Ekran 1" … "Ekran 6".

6) TEKNOLOJİ (kısa, posterin bir köşesinde)
- Flutter / Dart, Provider, SharedPreferences, assets JSON (category_skills), Android/iOS/Web.

7) GITHUB VE PROJE YÖNETİMİ
- GitHub: https://github.com/OzgurBuyukikiz01/Prolance_Freelance_App.git
- Proje yönetimi: [PROJE_YONETIM_ARACI: Trello / Monday / kullanılmadıysa "Kullanılmadı"] + küçük logo veya kanıt görseli alanı.

8) EKİP VE DANIŞMAN (fotoğraf alanları zorunlu)
- Danışman: [DANISMAN_ADI] — fotoğraf alanı: [DANISMAN_FOTO]
- Üye 1: [UYE1_AD] — Rol: [UYE1_ROL] — Foto: [UYE1_FOTO]
- Üye 2: [UYE2_AD] — Rol: [UYE2_ROL] — Foto: [UYE2_FOTO]
- Üye 3: [UYE3_AD] — Rol: [UYE3_ROL] — Foto: [UYE3_FOTO]
- (Varsa Üye 4 için aynı format)

Renk ve stil:
- Kurumsal sade palet (lacivert / beyaz / açık gri + tek vurgu rengi).
- Başlıklar büyük, gövde metni poster okuma mesafesine uygun.
- İkonlar minimal (mobil, eşleşme, mesaj, iş ilanı).

Çıktı:
1) Önce posterin bölüm yerleşimini metin olarak tarif et.
2) Ardından 70×100 cm poster için tek görsel üret (veya Canva/Figma için katman katman yapılacaklar listesi ver).
3) Türkçe metin kullan; teknik terimler İngilizce kalabilir (Flutter, MVP, GitHub).
```

### ChatGPT’de Prompt 1 sonrası kontrol listesi

- [ ] Ölçü 70 cm × 100 cm (dikey) olarak doğrulandı
- [ ] Duyurudaki tüm zorunlu bölümler yer alıyor
- [ ] Danışman + ekip adları, rolleri ve fotoğraf alanları eklendi veya görseller yüklendi
- [ ] GitHub bağlantısı doğru
- [ ] 6 ekran görüntüsü yerleştirildi (veya tasarım aracında aynı gridde)

---

## Prompt 2 — Tanıtım afişi (kompakt)

Afiş boyutu duyuruda tanımlı değil; kompakt düzen için **dikey A2** önerilir (isteğe bağlı A3).

```
Görev: Aynı bitirme projesi için kompakt TANITIM AFİŞİ tasarla (duyuruda afiş ölçüsü belirtilmediği için dikey A2 öner; kullanıcı istersen A3 söylesin).

Kısıt: 70×100 cm poster duyurusundaki zorunlu içerik dışına çıkma. Şunlar mutlaka yer alacak (kısaltılmış):
- Proje başlığı: Prolance — Serbest Çalışan Eşleştirme Platformu (Mobil MVP)
- Problem tanımı (en fazla 2 cümle)
- Proje hedefleri (en fazla 4 madde)
- Bağlam diyagramı (mini)
- En az 3 ekran görüntüsü alanı (placeholder)
- GitHub: https://github.com/OzgurBuyukikiz01/Prolance_Freelance_App.git
- Proje yönetim aracı: [PROJE_YONETIM_ARACI]
- Danışman: [DANISMAN_ADI] + foto alanı
- Grup üyeleri: ad, rol, foto (placeholder)

Stil: Tek bakışta okunur, kalabalık değil, üniversite + bölüm adı alt bilgide.

Çıktı: Tek sayfa afiş görseli veya baskıya hazır düzen tarifi. Türkçe.
```

### ChatGPT’de Prompt 2 sonrası kontrol listesi

- [ ] Afiş boyutu (A2 veya seçtiğiniz format) netleştirildi
- [ ] Posterle çelişen ek bilgi yok (tarih / süre / puan tablosu yok)
- [ ] En az üç ekran alanı için görseller veya placeholder düzeni hazır

---

## Görseller yüklendikten sonra — Prompt 3 (iyileştirme)

ChatGPT’ye ekran ve kişi fotoğraflarını **ayrı mesajda** ekleyip şunu kullanın:

```
Önceki poster tasarımını koru. Sadece şunları güncelle: danışman ve ekip bilgilerini gerçek verilerle değiştir; placeholder ekran kutularına yüklediğim PNG'leri yerleştir. Metinleri duyuru listesi dışına taşırma. 70×100 cm oranını bozma.
```

### Baskı / teslim öncesi

- [ ] Posterdeki metinler PDF raporunuzla tutarlı
- [ ] 21 Mayıs poster sunumu öncesi baskı terminine göre matbaaya dosya gönderildi
- [ ] Jüri için en az 3 adet basılı rapor (duyuru — sunum günü)

---

## Akış özeti

1. `poster-bilgileri-sablon.txt` dosyasını doldurun.
2. `assets/poster/screenshots/` altına PNG’leri kaydedin (README’deki isimlendirme).
3. ChatGPT’de önce Prompt 1, ardından gerekirse Prompt 3; afiş için Prompt 2.
4. Tasarımı Canva/Figma’da 70×100 cm özel boyutta kontrol edip export edin.
