// 1. Enumları tanımlıyoruz, böylece belirli değerleri kullanabiliyoruz.
enum HizmetKategorisi { ciltYenileme, medikalEstetik, lazerEpilasyon, Lipo }

// Seansın hangi durumda olduğunu tutuyoruz.
enum SeansDurumu { bekliyor, odadaIslemde, tamamlandi, iptalEdildi }

// Ödeme seçeneklerini belirliyoruz.
enum OdemeYontemi { krediKarti, havaleEft, nakit, klinikPaketKredisi }

// Danışan bilgilerini tutan sınıf.
class Danisan {
  final String id; // Danışanın kayıt numarası.
  final String adSoyad; // Danışanın adı ve soyadı.
  final String telefon; // İletişim numarası.
  final bool vipUyeMi; // VIP olup olmadığını tutar.
  final List<String> alerjiler; // Danışanın alerjilerini tutar.
  final String? ozelCiltNotu; // Varsa özel cilt notunu tutar.

  // Danışan oluştururken gerekli bilgileri alıyoruz.
  const Danisan({
    required this.id,
    required this.adSoyad,
    required this.telefon,
    this.vipUyeMi = false, // Varsayılan olarak VIP değildir.
    this.alerjiler = const [], // Varsayılan alerji listesi boştur.
    this.ozelCiltNotu, // Özel not girilmesi zorunlu değildir.
  });

  // Alerji varsa hassas cilt bilgisini true döndürür.
  bool get hassasCiltMi => alerjiler.isNotEmpty;

  // Danışanın bilgilerini tek bir metinde topluyoruz.
  String get bilgiOzeti {
    // Alerji durumuna göre gösterilecek yazıyı belirliyoruz.
    final String alerjiBilgisi = alerjiler.isEmpty
        ? "Kayıtlı Alerji Yok"
        : "Alerjiler: ${alerjiler.join(', ')}";

    // Not yoksa varsayılan bir mesaj gösteriyoruz.
    final String notBilgisi = ozelCiltNotu ?? "Özel medikal not girilmemiş";

    // Üyelik durumuna göre rozet yazısını seçiyoruz.
    final String vipRozeti = vipUyeMi ? "VİP" : "Standart";

    // Bilgileri birleştirip geri döndürüyoruz.
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi";
  }
}

// Seans ve randevu bilgilerini tutan sınıf.
class SeansKaydi {
  final String seansKodu; // Seansa özel kod.
  final Danisan danisan; // Seansın ait olduğu danışan.
  final HizmetKategorisi kategori; // Yapılacak işlemin kategorisi.
  final String islemAdi; // İşlemin adı.
  final double birimFiyat; // Bir seansın fiyatı.
  final int seansSayisi; // Alınan seans adedi.
  final double indirimOrani; // Uygulanacak indirim yüzdesi.
  final String? sorumluUzman; // İşlemden sorumlu uzman.
  SeansDurumu durum; // Seansın mevcut durumu.
  OdemeYontemi? odemeTipi; // Seçilen ödeme yöntemi.

  // Seans oluştururken gerekli bilgileri alıyoruz.
  SeansKaydi({
    required this.seansKodu,
    required this.danisan,
    required this.kategori,
    required this.islemAdi,
    required this.birimFiyat,
    this.seansSayisi = 1, // Belirtilmezse bir seans kabul edilir.
    this.indirimOrani = 0.0, // Varsayılan indirim sıfırdır.
    this.sorumluUzman, // Uzman bilgisi isteğe bağlıdır.
    this.durum = SeansDurumu.bekliyor, // İlk durum beklemedir.
    this.odemeTipi, // Ödeme yöntemi başlangıçta boş olabilir.
  });

  // Fiyat ile seans sayısını çarparak brüt tutarı buluyoruz.
  double get brutTutar => birimFiyat * seansSayisi;

  // Seans için uygulanacak toplam indirimi hesaplıyoruz.
  double get indirimTutari {
    double toplamOran = indirimOrani; // İşlemin indirim oranını alıyoruz.

    // Danışan VIP ise indirime 10 puan daha ekliyoruz.
    if (danisan.vipUyeMi) {
      toplamOran += 10.0;
    }

    // İndirim tutarını hesaplayıp döndürüyoruz.
    return brutTutar * (toplamOran / 100.0);
  }

  // Brüt tutardan indirimi çıkarıp net fiyatı buluyoruz.
  double get netTutar => brutTutar - indirimTutari;
}

// Klinik işlemlerini yöneten sınıf.
class KlinikYoneticisi {
  final String subeAdi; // Kliniğin şube adı.
  final List<SeansKaydi> _seanslar = []; // Seans kayıtlarını tutar.
  final Map<String, Danisan> _danisanRehberi = {}; // Danışanları ID ile saklar.

  // Yönetici oluşturulurken şube adını alıyoruz.
  KlinikYoneticisi({required this.subeAdi});

  // Yeni danışanı rehbere kaydediyoruz.
  void danisanKaydet(Danisan danisan) {
    _danisanRehberi[danisan.id] = danisan; // Danışanı ID ile ekliyoruz.

    // Kayıt bilgisini ekrana yazdırıyoruz.
    print(
      "Rehbere Eklendi: ${danisan.adSoyad} (${danisan.vipUyeMi ? "VİP" : "Standart"})",
    );
  }

  // Yeni randevuyu seans listesine ekliyoruz.
  void randevuOlustur(SeansKaydi seans) {
    _seanslar.add(seans); // Seansı listeye kaydediyoruz.

    // Eklenen randevunun bilgilerini gösteriyoruz.
    print(
      "Randevu Kaydedildi [${seans.seansKodu}]: ${seans.danisan.adSoyad}->${seans.islemAdi}",
    );
  }

  // Seansı tamamlayıp ödeme bilgisini kaydediyoruz.
  void seansiTamamla({required String seansKodu, required OdemeYontemi odeme}) {
    // Kayıtlı seansları tek tek kontrol ediyoruz.
    for (var seans in _seanslar) {
      // Kod eşleşirse ilgili seansı bulmuş oluyoruz.
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.tamamlandi; // Durumu tamamlandı yapıyoruz.
        seans.odemeTipi = odeme; // Ödeme yöntemini kaydediyoruz.

        // Tahsil edilen net tutarı ekrana yazdırıyoruz.
        print(
          "Seans Tamamlandı: [${seans.seansKodu}]: ${seans.netTutar.toStringAsFixed(2)} tahsil edildi (${odeme.name})",
        );
      }
    }

    // Kod bulunamadığında hata mesajı gösterilmesi amaçlanmıştır.
    print("Hata [$seansKodu] kodlu seans bulunamadı");
    return;
  }

  // İstenen seansı iptal ediyoruz.
  void seansiIptalEt(String seansKodu, {String? iptalNedeni}) {
    // Seans listesinde verilen kodu arıyoruz.
    for (var seans in _seanslar) {
      // Kod eşleşirse seansın durumunu değiştiriyoruz.
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.iptalEdildi;

        // İptal nedenini, varsa, ekrana yazdırıyoruz.
        print(
          "Seans İptal Edildi [${seans.seansKodu}]: ${iptalNedeni ?? "Gerekçe Belirtilmedi"}",
        );
        return; // İşlem bitince metottan çıkıyoruz.
      }
    }
  }

  // Tamamlanan seansların net tutarlarını topluyoruz.
  double get toplamTahsilEdilenCiro => _seanslar
      // Yalnızca tamamlanan seansları seçiyoruz.
      .where((s) => s.durum == SeansDurumu.tamamlandi)
      // Seans tutarlarını toplayıp toplam ciroyu buluyoruz.
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  // Henüz tamamlanmamış seansların olası gelirini hesaplıyoruz.
  double get beklenenPotansiyelCiro => _seanslar
      // Bekleyen ve işlemde olan seansları seçiyoruz.
      .where(
        (s) =>
            s.durum == SeansDurumu.bekliyor ||
            s.durum == SeansDurumu.odadaIslemde,
      )
      // Seçilen seansların net tutarlarını topluyoruz.
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  // Her kategoride kaç seans olduğunu hesaplıyoruz.
  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() {
    // Kategori sayılarını tutacak bir harita oluşturuyoruz.
    final Map<HizmetKategorisi, int> dagilim = {};

    // Bütün kategorileri başlangıçta sıfırlıyoruz.
    for (var kat in HizmetKategorisi.values) {
      dagilim[kat] = 0;
    }

    // Seansları dolaşıp ilgili kategori sayısını artırıyoruz.
    for (var s in _seanslar) {
      dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1;
    }

    // Hesaplanan kategori dağılımını döndürüyoruz.
    return dagilim;
  }

  // Seanslarda görevli olan uzmanları listeliyoruz.
  Set<String> gorevliUzmanKadrosu() {
    return _seanslar
        // Her seanstaki uzman bilgisini alıyoruz.
        .map((s) => s.sorumluUzman)
        // Boş uzman bilgilerini listeden çıkarıyoruz.
        .whereType<String>()
        // Tekrarlanan isimleri kaldırıyoruz.
        .toSet();
  }

  // Henüz uzman atanmamış seansları buluyoruz.
  List<SeansKaydi> uzmansizSeanslariGetir() {
    // Uzman bilgisi null olan seansları seçiyoruz.
    return _seanslar.where((s) => s.sorumluUzman == null).toList();
  }

  // Gün sonu raporunu ekrana yazdırıyoruz.
  void gunSonuRaporuYazdir() {
    print("Günlük Seans ve İşlem Çizelgesi"); // Rapor başlığı.
    print("---------------------------------------"); // Ayırıcı çizgi.

    // Tablo sütunlarının başlıklarını yazdırıyoruz.
    print(
      "${'Kod'.padRight((10))} | "
      "${'Danışan'.padRight(16)} | "
      "${'İşlem'.padRight(20)} | "
      "${'Uzman'.padRight(18)} | "
      "${'Tutar'.padRight(10)} | "
      "${'Durum'} | ",
    );

    print("---------------------------------------"); // Başlık altı çizgisi.

    // Bütün seansları rapora eklemek için dolaşıyoruz.
    for (var s in _seanslar) {
      // Uzman yoksa varsayılan bir ifade kullanıyoruz.
      final String uzman = s.sorumluUzman ?? " Nöbetçi Bekliyor";

      // Seans durumunu okunabilir bir yazıya çeviriyoruz.
      final String durumRozet = switch (s.durum) {
        SeansDurumu.tamamlandi => "Tamamlandı",
        SeansDurumu.odadaIslemde => "İşlemde",
        SeansDurumu.bekliyor => "Bekliyor",
        SeansDurumu.iptalEdildi => "İptal",
      };

      // Seansın bilgilerini aynı satırda gösteriyoruz.
      print(
        "${s.seansKodu.padRight(10)} | "
        "${s.danisan.adSoyad.padRight(10)} | "
        "${s.islemAdi.padRight(10)} | "
        "${uzman.padRight(10)} | "
        "${s.netTutar.toStringAsFixed(2).padRight(10)} | "
        "$durumRozet",
      );
    }

    print("---------------------------------------"); // Raporu ayırıyoruz.
    print("Finansal Özet:"); // Finansal özet başlığını yazdırıyoruz.

    // Tahsil edilen toplam tutarı gösteriyoruz.
    print(
      " * Gerçekleşen (kasadaki net ciro) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)}",
    );

    // Beklenen toplam geliri gösteriyoruz.
    print(
      " * Bekleyen Potansiyen Alacak : ${beklenenPotansiyelCiro.toStringAsFixed(2)}",
    );

    // Toplam randevu sayısını gösteriyoruz.
    print(" * Toplam Seans : ${_seanslar.length} Randevu");
    print("---------------------------------------"); // Ayırıcı çizgi.

    print("Aktif Uzmanlar"); // Uzman listesi başlığını yazdırıyoruz.

    // Kayıtlı uzmanları alıyoruz.
    final uzmanlar = gorevliUzmanKadrosu();

    // Uzman listesi boşsa bilgi mesajı gösteriyoruz.
    if (uzmanlar.isEmpty) {
      print("Kayıtlı Uzman Bulunamadı");
    } else {
      // Uzman isimlerini virgülle ayırarak yazdırıyoruz.
      print(" ${uzmanlar.join(', ')}");
    }

    // Uzman atanmamış seansları buluyoruz.
    final uzmansizlar = uzmansizSeanslariGetir();

    // Uzmansız seans varsa uyarı veriyoruz.
    if (uzmansizlar.isNotEmpty) {
      print(
        "Dikkat: ${uzmansizlar.length} adet seansa henüz uzman atanmamıştır",
      );

      // Uzmanı olmayan seansların bilgilerini tek tek yazdırıyoruz.
      for (var u in uzmansizlar) {
        print("->[${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})");
      }
    }

    print("---------------------------------------"); // Raporun sonu.
  }
}

// Programın çalışmaya başladığı ana fonksiyon.
void main() {
  print("Klinik yönetim sistemi başlatılıyor...."); // Başlangıç mesajı.

  // Klinik yöneticisini ve şube bilgisini oluşturuyoruz.
  final yonetici = KlinikYoneticisi(subeAdi: "Softito Bağcılar Şubesi");

  // Danışan kayıtlarını oluşturuyoruz.
  final d1 = Danisan(
    id: "DAN-101", // Danışan numarası.
    adSoyad: "Ahmet Yılmaz", // Ad ve soyadı.
    telefon: "0555 555 55 55", // Telefon numarası.
    vipUyeMi: true, // VIP üyeliği açık.
    alerjiler: ["Retinol,Aspirin"], // Alerji bilgisi.
    ozelCiltNotu: "Cilt bariyeri hassas", // Ciltle ilgili özel not.
  );

  // İkinci danışanın bilgilerini oluşturuyoruz.
  final d2 = Danisan(
    id: "DAN-102",
    adSoyad: "Ahmet Yılan",
    telefon: "0555 555 55 55",
    vipUyeMi: false, // Standart üyedir.
    alerjiler: [], // Kayıtlı alerjisi yoktur.
  );

  // Üçüncü danışanın bilgilerini oluşturuyoruz.
  final d3 = Danisan(
    id: "DAN-103",
    adSoyad: "Mehmet Yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: true,
    alerjiler: ["Retinol,Aspirin"],
  );

  // Dördüncü danışanın bilgilerini oluşturuyoruz.
  final d4 = Danisan(
    id: "DAN-104",
    adSoyad: "Ahmet Mehmet Yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: true,
    alerjiler: [],
    ozelCiltNotu: "Cilt bariyeri hassas",
  );

  // Oluşturduğumuz danışanları rehbere kaydediyoruz.
  yonetici.danisanKaydet(d1);
  yonetici.danisanKaydet(d2);
  yonetici.danisanKaydet(d3);
  yonetici.danisanKaydet(d4);

  print("Danışan güvenlik kontrolü"); // Kontrol başlığını yazdırıyoruz.

  // İlk iki danışanın özet bilgilerini gösteriyoruz.
  print(d1.bilgiOzeti);
  print(d2.bilgiOzeti);
  print("----------------------------------"); // Ayırıcı çizgi.

  // İlk randevunun bilgilerini oluşturuyoruz.
  final seans1 = SeansKaydi(
    seansKodu: "SNS-2026-1",
    danisan: d1, // İlk danışana ait.
    kategori: HizmetKategorisi.Lipo, // İşlem kategorisi.
    islemAdi: "Lipo gerisini bilmiyorum", // İşlemin adı.
    birimFiyat: 6500.0, // Bir seansın fiyatı.
    seansSayisi: 2, // İki seans alınmış.
    indirimOrani: 5.0, // Yüzde 5 indirim uygulanıyor.
    sorumluUzman: "Sümeyye Arab", // Sorumlu uzman.
  );

  // İkinci randevunun bilgilerini oluşturuyoruz.
  final seans2 = SeansKaydi(
    seansKodu: "SNS-2026-2",
    danisan: d2,
    kategori: HizmetKategorisi.ciltYenileme,
    islemAdi: "Siverex ile tyüz temizleme",
    birimFiyat: 2500.0,
    seansSayisi: 5, // Beş seans alınmış.
    indirimOrani: 15.0, // Yüzde 15 indirim uygulanıyor.
    sorumluUzman: null, // Henüz uzman atanmamış.
  );

  // Üçüncü randevunun bilgilerini oluşturuyoruz.
  final seans3 = SeansKaydi(
    seansKodu: "SNS-2026-3",
    danisan: d3,
    kategori: HizmetKategorisi.lazerEpilasyon,
    islemAdi: "Tüm Vücut",
    birimFiyat: 25000.0,
    seansSayisi: 15, // On beş seans alınmış.
    indirimOrani: 0.0, // İndirim uygulanmıyor.
    sorumluUzman: "Tuba Aydın",
  );

  // Dördüncü randevunun bilgilerini oluşturuyoruz.
  final seans4 = SeansKaydi(
    seansKodu: "SNS-2026-4",
    danisan: d4,
    kategori: HizmetKategorisi.medikalEstetik,
    islemAdi: "Burun Estetiği",
    birimFiyat: 1500.0,
    seansSayisi: 3,
    sorumluUzman: "Alaaddin Odabaşı",
  );

  // Oluşturduğumuz dört randevuyu sisteme ekliyoruz.
  yonetici.randevuOlustur(seans1);
  yonetici.randevuOlustur(seans2);
  yonetici.randevuOlustur(seans3);
  yonetici.randevuOlustur(seans4);

  print("Seanslar Gönderiliyor"); // Randevu işlemlerini bildiriyoruz.

  // İlk seansı kredi kartı ödemesiyle tamamlıyoruz.
  yonetici.seansiTamamla(
    seansKodu: "SNS-2026-1",
    odeme: OdemeYontemi.krediKarti,
  );

  // İkinci seansı nakit ödemeyle tamamlıyoruz.
  yonetici.seansiTamamla(seansKodu: "SNS-2026-2", odeme: OdemeYontemi.nakit);

  // Dördüncü seansı iptal etmeyi deniyoruz.
  yonetici.seansiIptalEt(
    "SNS-2026-04", // Buradaki kod seans4 ile eşleşmiyor.
    iptalNedeni: "Danışanın şehir dışından tanıdığı geldiği için gelemedi",
  );

  // Son durumda gün sonu raporunu yazdırıyoruz.
  yonetici.gunSonuRaporuYazdir();
}
