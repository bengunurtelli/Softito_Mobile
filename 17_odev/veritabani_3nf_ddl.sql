-- 1. Bölüm Tablosu
CREATE TABLE Bolum (
    bolum_id SERIAL PRIMARY KEY,
    bolum_adi VARCHAR(100) NOT NULL
);

-- 2. Ders Tablosu
CREATE TABLE Ders (
    ders_id SERIAL PRIMARY KEY,
    ders_kodu VARCHAR(10) NOT NULL,
    ders_adi VARCHAR(100) NOT NULL,
    kredi INT NOT NULL
);

-- 3. Öğrenci Tablosu (1-N Bölüm İlişkisi)
CREATE TABLE Ogrenci (
    ogrenci_id SERIAL PRIMARY KEY,
    ogrenci_no VARCHAR(20) NOT NULL,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    bolum_id INT REFERENCES Bolum(bolum_id)
);

-- 4. Öğrenci Ders Ara Tablosu (N-M Çoka Çok İlişki)
CREATE TABLE Ogrenci_Ders (
    ogrenci_id INT REFERENCES Ogrenci(ogrenci_id),
    ders_id INT REFERENCES Ders(ders_id),
    harf_notu VARCHAR(2),
    PRIMARY KEY (ogrenci_id, ders_id)
);