// Cihaz tiplerini belirliyoruz.
enum CihazTipi { sensor, gateway, edgeServer, router }

// Cihaz bulunamadığında kullanacağımız hata sınıfı.
class CihazErisilemezException implements Exception {
  final String mesaj;

  CihazErisilemezException(this.mesaj);

  @override
  String toString() => mesaj;
}

// IoT cihazlarının bilgilerini tutan sınıf.
class IoTCihaz {
  final String seriNo;
  final String cihazAdi;
  final CihazTipi tip;
  final double cpuYukYuzdesi;
  final int bellekMb;
  final Set<String> acikPortlar;
  final bool sslSertifikasiGecerliMi;
  final bool kapaliMi;

  IoTCihaz({
    required this.seriNo,
    required this.cihazAdi,
    required this.tip,
    required this.cpuYukYuzdesi,
    required this.bellekMb,
    required this.acikPortlar,
    required this.sslSertifikasiGecerliMi,
    this.kapaliMi = false,
  });

  // SSL geçersizse veya Telnet portu açıksa güvenlik açığı vardır.
  bool get guvenlikAcigiVarMi =>
      !sslSertifikasiGecerliMi || acikPortlar.contains("23/TELNET");
}

// Seri numarası bulunamazsa kullanılacak hata.
class CihazBulunamadiException implements Exception {
  final String mesaj;

  CihazBulunamadiException(this.mesaj);

  @override
  String toString() => mesaj;
}

// Seri numarasına göre cihaz bilgilerini döndürüyoruz.
// Record ile üç bilgiyi birlikte döndürüyoruz.
({String cihazAdi, CihazTipi tip, bool alarmDurumu}) cihazSorgula(
  String arananSeriNo,
  List<IoTCihaz> liste,
) {
  for (var cihaz in liste) {
    if (cihaz.seriNo == arananSeriNo) {
      bool riskli = cihaz.guvenlikAcigiVarMi || cihaz.cpuYukYuzdesi > 85.0;

      return (cihazAdi: cihaz.cihazAdi, tip: cihaz.tip, alarmDurumu: riskli);
    }
  }

  // Seri numarası listede yoksa hata fırlatıyoruz.
  throw CihazBulunamadiException(
    "$arananSeriNo seri numarali cihaz bulunamadi.",
  );
}

// Cihaz tipine göre izolasyon bölgesini belirliyoruz.
String bolgeKoduGetir(CihazTipi tip) {
  return switch (tip) {
    CihazTipi.sensor => "ZONE-S",
    CihazTipi.gateway => "ZONE-G",
    CihazTipi.edgeServer => "ZONE-E",
    CihazTipi.router => "ZONE-R",
  };
}

// Cihaza bağlanmayı kontrol ediyoruz.
void cihazaBaglan(IoTCihaz cihaz) {
  if (cihaz.kapaliMi) {
    throw CihazErisilemezException(
      "${cihaz.cihazAdi} su anda kapali. Baglanti kurulamadi.",
    );
  }

  print("${cihaz.cihazAdi} cihazina baglanildi.");
}

void main() {
  print("=== IoT Cihaz Yonetimi ===");

  // Cihazları oluşturup listeye ekliyoruz.
  final List<IoTCihaz> iotAgi = [
    IoTCihaz(
      seriNo: "SN-001",
      cihazAdi: "Termostat Sensoru",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 12.5,
      bellekMb: 128,
      acikPortlar: {"80/HTTP"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "SN-002",
      cihazAdi: "Guvenlik Kamerasi",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 45.0,
      bellekMb: 256,
      acikPortlar: {"80/HTTP", "23/TELNET"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "GW-101",
      cihazAdi: "Merkezi Gateway",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 92.4,
      bellekMb: 1024,
      acikPortlar: {"443/HTTPS"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "ES-201",
      cihazAdi: "Veri Sunucusu",
      tip: CihazTipi.edgeServer,
      cpuYukYuzdesi: 60.0,
      bellekMb: 4096,
      acikPortlar: {"8080/TCP"},
      sslSertifikasiGecerliMi: false,
    ),
    IoTCihaz(
      seriNo: "RT-301",
      cihazAdi: "Ana Router",
      tip: CihazTipi.router,
      cpuYukYuzdesi: 30.5,
      bellekMb: 2048,
      acikPortlar: {"22/SSH", "443/HTTPS"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "SN-003",
      cihazAdi: "Hareket Sensoru",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 2.0,
      bellekMb: 64,
      acikPortlar: {},
      sslSertifikasiGecerliMi: true,
      kapaliMi: true,
    ),
  ];

  // Guvenlik acigi olan veya CPU kullanimi %85'i gecen cihazlari buluyoruz.
  final riskliCihazlar = iotAgi
      .where((cihaz) => cihaz.guvenlikAcigiVarMi || cihaz.cpuYukYuzdesi > 85.0)
      .toList();

  print("\n--- Riskli Cihazlar ---");

  for (var cihaz in riskliCihazlar) {
    print(
      "${cihaz.cihazAdi} | CPU: %${cihaz.cpuYukYuzdesi} | Guvenlik Acigi: ${cihaz.guvenlikAcigiVarMi}",
    );
  }

  // Butun cihazlarin bellek kullanimini fold ile topluyoruz.
  final int toplamBellek = iotAgi.fold(
    0,
    (toplam, cihaz) => toplam + cihaz.bellekMb,
  );

  print("\n--- Toplam Bellek ---");
  print("$toplamBellek MB");

  // Record kullanarak cihaz bilgilerini sorguluyoruz.
  print("\n--- Cihaz Sorgulama ---");

  try {
    final sonuc = cihazSorgula("SN-002", iotAgi);

    print("Cihaz Adi: ${sonuc.cihazAdi}");
    print("Cihaz Tipi: ${sonuc.tip.name}");
    print("Alarm Durumu: ${sonuc.alarmDurumu}");
  } on CihazBulunamadiException catch (e) {
    print("Sorgulama Hatasi: $e");
  }

  // Bulunamayan cihazı da kontrol ediyoruz.
  try {
    cihazSorgula("SN-999", iotAgi);
  } on CihazBulunamadiException catch (e) {
    print("Sorgulama Hatasi: $e");
  }

  //  Cihazların izolasyon bölgelerini yazdırıyoruz.
  print("\n--- Izolasyon Bolgeleri ---");

  for (var cihaz in iotAgi) {
    print("${cihaz.cihazAdi} -> ${bolgeKoduGetir(cihaz.tip)}");
  }

  // Acik ve kapali cihazlara baglanmayi deniyoruz.
  print("\n--- Baglanti Kontrolu ---");

  try {
    cihazaBaglan(iotAgi[0]);
    cihazaBaglan(iotAgi[5]);
  } on CihazErisilemezException catch (e) {
    print("Baglanti Hatasi: $e");
  } catch (e) {
    print("Beklenmeyen hata: $e");
  }

  print("\nIslemler tamamlandi.");
}
