# Takas Uygulaması

Flutter ile geliştirilmiş, iOS tarzı cam (glassmorphism) arayüze sahip takas platformu. Kullanıcılar ürünlerini ekleyebilir, diğer kullanıcıların ürünlerine takas teklifi gönderebilir, kargo takibini yönetebilir ve takas sonrası birbirlerini değerlendirebilir.

## Özellikler

- **Kimlik Doğrulama:** E-posta/şifre ve Google ile giriş
- **Profil:** Fotoğraf, ad, şehir, biyografi; kullanıcı puanı ve değerlendirmeler
- **Ürün Yönetimi:** Kategori bazlı ürün ekleme (Telefon, Araba, Elektronik, Giyim, Koleksiyon/Kart, Aksesuar, Diğer)
  - Telefon için marka/model/depolama/renk/durum gibi dinamik alanlar
  - "Diğer" kategorisinde serbest başlık + açıklama
- **Keşfet:** Diğer kullanıcıların ürünlerini listeleme, arama ve kategori filtresi
- **Takas Teklifi:** Başka bir ürüne kendi ürünlerinden birini seçerek teklif gönderme
- **Teklif Yönetimi:** Gelen/giden teklifler, kabul/red
- **Kargo Süreci:** Kabul sonrası 5 günlük kargo süresi, her iki taraf için takip numarası girişi
- **Değerlendirme:** Takas sonrası 1-5 yıldız puan ve yorum; kullanıcı ortalaması güncellenir
- **Bildirimler:** Uygulama içi bildirimler (teklif alındı, kabul/red, kargo takibi, değerlendirme)

## Teknoloji

- **Flutter / Dart** (iOS + Android)
- **Firebase**: Authentication, Cloud Firestore, Storage, Cloud Messaging
- **Riverpod**: Durum yönetimi
- **go_router**: Yönlendirme
- **image_picker / cached_network_image / intl**

## Kurulum

### 1) Flutter bağımlılıkları

```bash
flutter pub get
```

### 2) Firebase yapılandırması

Bu proje Firebase kullanır. Kendi Firebase projenizi bağlamanız gerekir:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Bu komut `lib/firebase_options.dart` dosyasını gerçek değerlerle günceller ve platform dosyalarını oluşturur:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

> Not: Depodaki `lib/firebase_options.dart` yer tutucu değerler içerir; `flutterfire configure` çalıştırmadan Firebase özellikleri çalışmaz.

### 3) Firebase servislerini açın

Firebase Console üzerinden:
- **Authentication**: Email/Password ve Google sağlayıcılarını etkinleştirin
- **Cloud Firestore**: veritabanı oluşturun
- **Storage**: dosya depolamayı etkinleştirin
- **Cloud Messaging**: push bildirimleri için yapılandırın

### 4) Android Google Sign-In

`android/app/build.gradle` içinde uygulama kimliğiniz Firebase ile aynı olmalı. SHA-1/SHA-256 parmak izlerinizi Firebase proje ayarlarına ekleyin:

```bash
cd android && ./gradlew signingReport
```

### 5) Çalıştırma

```bash
flutter run
```

## Firestore Veri Modeli (özet)

- `users/{uid}`: profil, puan ortalaması, puan sayısı
- `items/{itemId}`: sahip, kategori, başlık, açıklama, dinamik özellikler, görseller, aktiflik
- `offers/{offerId}`: teklif eden/sahip, iki ürün, durum, kargo son tarihi, takip numaraları, değerlendirme bayrakları
- `reviews/{reviewId}`: teklif, puan, yorum
- `notifications/{userId_or_autoId}`: kullanıcıya özel bildirimler (`userId` alanı ile filtrelenir)

## Güvenlik Kuralları

Üretim öncesi Firestore ve Storage güvenlik kurallarını sıkılaştırın. Örnek başlangıç için `firestore.rules` dosyasına bakın; kendi ürün gereksinimlerinize göre gözden geçirin.

## Notlar

- Bu depo şu an Flutter/Dart kaynak kodunu içerir; platform klasörleri (`android/`, `ios/`) Flutter CLI ile oluşturulabilir (`flutter create .` mevcut kaynakları koruyarak birleştirmek için dikkatli kullanılmalıdır).
- Push bildirimleri için platform tarafı FCM yapılandırması (APNs anahtarı, Android bildirim kanalı vb.) ayrıca tamamlanmalıdır.
- UI, iOS esintili koyu cam/blur görünümü hedefler; `GlassSurface` ve `GlassBackground` bileşenleri bu temayı sağlar.
