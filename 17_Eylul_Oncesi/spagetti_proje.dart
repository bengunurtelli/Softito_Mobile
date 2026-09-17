// URUN SINIFLARI

// Urun sinifi sadece urunun temel bilgilerini tutar.Siparis, odeme, mail veya kargo islemleriyle ilgilenmez. Bu sayede SRP'ye (Single Responsibility Principle) uygun olur.
abstract class Urun {
  String id;
  String ad;
  double fiyat;
  int stok;
  String tip;

  Urun(this.id, this.ad, this.fiyat, this.stok, this.tip);
}

// Fiziksel urunlerin kargo ucreti vardir.
class FizikselUrun extends Urun {
  FizikselUrun(String id, String ad, double fiyat, int stok)
    : super(id, ad, fiyat, stok, "FIZIKSEL");

  double kargoUcretiHesapla() {
    return 29.90;
  }
}

// Dijital urun fiziksel kargo gerektirmez. Bu nedenle fiziksel urunun kargo metodunu override edip Exception firlatmak yerine ayri bir sinif olarak tasarlanmistir.
// Boylece LSP (Liskov Substitution Principle) ihlali ortadan kalkar.
class DijitalUrun extends Urun {
  DijitalUrun(String id, String ad, double fiyat, int stok)
    : super(id, ad, fiyat, stok, "DIJITAL");
}

// ODEME

// OCP ve DIP icin ortak odeme arayuzu. SiparisYoneticisi artik somut odeme siniflarini bilmek zorunda degil.
abstract class IOdemeYontemi {
  void odemeYap(double tutar);
}

class KrediKartiOdeme implements IOdemeYontemi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Kredi kartindan POS ile cekildi.");
  }
}

class HavaleOdeme implements IOdemeYontemi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Havale kontrol edildi.");
  }
}

class KapidaOdeme implements IOdemeYontemi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL Kapida odeme tahsil edilecek (Komisyon +15 TL).");
  }
}

class CryptoOdeme implements IOdemeYontemi {
  @override
  void odemeYap(double tutar) {
    print("$tutar TL USDT transferi onaylandi.");
  }
}

// VERITABANI
// SiparisYoneticisi'nin dogrudan SqliteVeritabani'na bagimli olmasini engellemek icin abstraction kullaniyoruz.Bu DIP (Dependency Inversion Principle) uygulamasidir.
abstract class ISiparisRepository {
  void siparisKaydet(String orderId, double tutar);
}

class SqliteVeritabani implements ISiparisRepository {
  @override
  void siparisKaydet(String orderId, double tutar) {
    print(
      "DB calistirildi: INSERT INTO siparisler VALUES ('$orderId', $tutar)",
    );
  }
}
// MAIL

abstract class IMailServisi {
  void mailGonder(String to, String body);
}

class SmtpMailServisi implements IMailServisi {
  @override
  void mailGonder(String to, String body) {
    print("SMTP Mail gonderildi: $to");
  }
}
// SMS

abstract class ISmsServisi {
  void smsGonder(String gsm, String text);
}

class NetgsmSmsServisi implements ISmsServisi {
  @override
  void smsGonder(String gsm, String text) {
    print("SMS iletildi: $gsm");
  }
}

// KARGO
abstract class IKargoServisi {
  void kargoGonder(String orderId, String adres);
}

class MngKargoServisi implements IKargoServisi {
  @override
  void kargoGonder(String orderId, String adres) {
    print("MNG Kargo takip fis basildi: $adres");
  }
}
// FATURA

abstract class IFaturaServisi {
  void faturaYazdir(String orderId);
}

class PdfFaturaServisi implements IFaturaServisi {
  @override
  void faturaYazdir(String orderId) {
    print("Fatura PDF cikarildi: $orderId");
  }
}
// SIPARIS YONETICISI

// SiparisYoneticisi artik her isi kendisi yapmiyor.Veritabani, odeme, mail, SMS, kargo ve fatura islemlerini ilgili servislerden istiyor. Bu durum SRP ve DIP prensiplerine uygundur.
class SiparisYoneticisi {
  final ISiparisRepository repository;
  final IOdemeYontemi odemeYontemi;
  final IMailServisi mailServisi;
  final ISmsServisi smsServisi;
  final IKargoServisi kargoServisi;
  final IFaturaServisi faturaServisi;

  // Bagimliliklar constructor araciligiyla disaridan veriliyor.Boylece SiparisYoneticisi somut siniflara bagimli degil.
  SiparisYoneticisi({
    required this.repository,
    required this.odemeYontemi,
    required this.mailServisi,
    required this.smsServisi,
    required this.kargoServisi,
    required this.faturaServisi,
  });

  void siparisTamamla(
    String orderId,
    List<Urun> sepet,
    String musteriAdi,
    String email,
    String tel,
    String adres,
    String kuponKodu,
  ) {
    double toplam = 0;

    for (var i = 0; i < sepet.length; i++) {
      if (sepet[i].stok <= 0) {
        print("Hata: ${sepet[i].ad} tukenmis!");
        return;
      }

      toplam += sepet[i].fiyat;

      // Sadece fiziksel urunler kargo ucreti alir. Dijital urunlerde kargo hesaplamasi yapilmaz.
      if (sepet[i] is FizikselUrun) {
        toplam += (sepet[i] as FizikselUrun).kargoUcretiHesapla();
      }

      sepet[i].stok--;
    }
    // KUPON KONTROLU
    if (kuponKodu == "INDIRIM10") {
      toplam = toplam * 0.90;
    } else if (kuponKodu == "YAZ20") {
      toplam = toplam * 0.80;
    } else if (kuponKodu == "SEPETTE50") {
      toplam = toplam - 50;
    }
    double kdv = toplam * 0.20;
    double sonTutar = toplam + kdv;

    // DIGER ISLEMLER
    // Odeme islemi artik SiparisYoneticisi tarafindanif/else ile secilmiyor.Bu sayede OCP ihlali giderildi.
    odemeYontemi.odemeYap(sonTutar);

    repository.siparisKaydet(orderId, sonTutar);
    faturaServisi.faturaYazdir(orderId);
    mailServisi.mailGonder(
      email,
      "Sayin $musteriAdi, siparisiniz alindi. "
      "Tutar: $sonTutar TL",
    );
    smsServisi.smsGonder(tel, "Siparisiniz onaylandi: $orderId");
    kargoServisi.kargoGonder(orderId, adres);
  }
}

// ============================================================
// MAIN
// ============================================================

void main() {
  // Fiziksel urun
  var urun1 = FizikselUrun("1", "Kablosuz Mouse", 450.0, 5);

  // Dijital urun
  var urun2 = DijitalUrun("2", "Flutter Kursu E-Kitap", 150.0, 100);

  var sepet = <Urun>[urun1, urun2];

  // ==========================================================
  // BAGIMLILIKLAR BURADA OLUSTURULUYOR
  // ==========================================================

  var siparisci = SiparisYoneticisi(
    repository: SqliteVeritabani(),

    // Hangi odeme yonteminin kullanilacagini
    // burada belirliyoruz.
    odemeYontemi: KrediKartiOdeme(),

    mailServisi: SmtpMailServisi(),

    smsServisi: NetgsmSmsServisi(),

    kargoServisi: MngKargoServisi(),

    faturaServisi: PdfFaturaServisi(),
  );

  siparisci.siparisTamamla(
    "SP-9921",
    sepet,
    "Selahaddin",
    "selahaddin@kodvance.com",
    "05551112233",
    "Kadikoy / Istanbul",
    "INDIRIM10",
  );
}
