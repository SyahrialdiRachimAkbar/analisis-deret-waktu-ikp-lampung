# CONTEXT: Proyek Analisis Ketahanan Pangan Lampung

## 1. Latar Belakang
Proyek akademik (tugas PSD / calon topik TA) yang melanjutkan proyek Kerja Praktik (KP).
Tujuan: menganalisis faktor-faktor yang memengaruhi Indeks Ketahanan Pangan (IKP)
kabupaten/kota di Provinsi Lampung.

## 2. Pertanyaan Penelitian
1. Apakah IPM, persentase kemiskinan, PDRB per kapita, dan produksi padi
   berpengaruh terhadap Indeks Ketahanan Pangan?
2. Apakah ada efek dimensi waktu — yaitu apakah kondisi tahun sebelumnya
   memengaruhi kondisi tahun berjalan?

## 3. Data
- Jenis: **Data panel** (banyak objek x banyak waktu)
- Unit cross-section: **15 kabupaten/kota Provinsi Lampung** (N = 15)
- Periode: **2018-2024** (T = 7)
- Total observasi: **105 baris**
- Struktur: 1 baris = 1 kabupaten x 1 tahun

### Kolom yang tersedia:
| Kolom | Deskripsi | Skala | Sumber |
|---|---|---|---|
| Kabupaten/Kota | Nama unit | kategorik | - |
| Tahun | 2018-2024 | - | - |
| Indeks Ketahanan Pangan | **Variabel Y** | 0-100 | Bapanas |
| PDRB per Kapita (Ribu) | **Variabel X** | rupiah | BPS Prov. Lampung |
| IPM | **Variabel X** | 0-100 | BPS Prov. Lampung |
| Kemiskinan (%) | **Variabel X** | persen | BPS Prov. Lampung |
| Produksi Padi (Ton) | **Variabel X** | ton | BPS Prov. Lampung |

Catatan: file data asli berbentuk spreadsheet, perlu di-reshape jadi long format
(panel) jika belum. File yang tersedia saat ini: `Data Fix - DATA.csv`.

## 4. Keputusan Metodologis (PENTING — sudah dianalisis dan diputuskan)

### System GMM DITOLAK, alasannya:
- Rencana awal memakai Dynamic Panel System GMM untuk menangkap efek dinamis
- Masalah: N = 15 terlalu kecil. GMM membentuk instrumen dari lag variabel,
  jumlahnya tumbuh cepat dan bisa mencapai puluhan instrumen
- Aturan (Roodman, 2009 — "A Note on the Theme of Too Many Instruments"):
  **jumlah instrumen tidak boleh melebihi jumlah grup (N)**
- Jika dilanggar: overfitting instrumen, uji Hansen/Sargan kehilangan power
  (p-value ~1.0 = pertanda BURUK, bukan valid)
- Kesimpulan: GMM tidak defensible dengan N=15, kecuali wilayah diperluas
  (misal se-Sumatera, N ~100+)

### Namun TIDAK menambah N — tetap di 15 kabupaten/kota

## 5. ROADMAP ANALISIS (yang harus dieksekusi)

### FASE 1 — Persiapan Data
1. Reshape data jadi long format: `kabupaten | tahun | IKP | IPM | kemiskinan | PDRB | padi`
2. Transformasi: **log-kan PDRB per kapita dan produksi padi**
   - Alasan: skala besar & distribusi miring (Bandar Lampung outlier),
     interpretasi jadi elastisitas
3. Buat **dummy COVID**: kolom `covid` = 1 untuk tahun 2020-2021, sisanya 0
   - Alasan: 2020-2021 adalah structural break
4. EDA: plot tren IKP 15 kabupaten, scatter X vs Y, cek outlier

### FASE 2 — Reality Check: Statis atau Dinamis?
- Hitung korelasi / regresi `IKP(t)` terhadap `IKP(t-1)`
- **Jika korelasi < 0.5** -> dinamika lemah -> pakai static panel murni (Fase 3-4)
- **Jika korelasi > 0.7** -> dinamika nyata -> tambahkan Fase 5
- JANGAN asumsikan efek dinamis tanpa uji — ini hipotesis, bukan asumsi

### FASE 3 — Pemilihan Model
Estimasi 3 model: Pooled OLS, Fixed Effect (FE), Random Effect (RE)
Lalu jalankan uji:
- **Uji Chow**: FE vs Pooled (signifikan -> efek individu ada)
- **Uji LM Breusch-Pagan**: RE vs Pooled
- **Uji Hausman**: FE vs RE (signifikan -> FE menang)

Prediksi: hampir pasti **FE menang**, karena karakteristik bawaan kabupaten
(geografis, kesuburan) berkorelasi dengan IPM/PDRB/produksi padi.

### FASE 4 — Estimasi Utama
Model:
- Gunakan **cluster-robust standard error** (cluster per kabupaten)
  - Alasan: autokorelasi antar tahun dalam kabupaten + heteroskedastisitas
- Diagnostik wajib:
  - **VIF** (curiga IPM <-> PDRB multikolinear — VIF > 10 = bahaya)
  - Modified Wald test (heteroskedastisitas)
  - Wooldridge test (autokorelasi)
  - Normalitas residual (kurang kritis, catat saja)

### FASE 5 — HANYA jika dinamika terbukti (dari Fase 2)
Pilih SALAH SATU:
- **Opsi A (DIREKOMENDASIKAN): lagged X** — variabel X di-lag 1 tahun, Y tidak.
  Tetap static FE, 100% aman secara metode, teori masuk akal (efek tertunda)
- **Opsi B: Bias-Corrected LSDV** (Bruno, 2005) — FE + koreksi bias analitis
- **Opsi C: FE + lag Y biasa** — boleh asal bias Nickell diakui di keterbatasan

### FASE 6 — Robustness Check
- Tanpa dummy COVID -> bandingkan koefisien
- Buang tahun 2020-2021
- Tukar IPM/PDRB jika VIF bermasalah
- Dengan vs tanpa lag (jika pakai Fase 5)

### FASE 7 — Pelaporan
- Framing: "indikasi pengaruh", BUKAN "membuktikan kausalitas"
- Bahas keterbatasan sampel kecil secara eksplisit
- Sertakan alasan tidak memakai GMM (nilai plus, bukan minus)

## 6. Alasan Teoretis Pemilihan Variabel X
- **Kemiskinan naik** -> sulit akses pangan (daya beli rendah)
- **IPM naik** -> kesadaran gizi naik (aspek "pemanfaatan pangan")
- **PDRB per kapita naik** -> daya beli naik -> akses pangan naik
- **Produksi padi naik** -> ketersediaan pangan naik (aspek "ketersediaan")
- Catatan: 4 variabel ini baru mencakup 2 dari 4 pilar FAO
  (ketersediaan & akses & pemanfaatan; "stabilitas" belum terwakili).
  Pertimbangkan tambah inflasi/IHK jika memungkinkan.

## 7. Tools & Software
- **R 4.5.2** terpasang di `C:\Program Files\R\R-4.5.2` (belum di PATH, panggil via full path `Rscript.exe`)
- Package terpasang: `plm`, `sandwich`, `lmtest`, `readxl`, `ggplot2`
- Preferensi awal `plm` untuk panel, `lmtest`/`sandwich` untuk cluster SE — TERPENUHI

## 8. Status Saat Ini

> **DIPERBARUI 2026-09-23 (setelah review desain + revisi Fase 2).** Status di bawah menggantikan
> klaim lama "Fase 1–7 SELESAI". Fase 1–7 **selesai untuk desain lama**; desain dirancang ulang
> setelah review 23 Sep 2026. Lihat `review/DESIGN_REVIEW.md`, `review/PLAN.md`, `LAPORAN_rev.md`.

- Data sudah dikumpulkan (BPS + Bapanas) dan **lolos verifikasi ke sumber primer**:
  IKP 2018 vs publikasi BKP 2018 (Tabel 4 & 5) = **15/15 cocok persis** (skor + peringkat);
  IKP 2019–2024 vs Satu Data Lampung = 85/90 (94%).
- **Fase 1 SELESAI (desain lama)** — cleaning + reshape + log + dummy COVID -> `data/lampung_panel_clean.csv` (105 baris, 15 wilayah, 7 tahun, 0 NA).
- **Fase 2 SELESAI (desain lama)** — reality check: korelasi pooled IKP(t) vs IKP(t-1) = 0.879; koef lag within/FE = 0.619 (p<0.001).
- **Fase 3 SELESAI (desain lama)** — Hausman klasik p=3.5e-11 -> FE menang. **Catatan revisi:** bentuk klasik tidak sah karena Wooldridge p=0.005 (korelasi serial); versi robust (Mundlak) W=24.44, p=6,5e-05 -> kesimpulan sama.
- **Fase 4 SELESAI (desain lama)** — FE + cluster-robust SE; VIF within aman (<5.4); Wooldridge p=0.005.
- **Fase 5 SELESAI (desain lama)** — lagged-X (Opsi A) diestimasi.
- **Fase 6 SELESAI (desain lama)** — robustness: tanpa COVID, tanpa 2020-21, dengan vs tanpa lag.
- **Fase 7 SELESAI (draft lama)** — `laporan_draft.md` (dipertahankan sebagai jejak proses, tidak diubah).
- **REVISI FASE 2 SELESAI (2026-09-23)** — `R/11_year_fe_inference.R` dijalankan (exit 0), log `output/11_year_fe.log`, 4 tabel CSV di `output/`. Isi: efek tahun sebagai model utama, F gabungan year dummies, robust Hausman (Mundlak), WCB Rademacher B=999, Driscoll-Kraay, MDE, estimasi terpisah 13 kab vs 2 kota, R2 ladder, spesifikasi RHS bersih.
- **REVISI NASKAH SELESAI** — `LAPORAN_rev.md` (Bab 3–7 ditulis ulang, klaim diturunkan).
- ⬜ **BELUM:** verifikasi metodologi IKP per tahun 2019–2024 (apakah indikator berubah di tengah rentang 2018–2024). Hanya 2018 yang tertelusuri ke publikasi primer. Ini aksi paling penting yang masih terbuka.
- ⬜ **BELUM diputuskan (perlu pembimbing):** boleh/tidak mengeluarkan kemiskinan dari RHS — ini mengubah rumusan masalah.
- ⬜ **BELUM:** API key BPS WebAPI (`webapi.bps.go.id/developer`, pakai email user; tanpa key diblokir WAF) kalau ingin menambah X bersih.
- ⬜ Belum konfirmasi: output final project (kontrak tugas dari dosen), kemungkinan bentuknya poster — perlu dikonfirmasi ke PJ kelas.

### Angka utama setelah revisi (jangan pakai angka lama)

| Spesifikasi | IPM coef | SE | p |
|---|---|---|---|
| FE + COVID (dilaporkan draft lama) | 1,959 | 0,443 | 0,0000 |
| FE + full year FE (**model benar**) | **−2,228** | 1,648 | **0,180** |
| FD murni | 1,605 | 0,717 | 0,028 |
| FD + year dummies | 0,158 | 1,233 | 0,899 |

WCB (Rademacher, klaster kabupaten, B=999): FE+COVID **p = 0,109**; FE+YearFE p = 0,425.
RHS bersih + year FE (N=105): ln(PDRB) 2,83 (p=0,740; WCB 0,747), ln(Padi) 2,77 (p=0,010; **WCB 0,249**).
**Tidak ada koefisien yang bertahan WCB.** MDE IPM = 5,11 SD within; MDE ln(PDRB) = 608 SD within.
**JANGAN laporkan ln(Padi) = 3,675 (p = 0,0146)** — non-finding (WCB p = 0,192).


## 9. Struktur File yang Dihasilkan
```
R/01_clean_data.R          # cleaning + reshape + log + covid
R/02_reality_check.R       # korelasi/lag IKP (Fase 2)
R/03_model_selection.R     # Pooled/FE/RE + Chow/LM/Hausman (Fase 3)
R/04_main_estimation.R     # FE + cluster-robust + VIF/Wooldridge/BP/normalitas (Fase 4)
R/05_robustness.R          # lagged-X + robustness (Fase 5-6)
R/06_descriptives.R        # statistik deskriptif + plot tren IKP (Fase 1/7)
data/lampung_panel_clean.csv
output/fase1_tren_ikp.pdf
output/fase2_ikp_lag.pdf
laporan_draft.md           # draft makalah lengkap (Fase 7)
```

## 10. HASIL ESTIMASI (Fase 4-6) — **SUPERSEDED, JANGAN DIKUTIP**

> ⚠️ **Bagian ini adalah hasil desain lama dan sudah tidak dipakai.** Angka di bawah benar sebagai
> keluaran kode `R/04`–`R/06`, tetapi **spesifikasinya cacat**: (a) tanpa efek tahun, padahal efek
> tahun menjelaskan 97,2% gerak within IPM; (b) dua dari empat X adalah indikator penyusun IKP;
> (c) inferensi memakai p asymptotik padahal G=15 (WCB memberi p = 0,109, bukan 0,0000).
> **Yang berlaku adalah Bab 4 `LAPORAN_rev.md` + `output/11_year_fe.log`.** Bagian ini dipertahankan
> hanya sebagai jejak proses.

### Model terpilih: Fixed Effect, cluster-robust SE (HC3, cluster kabupaten)
`IKP ~ IPM + Kemiskinan + ln(PDRB) + ln(Padi) + covid` | R2 within = 0.631

| Variabel | Main FE | tanp COVID | tanp 2020-21 | Lagged-X(t-1) |
|---|---|---|---|---|
| IPM | **1.96*** | **2.14*** | **2.13**** | **1.26**** |
| Kemiskinan | -0.49 | -0.33 | -0.32 | -1.09 (p=.067) |
| ln(PDRB) | 13.38 | 4.70 | 13.55 | 4.83 |
| ln(Padi) | 1.56 | 1.50 (p=.093) | 1.24 | **3.16*** |
| COVID | 1.24 (p=.065) | - | - | -0.73 |

*p<.05, **p<.01, ***p<.001

### Temuan utama
1. **IPM satu-satunya prediktor yang konsisten & signifikan positif** terhadap IKP di semua spesifikasi.
2. **Kemiskinan** arah negatif (sesuai teori) tapi tidak signifikan.
3. **ln(PDRB)** tidak stabil — sangat sensitif terhadap dummy COVID -> efeknya terbaur dengan waktu.
4. **ln(Padi)** baru signifikan saat di-lag 1 tahun -> indikasi efek tertunda (dinamis lemah).
5. **COVID** positif marginal (p=.065) pada model utama, tapi negatif-tidak signifikan saat lag -> tidak stabil.
6. Diagnostik: serial correlation ada (Wooldridge p=.005) -> cluster-robust SE tepat. Tidak ada hetero (BP p=.97). VIF within <5.4 (aman).

## 11. Tugas Berikutnya (untuk AI agent)
1. ~~Bantu cleaning & reshaping data ke format panel~~ SELESAI
2. ~~Buat syntax R lengkap untuk Fase 1-6~~ SELESAI
3. ~~Jalankan, interpretasi hasil~~ SELESAI
4. Bantu drafting laporan/poster (Fase 7)
5. Konfirmasi format output final ke PJ kelas

## 12. Catatan Kualitas Data (dari `Data Fix - DATA.csv`)
Dataset mentah belum sepenuhnya bersih:
1. **Header multi-line** (baris 1-5) perlu digabung menjadi satu baris header.
2. **Kode Wilayah kosong** pada baris tahun 2019-2024 -> perlu forward-fill dari baris 2018.
3. **Pemisah desimal tidak konsisten:**
   - Sebagian memakai koma desimal: `"70,76"`, `"13,54"`
   - Sebagian memakai titik desimal: `15.759`, `16.44`, `27.77`
4. **Pemisah ribuan titik** pada angka besar: `"81.355,00"`, `"155,711,37"` -> konflik dengan aturan desimal koma.
5. **Nilai rusak:** baris 57 (`215.987.34`) tidak valid (dua titik) -> kemungkinan `215.987,34`.
6. **Desimal berlebih:** baris 109 `29.992,775` (tiga angka desimal).
7. Kolom `Kabupaten/Kota` + `Tahun` dijadikan kunci wilayah.

> Setiap nilai numerik sebaiknya dinormalisasi: buang pemisah ribuan, ubah koma desimal ke titik, lalu cast ke float.
