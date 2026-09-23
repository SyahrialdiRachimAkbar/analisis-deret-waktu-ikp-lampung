# DESIGN REVIEW — Proyek Analisis Ketahanan Pangan Lampung

**Tanggal:** 2026-09-23
**Status:** REVIEW DESAIN — belum mengubah data, skrip, atau naskah apa pun
**Peran dokumen:** bahan keputusan untuk penulis + pembimbing/PJ, **bukan** pengganti keputusan mereka
**Reproduksi angka:** `review/review_checks.R` → log `review/review_output.log`

> Semua angka di dokumen ini berasal dari eksekusi nyata terhadap
> `data/lampung_panel_clean.csv` (SHA256 `becc5801…8431`, tidak diubah) dan dari
> publikasi resmi Badan Ketahanan Pangan (2019) *Indeks Ketahanan Pangan Indonesia 2018*.
> **Tidak ada berkas di `data/`, `output/`, `R/`, atau `laporan_draft.md` yang dimodifikasi.**

---

## 0. Ringkasan eksekutif

Rantai analisis (Fase 1–7) dieksekusi bersih dan hasilnya dapat direproduksi. Audit
(`AUDIT.md`) juga jujur. **Namun review ini menemukan tiga hal pada tingkat RANCANGAN
yang membatasi apa pun yang bisa disimpulkan dari hasil tersebut:**

| # | Temuan | Sifat | Dampak |
|---|---|---|---|
| 1 | Dua dari empat variabel X (kemiskinan; dan IPM lewat komponen AHH & RLS perempuan) adalah **indikator penyusun IKP itu sendiri** | Konstruksi indeks | Koefisiennya mengukur identitas komposit + tren, bukan pengaruh |
| 2 | IKP **Kabupaten** (9 indikator) dan IKP **Kota** (8 indikator, bobot berbeda) adalah **dua indeks berbeda**, tetapi di-*pool* dalam satu regresi | Konstruksi indeks | 2 dari 15 unit memiliki Y dengan definisi & bobot berbeda |
| 3 | Spesifikasi utama **tanpa efek tahun**, padahal ~97% gerak *within* IPM adalah tren bersama | Spesifikasi | Klaim utama tidak bertahan di spesifikasi yang benar |

Ketiganya **tidak** terdeteksi oleh audit aritmatika manapun, karena audit mengaudit
angka, bukan rancangan. Status `AUDIT.md` sebagai "LULUS" dan `project_context.md`
yang menandai "Fase 1–7 SELESAI" perlu dibaca bersama temuan ini.

**Kesimpulan rekomendasi:** jangan lanjutkan ke pelaporan naskah/postor sebelum tiga
keputusan rancangan di Bagian 6 diambil.

---

## 1. Yang sudah TERVERIFIKASI (aset yang harus dipertahankan)

Ini bukan temuan negatif — ini kualitas yang harus dipertahankan saat redesign.

### 1.1 Data asli, terlacak ke publikasi sumber

Perbandingan IKP 2018 di `lampung_panel_clean.csv` vs publikasi BKP 2018
(Tabel 4 kabupaten & Tabel 5 kota):

| Pemeriksaan | Hasil |
|---|---|
| 15 kabupaten/kota, IKP tahun 2018 | **15/15 cocok persis** (selisih < 1e-6) |
| Contoh: Pesisir Barat | data 67,99 = publikasi 67,99 |
| Contoh: Kota Metro | data 65,98 = publikasi 65,98 |
| Contoh: Kota Bandar Lampung | data 68,93 = publikasi 68,93 |

**Catatan:** traceability baru diuji untuk **tahun 2018**. Tahun 2019–2024 belum
diverifikasi ke publikasi tahunannya. Lihat aksi A5 di Bagian 6.

### 1.2 Keputusan metodologis yang memang benar

- **Menolak System GMM** dengan N=15 (aturan Roodman 2009: jumlah instrumen ≤ jumlah
  grup) — ini keputusan yang tepat dan justru jarang diambil mahasiswa.
- **Reality check sebelum mengasumsikan dinamika** (Fase 2) — semangatnya sudah benar.
- **Lagged-X, bukan FE + lag-Y** — menghindari bias Nickell; ini pilihan konservatif
  yang tepat.
- **Cluster-robust SE** setelah Wooldridge menunjukkan serial correlation — tepat.
- **Rantai data tunggal** (`01` → `data/` → `02–06` hanya baca) — tidak ada input
  tersembunyi, tidak ada tabel yang diketik tangan.

### 1.3 Integritas proses audit

`AUDIT.md` menolak mengarang (mis. P5: "tidak dapat diselesaikan oleh agen — tidak
akan mengarang nama tabel/halaman"), menandai asumsi secara eksplisit, dan mendokumentasikan
kelemahan parser. Ini di atas rata-rata. Masalahnya bukan kejujuran, melainkan **cakupan
pertanyaan** yang diaudit.

---

## 2. TEMUAN 1 — Variabel X adalah bagian dari definisi Y

### 2.1 Bukti dari dokumen resmi

IKP kabupaten/kota disusun sebagai indeks komposit berbobot (*expert judgement*) dari
9 indikator kabupaten / 8 indikator kota, mewakili tiga aspek: ketersediaan,
keterjangkauan, dan pemanfaatan pangan.

**Bobot indikator IKP KABUPATEN:**

| Indikator | Bobot | Status dalam model ini |
|---|---|---|
| Rasio konsumsi normatif vs ketersediaan bersih | 0,300 | — |
| **Persentase penduduk di bawah garis kemiskinan** | **0,150** | ✅ **X2 proyek ini** |
| RT dengan pengeluaran pangan >65% | 0,075 | — |
| RT tanpa akses listrik | 0,075 | — |
| **Rata-rata lama sekolah perempuan >15 tahun** | **0,050** | ⚠️ komponen IPM |
| RT tanpa akses air bersih | 0,150 | — |
| Rasio penduduk per tenaga kesehatan | 0,050 | — |
| Prevalensi balita stunting | 0,050 | — |
| **Angka harapan hidup saat lahir** | **0,100** | ⚠️ komponen IPM |
| **TOTAL** | **1,000** | |

IPM sendiri adalah indeks komposit AHH + rata-rata lama sekolah + pengeluaran per kapita.
Jadi **dua dari tiga komponen IPM ada di dalam IKP**, dan PDRB per kapita berkorelasi
sangat kuat dengan komponen ketiga (pengeluaran per kapita).

**Konsekuensi:** `kemiskinan` memiliki bobot 15% langsung di dalam Y yang dijelaskan.
Pertanyaan penelitian #1 ("apakah kemiskinan berpengaruh terhadap IKP?") karena itu
**bukan hipotesis yang dapat diuji dengan data ini** — jawabannya sebagian sudah
tertulis di rumus indeks.

### 2.2 Bukti dari data: berapa besar dijelaskan "secara mekanis"

Semua model sudah memuat dummies wilayah (FE), N=105:

| Model | R² | ΔR² |
|---|---|---|
| FE saja (dummies wilayah) | 0,6030 | — |
| **FE + kemiskinan** | **0,8050** | **+0,2020** |
| FE + IPM | 0,8425 | +0,2395 |
| FE + produksi padi | 0,6461 | +0,0431 |
| FE + PDRB | 0,7014 | +0,0984 |
| FE + model utama (IPM + kemiskinan + ln PDRB + ln padi + COVID) | 0,8535 | +0,2505 |
| FE + model utama + year FE | 0,8823 | +0,2793 |

Bacaan: **satu** variabel yang secara konstruksi ada di dalam Y menjelaskan 80,5%.
Empat variabel lain + dummy COVID secara kolektif hanya menambah **4,8 poin persentase**
(0,8535 − 0,8050) di atas kemiskinan saja. Bahkan `year FE` menambah **2,9 poin** —
lebih besar dari kontribusi bersama empat variabel itu.

Angka ini tidak membuktikan "tidak ada apa-apa", tetapi ia menunjukkan bahwa model utama
sebagian besar sedang mengukur **konstruksi indeks + tren waktu**, bukan hubungan
ekonomi antar variabel yang terpisah.

### 2.3 Koefisien kemiskinan sebagai cermin bobot indeks

FE tanpa variabel kontrol lain:

```
koefisien kemiskinan (FE, cluster-robust) = -2,643   p = 0,0000   R² within = 0,8050
```

Tanda negatif, sangat presisi, dan hanya dengan satu regresor. Ini konsisten dengan
kemiskinan masuk ke dalam Y dengan bobot negatif tetap (0,15 setelah standardisasi
z-score & distance-to-scale). **Angka ini tidak boleh ditafsirkan sebagai elastisitas
kebijakan** ("turunkan kemiskinan 1%, IKP naik 2,64 poin").

### 2.4 Konsekuensi untuk interpretasi saat ini

| Klaim di `laporan_draft.md` | Masalah |
|---|---|
| §4.7.2 "Kemiskinan berarah negatif **sesuai teori**" | Bukan konfirmasi teori; sebagian adalah identitas indeks |
| §4.7.1 "IPM adalah pendorong utama yang robust" | Berpotensi tautologis (AHH 0,10 + RLS perempuan 0,05 ada di dalam IKP) |
| §5.2 "IPM berpengaruh positif dan signifikan" | Tidak dapat dibedakan dari "dua indeks bergerak bersama" |
| §7 "Prioritas kebijakan: peningkatan kualitas pembangunan manusia akan meningkatkan ketahanan pangan" | Nyata-nyata tidak didukung oleh desain ini |

---

## 3. TEMUAN 2 — IKP Kota dan IKP Kabupaten adalah dua indeks berbeda

Dokumen BKP menyatakan: untuk **wilayah perkotaan hanya digunakan 8 indikator**
(dari aspek keterjangkauan & pemanfaatan), karena "ketersediaan pangan di tingkat
perkotaan tidak dipengaruhi oleh produksi yang berasal dari wilayah sendiri".
**Bobot aspek ketersediaan (0,30) dihapus lalu dialihkan secara proporsional**:

| Indikator | Bobot KABUPATEN | Bobot KOTA |
|---|---|---|
| Rasio konsumsi normatif vs ketersediaan bersih | 0,300 | **0 (dihapus)** |
| Persentase penduduk di bawah garis kemiskinan | 0,150 | **0,200** |
| Pengeluaran pangan >65% | 0,075 | 0,125 |
| RT tanpa akses listrik | 0,075 | 0,125 |
| Rata-rata lama sekolah perempuan >15 th | 0,050 | 0,080 |
| RT tanpa akses air bersih | 0,150 | 0,180 |
| Penduduk per tenaga kesehatan | 0,050 | 0,080 |
| Prevalensi balita stunting | 0,050 | 0,080 |
| Angka harapan hidup saat lahir | 0,100 | 0,130 |

Juga: *cut off point* pengelompokan berbeda untuk kabupaten (≤41,52 … >75,68) dan
kota (≤28,84 … >70,64).

**Implikasi statistik:** 13 kabupaten dan 2 kota (Bandar Lampung, Metro) diperlakukan
sebagai unit yang identik dalam satu regresi FE. Untuk 2 dari 15 unit, **skala dan bobot
Y berbeda**. Ini adalah penggabungan dua instrumen berbeda.

**Bukti pola data** — lompatan 2022→2023:

```
Delta IKP 2022→2023: rata-rata +2,95, naik di 14/15 wilayah
  Kota Bandar Lampung  +9,96      <- kota (9 indikator -> 8 indikator)
  Kota Metro          +10,31      <- kota
  Tulang Bawang Barat  +4,61      <- kabupaten
  Lampung Timur        +3,65
  ...
  Lampung Utara        -0,06      <- satu-satunya yang tidak naik

Delta kemiskinan 2022→2023: TURUN di 15/15 wilayah
```

Dua kota melompat ~3x rata-rata kabupaten. Pola "semua unit bergerak searah,
kemiskinan turun serentak" menunjukkan perubahan ini lebih mirip **revisi/penyesuaian
seri data** (atau perubahan metodologi/backcasting) daripada kejadian ekonomi 2023.
Ini memperkuat kebutuhan efek tahun (Temuan 3) dan **wajib dikonfirmasi** ke publikasi
Bapanas/BPS (aksi A5).

### 3.2 Hasil estimasi terpisah: 13 kabupaten saja

Kalau 2 kota dibuang (menyisakan 13 kabupaten, n = 91):

| Variabel | FE + COVID | FE + Year FE |
|---|---|---|
| IPM | 1,787 (0,269) p=0,0000 | 0,226 (1,281) p=0,8607 |
| Kemiskinan | −0,440 (0,321) p=0,1745 | 0,033 (0,546) p=0,9519 |
| ln(PDRB) | 3,192 (6,734) p=0,6369 | −3,393 (8,055) p=0,6749 |
| ln(Padi) | 2,616 (1,085) **p=0,0184** | **3,675 (1,467) p=0,0146** |
| COVID | 0,835 (0,581) p=0,1546 | — |

**Catatan penting yang tidak boleh dilewatkan:** pada sampel 13 kabupaten dengan year FE,
satu-satunya koefisien yang signifikan adalah **ln(Padi) (3,675; p = 0,0146)**. Ini
tampak seperti temuan, tetapi justru **paling mencurigakan** di seluruh analisis, karena:

1. Komponen ketersediaan IKP dibekukan pada angka tetap 2014–2016 (Bagian 5) — jadi
   produksi padi tahunan bukan input yang menggerakkan Y.
2. Varians within `produksi_padi` sangat kecil dibandingkan `ikp`
   (`var(within)` = 7,8e8 vs 10,391 pada skala berbeda; lihat `review_output.log` §6),
   sehingga koefisien besar dengan SE sedang mudah muncul dari gerak acak.
3. Angka ini hanya muncul setelah (a) membuang 2 kota **dan** (b) memasukkan year FE —
   kombinasi yang belum pernah dilaporkan, jadi belum teruji ketahanannya.

**Jangan jadikan ini temuan.** Kalau Opsi A ditempuh, ia harus masuk laporan sebagai
"tidak stabil / tidak dapat ditafsirkan", bukan sebagai hasil positif. Uji wajib
sebelum dipakai: WCB pada spesifikasi ini, dan jackknife per kabupaten.

Untuk 2 kota: hanya 14 observasi, sehingga FE dengan 2 dummies wilayah + 5 koefisien
tidak bermakna. Estimasi terpisah untuk kota memerlukan data tambahan (misal kota
se-Sumatera), bukan dijalankan pada n = 14.

---

## 4. TEMUAN 3 — Spesifikasi tanpa efek tahun tidak dapat dipertahankan

### 4.1 year dummies wajib secara statistik

```
F gabungan year dummies (FE+tanpa covid vs FE+year FE)
  Res.Df 86 -> 80 | Df 6 | F = 6,87 | p = 6,6e-06   -> tolak H0 (year dummies perlu)
```

### 4.2 Ukuran masalahnya: 97% gerak within IPM adalah tren bersama

```
R² variasi within (deviasi dari rata-rata wilayah) yang dijelaskan year dummies saja:
  ikp          var(within)= 10,391 | R² thd tahun=0,677 | var sisa= 3,352
  IPM          var(within)=  0,942 | R² thd tahun=0,972 | var sisa= 0,027
  kemiskinan   var(within)=  0,757 | R² thd tahun=0,879 | var sisa= 0,092
  ln_pdrb      var(within)=  0,002 | R² thd tahun=0,677 | var sisa= 0,0005
  ln_padi      var(within)=  0,022 | R² thd tahun=0,309 | var sisa= 0,015
```

Profil within IKP per tahun (deviasi dari rata-rata wilayah):

| 2018 | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 |
|---|---|---|---|---|---|---|
| −4,375 | −1,499 | −0,917 | −0,518 | +0,130 | +3,077 | +4,103 |

Rata-rata per tahun + perubahan YoY:

| Tahun | IKP | ΔIKP | IPM | Kemiskinan |
|---|---|---|---|---|
| 2018 | 74,10 | — | 67,92 | 12,57 |
| 2019 | 76,98 | **+2,88** | 68,51 | 12,09 |
| 2020 | 77,56 | +0,58 | 68,66 | 11,82 |
| 2021 | 77,96 | +0,40 | 68,89 | 12,15 |
| 2022 | 78,61 | +0,65 | 69,51 | 11,12 |
| 2023 | 81,55 | **+2,94** | 70,18 | 10,65 |
| 2024 | 82,58 | +1,03 | 70,87 | 10,19 |

**Perhatikan:** dummy COVID menandai 2020–2021 sebagai *structural break*, tetapi
perubahan pada dua tahun itu (+0,58, +0,40) justru **lebih kecil** daripada tahun
non-COVID 2019 (+2,88) dan 2023 (+2,94). Dummy COVID mengarah ke periode yang salah
untuk alasan yang salah.

### 4.3 Koefisien berubah tanda ketika efek tahun dimasukkan

Cluster-robust (HC1, klaster kabupaten):

| Variabel | FE + COVID (dilaporkan) | FE + **Year FE** |
|---|---|---|
| IPM | **1,959** (SE 0,443) p=0,0000 | **−2,228** (SE 1,648) p=0,1803 |
| Kemiskinan | −0,489 (0,477) p=0,2852 | **+0,781** (0,813) p=0,3393 |
| ln(PDRB) | 13,377 (10,490) p=0,1608 | 1,627 (8,281) p=0,8448 |
| ln(Padi) | 1,557 (1,034) p=0,1534 | 2,527 (1,272) p=0,0504 |
| COVID | 1,242 (0,734) p=0,0652 | — |

**First difference:**

| Model | IPM | Kemiskinan | ln(PDRB) | ln(Padi) |
|---|---|---|---|---|
| FD murni | 1,605 (0,717) **p=0,028** | −0,077 (0,377) | 0,921 (6,376) | −1,727 (1,142) |
| **FD + year dummies** | 0,158 (1,233) **p=0,899** | −0,031 (1,108) | −2,676 (7,763) | — |

Tanda IPM berbalik dan menjadi tidak signifikan pada spesifikasi yang
mengidentifikasi efek dari gerak antarwilayah, bukan dari tren bersama.

### 4.4 Penting: ini BUKAN masalah "N kecil"

Supaya diagnosis tidak salah arah:

- **Jackknife per tahun** (7 run): koef IPM = 1,592 … 2,258; semua p ≤ 0,0012
- **Jackknife per kabupaten** (15 run): koef IPM = 1,708 … 2,203; **15/15 tetap p < 0,05**
- **Pesaran CD** (dependensi lintas wilayah): z = 0,128; **p = 0,898** → tidak ada dependensi

Artinya koefisien stabil terhadap perubahan unit, tetapi rapuh terhadap perubahan
**spesifikasi**. Diagnosis yang benar bukan "sampelnya terlalu kecil", melainkan
**"data ini tidak dapat mengidentifikasi pengaruh variabel X terhadap IKP secara
terpisah dari tren waktu bersama dan dari konstruksi indeks"**. Dua diagnosis ini
memiliki konsekuensi penulisan yang berbeda jauh.

### 4.5 Inferensi dengan G = 15

- **Robust Hausman (Mundlak)**, Wald klaster: W = 24,44; df = 4; p = 6,5e-05
  → kesimpulan tetap FE. **Catatan:** uji Hausman klasik yang dipakai laporan
  (χ² = 57,77; p = 3,5e-11) dijalankan padahal Wooldridge sudah menunjukkan serial
  correlation; bentuk klasiknya tidak sah untuk inferensi. Kesimpulannya kebetulan sama,
  tetapi yang dilaporkan sebaiknya versi robust.
- **Wild cluster bootstrap** (Rademacher, klaster kabupaten, B=999):

| Model | p asymptotik (HC1) | p WCB |
|---|---|---|
| FE + COVID | 0,0000 | **0,109** |
| FE + Year FE | 0,180 | **0,425** |

Dengan G=15, asymptotik terlalu optimistis. Klaim signifikansi "***" pada IPM tidak
bertahan di bawah WCB.

---

## 5. TEMUAN 4 — Produksi padi tidak dapat menjadi input yang "berpengaruh"

Dokumen BKP menyatakan produksi padi, jagung, ubi kayu, dan ubi jalar menggunakan
**angka tetap 2014–2016** dalam penyusunan IKP. Artinya komponen ketersediaan IKP
**dibekukan** selama periode pengamatan dan hampir tidak bergerak antar tahun.

Konsekuensi:
- X4 (produksi padi tahunan BPS) **bukan** input yang menggerakkan Y dalam seri ini.
- Ini menjelaskan mengapa padi tidak signifikan pada model utama.
- Ini juga berarti hasil **lagged-X (3,16; p = 0,042)** pada §4.6 naskah **tidak dapat
  ditafsirkan sebagai "efek tertunda"**. Yang lebih mungkin: lag menyelaraskan pola
  gerak/level, dan dengan hanya 90 observasi efektif hasilnya rapuh.
- Sebagai kontrol: variasi within produksi padi juga kecil dibandingkan variasi within IKP
  (lihat `review_output.log` bagian 6).

---

## 6. Yang TIDAK saya verifikasi (jangan diperlakukan sebagai temuan)

Supaya tidak ada angka yang tampak lebih kuat daripada buktinya:

1. **Dokumen IKP untuk tahun 2019–2024.** Yang saya pegang hanya publikasi 2018
   (9 indikator kabupaten / 8 indikator kota). Bapanas versi terbaru memakai
   **12 indikator** (5 ketersediaan, 4 keterjangkauan, 3 pemanfaatan). Kalau metodologi
   berubah di dalam rentang 2018–2024, maka seri IKP-nya **bukan satu seri yang sama**,
   dan itu harus diungkapkan sebagai keterbatasan eksplisit — atau periode dipotong.
   Ini **aksi paling penting** yang harus dilakukan penulis.
2. **Traceability tahun 2019–2024.** Hanya 2018 yang saya cocokkan ke publikasi.
3. **Satuan & basis PDRB (ADHB/ADHK)** — masih asumsi, sudah ditandai di `AUDIT.md` §4.
4. **Niat dokumen berbahasa Indonesia di atas** (rendah R², kategori "hubungan
   kontemporer") adalah **interpretasi saya**, bukan kutipan. Dokumen BKP tidak
   membahas penaksiran efek.

---

## 7. Rekomendasi — tiga opsi, dan apa yang saya sarankan

Urutan opsi dari paling murah ke paling besar perubahan.

### Opsi A — Perbaiki spesifikasi saja (perubahan paling kecil)

**Lakukan:** tambahkan year FE sebagai model utama, buang dummy COVID, laporkan F
gabungan year dummies, ganti Hausman klasik → robust/Mundlak, tambahkan WCB, laporkan
MDE, dan **turunkan klaim** pada Bab 4–5 serta abstrak.

**Hasil yang bisa dipertahankan:** "tidak ada variabel X yang teridentifikasi berpengaruh
secara robust terhadap IKP ketika efek tahun dan konstruksi indeks diperhitungkan."

**Kelebihan:** cepat, jujur, tidak menghapus pekerjaan Fase 1–7 (justru jadi robustness).
**Kekurangan:** pertanyaan penelitian #1 ("apakah X berpengaruh") hanya dijawab
"tidak teridentifikasi" — secara akademik sah tetapi lemah sebagai kontribusi.
**Cocok untuk:** tugas PSD yang butuh diselesaikan, bukan TA.

### Opsi B — Ganti objek studi: dari skor agregat ke indikator komponen

**Lakukan:** jadikan **indikator penyusun** sebagai variabel terikat (mis. aspek
*pemanfaatan*: akses air bersih, stunting, RLS perempuan, AHH), bukan skor IKP agregat.
Modelkan tiap indikator terhadap faktor penjelas yang **tidak** ada di dalamnya
(geografi, infrastruktur, anggaran, produksi lokal), dengan FE + year FE.

**Kelebihan:** menghilangkan tumpang tindih X-Y secara struktural; pertanyaan penelitian
tetap bermakna; dataset yang sudah dibangun tetap terpakai.
**Kekurangan:** butuh data indikator penyusun (kemungkinan besar tersedia dari Susenas/
Bapanas, tapi perlu pengumpulan ulang); mengubah pertanyaan penelitian.
**Cocok untuk:** topik TA — ini jalur paling kuat secara metodologis.

### Opsi C — Perluas ruang lingkup

Perluas N (mis. se-Sumatera, N ≫ 15) dan/atau pertahankan skor IKP tetapi defensibelkan
dengan efek tahun + klaster yang cukup. Ini juga membuka kembali opsi GMM/dinamis yang
sekarang ditolak karena N.

**Kelebihan:** mengatasi keterbatasan daya statistik sekaligus membuka metode dinamis.
**Kekurangan:** pekerjaan pengumpulan data besar; menunda penyelesaian.
**Cocok untuk:** kalau ini memang diniatkan jadi TA, bukan hanya tugas PSD.

### Saran saya

1. **Kerjakan aksi A1–A4 sekarang** — murah, tidak perlu keputusan pembimbing, dan
   berhenti menyebarkan angka yang menyesatkan dalam bentuk sekarang.
2. **Bawa Bagian 2 & 3 dokumen ini ke pembimbing/PJ** dan minta keputusan **A vs B**.
   Ini keputusan rancangan akademik, bukan keputusan teknis — saya tidak boleh
   memutuskannya untuk penulis.
3. **Kalau ini akan jadi TA → ambil Opsi B.** Opsi A terlalu tipis untuk kontribusi TA;
   Opsi C menunda tanpa jaminan.
4. **Kalau hanya perlu menyelesaikan tugas PSD → Opsi A**, tulis apa adanya termasuk
   bagian "mengapa hasilnya tidak teridentifikasi" — itu nilai plus, bukan kekurangan.

---

## 8. Aksi cepat (murah, dapat dikerjakan sekarang)

| # | Aksi | Risiko kalau ditunda |
|---|---|---|
| A1 | Tambahkan **year FE** sebagai model utama (`R/11_*.R`), laporkan F gabungan year dummies, **buang dummy COVID** dari model utama | Pertanyaan "kenapa efek tahun tidak dimasukkan?" membongkar Bab 4–5 |
| A2 | Turunkan klaim di `laporan_draft.md` Bab 4–5 + abstrak jadi "tidak teridentifikasi" | Klaim saat ini tidak dapat dipertahankan |
| A3 | Hapus/tandai **kemiskinan** dari RHS, atau ubah framing ke dekomposisi indeks | Koefisien −0,49/−2,64 ditafsirkan sebagai elastisitas kebijakan |
| A4 | Estimasi **terpisah 13 kabupaten vs 2 kota** (atau batasi ke 13 kabupaten + sebut alasannya). **Hati-hati:** pada 13 kabupaten + year FE muncul ln(Padi) p=0,0146 — perlakukan sebagai **non-temuan** sampai diuji WCB (lihat §3.2) | Penggabungan dua instrumen berbeda tanpa peringatan |
| A5 | **Cari publikasi IKP Bapanas untuk 2019–2024**; cek apakah metodologi berubah (9 → 12 indikator) di dalam rentang | Seri IKP mungkin tidak komparabel antar tahun |
| A6 | Ganti Hausman klasik → **robust (Mundlak)**; laporkan **WCB** berdampingan dengan asymptotik | Inferensi dengan G=15 terlalu optimistis |
| A7 | Tambahkan **MDE / daya uji**; tandai `ln_pdrb` (var within 0,002) dan `ln_padi` (0,022) sebagai near-zero-signal | Koefisien tak signifikan ditafsirkan sebagai "tidak berpengaruh" |
| A8 | Pindahkan parser **digit-based** (`parse_pdrb` di `R/10`) ke `R/01_clean_data.R`; hapus `* 1000` yang rapuh; re-audit hash | Kebenaran pipeline bergantung pada kebetulan pola string |
| A9 | Sinkronkan `project_context.md` (klaim "Fase 1–7 SELESAI") vs `CHANGELOG.md` (Step 3/4/5 tertunda) | Dokumen saling bertentangan |
| A10 | Inisialisasi **git** + `git config --local user.name/email` (identitas global sengaja kosong) | Tidak ada riwayat perubahan untuk proyek sekompleks ini |

---

## 9. Yang tidak berubah

- `data/lampung_panel_clean.csv` **tidak diubah** — hash SHA256 `becc5801facc6ee6f04a5d1906646a71eaa9e0c45c3cb45c22e6febb506a8431` tetap sama.
- `Data Fix - DATA.csv` tidak diubah — `ad69f257005795e69fe56006f32e913e8231777a6cb66bcb40782cdd7eea0eb5`.
- Skrip `R/01`–`R/10` tidak diubah; audit dan estimasi lama tetap dapat direproduksi apa adanya.
- Hasil yang dilaporkan di `laporan_draft.md` **benar sebagai output kode**; yang
  bermasalah adalah **tafsir dan spesifikasi**, bukan aritmatika.
- `review/review_checks.R` hanya membaca; ia tidak menulis ke `data/` atau `output/`.
