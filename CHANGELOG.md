# CHANGELOG

Semua perubahan terhadap naskah, skrip, dan artefak dicatat di sini.
Format: tanggal — item — apa yang berubah — kenapa — dampak ke kesimpulan.

---

## 2026-10-06 — Revisi hasil evaluasi: reproduksi dan rekonsiliasi

- Integritas input memakai SHA256 teks LF untuk menghindari kegagalan clone akibat
  CRLF/LF. Hash byte lokal tetap dicatat; perubahan angka tetap ditolak. Ditambahkan
  .gitattributes dan pemeriksaan regresi akhir baris.
- Tahun wajib numerik bulat dan finite sebelum konversi. Catatan status backtest
  mengikuti parameter minimal latihan, tanpa angka 4 yang tertanam dalam status.
- Lima selisih sumber direkonsiliasi dengan URL/lokasi/tingkat bukti. Tanggamus 2020
  dikoreksi dari 76,67 menjadi 74,67 hanya pada salinan analisis. Nilai asal tetap
  tersedia dan sumber/arsip tidak ditulis ulang. Kecocokan provinsi 85/90 → 86/90.
- Rata-rata kabupaten 2020 78,08 → 77,926154; SD 4,161991 → 4,254393. Tanggamus
  memiliki SD perubahan 4,574981 dan satu tahun turun sesudah koreksi.
- Uji sensitivitas sumber dan pengeluaran satu target diperluas. Tanpa target 2022,
  drift unggul pada MAE; urutan metode tidak dinyatakan berlaku umum.
- Metodologi 2018 diperiksa ulang dengan pdfminer.six yang sudah tersedia. Cuplikan
  primer 2019 memberi bukti parsial; akses penuh 2019 dan publikasi teknis 2024
  belum berhasil. Parameter normalisasi identik/harmonisasi tetap tidak diklaim.
- Versi 16 dependensi runtime dikunci melalui renv.lock dan manifest; penyiapan
  eksplisit memakai renv di .library/. Tidak ada dependensi baru dipasang pada sesi
  analisis lokal. CI Windows/Linux, kamus data, dan petunjuk reproduksi ditambahkan.
- Laporan, grafik, tabel, dan jejak pemeriksaan dibuat ulang dari analisis revisi.

---

## 2026-10-06 — Project aktif dialihkan ke analisis deret waktu IKP

**Arahan penulis:** tetap memakai dataset saat ini dengan tema Analisis Deret Waktu.
Inti analisis adalah tren, stabilitas perubahan skor, dan kesenjangan; naïve/drift
sebagai evaluasi tambahan. Paket hasil: laporan dan kode R, CSV, PNG 300 dpi, PDF.

**Implementasi:** pipeline terpisah `R/timeseries/run.R` beserta modul analisis,
audit metodologi, pemeriksaan, grafik, dan pembuat laporan. Hasil di
`output/timeseries/`; naskah `LAPORAN_deret_waktu.md` dibangkitkan dari hasil kode.
Ditambahkan README dan jejak sumber `review/timeseries/SOURCES.md`.

**Temuan sumber yang mengubah cakupan:** perbedaan rincian komponen ketersediaan
pada dokumen 2021 (stok beras), 2022 (sagu), dan laporan resmi 2024 (bantuan pangan).
Perubahan tersebut diterapkan sebagai batas konservatif pada seri kabupaten.
Pipeline tidak menganggap jumlah indikator yang tetap sebagai bukti harmonisasi.
Metodologi 2019 dan rincian penuh 2024 masih ditandai belum lengkap.

**Hasil eksekusi:** exit 0; raw/clean cocok 105/105. Dari 90 kandidat perubahan,
51 dihitung dan 39 dikecualikan. Dari 90 kandidat ramalan, 12 dihitung untuk dua kota
dan 78 kabupaten tidak diestimasi karena segmen latihan kurang dari empat tahun.
MAE kota naïve = 4,635, drift = 4,970806; RMSE naïve = 6,105663, drift = 5,907966.
Hasil bersifat eksploratif; tidak ada klaim kausal atau metode terbaik secara umum.

**Verifikasi:** rumus pada seri konstan/tren tetap, penolakan input invalid,
independensi ramalan terhadap data tahun target/masa depan, pemisahan segmen,
aritmetika MAE/RMSE, kelengkapan ekspor CSV, dan hash arsip lulus. Enam grafik
diperiksa secara visual dan label grafik dirapikan. Sumber provinsi tetap 85/90 cocok;
lima selisih tersimpan tanpa mengganti data.

**Tidak berubah:** input mentah/bersih, `R/01`–`R/11`, kedua naskah panel lama,
dan sumber resmi yang sebelumnya tersimpan. Konteks historis tetap tersedia;
`project_context.md` diawali desain aktif agar tidak tertukar dengan desain lama.

---

## 2026-09-23 — Revisi Fase 2: efek tahun + inferensi G kecil + naskah `LAPORAN_rev.md`

**Pemicu:** review desain (`review/DESIGN_REVIEW.md`, `review/PLAN.md`) menemukan tiga cacat
rancangan: tumpang tindih X–Y (kemiskinan & komponen IPM adalah penyusun IKP), spesifikasi tanpa
efek tahun, dan inferensi asimtotik pada G = 15.

**Skrip baru:** `R/11_year_fe_inference.R` (9 bagian) → **exit 0**, log `output/11_year_fe.log`.
Bug pada run pertama diperbaiki: `wcb()` memakai `vcCL()` yang mengoper klaster sebagai **formula**
(`~ kode`) — `sandwich::vcovCL()` mengevaluasi ulang formula di frame yang salah dan gagal
(`object 'dat' not found`) karena `lm()` di dalam fungsi memakai argumen `dat`. Perbaikan:
klaster dioper sebagai **vektor**. Bug kedua: indexing `[1:4, ]` pada tabel 13 kabupaten
menampilkan dummy wilayah, bukan koefisien substantif.

**Tabel baru di `output/`:** `tabel_4_4_FEcovid.csv`, `tabel_4_4_FEyear.csv`, `tabel_4_5_mde.csv`,
`tabel_4_6_rhs_bersih.csv`.

**Angka utama (cluster-robust HC1, klaster kabupaten):**

| Spesifikasi | IPM coef | SE | p |
|---|---|---|---|
| FE + COVID (dilaporkan `R/04`) | 1,959 | 0,443 | 0,0000 |
| FE + year FE | **−2,228** | 1,648 | **0,180** |
| FD murni | 1,605 | 0,717 | 0,028 |
| FD + year dummies | 0,158 | 1,233 | 0,899 |

- F gabungan year dummies: **F = 6,872; df 6/80; p = 6,576e-06** → efek tahun wajib.
- Year dummies menjelaskan **97,2%** variasi within IPM dan 67,8% within IKP.
- Robust Hausman (Mundlak, Wald klaster): **W = 24,44; p = 6,5e-05** → FE tetap tepat
  (menggantikan Hausman klasik χ² = 57,77 yang bentuknya tidak sah karena Wooldridge p = 0,005).
- WCB Rademacher (B = 999, seed 1093): FE+COVID **p = 0,109**; FE+YearFE p = 0,425.
- RHS bersih + year FE (N = 105): ln(PDRB) 2,830 (p = 0,740; WCB 0,747); ln(Padi) 2,770
  (p = 0,010; **WCB 0,249**). Pada 13 kabupaten: ln(Padi) 3,675 (p = 0,015; **WCB 0,192**).
- MDE: IPM 5,11× SD within; kemiskinan 2,81×; ln(PDRB) **608,56×**; ln(Padi) 25,72×.

**Naskah:** `LAPORAN_rev.md` ditulis (Bab 3–7 + 2 lampiran). `laporan_draft.md` **TIDAK ditimpa**.

**Kesimpulan berubah:** dari "IPM berpengaruh positif signifikan" → **"tidak ada variabel yang
teridentifikasi berpengaruh robust; 2 dari 4 X adalah komponen IKP itu sendiri; sisanya tidak
teridentifikasi terpisah dari tren bersama"**.

**Non-temuan yang dicatat:** ln(Padi) = 3,675 (p = 0,0146) **tidak boleh dilaporkan sebagai temuan**
— gagal uji WCB dan komponen ketersediaan IKP dibekukan pada angka tetap 2014–2016.

**Yang tidak diubah:** `data/lampung_panel_clean.csv`
(`becc5801facc6ee6f04a5d1906646a71eaa9e0c45c3cb45c22e6febb506a8431`), `Data Fix - DATA.csv`
(`ad69f257005795e69fe56006f32e913e8231777a6cb66bcb40782cdd7eea0eb5`), `R/01`–`R/10`
(diperiksa ulang 2026-09-23, tidak dimodifikasi), dan `laporan_draft.md`.

---

## 2026-09-19 — Verifikasi parsing angka (P1–P5) + aturan label hash

**Aturan baru:** semua hash ditulis **penuh** + **nama algoritma eksplisit**
(bentuk `XXXX...YYYY` dilarang). `AUDIT.md` Bagian 8 diperbarui; hash acuan A3
ditetapkan sebagai **pasangan** SHA256 + MD5.

**Verifikasi parsing (`R/09_parsing_audit.R`, log `OUTPUT/parsing_audit.log`):**
- `pdrb`: 105/105 string kelas titik-tunggal.
- `produksi_padi`: 103 kelas titik+koma, 1 koma-ganda (`155,711,37`), 1
  titik-ganda (`215.987.34`). Keduanya ditafsirkan benar (155711,37 dan
  215987,34).
- Sanity check YoY>60%: 1 flag (Kota Metro 2020, +218,7%) → **fitur data nyata**,
  bukan galat parsing. Tidak ada nilai >20x median.
- P3: logika "pemisah terakhir = desimal" didokumentasikan + batas kelemahannya.

**Konsistensi jumlah skrip:** Step 0 menyebut 6 skrip (saat itu `01`–`06`);
kini **9 skrip** (`01`–`09`). Inventaris lengkap + SHA256 penuh ada di
`AUDIT.md` Bagian 11.

**Dampak ke kesimpulan:** tidak ada. Parsing terbukti konsisten; angka tetap.

---

## 2026-09-19 — Klarifikasi "diskrepansi hash" (TIDAK ada perubahan data)

**Yang dilaporkan:** MD5 `data/lampung_panel_clean.csv` dianggap berubah
(Step 0: `SHA256: BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431` vs Step 2: `MD5: 1DCF8AD2A0793DC36080687F34428264`).

**Temuan:** bukan perubahan file. `SHA256: BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431` adalah **SHA256**, sedangkan
`MD5: 1DCF8AD2A0793DC36080687F34428264` adalah **MD5** dari file yang **sama**. Brief A3 salah melabeli
SHA256 sebagai MD5.

**Bukti:** `R/08_audit_hashes.R` → `OUTPUT/audit_hash_check.log`.
- SHA256 clean CSV (dihitung ulang): `SHA256: becc5801facc6ee6f04a5d1906646a71eaa9e0c45c3cb45c22e6febb506a8431`
- MD5 clean CSV (dihitung ulang): `MD5: 1dcf8ad2a0793dc36080687f34428264`

**Dampak ke kesimpulan:** **TIDAK ADA.** Data tidak berubah; estimasi Step 4
lama tetap valid untuk data versi ini.

**Perbaikan dokumen:**
- `AUDIT.md` Bagian 8 ditambah riwayat hash + jawaban Q1–Q5.
- Klaim hipotetis "rerun akan menghasilkan file identik" dihapus/koreksi
  (tidak pernah masuk AUDIT.md; hanya ada di chat).
- Hash acuan A3 ditetapkan (pasangan):
  `SHA256: BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431`
  `MD5: 1DCF8AD2A0793DC36080687F34428264`

---

## 2026-09-19 — Verifikasi V1 & V2

- **V1:** statistik deskriptif dari file saat ini **cocok persis** dengan
  Tabel 4.1 draft → membuktikan draft bersumber dari versi data ini.
- **V2:** perbandingan raw vs parsed pada nilai anomali
  (`155,711,37`, `215.987.34`, `29.992,775`, `81.355,00`) → **tidak ada
  desimal yang hilang**. Kolom `pdrb` integer karena nilai mentah memang tanpa
  desimal.

**Dampak ke kesimpulan:** tidak ada; memperkuat status audit.

---

## 2026-09-19 — Skrip `R/01_clean_data.R`

- **Status: TIDAK DIUBAH** setelah dibuat (mtime `15:41:31`; CSV dihasilkan
  `15:41:34`). Tidak ada entri perubahan.
- Tidak ada skrip lain yang menulis ke `data/` (hanya `01`).
- **Dampak:** estimasi `R/04_main_estimation.R` tetap berlaku.

---

## 2026-09-19 — Struktur deliverable

- Skrip tetap di folder `R/` (keputusan: **tidak** rename ke `KODE/`, sesuai
  arahan, agar path relatif dan hasil A3 tidak rusak).
- Log mentah disimpan di `OUTPUT/` (`OUTPUT` = `output` pada Windows,
  case-insensitive).
- Ditambahkan: `R/07_data_structure.R`, `R/08_audit_hashes.R`.

**Dampak ke kesimpulan:** tidak ada.

---

## (Awal) — Draft pertama

- `laporan_draft.md` dibuat dari hasil eksekusi 6 skrip (`R/01`–`R/06`).
- Angka Bab 4.1–4.6 + abstrak **terverifikasi** berasal dari eksekusi nyata
  (lihat `AUDIT.md`).

**Catatan:** keputusan metodologis GMM ditolak, uji Chow→LM→Hausman, dan
struktur robustness dipertahankan sesuai brief.

---

## Tertunda (belum dikerjakan) — **DIPERBARUI 2026-09-23**

> **Status per 2026-09-23:** ketiga item di bawah **sudah dikerjakan** pada revisi Fase 2
> (lihat entri terbaru di atas). Bagian ini dipertahankan sebagai jejak proses; daftar
> tunggakan yang **masih berlaku** ada di `project_context.md` Bagian 8.

- **Step 3:** estimasi Pooled/RE/FE + uji pemilihan (re-run terdokumentasi). → **SELESAI**;
  namun Hausman klasik digantikan versi robust (Mundlak) karena korelasi serial.
- **Step 4:** Year FE (buang COVID) + uji F gabungan year dummy + diagnostik +
  wild cluster bootstrap (dengan fallback base-R) + robustness 3 kolom
  (FE+COVID | FE+YearFE | FD+YearFE). **Potensi mengubah kesimpulan utama**
  (IPM bisa melemah) — akan dilaporkan apa adanya. → **SELESAI**; dan **benar mengubah
  kesimpulan utama**: IPM +1,959 (p=0,0000) → −2,228 (p=0,180), p WCB = 0,109.
- **Step 5:** revisi naskah `LAPORAN_rev.md` + changelog final. → **SELESAI**;
  `LAPORAN_rev.md` ditulis (Bab 3–7), `laporan_draft.md` **tidak** ditimpa.
