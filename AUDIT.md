# AUDIT INTEGRITAS ANGKA — Laporan Ketahanan Pangan Lampung

Tanggal audit: 2026-09-19
Auditor: AI agent (opencode) atas permintaan penulis

---

## 0. VERDICT RINGKAS

**STATUS: LULUS BERSYARAT (A3 pending)** — audit mandiri (belum audit independen).
A1, A1b, A1c, A2, A2b sudah selesai. Syarat penutup: **A3 (uji ulang
end-to-end oleh penulis di sesi R bersih)** belum dilakukan. Setelah A3 selesai
dan hash CSV identik serta seluruh tabel estimasi cocok, status baru
"TERVERIFIKASI".

**Tidak ditemukan fabrikasi angka.** Seluruh angka statistik pada draft
(`laporan_draft.md`) Bab 4.1 s.d. 4.6 dan abstrak **berasal dari eksekusi kode
nyata** (`Rscript`) pada data nyata (`Data Fix - DATA.csv` yang telah dibersihkan
menjadi `data/lampung_panel_clean.csv`). Tidak ada angka yang perlu diganti `TBD`.

**Pengecualian:** ada tiga kelompok **bukan-statistik** yang TIDAK dapat
diverifikasi dari komputasi dan harus ditandai sebagai belum terverifikasi:
1. Rujukan pustaka (Baltagi 2005; Wooldridge 2010) — belum dicek keberadaannya.
2. Sumber & metode penyusunan IKP Bapanas — belum dirujuk ke publikasi spesifik.
3. Basis harga PDRB (ADHB vs ADHK) dan satuan — **asumsi**, belum dikonfirmasi ke BPS.

---

## 1. FILE DATA YANG BENAR-BENAR DIAKSES

| File | SHA256 | Peran |
|---|---|---|
| `C:\Akbar\PSD\Data Fix - DATA.csv` | `SHA256: AD69F257005795E69FE56006F32E913E8231777A6CB66BCB40782CDD7EEA0EB5` | Data mentah (input) |
| `C:\Akbar\PSD\data\lampung_panel_clean.csv` | `SHA256: BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431` | Data bersih (hasil olahan) |

- Data mentah berisi 105 baris data + header multi-baris.
- Data bersih: 105 observasi, 15 kabupaten/kota, 7 tahun (2018–2024), 0 nilai NA.

## 2. APAKAH PERNAH MENJALANKAN REGRESI PADA FILE TERSEBUT?

**Ya.** Regresi panel (`plm`), uji pemilihan model (Chow/LM/Hausman),
cluster-robust SE, dan diagnostik dijalankan melalui `Rscript.exe` pada file
`data/lampung_panel_clean.csv`. Skrip tersimpan di folder `R/`:

| Skrip | Isi |
|---|---|
| `R/01_clean_data.R` | cleaning, reshape, log, dummy COVID |
| `R/02_reality_check.R` | korelasi/lag IKP (Fase 2) |
| `R/03_model_selection.R` | Pooled/FE/RE + Chow/LM/Hausman |
| `R/04_main_estimation.R` | FE + cluster-robust + VIF/Wooldridge/BP/Shapiro |
| `R/05_robustness.R` | lagged-X + robustness |
| `R/06_descriptives.R` | statistik deskriptif + korelasi + plot |

---

## 3. PETA ANGKA → SKRIP → OUTPUT MENTAH → STATUS

### Bab 4.1 Statistik Deskriptif — skrip `R/06_descriptives.R`

```text
      Variabel       Mean         SD       Min        Max
           ikp     78.478      5.116    65.980     88.780
           ipm     69.219      3.927    62.880     79.190
    kemiskinan     11.511      3.279     6.310     20.850
          pdrb  26478.419   6559.398 15759.000  40472.000
 produksi_padi 171675.039 159765.565  2318.240 614016.700
=== Rata-rata IKP per Tahun ===
 2018 74.10 | 2019 76.98 | 2020 77.56 | 2021 77.96 | 2022 78.61 | 2023 81.55 | 2024 82.58
=== Korelasi === ikp-ipm 0.088 | ikp-kemiskinan -0.485 | ikp-ln_pdrb 0.453
=== Top === Mesuji 84.55, Tulang Bawang 84.35, Pringsewu 84.05
=== Bottom === Pesisir Barat 72.61, Lampung Utara 73.54, Lampung Barat 73.73
```
**Status: TERVERIFIKASI.**

### Bab 4.2 Reality Check — skrip `R/02_reality_check.R`

```text
Pooled (raw)   : 0.8793
Within (FE) koef lag: 0.6193
Within R2: 0.4305   (p = 1.673058e-12)
```
**Status: TERVERIFIKASI.**

### Bab 4.3 Pemilihan Model — skrip `R/03_model_selection.R`

```text
Chow:  F = 9.9417, df1 = 14, df2 = 85, p-value = 1.029e-12
LM BP: chisq = 21.878, df = 1, p-value = 2.905e-06
Hausman: chisq = 57.774, df = 5, p-value = 3.503e-11
```
**Status: TERVERIFIKASI.**

### Bab 4.4 Estimasi Utama — skrip `R/04_main_estimation.R`

```text
           Estimate Std. Error t value  Pr(>|t|)
ipm         1.95865    0.41382  4.7331 8.737e-06
kemiskinan -0.48932    0.45500 -1.0754   0.28523
ln_pdrb    13.37656    9.45482  1.4148   0.16078
ln_padi     1.55658    1.08067  1.4404   0.15343
covid       1.24150    0.66450  1.8683   0.06516
R2 within: 0.6309 | R2 adjusted: 0.5484
```
**Status: TERVERIFIKASI.**

### Bab 4.5 Diagnostik — skrip `R/04_main_estimation.R`

```text
VIF within: ipm 5.318 | kemiskinan 5.061 | ln_pdrb 2.300 | ln_padi 1.068 | covid 1.564
Wooldridge pwartest: F = 8.233, p-value = 0.00515
Breusch-Pagan: BP = 0.0016434, p-value = 0.9677
Shapiro-Wilk: W = 0.97204, p-value = 0.02549
```
**Status: TERVERIFIKASI.**

### Bab 4.6 Robustness — skrip `R/05_robustness.R`

```text
                  main no_covid no_2020 lagged
ipm              1.959    2.145   2.135     NA      (p: .0000/.0000/.0015)
lag(ipm)            NA       NA      NA  1.257      (p: .0017)
kemiskinan      -0.489   -0.330  -0.317     NA      (p: .2852/.4476/.6521)
lag(kemiskinan)     NA       NA      NA -1.090      (p: .0672)
ln_pdrb         13.377    4.697  13.547     NA
lag(ln_pdrb)        NA       NA      NA  4.835
ln_padi          1.557    1.497   1.235     NA      (p .1534/.0935/.3399)
lag(ln_padi)        NA       NA      NA  3.160      (p: .0419)
covid            1.242       NA      NA -0.734
```
**Status: TERVERIFIKASI.**

### Abstrak

- "15 kabupaten/kota", "105 observasi" — TERVERIFIKASI (`R/01`, output "Baris: 105 / Wilayah: 15").
- Klaim kualitatif (IPM satu-satunya yang konsisten, dst.) — TERVERIFIKASI dari tabel di atas.

---

## 4. YANG TIDAK TERVERIFIKASI (bukan angka statistik)

| Item | Alasan | Tindakan |
|---|---|---|
| Baltagi (2005) | Belum dicek keberadaan/edisi | Tandai `[BELUM DIVERIFIKASI]` |
| Wooldridge (2010) | Belum dicek keberadaan/edisi | Tandai `[BELUM DIVERIFIKASI]` |
| Roodman (2009) | Belum dicek DOI | Perlu verifikasi DOI |
| Publikasi & metode IKP Bapanas | Belum dirujuk ke dokumen spesifik | TBD — cari sumber resmi |
| Basis harga PDRB (ADHB/ADHK) | **Asumsi**: diperlakukan sebagai nominal | Perlu konfirmasi; jika ADHK tersedia, ulangi (Prioritas 4) |
| Satuan PDRB "ribu" | **Asumsi** dari header; faktor skala tidak memengaruhi koefisien log | Catat sebagai asumsi |
| Interpretasi nilai "16.44" sebagai 16.440 | **Asumsi** konversi saat cleaning | Catat; tidak memengaruhi koefisien log |

---

## 5. VERSI SOFTWARE (untuk reproduksibilitas)

```text
R version 4.5.2 (2025-10-31 ucrt)
Platform: x86_64-w64-mingw32/x64 | Windows 11 x64 (build 26200)
plm      2.6-7
sandwich 3.1-3
lmtest   0.9-40
zoo      1.8-15
ggplot2  4.0.1
```

---

## 6. PERNYATAAN INTEGRITAS

- Setiap angka yang dilaporkan pada draft dapat direproduksi dengan menjalankan
  ulang skrip di folder `R/` terhadap `data/lampung_panel_clean.csv`.
- Tidak ada angka yang diisi "agar terlihat masuk akal".
- Angka yang dilaporkan di draft dan lulus audit ini sama dengan output mentah
  di atas; tidak ada yang diubah diam-diam.
- Item di Bagian 4 secara eksplisit ditandai belum terverifikasi dan **bukan**
  hasil komputasi.

**Catatan proses:** output mentah pada dokumen ini tersimpan dari sesi eksekusi.
Log mentah per-skrip dipersistenkan ke folder `OUTPUT/`.

---

## 7. LANGKAH 0 — A1 (grep angka hardcoded) & A2 (verifikasi rantai data)

Log mentah: `OUTPUT/audit_step0.log` (dijalankan 2026-09-19).

### A1 — Grep pola angka desimal di `R/*.R`

Perintah: pola `[0-9]+\.[0-9]{2,}` dengan pengecualian
`alpha|conf|level|base|width|height|size|seed|rep`.
Tool `rg` tidak tersedia di PATH; dipakai `Select-String` sebagai padanan
(didokumentasikan). Hasil mentah (1 match):

```text
R\06_descriptives.R:42:       lty = 1, lwd = 1.6, cex = 0.62, ncol = 2, bty = "n")
```

**Kesimpulan A1: BERSIH.** Satu-satunya angka desimal adalah konstanta kosmetik
plot (`cex = 0.62`, `lwd = 1.6`), bukan koefisien/hasil uji. Tidak ada vektor
angka yang menyerupai hasil estimasi.

### A1b — Baris yang DIKELUARKAN filter (menutup blind spot)

Tanpa filter, total match hanya **1** (baris kosmetik di atas). Baris yang
dikeluarkan oleh filter `alpha|conf|level|base|width|height|size|seed|rep` =
**0**. Artinya filter **tidak menyembunyikan apa pun**; kesimpulan A1 tidak
berubah.

```text
Total match tanpa filter: 1
Baris dikeluarkan oleh filter: 0
```

### A1c — Cakupan grep seluruh repo

Seluruh file skrip di repo (termasuk folder tersembunyi, `-Force`):

```text
C:\Akbar\PSD\R\01_clean_data.R
C:\Akbar\PSD\R\02_reality_check.R
C:\Akbar\PSD\R\03_model_selection.R
C:\Akbar\PSD\R\04_main_estimation.R
C:\Akbar\PSD\R\05_robustness.R
C:\Akbar\PSD\R\06_descriptives.R
```

- **Tidak ada** file `.Rmd`, `.qmd`, `.py`, `.do`, `.stan`, `.jl`.
- **Tidak ada** `.Rhistory`, `.RData`, `.Rproj`, `.Ruserdata`.
- Tidak ada estimasi ad-hoc di console di luar 6 skrip. (Perintah `Rscript -e`
  yang pernah dijalankan hanya untuk cek versi package dan `sessionInfo()`,
  **tanpa estimasi**.)

**Kesimpulan A1c: BERSIH & REPRODUCIBLE.** Semua estimasi yang dilaporkan
berada di dalam 6 skrip.

### A2b — Hash data mentah (permanen)

Hash file mentah **dan** file olahan tercatat di Bagian 1 dan Bagian 7:

```text
AD69F257005795E69FE56006F32E913E8231777A6CB66BCB40782CDD7EEA0EB5  Data Fix - DATA.csv
BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431  data/lampung_panel_clean.csv
```

Catatan: `SHA256: BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431` di atas dihitung dari file `data/lampung_panel_clean.csv`.
Header A3 menyebut target MD5 `SHA256: BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431`; nilai tersebut sebenarnya
adalah **SHA256**, bukan MD5. A3 sebaiknya membandingkan **SHA256** agar
konsisten. Nilai MD5 untuk pembanding alternatif:

```text
SHA256 (clean CSV): BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431
MD5    (clean CSV): 1DCF8AD2A0793DC36080687F34428264
MD5    (raw CSV)  : 09D8A3714B44944ABD3F48F46721E7CB
```

### A2 — Verifikasi rantai data

Rantai input/output tiap skrip (dari log mentah):

```text
01_clean_data.R : readLines("Data Fix - DATA.csv") -> scan() -> write.csv(data/lampung_panel_clean.csv)
02..06          : read.csv("data/lampung_panel_clean.csv")  [satu-satunya input]
02,06           : pdf(output/*.pdf)
```

**Kesimpulan A2: RANTAI UTUH.** Satu-satunya sumber data mentah adalah
`Data Fix - DATA.csv`; skrip `01` memproduksi `data/lampung_panel_clean.csv`;
skrip `02`-`06` membaca file olahan itu dan **tidak ada** tabel yang diketik
tangan di tengah rantai. Tidak ada input tersembunyi.

### Hash artefak (SHA256)

```text
AD69F257005795E69FE56006F32E913E8231777A6CB66BCB40782CDD7EEA0EB5  Data Fix - DATA.csv
BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431  data/lampung_panel_clean.csv
88343BAD9FDCC25EEC8F40A278008CE29A468AD1547924CDDA7251D549952191  output/fase1_tren_ikp.pdf
558FAE3C45C9F6C78FB74F007309822C4735BD94EAE320E736DE69661C29F242  output/fase2_ikp_lag.pdf
```

Catatan: PDF memuat metadata waktu pembuatan sehingga hash-nya **tidak
deterministik** antar-run. Data CSV deterministik.

### Session info (R 4.5.2)

```text
other attached packages:
[1] lmtest_0.9-40  zoo_1.8-15  sandwich_3.1-3  plm_2.6-7
Platform: x86_64-w64-mingw32/x64 | Windows 11 x64 (build 26200)
```

---

## 8. DISKREPANSI HASH — KLARIFIKASI & RIWAYAT (Q1–Q5)

### Temuan inti
**Tidak ada perubahan data.** "Diskrepansi" murni karena **label algoritma**:
- `SHA256: BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431` = **SHA256** dari `data/lampung_panel_clean.csv`
- `MD5: 1DCF8AD2A0793DC36080687F34428264` = **MD5** dari file yang **SAMA PERSIS**

Keduanya dihitung ulang dari file saat ini dan cocok dengan nilainya
masing-masing (lihat `OUTPUT/audit_hash_check.log`). Brief A3 salah melabeli
nilai SHA256 sebagai "MD5", sehingga tampak seperti dua file berbeda.

### Riwayat hash (R1)

| Waktu | File | Algoritma | Nilai | Sumber |
|---|---|---|---|---|
| Step 0 | clean CSV | SHA256 | `SHA256: BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431` | PowerShell Get-FileHash |
| Step 0 (brief A3 keliru menyebut "MD5") | clean CSV | — | `SHA256: BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431` | salah label, **bukan** file baru |
| Step 2 | clean CSV | MD5 | `MD5: 1DCF8AD2A0793DC36080687F34428264` | R `tools::md5sum` + PowerShell |
| Step 2 (verifikasi ulang) | clean CSV | SHA256 | `SHA256: becc5801facc6ee6f04a5d1906646a71eaa9e0c45c3cb45c22e6febb506a8431` | R `digest::digest` |
| Step 2 | raw CSV | SHA256 | `SHA256: AD69F257005795E69FE56006F32E913E8231777A6CB66BCB40782CDD7EEA0EB5` | Get-FileHash |
| Step 2 | raw CSV | MD5 | `MD5: 09D8A3714B44944ABD3F48F46721E7CB` | R `tools::md5sum` |

**Hanya SATU versi `data/lampung_panel_clean.csv` yang pernah ada.**

### Jawaban Q1–Q5

- **Q1:** Tidak. File tidak berubah antara Step 0 dan Step 2. Nilai SHA256-nya
  tetap `BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431`;
  nilai MD5-nya `1DCF8AD2A0793DC36080687F34428264`. Keduanya berbeda karena
  algoritmanya berbeda.
- **Q2:** Tidak. `R/01_clean_data.R` **tidak diedit** setelah dibuat. mtime-nya
  `2026-09-19 15:41:31`, sedangkan clean CSV `15:41:34` (3 detik setelah) →
  konsisten bahwa CSV dihasilkan oleh versi skrip 01 yang sekarang. Tidak ada
  perubahan skrip → tidak ada entri CHANGELOG untuk 01, dan estimasi di `04`
  tidak terpengaruh.
- **Q3:** Tidak ada. Hanya `R/01_clean_data.R` yang menulis ke `data/`
  (satu-satunya `write.csv`, target `data/lampung_panel_clean.csv`). Skrip
  `02`–`09` hanya membaca. Tidak ada proses tulis kedua.
- **Q4:** `file.info()` (repo **bukan** git, `git log` tidak tersedia):
  ```text
  R/01_clean_data.R             size 2454   mtime 2026-09-19 15:41:31
  data/lampung_panel_clean.csv  size 10257  mtime 2026-09-19 15:41:34
  Data Fix - DATA.csv           size 6834   mtime 2026-09-19 15:25:33
  ```
- **Q5:** Versi ber-hash SHA256 `BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431` adalah file yang **sama** dengan yang
  sekarang (tidak ada dua versi). 11 kolom:
  `kode, kabupaten, tahun, ikp, pdrb, ipm, kemiskinan, produksi_padi, ln_pdrb, ln_padi, covid`.
  Tidak ada diff.

### Koreksi klaim (R3)

Kalimat di chat Step 2 ("source(...) akan menghasilkan file identik") adalah
**hipotesis**, bukan hasil, dan **tidak** pernah dimasukkan ke AUDIT.md.
A3 hanya sah bila dijalankan penulis di sesi R bersih.

### Hash acuan A3 (R4) — pasangan SHA256 + MD5

```text
SHA256 : BECC5801FACC6EE6F04A5D1906646A71EAA9E0C45C3CB45C22E6FEBB506A8431
MD5    : 1DCF8AD2A0793DC36080687F34428264
```

---

## 9. VERIFIKASI V1 (deskriptif) & V2 (truncation)

### V1 — Statistik deskriptif dari file saat ini

| Variabel | mean | sd | min | max |
|---|---|---|---|---|
| ikp | 78,478 | 5,116 | 65,980 | 88,780 |
| ipm | 69,219 | 3,927 | 62,880 | 79,190 |
| kemiskinan | 11,511 | 3,279 | 6,310 | 20,850 |
| pdrb | 26.478,419 | 6.559,398 | 15.759 | 40.472 |
| produksi_padi | 171.675,039 | 159.765,565 | 2.318,24 | 614.016,70 |

**TRACEABILITY (bukti keterlacakan): COCOK PERSIS dengan Tabel 4.1 draft**
(mean/SD/min/max). Ini membuktikan angka statistik draft berasal dari
**versi data ini**, bukan hasil generate dari versi lain.

### V2 — Validasi raw vs parsed (tidak ada desimal hilang)

| Baris mentah | Nilai mentah | Parsed `pdrb` | Parsed `produksi_padi` |
|---|---|---|---|
| 1 | `15.759` / `"81.355,00"` | 15759 | 81355,00 |
| 8 | `17.469` / `"155,711,37"` | 17469 | 155711,37 |
| 52 | `36.32` / `215.987.34` | 36320 | 215987,34 |
| 104 | `27.468` / `"29.992,775"` | 27468 | 29992,775 |

Tidak ada nilai terpotong. Kolom `pdrb` bertipe integer karena seluruh nilai
mentah PDRB tidak memiliki desimal (hanya titik pemisah ribuan); `produksi_padi`
tetap `numeric` (menyimpan desimal, mis. 29992,775). Log: `OUTPUT/audit_hash_check.log`.

---

## 10. VERIFIKASI PARSING ANGKA (P1–P5)

Skrip: `R/09_parsing_audit.R` — log mentah: `OUTPUT/parsing_audit.log`.

### P1 — Klasifikasi string mentah

| Kolom | Kelas | Jumlah |
|---|---|---|
| `pdrb` | a1_dot_single (hanya titik, tunggal) | **105** |
| `produksi_padi` | c_dot+comma (titik DAN koma) | **103** |
| `produksi_padi` | b2_comma_multi (koma ganda) | **1** |
| `produksi_padi` | a2_dot_multi (titik ganda) | **1** |

**Kelas (c) — 103 string.** Karena jumlahnya besar, daftar lengkap tiap string
ada di `OUTPUT/parsing_audit.log` (format: `raw=... parsed=...` per baris). Pola
umum kelas (c): `<ribuan titik>,<desimal>` mis. `81.355,00`, `525.372,11`.

**Dua string paling berisiko (ambigu di kedua konvensi):**
1. `155,711,37` — Tanggamus 2018 (dua koma, tanpa titik).
2. `215.987.34` — Tulang Bawang 2020 (dua titik, tanpa koma).

### P2 — Tafsiran parser untuk setiap string risiko

| Baris | Wilayah | Kolom | String mentah | Tafsiran parser | Nilai hasil |
|---|---|---|---|---|---|
| 8 | Tanggamus 2018 | produksi_padi | `155,711,37` | koma terakhir = desimal, koma lain = ribuan | **155711,37** |
| 52 | Tulang Bawang 2020 | produksi_padi | `215.987.34` | titik terakhir = desimal, titik lain = ribuan | **215987,34** |
| 104 | Kota Metro 2023 | produksi_padi | `29.992,775` | koma = desimal (3 digit), titik = ribuan | **29992,775** |
| 1 | Lampung Barat 2018 | produksi_padi | `81.355,00` | koma = desimal, titik = ribuan | **81355,00** |
| 1 | Lampung Barat 2018 | pdrb | `15.759` | desimal-titik × 1000 (lihat P3) | **15759** |

### P3 — Logika parser (`R/01_clean_data.R`)

```r
 9: parse_id <- function(s) {
10:   s <- gsub("[^0-9.,-]", "", s)
11:   if (!nzchar(s)) return(NA_real_)
12:   nd <- gregexpr("\\.", s)[[1]]
13:   nd <- if (nd[1] == -1) integer(0) else nd
14:   nc <- gregexpr(",", s)[[1]]
15:   nc <- if (nc[1] == -1) integer(0) else nc
16:   last_dot <- if (length(nd)) max(nd) else -1
17:   last_com <- if (length(nc)) max(nc) else -1
18:   if (last_com > last_dot) {
19:     s <- gsub("\\.", "", s)
20:     pos <- gregexpr(",", s)[[1]]
21:     if (length(pos) > 1) {
22:       last <- max(pos)
23:       prefix <- gsub(",", "", substr(s, 1, last - 1))
24:       suffix <- substr(s, last + 1, nchar(s))
25:       s <- paste0(prefix, ".", suffix)
26:     } else {
27:       s <- sub(",", ".", s, fixed = TRUE)
28:     }
29:   } else {
30:     pos <- gregexpr("\\.", s)[[1]]
31:     if (length(pos) > 1) {
32:       last <- max(pos)
33:       prefix <- gsub("\\.", "", substr(s, 1, last - 1))
34:       suffix <- substr(s, last + 1, nchar(s))
35:       s <- paste0(prefix, ".", suffix)
36:     }
37:   }
38:   as.numeric(s)
39: }
```

**Penjelasan (mengapa benar untuk kedua konvensi).** Aturannya:
*"pemisah yang muncul PALING AKHIR adalah pemisah desimal; semua pemisah lain
adalah pemisah ribuan."* Parser membandingkan posisi titik terakhir vs koma
terakhir (baris 16–18):
- **Koma paling akhir** (mis. `81.355,00`, `155,711,37`) → koma = desimal.
  Titik dibuang; bila ada >1 koma, hanya koma terakhir jadi desimal, koma lain
  dibuang (baris 21–25). Ini benar untuk konvensi **Indonesia** dan untuk
  string cacat `155,711,37` (koma ribuan **dan** desimal).
- **Titik paling akhir / hanya titik** (mis. `215.987.34`, `70,76` tanpa titik)
  → titik = desimal; bila ada >1 titik, hanya yang terakhir jadi desimal
  (baris 30–36). Ini benar untuk konvensi **Inggris**.
- **PDRB** dipanggil dengan `* 1000` (di `R/01`), sehingga baik `15.759`
  (dibaca 15,759) maupun `36.32` (dibaca 36,32) dikonversi ke satuan ribu →
  `15759` dan `36320`. Karena PDRB di-log, faktor skala ini tidak memengaruhi
  koefisien.

**Batas kelemahan yang diakui:** string dengan **satu pemisah tunggal** yang
sebenarnya pemisah ribuan (mis. seharusnya `155.711` artinya 155711) akan
dibaca sebagai desimal (155,711). Pada data ini **tidak ada** kasus seperti itu
di kolom `produksi_padi` (satu-satunya nilai titik-ganda sudah tertangani), dan
kolom `pdrb` memang konvensi desimal-titik. Risiko ini dikonfirmasi nihil oleh
P4.

### P4 — Sanity check magnitudo

- **Lonjakan year-over-year > 60%:** hanya **1 flag**:
  `Kota Metro 2020 produksi_padi +218,7%`.
  Cek mentah: 2019 `"13.073,36"` (13073,36) → 2020 `"41.669,07"` (41669,07).
  Kedua string tidak ambigu (kelas c), parse benar → ini **fitur data nyata**
  (fluktuasi produksi padi Kota Metro yang lahan sawahnya kecil), **bukan** galat
  parsing.
- **Nilai >20x / <1/20x median kabupaten:** **TIDAK ADA**.

### P5 — Cross-check ke publikasi sumber

**Status: TIDAK DAPAT DISELESAIKAN oleh agen — tidak ada dokumen sumber di
workspace, dan saya tidak akan mengarang nama tabel/halaman.** Yang bisa
dipastikan adalah keterlacakan internal tiap sel ke string mentah. Untuk
penulis, berikut 3 sel (format berbeda) untuk dicek langsung ke publikasi
BPS/Bapanas:

| # | Nilai | String mentah | Nilai terparse | Yang perlu dikonfirmasi |
|---|---|---|---|---|
| 1 | PDRB/kapita Lampung Barat 2018 | `15.759` | 15759 (ribu) | apakah satuan & besarannya sesuai (ADHB/ADHK) |
| 2 | Produksi padi Tanggamus 2018 | `155,711,37` | 155711,37 ton | angka publikasi (2 koma) |
| 3 | Produksi padi Tulang Bawang 2020 | `215.987.34` | 215987,34 ton | angka publikasi (2 titik) |

---

## 11. INVENTARIS SKRIP (konsistensi jumlah)

Laporan Step 0 menyebut "6 skrip" karena saat itu hanya `01`–`06` yang ada.
Selanjutnya ditambahkan `07` (struktur), `08` (hash), `09` (parsing), dan `10`
(validasi T1–T3) → total **10 skrip**. Tidak ada skrip yang dihapus/di-rename.
Selisih 6→10 semata karena penambahan skrip audit/validasi.

```text
SHA256: 91E304F8F89304A75E759C6640694DCACAC3D1CAB564DF6B6D32AA272686B291  R/01_clean_data.R
SHA256: 7F0D31B2D929D97FD78FAA66BF26767B8AF8BA3985C579ECF9EA81E0BE1DDB97  R/02_reality_check.R
SHA256: DD01047351A6C9124743D61D7CFFB51D6E3F48513A84D172FC1C0622F8318C51  R/03_model_selection.R
SHA256: 6C0D39C54F935694FB26DB86176F6A844464143EDBBE17A82EF149DB0E44F79B  R/04_main_estimation.R
SHA256: 0586539E5762FF56F4967468CBE461EA74D2EE3FCD402C08421505B6208BBF47  R/05_robustness.R
SHA256: 71B0CBD15480238C8B0E6547CE41F674098BB33DABF385B9DBA1B08E6DCB3F6C  R/06_descriptives.R
SHA256: 17333C8271DEE2035E926C51499CD33E69BDBBEE8A2C2768CB001278E8614DB5  R/07_data_structure.R
SHA256: 6CE965B1B00BF3917D056770289BA4BEA8014F75F23D9BA455BC775490EE6296  R/08_audit_hashes.R
SHA256: 424D939AD49B1546CA8334C00FE885557F2093CD2D69920D8A0CB166D9226C4B  R/09_parsing_audit.R
SHA256: 8652BB2463B08A82A1C65A56129207BE06192999FEF5BF5AD9F74196E9B52014  R/10_validation_totals.R
```

| Skrip | Fungsi (satu baris) |
|---|---|
| `01_clean_data.R` | Baca data mentah, parse angka campuran, ffill kode, log PDRB/padi, dummy COVID, tulis CSV bersih |
| `02_reality_check.R` | Uji persistensi IKP(t) vs IKP(t-1) statis vs dinamis |
| `03_model_selection.R` | Estimasi Pooled/FE/RE + Chow/LM/Hausman |
| `04_main_estimation.R` | FE + cluster-robust SE + VIF/Wooldridge/BP/Shapiro |
| `05_robustness.R` | Lagged-X + robustness (tanpa COVID, tanpa 2020-21) |
| `06_descriptives.R` | Statistik deskriptif, korelasi, plot tren IKP |
| `07_data_structure.R` | Laporan struktur data (Step 2) |
| `08_audit_hashes.R` | Hash + mtime + V1/V2 (audit) |
| `09_parsing_audit.R` | P1–P4 verifikasi parsing angka |

**Total: 9 skrip.** Tidak ada `.Rmd/.qmd/.py/.do`, tidak ada `.Rhistory`.
