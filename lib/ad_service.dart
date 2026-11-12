import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// REKLAM KIMLIKLERI
/// Yayina cikmadan once asagidaki 4 degeri AdMob panelinizden aldiginiz
/// kendi reklam birimi kimliklerinizle degistirin. Debug modunda her zaman
/// Google'in test kimlikleri kullanilir (kendi reklamlariniza tiklamak
/// hesabinizin kapatilmasina yol acabilir).
/// ---------------------------------------------------------------------------
class AdIds {
  static const _androidBanner = 'ca-app-pub-8413907156839185/5767596212';
  static const _androidInterstitial =
      'ca-app-pub-8413907156839185/2981650772';
  static const _iosBanner = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _iosInterstitial = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Google'in resmi test kimlikleri
  static const _testAndroidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _testIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static bool _useTest(String id) => kDebugMode || id.contains('XXXX');

  static String get banner {
    if (Platform.isIOS) {
      return _useTest(_iosBanner) ? _testIosBanner : _iosBanner;
    }
    return _useTest(_androidBanner) ? _testAndroidBanner : _androidBanner;
  }

  static String get interstitial {
    if (Platform.isIOS) {
      return _useTest(_iosInterstitial)
          ? _testIosInterstitial
          : _iosInterstitial;
    }
    return _useTest(_androidInterstitial)
        ? _testAndroidInterstitial
        : _androidInterstitial;
  }
}

/// ---------------------------------------------------------------------------
/// REKLAM DENGESI
/// Kullaniciyi rahatsiz etmemek icin tam ekran reklam kurallari.
/// Bu degerleri degistirerek reklam sikligini ayarlayabilirsiniz.
/// ---------------------------------------------------------------------------
class AdPolicy {
  /// Uygulama acildiktan sonra bu sure dolmadan tam ekran reklam yok.
  static const startupGrace = Duration(minutes: 5);

  /// Her oturumda ilk bu kadar yayin reklamsiz acilir.
  static const freePlaysPerSession = 2;

  /// Iki tam ekran reklam arasindaki en kisa sure.
  static const minInterval = Duration(minutes: 15);

  /// Bir gunde gosterilecek en fazla tam ekran reklam.
  static const maxPerDay = 6;
}

class AdService {
  AdService._();
  static final instance = AdService._();

  final ValueNotifier<bool> ready = ValueNotifier(false);
  InterstitialAd? _interstitial;
  final DateTime _startedAt = DateTime.now();
  int _plays = 0;

  static const _kLastShown = 'ad_last_shown';
  static const _kDay = 'ad_day';
  static const _kDayCount = 'ad_day_count';

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  /// Kurallara gore su an tam ekran reklam gosterilebilir mi?
  Future<bool> _allowed() async {
    if (_plays <= AdPolicy.freePlaysPerSession) return false;
    if (DateTime.now().difference(_startedAt) < AdPolicy.startupGrace) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_kLastShown);
    if (last != null &&
        DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(last)) <
            AdPolicy.minInterval) {
      return false;
    }
    final count =
        prefs.getString(_kDay) == _today() ? (prefs.getInt(_kDayCount) ?? 0) : 0;
    return count < AdPolicy.maxPerDay;
  }

  Future<void> _recordShown() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final count =
        prefs.getString(_kDay) == today ? (prefs.getInt(_kDayCount) ?? 0) : 0;
    await prefs.setInt(_kLastShown, DateTime.now().millisecondsSinceEpoch);
    await prefs.setString(_kDay, today);
    await prefs.setInt(_kDayCount, count + 1);
  }

  /// Once kullanici izni (GDPR/KVKK icin Google UMP), sonra SDK baslatma.
  void init() {
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) => _start()),
      (_) => _start(),
    );
  }

  Future<void> _start() async {
    if (ready.value) return;
    await MobileAds.instance.initialize();
    ready.value = true;
    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Kurallar izin veriyorsa tam ekran reklam gosterir; reklam kapaninca
  /// (veya reklam yoksa hemen) tamamlanir. Video oynatmadan ONCE cagrilir,
  /// oynatma sirasinda asla reklam gosterilmez.
  Future<void> maybeShowInterstitial() async {
    _plays++;
    final ad = _interstitial;
    if (ad == null || !await _allowed()) return;
    if (!identical(ad, _interstitial)) return;
    await _recordShown();

    final done = Completer<void>();
    void finish(Ad a) {
      a.dispose();
      _loadInterstitial();
      if (!done.isCompleted) done.complete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: finish,
      onAdFailedToShowFullScreenContent: (a, _) => finish(a),
    );
    _interstitial = null;
    ad.show();
    return done.future;
  }
}

/// Ekranin altina yerlestirilen banner reklam.
class BannerAdBar extends StatefulWidget {
  const BannerAdBar({super.key});

  @override
  State<BannerAdBar> createState() => _BannerAdBarState();
}

class _BannerAdBarState extends State<BannerAdBar> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (AdService.instance.ready.value) {
      _load();
    } else {
      AdService.instance.ready.addListener(_load);
    }
  }

  void _load() {
    if (_ad != null || !AdService.instance.ready.value) return;
    _ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _ad = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    AdService.instance.ready.removeListener(_load);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
