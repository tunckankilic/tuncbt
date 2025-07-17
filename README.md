# 🚀 TuncBT - Team Management & Collaboration Platform

<div align="center">
  <img src="assets/images/wallpaper.jpg" alt="TuncBT Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.32.5-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-02569B?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
  [![GetX](https://img.shields.io/badge/GetX-State%20Management-9C27B0?style=for-the-badge)](https://pub.dev/packages/get)
  [![Version](https://img.shields.io/badge/Version-2.0.0-green?style=for-the-badge)](https://github.com/tunckankilic/tuncbt)
</div>

## 📋 İçerik

- [Genel Bakış](#-genel-bakış)
- [Özellikler](#-özellikler)
- [Teknolojiler](#-teknolojiler)
- [Kurulum](#-kurulum)
- [Yapılandırma](#-yapılandırma)
- [Kullanım](#-kullanım)
- [Proje Yapısı](#-proje-yapısı)
- [Katkıda Bulunma](#-katkıda-bulunma)
- [Lisans](#-lisans)

## 🎯 Genel Bakış

**TuncBT**, modern takım yönetimi ve işbirliği için geliştirilmiş cross-platform bir uygulamadır. Takımlar için görev yönetimi, gerçek zamanlı mesajlaşma ve üye yönetimi özellikleri sunar.

### 🌟 Temel Amaçlar

- Takım içi iletişimi güçlendirmek
- Görev ve proje yönetimini kolaylaştırmak
- Çoklu platform desteği ile her yerden erişim
- Güvenli ve ölçeklenebilir altyapı

## ✨ Özellikler

### 👥 Takım Yönetimi

- **Takım Oluşturma**: Yeni takımlar oluşturun ve referral kodları ile üye davet edin
- **Rol Tabanlı Yetkilendirme**: Admin, Member rolleri ile esnek yetki yönetimi
- **Üye Yönetimi**: Takım üyelerini görüntüleyin, ekleyin veya çıkarın
- **Takım Ayarları**: Takım bilgilerini düzenleyin ve yapılandırın

### 📊 Görev Yönetimi

- **Görev Oluşturma**: Detaylı görevler oluşturun (başlık, açıklama, kategori, son tarih)
- **Durum Takibi**: Görevlerin tamamlanma durumunu izleyin
- **Kategori Filtreleme**: Görevleri kategorilere göre filtreleyin
- **Yorum Sistemi**: Görevler üzerinde takım içi tartışma

### 💬 Gerçek Zamanlı Mesajlaşma

- **Özel Mesajlar**: Takım üyeleri ile birebir mesajlaşma
- **Grup Sohbetleri**: Takım geneli grup konuşmaları
- **Medya Paylaşımı**: Fotoğraf, video ve dosya paylaşımı
- **Sesli Mesaj**: Ses kayıtları gönderme
- **Online Durum**: Kullanıcıların çevrimiçi durumunu görme

### 🌍 Çoklu Dil Desteği

- **Türkçe** (varsayılan)
- **İngilizce**
- **Almanca**

### 📱 Cross-Platform

- **Android** - Native performans
- **iOS** - Apple ecosystem entegrasyonu
- **Web** - Tarayıcı desteği
- **Windows** - Desktop uygulaması
- **macOS** - Mac bilgisayarlar için
- **Linux** - Linux dağıtımları

## 🛠 Teknolojiler

### Frontend

- **Flutter 3.32.5** - UI framework
- **Dart** - Programlama dili
- **GetX 4.6.6** - State management ve routing
- **Flutter ScreenUtil** - Responsive design

### Backend & Services

- **Firebase Auth** - Kimlik doğrulama
- **Cloud Firestore** - NoSQL veritabanı
- **Firebase Storage** - Dosya depolama
- **Firebase Messaging** - Push notifications

### Kullanılan Paketler

```yaml
dependencies:
  get: ^4.6.6 # State management
  firebase_core: ^3.3.0 # Firebase core
  firebase_auth: ^5.1.4 # Authentication
  cloud_firestore: ^5.2.1 # Database
  firebase_storage: ^12.1.3 # File storage
  firebase_messaging: ^15.1.1 # Push notifications
  flutter_localizations: # Internationalization
  cached_network_image: ^3.4.0 # Image caching
  image_picker: ^1.1.2 # Image selection
  file_picker: ^10.2.0 # File selection
  permission_handler: ^12.0.0+1 # Permissions
  shared_preferences: ^2.2.2 # Local storage
  connectivity_plus: ^6.1.4 # Network status
```

## 🚀 Kurulum

### Gereksinimler

- **Flutter SDK**: 3.32.5 veya üzeri
- **Dart SDK**: 3.2.3 veya üzeri
- **Android Studio** veya **VS Code**
- **Git**

### 1. Repository'yi Klonlayın

```bash
git clone https://github.com/tunckankilic/tuncbt.git
cd tuncbt
```

### 2. Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### 3. Firebase Yapılandırması

Firebase projesi oluşturun ve yapılandırma dosyalarını ekleyin:

#### Android

`android/app/google-services.json` dosyasını ekleyin

#### iOS

`ios/Runner/GoogleService-Info.plist` dosyasını ekleyin

### 4. Environment Dosyası

`.env.production` dosyasını oluşturun:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_AUTH_DOMAIN=your_auth_domain

# App Configuration
APP_NAME=TuncBT
APP_VERSION=2.0.0
APP_ENV=production

# Push Notifications
FCM_SERVER_KEY=your_fcm_server_key
NOTIFICATION_CHANNEL_ID=high_importance_channel
```

### 5. Uygulamayı Çalıştırın

```bash
# Debug modda çalıştırma
flutter run

# Release build oluşturma
flutter build apk --release  # Android
flutter build ios --release  # iOS
flutter build web --release  # Web
```

## ⚙️ Yapılandırma

### Firebase Rules

Firestore güvenlik kuralları `firestore.rules` dosyasında tanımlanmıştır:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null &&
        (request.auth.uid == userId ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.teamRole == 'admin');
    }

    // Teams collection
    match /teams/{teamId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // Tasks collection
    match /teams/{teamId}/tasks/{taskId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Bu uygulama profil fotoğrafı çekmek için kamera erişimi gerektirir.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Bu uygulama sesli mesaj göndermek için mikrofon erişimi gerektirir.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Bu uygulama fotoğraf paylaşmak için galeri erişimi gerektirir.</string>
```

## 📖 Kullanım

### 1. Hesap Oluşturma

- Uygulamayı açın
- "Kayıt Ol" sekmesine gidin
- Gerekli bilgileri doldurun
- Email doğrulamasını tamamlayın

### 2. Takım Oluşturma veya Katılma

#### Yeni Takım Oluşturma

```dart
// Takım oluşturma akışı
1. "Takım Oluştur" butonuna tıklayın
2. Takım adını girin
3. Referral kodu otomatik oluşturulur
4. Takım üyelerini davet edin
```

#### Mevcut Takıma Katılma

```dart
// Takıma katılma akışı
1. "Takıma Katıl" sekmesine gidin
2. Referral kodunu girin
3. Takım bilgilerini onaylayın
4. Katılma işlemini tamamlayın
```

### 3. Görev Yönetimi

- **Görev Oluşturma**: Ana ekranda "+" butonuna tıklayın
- **Görev Görüntüleme**: Görev listesinden istediğiniz görevi seçin
- **Durum Güncelleme**: Görev detayında tamamlama durumunu değiştirin
- **Yorum Ekleme**: Görev altına yorum yazarak takım üyeleri ile tartışın

### 4. Mesajlaşma

- **Özel Mesaj**: Takım üyesi listesinden kullanıcıya tıklayın
- **Grup Sohbeti**: Sol menüden "Mesajlar" bölümüne gidin
- **Medya Gönderme**: Mesaj yazma alanındaki eklenti simgesini kullanın

## 📁 Proje Yapısı

```
lib/
├── core/                           # Temel yapılar
│   ├── config/                     # Yapılandırma dosyaları
│   │   ├── constants.dart          # Sabitler
│   │   ├── env_config.dart         # Environment yapılandırması
│   │   ├── firebase_constants.dart # Firebase sabitleri
│   │   └── router.dart             # Route tanımları
│   ├── enums/                      # Enum tanımları
│   ├── models/                     # Veri modelleri
│   └── services/                   # İş katmanı servisleri
│       ├── auth_service.dart       # Kimlik doğrulama
│       ├── team_service.dart       # Takım yönetimi
│       ├── cache_service.dart      # Önbellekleme
│       └── error_handling_service.dart
├── l10n/                          # Çoklu dil desteği
│   ├── app_en.arb                 # İngilizce çeviriler
│   ├── app_tr.arb                 # Türkçe çeviriler
│   └── app_de.arb                 # Almanca çeviriler
├── view/                          # UI katmanı
│   ├── screens/                   # Ekranlar
│   │   ├── auth/                  # Kimlik doğrulama ekranları
│   │   ├── tasks_screen/          # Görev yönetimi
│   │   ├── chat/                  # Mesajlaşma
│   │   └── inner_screens/         # İç sayfalar
│   └── widgets/                   # Yeniden kullanılabilir bileşenler
├── utils/                         # Yardımcı sınıflar
└── main.dart                      # Ana giriş noktası
```

## 🧪 Test

### Test Çalıştırma

```bash
# Tüm testleri çalıştır
flutter test

# Coverage raporu oluştur
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Test Türleri

- **Unit Tests**: İş mantığı testleri
- **Widget Tests**: UI bileşen testleri
- **Integration Tests**: Uçtan uca testler

## 🔧 Development

### Code Quality

```bash
# Kod analizi
flutter analyze

# Kod formatlama
dart format .

# Import düzenleme
dart fix --apply
```

### Build Varyantları

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Profile build (performans analizi)
flutter build apk --profile
```

## 🤝 Katkıda Bulunma

1. **Fork** edin
2. **Feature branch** oluşturun (`git checkout -b feature/amazing-feature`)
3. **Commit** edin (`git commit -m 'feat: add amazing feature'`)
4. **Push** edin (`git push origin feature/amazing-feature`)
5. **Pull Request** açın

### Commit Kuralları

```
feat: yeni özellik
fix: hata düzeltmesi
docs: dokümantasyon
style: kod formatı
refactor: kod refaktörü
test: test ekleme
chore: build/config değişiklikleri
```

## 📄 Lisans

Bu proje özel lisans altındadır. Tüm hakları saklıdır.

## 📞 İletişim

- **Geliştirici**: Tunç Kankılıç
- **Email**: [contact@tuncbt.com]
- **Website**: [https://tuncbt.com]

## 🙏 Teşekkürler

- Flutter Team - Harika framework için
- Firebase Team - Backend altyapısı için
- GetX Team - State management için
- Tüm açık kaynak katkıda bulunanlar

---

<div align="center">
  <p>❤️ ile geliştirildi</p>
  <p>© 2024 TuncBT. Tüm hakları saklıdır.</p>
</div>
