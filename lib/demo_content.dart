import 'models.dart';

/// Demo modu: IPTV hesabı olmayan kullanıcılar ve mağaza inceleme ekipleri
/// için yerleşik örnek içerik. Yalnızca serbestçe kullanılabilen, lisanslı
/// örnek videolar kullanılır:
/// - Apple HLS test yayını (geliştiriciler için herkese açık örnek)
/// - Blender Foundation açık filmleri (Creative Commons Attribution)
class DemoContent {
  /// id -> oynatma adresi (hepsi serbestce kullanilabilen test/ornek yayinlar)
  static const urls = <String, String>{
    'live1':
        'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8',
    'live2': 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
    'vod1': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'vod2':
        'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
    'vod3': 'https://archive.org/download/ElephantsDream/ed_1024_512kb.mp4',
    'ep1': 'https://archive.org/download/ElephantsDream/ed_1024_512kb.mp4',
    'ep2': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'ep3':
        'https://download.blender.org/demo/movies/ToS/tears_of_steel_720p.mov',
  };

  static List<Category> categories(ContentKind kind) => switch (kind) {
        ContentKind.live => const [
            Category(null, 'Tümü'),
            Category('demo', 'Demo yayınlar'),
          ],
        ContentKind.vod => const [
            Category(null, 'Tümü'),
            Category('demo', 'Açık kaynak filmler'),
          ],
        ContentKind.series => const [
            Category(null, 'Tümü'),
            Category('demo', 'Demo diziler'),
          ],
      };

  static List<StreamItem> streams(ContentKind kind) => switch (kind) {
        ContentKind.live => const [
            StreamItem(id: 'live1', name: 'Demo Yayın 1 (Apple HLS test)', kind: ContentKind.live),
            StreamItem(id: 'live2', name: 'Demo Yayın 2 (Canlı test)', kind: ContentKind.live),
          ],
        ContentKind.vod => const [
            StreamItem(id: 'vod1', name: 'Big Buck Bunny (2008)', kind: ContentKind.vod, extension: 'mp4'),
            StreamItem(id: 'vod2', name: 'Tears of Steel (2012)', kind: ContentKind.vod, extension: 'mp4'),
            StreamItem(id: 'vod3', name: 'Elephants Dream (2006)', kind: ContentKind.vod, extension: 'mp4'),
          ],
        ContentKind.series => const [
            StreamItem(id: 'series1', name: 'Blender Açık Filmleri', kind: ContentKind.series),
          ],
      };

  static const episodes = [
    Episode(id: 'ep1', title: 'Bölüm 1 - Elephants Dream', season: '1', extension: 'mp4'),
    Episode(id: 'ep2', title: 'Bölüm 2 - Big Buck Bunny', season: '1', extension: 'mp4'),
    Episode(id: 'ep3', title: 'Bölüm 3 - Tears of Steel', season: '1', extension: 'mp4'),
  ];
}
