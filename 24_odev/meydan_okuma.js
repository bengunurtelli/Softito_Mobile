const mevcutYuzde = 30;
const hedefYuzde = 80;
const bataryaKW = 60;
const istasyonKW = 22;

const doldurulacakYuzde = hedefYuzde - mevcutYuzde;
const doldurulacakKW = bataryaKW * doldurulacakYuzde / 100;

const sarjSuresiSaat = doldurulacakKW / istasyonKW;
const sarjSuresiDakika = sarjSuresiSaat * 60;

console.log("Tahmini sarj suresi: " + sarjSuresiDakika + " dakika");
//--------------------------------------------------------------------
//Eğer kullanıcıdan veriler alınacaksa,
/*const mevcutYuzde = Number(prompt("Mevcut yuzdeyi giriniz:"));
const hedefYuzde = Number(prompt("Hedef yuzdeyi giriniz:"));
const bataryaKW = Number(prompt("Batarya kapasitesini giriniz:"));
const istasyonKW = Number(prompt("Istasyon gucunu giriniz:"));

const doldurulacakYuzde = hedefYuzde - mevcutYuzde;
const doldurulacakKW = bataryaKW * doldurulacakYuzde / 100;

const sarjSuresiSaat = doldurulacakKW / istasyonKW;
const sarjSuresiDakika = sarjSuresiSaat * 60;

console.log("Tahmini sarj suresi: " + sarjSuresiDakika + " dakika");*/
//--------------------------------------------------------------------
//Gece fiyatlandırması ayrı gündüz fiyatlandırması ayrı olacak şekilde tarife eklemek
/* const mevcutYuzde = 30;
const hedefYuzde = 80;
const bataryaKW = 60;
const istasyonKW = 22;

const doldurulacakYuzde = hedefYuzde - mevcutYuzde;
const doldurulacakKW = bataryaKW * doldurulacakYuzde / 100;

const sarjSuresiSaat = doldurulacakKW / istasyonKW;
const sarjSuresiDakika = sarjSuresiSaat * 60;

console.log("Tahmini sarj suresi: " + sarjSuresiDakika + " dakika");


const gunduzTarife = 8;
const geceTarife = 5;

const saat = 23;

let tarife;

if (saat >= 22 || saat < 6) {
    tarife = geceTarife;
} else {
    tarife = gunduzTarife;
}

const toplamUcret = doldurulacakKW * tarife;

console.log("Toplam sarj ucreti: " + toplamUcret + " TL"); */
//Mantığı:22:00 - 05:59 → gece tarifesi 06:00 - 21:59 → gündüz tarifesi
//------------------------------------------------------------------
//Veriler kullanıcıdan alınacaksa gece ve gündüz tarifesi eklenmiş hali
/*const mevcutYuzde = Number(prompt("Mevcut yuzdeyi giriniz:"));
const hedefYuzde = Number(prompt("Hedef yuzdeyi giriniz:"));
const bataryaKW = Number(prompt("Batarya kapasitesini giriniz:"));
const istasyonKW = Number(prompt("Istasyon gucunu giriniz:"));
const saat = Number(prompt("Saati giriniz:"));

const doldurulacakYuzde = hedefYuzde - mevcutYuzde;
const doldurulacakKW = bataryaKW * doldurulacakYuzde / 100;

const sarjSuresiSaat = doldurulacakKW / istasyonKW;
const sarjSuresiDakika = sarjSuresiSaat * 60;

console.log("Tahmini sarj suresi: " + sarjSuresiDakika + " dakika");

const gunduzTarife = 8;
const geceTarife = 5;

let tarife;

if (saat >= 22 || saat < 6) {
    tarife = geceTarife;
} else {
    tarife = gunduzTarife;
}

const toplamUcret = doldurulacakKW * tarife;

console.log("Toplam sarj ucreti: " + toplamUcret + " TL");*/

/*Mantığı:
 Girdiler
   ↓
Şarj edilecek yüzdeyi hesapla
   ↓
Şarj edilecek kW'ı hesapla
   ↓
Şarj süresini hesapla
   ↓
Saat bilgisine bak
   ↓
Gece mi gündüz mü?
   ↓
Tarifeyi belirle
   ↓
Toplam ücreti hesapla
   ↓
Sonucu ekrana yazdır.*/
