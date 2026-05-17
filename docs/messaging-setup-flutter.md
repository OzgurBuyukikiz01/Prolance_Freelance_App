# Flutter mesajlaşma kurulumu (Prolance)

Uygulama `SupabaseMessageRepository` ile gerçek zamanlı mesaj ve `chat-attachments` depolama kullanır. Demo sohbetler (`conv_*` id) veritabanına yazılmadan yerel olarak çalışır.

## Sizden gerekenler

1. **Supabase projesi**  
   - Dashboard URL, **anon (public) key**, **service role key** (sadece sunucu tarafı; mobil istemciye koymayın).  
   - Flutter’da kullanılan env: `SupabaseConfig` (genelde `--dart-define` veya `lib/core/config/` altındaki yapılandırma).

2. **Veritabanı migrasyonları**  
   Repo kökünde `supabase/migrations/` uygulanmış olmalı; özellikle:  
   - `conversations`, `messages` tabloları  
   - RLS: `messages_insert_sender`, `messages_select_conversation_member`, `conversations_*` politikaları  

3. **Storage**  
   - Bucket: **`chat-attachments`** (private veya signed URL ile okuma).  
   - Kullanıcıların kendi yüklemelerine yazma politikası (RLS veya storage policy).

4. **Realtime (isteğe bağlı ama önerilir)**  
   - `messages` tablosu için **Realtime** açık olsun; böylece karşı taraf mesajı anında görür.

5. **Auth**  
   - Kullanıcılar **giriş yapmış** olmalı; `sender_id = auth.uid()` RLS ile uyumlu.  
   - Konuşma satırında `participant_ids` içinde her iki kullanıcının UUID’si olmalı (`ensureConversationForJobAsync` akışı).

## Kontrol listesi (hızlı)

- [ ] `USE_SUPABASE=true` (veya projenizdeki eşdeğer) ve URL + anon key tanımlı  
- [ ] `profiles` satırı her kullanıcı için mevcut (kayıt / trigger)  
- [ ] `chat-attachments` bucket ve policy  
- [ ] `messages` + `conversations` RLS hatasız (Dashboard → SQL veya Table Editor ile test)  
- [ ] İki gerçek kullanıcıyla aynı `conversation_id` üzerinden insert testi  

## Sorun giderme

| Belirti | Olası neden |
|--------|----------------|
| Mesaj gönderilemedi (toast) | RLS reddi, yanlış `conversation_id`, veya oturum yok |
| Liste boş | Konuşma UUID’si yanlış veya `participant_ids` içinde kullanıcı yok |
| Ek yüklenmiyor | `chat-attachments` policy veya bucket yok |

Demo `conv_*` sohbetlerde mesajlar **yalnızca cihazda** tutulur; üretimde gerçek UUID konuşmaları kullanın.
