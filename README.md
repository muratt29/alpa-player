# Alpa Player

Ücretsiz, reklam destekli IPTV oynatıcı. **Android + iOS** (Flutter, tek kod tabanı).
Kullanıcı kendi IPTV hesabıyla (sunucu adresi + kullanıcı adı + şifre, Xtream Codes) Canlı TV, Film ve Dizi izler.

- Tema: lacivert (#0B1F4B) + beyaz
- Logo ve uygulama ikonları: `store/` ve platform klasörlerinde hazır
- Android paket adı / iOS bundle id: `com.alpaplayer.app`

## Özellikler

- Xtream Codes girişi; sunucu alanına tam M3U linki yapıştırılırsa kullanıcı adı ve şifre linkten okunur
- Canlı TV / Filmler / Diziler, kategoriler, arama, sezon ve bölüm listesi
- media_kit (libmpv) oynatıcı: TS, HLS, MP4, MKV
- Hesap bilgileri cihazın güvenli deposunda saklanır
- Lacivert açılış ekranı, uyarlanabilir (adaptive) Android ikonu

## Reklam dengesi

Kullanıcıyı rahatsız etmemek için kurallar (`lib/ad_service.dart` → `AdPolicy`):

| Kural | Değer |
|---|---|
| Video oynarken reklam | Hiç yok |
| Giriş ekranında reklam | Yok |
| Banner | Sadece listelerin altında küçük şerit |
| Uygulama açılışından sonra tam ekran reklamsız süre | 5 dakika |
| Her oturumda reklamsız açılan yayın sayısı | 2 |
| İki tam ekran reklam arası en az | 15 dakika |
| Günde en fazla tam ekran reklam | 6 |

Tam ekran reklam yalnızca yeni bir yayın açılırken, yayın başlamadan önce çıkar.

## Derleme

### Otomatik (GitHub Actions)

Proje bir GitHub deposuna yüklendiğinde `.github/workflows/build.yml` her push'ta:
- Android: `app-release.apk` (telefona doğrudan kurulur) ve `app-release.aab` (Google Play için)
- iOS: imzasız `.ipa`

üretir. Çıktılar: GitHub → Actions → çalışma → **Artifacts**.

### Kendi bilgisayarınızda

```bash
flutter pub get
flutter run                  # bağlı telefonda çalıştırır
flutter build apk --release  # Android APK
flutter build ios --release  # iOS (Mac + Xcode gerekir)
```

## Yayına çıkmadan önce yapılacaklar

1. **AdMob**: https://admob.google.com adresinde hesap açın, Android ve iOS için birer uygulama ve her birinde bir *Banner* ve bir *Geçiş (Interstitial)* reklam birimi oluşturun.
   - Uygulama kimlikleri (`~` içerir): `android/app/src/main/AndroidManifest.xml` ve `ios/Runner/Info.plist` içindeki test kimliklerini değiştirin.
   - Reklam birimi kimlikleri (`/` içerir): `lib/ad_service.dart` içindeki `ca-app-pub-XXXX…` değerlerini doldurun.
   - AdMob → *Gizlilik ve mesajlaşma* bölümünden GDPR izin mesajı oluşturun.
2. **Gizlilik politikası**: `docs/gizlilik-politikasi.md` hazır; iletişim e-postanızı ekleyip bir web adresinde yayınlayın (her iki mağaza da adres ister).
3. **Android imzalama**: Google Play için bir yükleme anahtarı oluşturun ve `android/app/build.gradle.kts` içindeki `signingConfig`'i ona bağlayın (https://docs.flutter.dev/deployment/android#sign-the-app). Şu an release derlemesi test anahtarıyla imzalanır; telefona kurmak için yeterlidir.
4. **Mağaza hesapları**: Google Play Console (tek seferlik ücret) ve Apple Developer Program (yıllık ücret). iOS uygulamasını App Store'a göndermek için Mac + Xcode veya imzalı CI derlemesi gerekir.
5. **Mağaza ikonları**: `store/play_store_icon_512.png`, `store/app_store_icon_1024.png`.

## Dosya yapısı

```
lib/
  main.dart                 uygulama girişi
  theme.dart                lacivert-beyaz tema
  models.dart               Account, Category, StreamItem, Episode
  xtream_api.dart           Xtream Codes API istemcisi ve yayın URL'leri
  account_store.dart        hesap bilgilerinin güvenli saklanması
  ad_service.dart           AdMob: kimlikler, reklam dengesi kuralları, banner
  screens/
    login_screen.dart       giriş ekranı
    home_screen.dart        sekmeler + kategoriler
    stream_list_screen.dart kanal/film/dizi listesi + arama
    series_screen.dart      sezonlar ve bölümler
    player_screen.dart      video oynatıcı
android/  ios/              platform projeleri (ikonlar, izinler, AdMob ayarları dahil)
assets/logo.png             uygulama içi logo
store/                      mağaza ikonları ve logo (SVG)
docs/                       gizlilik politikası
```
