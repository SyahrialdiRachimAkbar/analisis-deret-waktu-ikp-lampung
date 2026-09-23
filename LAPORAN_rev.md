# Determinan Indeks Ketahanan Pangan Kabupaten/Kota di Provinsi Lampung, 2018–2024: Analisis Panel dengan Efek Tahun dan Inferensi Klaster Kecil

**Laporan revisi — Project Sains Data**

**Status berkas:** `LAPORAN_rev.md`. Berkas ini **tidak menimpa** `laporan_draft.md` (draft lama, 19 Sep 2026). Draft lama tetap ada sebagai jejak proses; seluruh klaim di Bab 4–5 di sini menggantikannya.

**Reproduksi seluruh angka:** `R/11_year_fe_inference.R` → log `output/11_year_fe.log` (exit 0). Tabel: `output/tabel_4_4_FEcovid.csv`, `output/tabel_4_4_FEyear.csv`, `output/tabel_4_5_mde.csv`, `output/tabel_4_6_rhs_bersih.csv`.

---

## Abstrak

Penelitian ini menganalisis determinan Indeks Ketahanan Pangan (IKP) pada 15 kabupaten/kota Provinsi Lampung, 2018–2024 (panel seimbang, 105 observasi), menggunakan Indeks Pembangunan Manusia (IPM), persentase penduduk miskin, log PDRB per kapita, dan log produksi padi sebagai variabel penjelas. Estimasi awal dengan efek tetap wilayah dan *cluster-robust standard error* menghasilkan koefisien IPM sebesar **+1,959 (p < 0,001)**, yang sempat ditafsirkan sebagai pengaruh positif IPM terhadap IKP.

Revisi ini menunjukkan bahwa **kesimpulan tersebut tidak dapat dipertahankan**, karena tiga alasan yang saling menguatkan. *Pertama*, dua dari empat variabel penjelas adalah **indikator penyusun IKP itu sendiri**: persentase penduduk miskin berbobot 0,15 (kabupaten) / 0,20 (kota) langsung di dalam indeks, sementara angka harapan hidup (0,10/0,13) dan rata-rata lama sekolah perempuan (0,05/0,08) adalah komponen IPM yang juga masuk ke dalam IKP. Koefisien keduanya mengukur identitas konstruksi indeks, bukan pengaruh. *Kedua*, spesifikasi tersebut menghilangkan **efek tahun**, padahal uji F gabungan menolak penghilangan itu (F = 6,87; df 6/80; p = 6,6e-06) dan efek tahun menjelaskan **97,2%** variasi *within* IPM. Setelah efek tahun dimasukkan, koefisien IPM berbalik menjadi **−2,228 (SE 1,648; p = 0,180)**. *Ketiga*, dengan hanya **G = 15** klaster, *p-value* asimtotik terlalu optimistis: *wild cluster bootstrap* (Rademacher, klaster kabupaten, B = 999) memberi **p = 0,109** untuk IPM — tidak signifikan pada taraf 5%.

Pada spesifikasi yang layak — efek tetap wilayah + efek tetap tahun, dengan IPM dan kemiskinan dikeluarkan dari sisi kanan — tidak ada satu pun koefisien yang bertahan terhadap uji *wild cluster bootstrap*: log(PDRB) p = 0,747 dan log(Padi) p = 0,249. Daya uji juga dilaporkan secara eksplisit: *minimum detectable effect* untuk IPM setara **5,11 simpangan baku *within***, sehingga ketidakbergantungan hasil tidak dapat dibedakan dari keterbatasan daya uji. Kesimpulan yang dapat dipertahankan adalah **tidak ada variabel penjelas yang teridentifikasi berpengaruh secara robust terhadap IKP**; dua dari empat variabel penjelas adalah komponen indeks itu sendiri, dan sisanya tidak teridentifikasi terpisah dari tren bersama. Laporan ini juga mendokumentasikan bahwa **dua berkas resmi Bapanas memberi nilai IKP berbeda hingga 17,10–18,24 poin untuk tahun yang sama** karena perbedaan *vintage* metodologi indeks, satu temuan metodologis yang wajib disertakan dalam setiap penggunaan IKP sebagai variabel dependen.

**Kata kunci:** ketahanan pangan, IKP, data panel, efek tetap tahun, inferensi klaster kecil, wild cluster bootstrap, Lampung

---

## 1. Pendahuluan

### 1.1 Latar Belakang

Ketahanan pangan merupakan prioritas pembangunan nasional dan termuat dalam Tujuan Pembangunan Berkelanjutan (SDGs), khususnya tujuan kedua (tanpa kelaparan). Ketahanan pangan bersifat multidimensi dan mencakup empat pilar: **ketersediaan** (*availability*), **akses** (*access*), **pemanfaatan** (*utilization*), dan **stabilitas** (*stability*). Pemerintah mengukur capaian ketahanan pangan salah satunya melalui Indeks Ketahanan Pangan (IKP) yang disusun oleh Badan Pangan Nasional (Bapanas).

Provinsi Lampung merupakan salah satu lumbung pangan nasional, namun capaian IKP antarwilayahnya beragam. Perbedaan karakteristik geografis, tingkat pembangunan manusia, daya beli, dan kapasitas produksi pertanian diduga menjadi penyebab variasi tersebut. Memahami determinan IKP secara empiris penting untuk merumuskan kebijakan pangan yang tepat sasaran.

### 1.2 Rumusan Masalah

1. Apakah IPM, persentase kemiskinan, PDRB per kapita, dan produksi padi berpengaruh terhadap Indeks Ketahanan Pangan kabupaten/kota di Provinsi Lampung?
2. Apakah terdapat efek dimensi waktu, yaitu apakah kondisi tahun sebelumnya memengaruhi kondisi tahun berjalan?

### 1.3 Tujuan

1. Menganalisis pengaruh IPM, kemiskinan, PDRB per kapita, dan produksi padi terhadap IKP.
2. Menguji keberadaan efek dinamika waktu pada IKP.
3. Menyusun rekomendasi kebijakan yang **sejalan dengan apa yang benar-benar dapat disimpulkan** dari data, termasuk secara eksplisit menyebutkan apa yang **tidak** dapat disimpulkan.

### 1.4 Manfaat

Secara akademik, penelitian ini menyajikan dua kontribusi metodologis yang jarang dilaporkan pada studi ketahanan pangan tingkat daerah: (i) identifikasi tumpang tindih antara variabel penjelas dan komponen penyusun indeks dependen, dan (ii) penanganan inferensi pada panel dengan jumlah klaster sangat kecil. Secara praktis, laporan ini memberi peringatan bahwa koefisien regresi atas IKP tidak boleh ditafsirkan sebagai elastisitas kebijakan.

---

## 2. Tinjauan Pustaka dan Kerangka Teori

### 2.1 Ketahanan Pangan dan IKP

Ketahanan pangan didefinisikan sebagai kondisi terpenuhinya pangan bagi negara sampai perseorangan, yang tercermin dari tersedianya pangan yang cukup, baik jumlah maupun mutunya, aman, beragam, bergizi, merata, dan terjangkau. IKP mengoperasionalkan konsep ini dalam skala 0–100, di mana nilai yang lebih tinggi mencerminkan kondisi ketahanan pangan yang lebih baik.

Penting untuk ditegaskan sejak awal: **IKP adalah indeks komposit berbobot (*expert judgement*), bukan pengukuran langsung suatu luaran.** Nilai IKP adalah fungsi deterministik dari indikator-indikator yang menyusunnya. Konsekuensi metodologis dari sifat ini dibahas pada Bab 3.5 dan menjadi temuan utama Bab 4.

### 2.2 Determinan yang Diuji

- **IPM** mencerminkan dimensi pendidikan, kesehatan, dan standar hidup layak. IPM yang lebih tinggi diasosiasikan dengan kesadaran gizi dan pola pemanfaatan pangan yang lebih baik (pilar *utilization*).
- **Kemiskinan** membatasi daya beli rumah tangga sehingga menghambat akses terhadap pangan (pilar *access*).
- **PDRB per kapita** mencerminkan kemampuan ekonomi wilayah dan daya beli masyarakat; peningkatan PDRB diasosiasikan dengan akses pangan yang lebih baik.
- **Produksi padi** merupakan proksi ketersediaan pangan lokal (pilar *availability*); pasokan yang melimpah diharapkan menopang ketahanan pangan.

### 2.3 Efek Waktu (Dinamika)

Kondisi ketahanan pangan suatu wilayah cenderung persisten karena bersifat struktural. Kondisi tahun sebelumnya dapat memengaruhi tahun berjalan, baik melalui ketersediaan infrastruktur, kebiasaan konsumsi, maupun kondisi sosial-ekonomi yang lambat berubah. Karena itu, dimensi waktu perlu diuji secara empiris dan tidak diasumsikan.

Pada revisi ini ditambahkan satu pertimbangan yang sebelumnya terlewat: dalam panel dengan tren makro yang kuat dan serentak di semua wilayah, **efek tahun berfungsi sekaligus sebagai pemisah antara variasi antarwilayah dan tren bersama.** Mengabaikannya membuat koefisien menyerap gerakan serentak se-Indonesia dan mengatribusikannya kepada variabel penjelas yang sama-sama bergerak naik sepanjang waktu.

### 2.4 Catatan Kerangka

Keempat variabel yang diuji baru mencakup pilar ketersediaan, akses, dan pemanfaatan; pilar **stabilitas** belum terwakili secara eksplisit. Variabel seperti inflasi/indeks harga pangan dapat dipertimbangkan pada pengembangan penelitian selanjutnya. Pendekatan ekonometrika data panel mengacu pada Baltagi (2005) dan Wooldridge (2010); aturan penggunaan instrumen pada GMM mengacu pada Roodman (2009); inferensi *wild cluster bootstrap* mengacu pada Cameron, Gelbach & Miller (2008) dan praktik dengan jumlah klaster kecil; koreksi Hausman yang tahan terhadap korelasi serial mengikuti pendekatan Mundlak (1978).

---

## 3. Metode Penelitian

### 3.1 Jenis dan Sumber Data

Penelitian menggunakan **data panel seimbang** (*balanced panel*) dengan unit *cross-section* 15 kabupaten/kota di Provinsi Lampung (N = 15) selama 7 tahun (T = 7), sehingga total observasi 105 dan tidak ada nilai hilang. Data IKP bersumber dari Badan Pangan Nasional; IPM, kemiskinan, PDRB per kapita, dan produksi padi bersumber dari BPS Provinsi Lampung.

### 3.2 Vintage Indeks: Temuan Metodologis yang Wajib Dilaporkan

Ini bagian yang **tidak ada di draft lama** dan harus ada di setiap naskah yang memakai IKP sebagai variabel dependen.

IKP bukan satu seri tunggal. Bapanas telah menerbitkan lebih dari satu *vintage* indeks, dan **dua di antaranya memberi nilai yang berbeda jauh untuk tahun yang sama**:

| Wilayah | Bapanas `dataset/90` (2024) | Bapanas *backcasting* 12-indikator (2024) | Selisih |
|---|---|---|---|
| Tulang Bawang Barat | 83,74 | 65,50 | **18,24** |
| Kota Bandar Lampung | 84,64 | 67,05 | **17,59** |
| Mesuji | 88,18 | 70,69 | **17,49** |
| Tulang Bawang | 88,78 | 71,68 | **17,10** |
| Lampung Tengah | 84,93 | 70,15 | 14,78 |
| Way Kanan | 79,61 | 77,12 | 2,49 |

Selisih terbesar (18,24 poin) setara sekitar **1,5 kali simpangan baku IKP antarwilayah** dalam sampel ini (SD *pooled* IKP = 5,12). Perbedaan ini **bukan galat** — keduanya berasal dari berkas resmi — melainkan perbedaan jumlah indikator: versi lama memakai **9 indikator untuk kabupaten dan 8 indikator untuk kota**, sedangkan versi *backcasting* terbaru memakai **12 indikator** (5 ketersediaan, 4 keterjangkauan, 3 pemanfaatan).

Implikasi yang harus dinyatakan sebagai keterbatasan:

1. **Tidak ada satu "nilai IKP yang benar" tunggal**; yang ada adalah nilai per versi metodologi. Setiap naskah wajib menyebut versi yang dipakai.
2. Seri yang digunakan di sini adalah **versi 9 indikator kabupaten / 8 indikator kota**, dipakai konsisten untuk 2018–2024 sehingga komparabel *di dalam* rentang pengamatan.
3. Versi tersebut **tidak komparabel** dengan versi 12-indikator. Pencampuran dua *vintage* dalam satu seri akan menghasilkan lompatan artifisial sebesar belasan poin.

### 3.3 Verifikasi Data ke Sumber Primer

Verifikasi dilakukan ke **publikasi primer**, bukan ke berkas turunan (*reproduce:* `review/verify_ikp_sources.R` → `review/verify_output.log`).

| Uji | Hasil |
|---|---|
| IKP 2018 vs publikasi BKP 2018 Tabel 4 & 5 (skor **dan** peringkat nasional) | **15/15 cocok persis** |
| IKP 2019–2024 vs Satu Data Lampung | 85/90 cocok (94%) |

Contoh yang cocok persis: Mesuji peringkat 44 (80,82), Tulang Bawang Barat peringkat 45 (80,70), Lampung Barat peringkat 256 (70,76), Kota Metro peringkat 71 (65,98).

**Catatan yang berlawanan dengan dugaan awal:** berkas *open data* resmi Bapanas (`dataset/90`) justru memiliki **nama unit yang salah tempel** pada 8 dari 15 unit Lampung — nilai dan kodenya benar, namanya tertukar. Contoh: berkas itu menulis kode `1804` = "Lampung Barat", padahal `1804` = Lampung Timur dan nilainya memang Lampung Timur. Data yang dipakai pada penelitian ini sudah diverifikasi ke publikasi dan **bukan** hasil salinan berkas tersebut.

**Catatan identitas unit:** kolom `kode` pada panel (`1801`…`1872`) adalah **nomor urut internal proyek**, bukan kode BPS yang resmi. Pada panel ini `1801` = Lampung Barat, sedangkan kode BPS `1801` = Lampung Selatan. Kolom `kode` aman dipakai sebagai identitas unit dan klaster, tetapi **tidak boleh** dipakai untuk menggabungkan (*join*) data eksternal; penggabungan wajib melalui nama wilayah.

**Integritas berkas (SHA256, dihitung ulang):**

| Berkas | SHA256 |
|---|---|
| `Data Fix - DATA.csv` | `ad69f257005795e69fe56006f32e913e8231777a6cb66bcb40782cdd7eea0eb5` |
| `data/lampung_panel_clean.csv` | `becc5801facc6ee6f04a5d1906646a71eaa9e0c45c3cb45c22e6febb506a8431` |
| `review/sources/bapanas_ikp_kabkota_2018-2024_514.csv` | `d5e052955db4f818271e4532f6fb299df409090dd6bd7bfd7632c049255503c8` |
| `review/sources/bapanas_ikp_kabkota_2024_12indikator.csv` | `b1a8753d6b7746ad8f5e4461bd22fb965221bf82727d0538b6760aab471c015b` |
| `review/sources/lampungprov_ikp_kabkota_2019-2024.csv` | `d07a4b96b17522f80db860496b021becd38d2e2da6de1903ca57c542e2b8c7d3` |
| `review/sources/BKP_Indeks_Ketahanan_Pangan_2018.pdf` | `2d58a0e9857a7e2299e621373cbf4d789bebd26d3dd7dd399ee48c7133b65fb9` |

Tanggal unduh berkas sumber: 23 September 2026.

### 3.4 Definisi Operasional Variabel

| Variabel | Simbol | Deskripsi | Skala |
|---|---|---|---|
| Indeks Ketahanan Pangan | `ikp` | Variabel terikat (Y) | 0–100 |
| IPM | `ipm` | Indeks Pembangunan Manusia | 0–100 |
| Kemiskinan | `kemiskinan` | Persentase penduduk miskin | persen |
| PDRB per kapita | `ln_pdrb` | Logaritma natural PDRB per kapita | rasio |
| Produksi padi | `ln_padi` | Logaritma natural produksi padi | rasio |
| COVID | `covid` | Dummy 1 untuk 2020–2021, 0 lainnya | 0/1 |

PDRB per kapita dan produksi padi ditransformasi ke logaritma natural untuk meredam skala besar dan distribusi yang miring.

### 3.5 Tumpang Tindih antara Variabel Penjelas dan Komponen Indeks

Ini pertimbangan metodologis yang menentukan bentuk seluruh Bab 4, dan **tidak ada** di draft lama.

IKP adalah indeks komposit berbobot. Bobot indikator IKP **kabupaten** (9 indikator) dan **kota** (8 indikator) adalah sebagai berikut:

| Indikator penyusun IKP | Bobot kabupaten | Bobot kota | Status dalam model awal |
|---|---|---|---|
| Rasio konsumsi normatif vs ketersediaan bersih | 0,300 | 0,000 (aspek ketersediaan dihapus) | — |
| **Persentase penduduk di bawah garis kemiskinan** | **0,150** | **0,200** | ⚠️ **variabel X2** |
| RT dengan pengeluaran pangan > 65% | 0,075 | 0,125 | — |
| RT tanpa akses listrik | 0,075 | 0,125 | — |
| **Rata-rata lama sekolah perempuan > 15 tahun** | **0,050** | **0,080** | ⚠️ **komponen IPM** |
| RT tanpa akses air bersih | 0,150 | 0,180 | — |
| Rasio penduduk per tenaga kesehatan | 0,050 | 0,080 | — |
| Prevalensi balita *stunting* | 0,050 | 0,080 | — |
| **Angka harapan hidup saat lahir** | **0,100** | **0,130** | ⚠️ **komponen IPM** |
| **Total** | **1,000** | **1,000** | |

IPM adalah indeks komposit dari angka harapan hidup, rata-rata lama sekolah, dan pengeluaran per kapita. **Dua dari tiga komponen IPM berada di dalam IKP.** Ditambah kemiskinan, **0,30 dari indeks kabupaten (0,41 dari indeks kota) tersusun dari variabel-variabel yang ada di sisi kanan persamaan.** Jadi pertanyaan penelitian "apakah kemiskinan memengaruhi IKP" **bukan hipotesis yang dapat diuji secara sah dengan desain ini** — sebagian jawabannya sudah tertulis di rumus indeks.

Dua konsekuensi yang diterapkan pada Bab 4:

1. **Spesifikasi dengan RHS bersih** (tanpa IPM dan kemiskinan) dilaporkan sebagai model utama, karena hanya dua variabel tersisa (PDRB per kapita, produksi padi) yang secara struktural terpisah dari Y.
2. Spesifikasi dengan IPM dan kemiskinan tetap dilaporkan, tetapi **diberi label "model indikator penyusun"** dan tidak ditafsirkan sebagai estimasi pengaruh.

Tambahan penting soal produksi padi: dokumen BKP menyatakan komponen ketersediaan IKP memakai **angka tetap 2014–2016**. Artinya komponen ketersediaan **dibekukan** selama periode pengamatan, sehingga produksi padi tahunan dari BPS bukan input yang menggerakkan Y pada seri 2018–2024. Ini membatasi (bahkan menghapus) jalur mekanis dari X4 ke Y.

### 3.6 Dua Instrumen Berbeda: IKP Kabupaten vs IKP Kota

Persentase kemiskinan berbobot 0,15 di kabupaten dan 0,20 di kota; rata-rata lama sekolah perempuan 0,05 vs 0,08; angka harapan hidup 0,10 vs 0,13; dan aspek ketersediaan (bobot 0,30) **dihapus seluruhnya** untuk kota karena "ketersediaan pangan di tingkat perkotaan tidak dipengaruhi oleh produksi yang berasal dari wilayah sendiri". *Cut-off* pengelompokan kategori pun berbeda (kabupaten ≤ 41,52 … > 75,68; kota ≤ 28,84 … > 70,64).

Konsekuensinya, **13 kabupaten dan 2 kota memiliki Y dengan definisi, skala, dan bobot berbeda.** Menggabungkannya dalam satu regresi berarti memperlakukan dua instrumen berbeda sebagai satu variabel. Karena itu estimasi juga dijalankan terpisah: 13 kabupaten (n = 91) sebagai sampel terpisah, sedangkan 2 kota (n = 14) hanya disajikan deskriptif karena efek tetap dua wilayah dengan lima koefisien tidak bermakna secara statistik.

### 3.7 Model

Model yang diestimasi (efek tetap wilayah, `μ_i`; efek tetap tahun, `λ_t`):

```
ikp_it = α + β1·ipm_it + β2·kemiskinan_it + β3·ln_pdrb_it + β4·ln_padi_it + β5·covid_t + μ_i + ε_it     (M1: draft lama)
ikp_it = α + β1·ipm_it + β2·kemiskinan_it + β3·ln_pdrb_it + β4·ln_padi_it + λ_t + μ_i + ε_it            (M2: + efek tahun)
ikp_it = α + β3·ln_pdrb_it + β4·ln_padi_it + λ_t + μ_i + ε_it                                            (M3: RHS bersih + efek tahun)
```

M1 adalah spesifikasi yang dilaporkan draft lama; **M3 adalah model utama revisi ini**. M2 dilaporkan sebagai jembatan untuk menunjukkan apa yang berubah ketika efek tahun masuk.

### 3.8 Strategi Inferensi

- **Pemilihan model:** uji Chow, uji *Lagrange Multiplier* Breusch–Pagan, dan uji Hausman. Uji Hausman klasik dijalankan, tetapi karena uji Wooldridge menunjukkan korelasi serial (p = 0,005), bentuk klasiknya **tidak sah** untuk inferensi (matriks varians-kovarians tidak sesuai di bawah korelasi serial). Karena itu versi **robust Hausman (pendekatan Mundlak)** dengan varians Wald klaster dilaporkan sebagai pengganti.
- **Efek tahun:** uji F gabungan tahun dummies dilaporkan, bukan hanya koefisien individualnya.
- **Standard error:** *cluster-robust* (HC1 dan, untuk kontinuitas, HC3) dengan klaster kabupaten; serta **Driscoll–Kraay** sebagai pembanding yang tahan terhadap dependensi lintas wilayah dan autokorelasi.
- **Inferensi klaster kecil:** **wild cluster bootstrap** (Rademacher, klaster kabupaten, B = 999, seed 1093) dilaporkan **berdampingan** dengan p-value asimtotik, karena dengan G = 15 p-value asimtotik terlalu optimistis.
- **Daya uji:** *minimum detectable effect* (MDE) pada α = 5% dan *power* = 80%, dibandingkan dengan simpangan baku *within* masing-masing variabel, untuk membedakan "tidak ada efek" dari "tidak bertenaga".

### 3.9 Mengapa Bukan Dynamic Panel GMM

Rencana awal menggunakan *System GMM* untuk menangkap dinamika. Namun, dengan N = 15, jumlah instrumen yang terbentuk dari lag variabel tumbuh cepat dan berpotensi melampaui jumlah grup. Sesuai Roodman (2009), jumlah instrumen tidak boleh melebihi jumlah grup; pelanggaran menyebabkan *overfitting* instrumen dan membuat uji Hansen/Sargan kehilangan daya (p-value mendekati 1,0 adalah pertanda buruk, bukan validasi). Karena itu GMM dinilai tidak dapat dipertanggungjawabkan dan tidak digunakan. Sebagai gantinya digunakan model panel statis dengan efek tetap wilayah dan tahun.

### 3.10 Tahapan Analisis

1. Pembersihan dan penataan data ke format panel, transformasi log, dan pembuatan dummy COVID.
2. *Reality check* dinamika melalui korelasi/regresi IKP(t) terhadap IKP(t−1).
3. Estimasi Pooled/FE/RE dan uji pemilihan model.
4. Estimasi model M1, M2, M3 dengan diagnostik lengkap.
5. Revisi spesifikasi: efek tahun masuk model utama, Hausman klasik → robust, WCB + Driscoll–Kraay + MDE, estimasi terpisah kabupaten vs kota, dan spesifikasi RHS bersih.

---

## 4. Hasil dan Pembahasan

Seluruh angka pada bab ini dihasilkan oleh `R/11_year_fe_inference.R` (exit 0) dan dapat direproduksi dari `output/11_year_fe.log`.

### 4.1 Statistik Deskriptif

Selama 2018–2024, rata-rata IKP kabupaten/kota di Lampung adalah **78,48** dengan rentang 65,98 hingga 88,78.

| Variabel | Mean | SD | Min | Max |
|---|---|---|---|---|
| ikp | 78,478 | 5,116 | 65,980 | 88,780 |
| ipm | 69,219 | 3,927 | 62,880 | 79,190 |
| kemiskinan | 11,511 | 3,279 | 6,310 | 20,850 |
| pdrb (ribu rupiah) | 26.478,4 | 6.559,4 | 15.759,0 | 40.472,0 |
| produksi_padi (ton) | 171.675,0 | 159.765,6 | 2.318,2 | 614.016,7 |

Rata-rata IKP per tahun memperlihatkan dua lompatan: **2019 (+2,88)** dan **2023 (+2,94)**.

| Tahun | IKP rata-rata | Δ IKP | IPM rata-rata | Kemiskinan rata-rata |
|---|---|---|---|---|
| 2018 | 74,10 | — | 67,92 | 12,57 |
| 2019 | 76,98 | **+2,88** | 68,51 | 12,09 |
| 2020 | 77,56 | +0,58 | 68,66 | 11,82 |
| 2021 | 77,96 | +0,40 | 68,89 | 12,15 |
| 2022 | 78,61 | +0,65 | 69,51 | 11,12 |
| 2023 | 81,55 | **+2,94** | 70,18 | 10,65 |
| 2024 | 82,58 | +1,03 | 70,87 | 10,19 |

Perhatikan bahwa **tahun-tahun COVID (2020–2021) justru tahun dengan perubahan terkecil** (+0,58; +0,40). Dummy COVID menandai periode yang salah untuk alasan yang salah.

Lompatan 2023 **bukan artefak lokal**: rata-rata IKP nasional 514 kabupaten/kota bergerak dari 71,84 (2022) ke **74,43 (2023)**, atau +2,59, sedangkan 2020 dan 2021 hanya +0,53 dan +0,32. Pola Lampung identik dengan pola nasional. Ini bukti eksternal bahwa yang terjadi pada 2023 adalah gerakan serentak se-Indonesia — persis jenis gerakan yang akan terserap oleh koefisien apabila efek tahun tidak dimasukkan.

Secara *pooled*, korelasi IKP–IPM hanya **0,088**, sedangkan korelasi IKP dengan kemiskinan **−0,485** dan dengan ln(PDRB) **0,453**. Rendahnya korelasi *pooled* IKP–IPM penting: secara *antarwilayah*, kota dengan IPM tinggi (Bandar Lampung, Metro) tidak otomatis memiliki IKP tinggi. Inilah alasan mengapa analisis *within* (FE) lebih tepat daripada *pooled*. Namun, sebagaimana ditunjukkan di bawah, seluruh korelasi *pooled* ini mencampur perbedaan antarwilayah dengan tren bersama waktu.

### 4.2 Reality Check: Statis atau Dinamis?

Korelasi *pooled* IKP(t) dengan IKP(t−1) sebesar **0,879**, tetapi ukuran ini mencampur perbedaan antarwilayah. Setelah mengendalikan efek individu (dalam/FE), koefisien lag IKP(t−1) turun menjadi **0,619** (p < 0,001). Dengan demikian persistensi bersifat moderat dan model panel statis masih memadai sebagai kerangka utama; lag-Y penuh tidak diwajibkan, terutama karena N = 15 menutup estimator dinamis yang valid.

### 4.3 Pemilihan Model

| Uji | Statistik | p-value | Keputusan |
|---|---|---|---|
| Chow (FE vs Pooled) | F = 9,94 | 1,0e-12 | Efek individu ada |
| LM Breusch–Pagan (RE vs Pooled) | χ² = 21,88 | 2,9e-06 | Tolak Pooled |
| Hausman klasik (FE vs RE) | χ² = 57,77 | 3,5e-11 | FE lebih tepat |
| **Robust Hausman / Mundlak (dilaporkan)** | **W = 24,44** | **6,5e-05** | **FE tetap tepat** |

Uji Hausman klasik dilaporkan **untuk transparansi**, tetapi bentuknya tidak sah: uji Wooldridge menunjukkan korelasi serial (p = 0,005), sehingga asumsi matriks varians-kovarians yang mendasarinya dilanggar. Versi robust (Mundlak, varians Wald klaster) memberi hasil yang sama secara kesimpulan, dan itulah yang dipakai: **efek tetap wilayah tetap tepat.**

### 4.4 Spesifikasi Draft Lama (M1) dan Apa yang Salah

Ini angka yang dilaporkan draft lama, disertakan untuk jejak revisi:

**M1. FE wilayah + dummy COVID (N = 105, cluster-robust HC1, klaster kabupaten)**

| Variabel | Koefisien | SE | p-value |
|---|---|---|---|
| IPM | **1,959** | 0,443 | < 0,001 |
| Kemiskinan | −0,489 | 0,477 | 0,308 |
| ln(PDRB) | 13,377 | 10,490 | 0,206 |
| ln(Padi) | 1,557 | 1,034 | 0,136 |
| COVID | 1,242 | 0,734 | 0,094 |

R² (dengan dummies wilayah) = 0,8535.

Angka ini **benar sebagai keluaran kode** — yang bermasalah adalah tafsir dan spesifikasinya. Tiga keberatannya:

**Keberatan 1 — efek tahun wajib, bukan pilihan.** Uji F gabungan tahun *dummies* menolak model tanpa efek tahun:

```
F = 6,8723 | df 6/80 | p = 6,576e-06
```

Dan ukurannya besar, bukan marginal: efek tahun menjelaskan **97,2%** variasi *within* IPM dan 67,8% variasi *within* IKP.

| Variabel | var(within) | R² terhadap tahun | var sisa |
|---|---|---|---|
| ikp | 10,391 | 0,6775 | 3,352 |
| **ipm** | **0,942** | **0,9717** | **0,027** |
| kemiskinan | 0,757 | 0,8787 | 0,092 |
| ln_pdrb | 0,0017 | 0,6774 | 0,0005 |
| ln_padi | 0,0222 | 0,3087 | 0,0153 |
| produksi_padi | 7,83e+08 | 0,2319 | 6,01e+08 |

Hanya **2,7%** variasi *within* IPM yang tertinggal setelah tren tahun dikeluarkan. Korelasi *within* IPM terhadap tahun = **0,965**. Dengan kalimat lain: IPM yang dipakai di M1 hampir seluruhnya adalah **penanda tahun**, dan koefisien IPM menyerap gerakan serentak se-Indonesia.

**Keberatan 2 — tanda koefisien berbalik.** Begitu efek tahun masuk (M2):

**M2. FE wilayah + FE tahun (N = 105, cluster-robust HC1)**

| Variabel | Koefisien | SE | p-value |
|---|---|---|---|
| IPM | **−2,228** | 1,648 | 0,180 |
| Kemiskinan | +0,781 | 0,813 | 0,339 |
| ln(PDRB) | 1,627 | 8,281 | 0,845 |
| ln(Padi) | 2,527 | 1,272 | 0,050 |

R² = 0,8823. Koefisien IPM berbalik dari +1,959 menjadi **−2,228** dan menjadi tidak signifikan. Ini bukan efek samping kosmetik: pada spesifikasi yang mengidentifikasi efek dari gerak **antarwilayah**, bukan dari tren bersama, tanda hubungannya berbalik.

Hasil yang sama muncul pada estimasi *first difference*:

| Model | IPM | Kemiskinan | ln(PDRB) | ln(Padi) |
|---|---|---|---|---|
| FD murni | 1,605 (0,717) **p = 0,028** | −0,077 (0,377) | 0,921 (6,376) | −1,727 (1,142) |
| **FD + year dummies** | 0,158 (1,233) **p = 0,899** | −0,031 (1,108) | −2,676 (7,763) | — |

**Keberatan 3 — tumpang tindih X–Y (Bab 3.5).** Bahkan bila efek tahun ditangani, IPM dan kemiskinan tetap tidak dapat ditafsirkan. Besarnya pengaruh tumpang tindih ini terlihat dari kontribusi masing-masing variabel terhadap R²:

| Spesifikasi (semua sudah memuat dummies wilayah) | R² | ΔR² dari FE saja |
|---|---|---|
| FE saja | 0,6030 | — |
| **FE + kemiskinan** | **0,8050** | **+0,2020** |
| FE + IPM | 0,8425 | +0,2395 |
| FE + produksi_padi | 0,6461 | +0,0431 |
| FE + PDRB | 0,7014 | +0,0984 |
| FE + model utama (5 variabel + COVID) | 0,8535 | +0,2505 |
| FE + model utama + efek tahun | 0,8823 | +0,2793 |

**Satu variabel yang secara konstruksi ada di dalam Y (kemiskinan, bobot 0,15) menjelaskan 80,5% variasi.** Empat variabel lain ditambah dummy COVID secara kolektif hanya menambah **4,8 poin persentase** di atas kemiskinan saja; efek tahun menambah 2,9 poin, lebih besar dari kontribusi bersama keempat variabel itu. Model utama dengan demikian sebagian besar sedang mengukur **konstruksi indeks + tren waktu**.

Sebagai ilustrasi langsung: koefisien kemiskinan pada FE tanpa kontrol lain adalah **−2,643 (p < 0,001)** dengan R² 0,8050. Angka yang sangat presisi dari **satu** regresor ini bukan temuan ekonomi — ia mencerminkan bobot negatif tetap kemiskinan di dalam rumus indeks. Angka itu **tidak boleh** ditafsirkan sebagai elastisitas kebijakan ("turunkan kemiskinan 1%, IKP naik 2,64 poin").

### 4.5 Model Utama Revisi: RHS Bersih + Efek Tahun

Hanya log(PDRB per kapita) dan log(produksi padi) yang terpisah secara struktural dari Y. Model M3 diestimasi pada N = 105 dan pada 13 kabupaten saja.

| Spesifikasi | ln(PDRB) | p | ln(Padi) | p | R² |
|---|---|---|---|---|---|
| RHS bersih + dummy COVID (N = 105) | 50,632 (13,121) | 0,0002 | 4,544 (2,080) | 0,032 | 0,7395 |
| **RHS bersih + FE tahun (N = 105)** | **2,830 (8,483)** | **0,740** | **2,770 (1,050)** | **0,010** | **0,8768** |
| RHS bersih + FE tahun (13 kabupaten, n = 91) | −3,633 (7,618) | 0,635 | 3,665 (1,175) | 0,003 | 0,9306 |

*(SE cluster-robust HC1 dalam tanda kurung.)*

Uji F gabungan efek tahun pada RHS bersih: **F = 22,221; df 6/82; p = 2,3e-15** — lebih kuat daripada pada model dengan IPM, karena tanpa IPM tidak ada lagi proksi tahun di sisi kanan.

Polanya identik dengan M1→M2: **apabila efek tahun tidak dikontrol, koefisien ln(PDRB) menggelembung menjadi 50,63 (tampak sangat signifikan); setelah efek tahun masuk, nilainya menjadi 2,83 dan sama sekali tidak signifikan.** ln(PDRB) bahkan berbalik tanda (−3,63) pada sampel 13 kabupaten. Rasio sinyal PDRB juga sangat tipis: simpangan baku *within* ln(PDRB) hanya **0,041**, sementara MDE-nya 24,95 — artinya uji ini hanya mampu mendeteksi efek ratusan kali lebih besar daripada variasi yang tersedia.

### 4.6 Inferensi dengan G = 15: Mengapa p Asimtotik Tidak Cukup

**Wild cluster bootstrap (Rademacher, klaster kabupaten, B = 999, seed 1093)** — dibandingkan dengan p asimtotik:

| Model | t | p asimtotik (HC1) | **p WCB** |
|---|---|---|---|
| M1: FE + COVID, koef IPM | 4,423 | 0,0000 | **0,109** |
| M2: FE + FE tahun, koef IPM | −1,352 | 0,180 | **0,425** |
| M3: RHS bersih + FE tahun (N = 105), koef ln(PDRB) | 0,334 | 0,740 | 0,747 |
| M3: RHS bersih + FE tahun (N = 105), koef ln(Padi) | 2,638 | 0,010 | **0,249** |
| M3: RHS bersih + FE tahun (13 kab., n = 91), koef ln(Padi) | 3,120 | 0,003 | **0,192** |

**Tidak satu pun koefisien yang bertahan pada uji WCB.** Bahkan pada spesifikasi draft lama, klaim "IPM signifikan (***)" menjadi p = 0,109. Dengan G = 15, p asimtotik terlalu optimistis dan tidak layak dijadikan dasar klaim signifikansi.

Perlu ditegaskan: **ini bukan sekadar masalah "N kecil"**. Uji ketahanan berikut menunjukkan koefisien M1 justru stabil terhadap perubahan unit:

- *Jackknife* buang-satu-tahun (7 run): koef IPM 1,59–2,26; semua p ≤ 0,0012.
- *Jackknife* buang-satu-kabupaten (15 run): koef IPM 1,71–2,20; **15/15 tetap p < 0,05.**
- Pesaran CD (dependensi lintas wilayah): z = 0,128; **p = 0,898** → tidak ada dependensi lintas wilayah.

Artinya koefisien **stabil terhadap perubahan unit, tetapi rapuh terhadap perubahan spesifikasi dan terhadap cara menghitung p-value.** Diagnosis yang benar bukan "sampelnya terlalu kecil", melainkan **"data ini tidak dapat mengidentifikasi pengaruh variabel penjelas terhadap IKP secara terpisah dari tren waktu bersama dan dari konstruksi indeks"**. Dua diagnosis ini membawa konsekuensi penulisan yang berbeda jauh.

Sebagai pembanding, *Driscoll–Kraay* SE (tahan dependensi lintas wilayah dan autokorelasi, *maxlag* = 2) memberi hasil:

| Model | Variabel | Koefisien | DK SE | p |
|---|---|---|---|---|
| M1 (FE + COVID) | ipm | 1,959 | 0,279 | 0,0000 |
| | kemiskinan | −0,489 | 0,177 | 0,007 |
| | ln_pdrb | 13,377 | 5,444 | 0,016 |
| | ln_padi | 1,557 | 0,948 | 0,104 |
| | covid | 1,242 | 0,284 | 0,000 |
| M2 (FE + FE tahun) | ipm | −2,228 | 1,257 | 0,080 |
| | kemiskinan | 0,781 | 0,306 | 0,013 |
| | ln_pdrb | 1,627 | 3,535 | 0,647 |
| | ln_padi | 2,527 | 0,929 | 0,008 |

Driscoll–Kraay memberi p yang lebih kecil daripada WCB, **dan itu justru pelajaran pentingnya**: dua koreksi yang sama-sama dirancang untuk G kecil dapat memberi kesimpulan berlawanan pada sampel ini. Karena itu p asimtotik saja, atau satu jenis koreksi saja, tidak cukup untuk mengklaim signifikansi. Hanya WCB yang secara eksplisit memperlakukan jumlah klaster sebagai terbatas (G = 15 digunakan penuh dalam resampling), dan itu yang diambil sebagai acuan konservatif.

### 4.7 Daya Uji: Membedakan "Tidak Ada Efek" dari "Tidak Bertenaga"

| Variabel | β (M1) | SE | MDE (M1) | β (M2) | SE | MDE (M2) | SD *within* | **MDE / SD *within*** |
|---|---|---|---|---|---|---|---|---|
| ipm | 1,959 | 0,443 | 1,334 | −2,228 | 1,648 | 4,966 | 0,971 | **5,11** |
| kemiskinan | −0,489 | 0,477 | 1,438 | 0,781 | 0,813 | 2,449 | 0,870 | **2,81** |
| ln_pdrb | 13,377 | 10,490 | 31,604 | 1,627 | 8,281 | 24,951 | 0,041 | **608,56** |
| ln_padi | 1,557 | 1,034 | 3,116 | 2,527 | 1,272 | 3,833 | 0,149 | **25,72** |

*(df = G − 1 = 14; t₀,₉₇₅ = 2,145; t₀,₈₀ = 0,868.)*

Kolom terakhir adalah kuncinya. Dengan N = 15, penelitian ini **hanya mampu mendeteksi efek yang jauh lebih besar daripada variasi data yang tersedia** — untuk ln(PDRB) dua orde besaran lebih besar. Ini berarti hasil "tidak signifikan" pada model M2/M3 **tidak boleh** ditulis sebagai "variabel ini tidak berpengaruh". Yang dapat ditulis adalah: dengan daya uji yang tersedia, tidak ada efek yang cukup besar untuk melampaui ambang deteksi, dan ambang itu sangat tinggi.

### 4.8 Estimasi Terpisah: 13 Kabupaten vs 2 Kota

**13 kabupaten (n = 91), cluster-robust HC1:**

| Variabel | M1: FE + COVID | M2: FE + FE tahun |
|---|---|---|
| ipm | 1,787 (0,269) p < 0,001 | 0,226 (1,281) p = 0,861 |
| kemiskinan | −0,440 (0,321) p = 0,175 | 0,033 (0,546) p = 0,952 |
| ln_pdrb | 3,192 (6,734) p = 0,637 | −3,393 (8,055) p = 0,675 |
| ln_padi | 2,616 (1,085) **p = 0,018** | **3,675 (1,467) p = 0,015** |
| covid | 0,835 (0,581) p = 0,155 | — |

**2 kota (n = 14):** hanya disajikan deskriptif. Kota Bandar Lampung dan Kota Metro, IKP dan IPM:

| Wilayah | 2018 | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 |
|---|---|---|---|---|---|---|---|
| Kota Bandar Lampung (IKP) | 68,93 | 73,49 | 71,62 | 74,17 | 73,41 | 83,37 | 84,64 |
| Kota Metro (IKP) | 65,98 | 75,85 | 76,76 | 76,74 | 73,35 | 83,66 | 85,78 |
| Kota Bandar Lampung (IPM) | 76,63 | 77,33 | 77,44 | 77,58 | 78,01 | 78,56 | 79,19 |
| Kota Metro (IPM) | 76,22 | 76,77 | 77,19 | 77,49 | 77,89 | 78,36 | 78,93 |

Perhatikan lompatan 2022→2023: **+9,96** (Bandar Lampung) dan **+10,31** (Metro), dibanding rata-rata kabupaten sekitar +3. Sebagaimana dijelaskan Bab 3.6, dua kota memakai instrumen berbeda (tanpa aspek ketersediaan). Estimasi terpisah untuk kota memerlukan data tambahan (misalnya kota se-Sumatera), bukan dijalankan pada n = 14.

**Catatan penting — jangan jadikan ln(Padi) = 3,675 sebagai temuan.** Pada sampel 13 kabupaten dengan efek tahun, satu-satunya koefisien yang tampak signifikan adalah ln(Padi) (3,675; p = 0,015). Angka ini **paling mencurigakan** di seluruh analisis, karena:

1. Komponen ketersediaan IKP dibekukan pada angka tetap **2014–2016**, sehingga produksi padi tahunan secara mekanis bukan input yang menggerakkan Y.
2. Varians *within* produksi padi sangat kecil (7,83e+08 pada skala ton, dengan R² terhadap tahun hanya 0,232 → variasi antarwaktu lemah), sehingga koefisien besar dengan SE sedang mudah muncul dari gerak acak.
3. Angka ini hanya muncul setelah **membuang 2 kota** *dan* **memasukkan efek tahun** — kombinasi yang belum pernah dilaporkan.
4. **Uji wajib sudah dijalankan dan gagal:** WCB memberi **p = 0,192** (13 kabupaten) dan **p = 0,249** (N = 105). Klaim signifikansi tidak bertahan.

Kesimpulannya: ln(Padi) = 3,675 adalah **non-temuan**, dan dicatat di sini secara eksplisit agar tidak "ditemukan kembali" sebagai hasil positif di kemudian hari.

### 4.9 Pembahasan

Draft lama menyimpulkan bahwa "IPM adalah pendorong utama yang robust" terhadap IKP. Revisi ini menunjukkan bahwa kalimat itu tidak dapat dipertahankan. Tiga pemeriksaan yang berbeda menuju kesimpulan yang sama:

| Pemeriksaan | Hasil pada spesifikasi draft lama | Setelah diperbaiki |
|---|---|---|
| Efek tahun (uji F gabungan) | tidak dikontrol | **F = 6,87; p = 6,6e-06** → wajib dikontrol |
| Koefisien IPM | +1,959 (p < 0,001) | **−2,228 (p = 0,180)** |
| Tafsir koefisien IPM | "pengaruh IPM" | sebagian identitas indeks (AHH 0,10; RLS perempuan 0,05 ada di dalam IKP) |
| Inferensi | p asimtotik | **p WCB = 0,109** |
| Model dengan RHS bersih | tidak pernah dijalankan | **tidak ada koefisien yang bertahan WCB** |
| Daya uji | tidak dilaporkan | **MDE = 5,11 SD *within* (IPM)** |

Dengan demikian:

1. **Kemiskinan.** Arah negatif yang "sesuai teori" pada draft lama bukan konfirmasi teori: kemiskinan berbobot 0,15 (kabupaten) / 0,20 (kota) **di dalam** IKP. Koefisien −2,643 yang sangat presisi pada FE sederhana adalah cermin bobot indeks. Pertanyaan penelitian #1 untuk variabel ini **tidak dapat diuji** dengan desain ini.
2. **IPM.** Dua dari tiga komponen IPM (angka harapan hidup 0,10/0,13 dan rata-rata lama sekolah perempuan 0,05/0,08) juga berada di dalam IKP. Setelah efek tahun masuk, tanda koefisien berbalik. Yang tersisa dari temuan draft lama bukan "pengaruh IPM", melainkan **"dua indeks yang berbagi komponen dan bergerak bersama sepanjang waktu"**.
3. **PDRB per kapita.** Sangat sensitif terhadap spesifikasi (+50,63 → +2,83 → −3,63). Rasio sinyal terhadap *noise* ekstrem: SD *within* = 0,041. Identifikasi *within* praktis kosong; tidak ada kesimpulan yang bisa ditarik.
4. **Produksi padi.** Komponen ketersediaan IKP dibekukan pada angka 2014–2016, sehingga jalur mekanis dari produksi padi tahunan ke Y tidak ada. Hasil lagged-X pada draft lama (3,16; p = 0,042) karena itu **tidak dapat** ditafsirkan sebagai "efek tertunda"; penjelasan yang lebih masuk akal adalah lag menyelaraskan pola gerak/level pada sampel kecil. Uji WCB atas variasi terkuat dari angka ini (3,675) memberi p = 0,192 → non-temuan.
5. **COVID.** Dummy COVID positif marginal pada draft lama, dan setelah dilihat per tahun, 2020–2021 justru tahun dengan perubahan IKP **terkecil** (+0,58; +0,40) sementara 2019 (+2,88) dan 2023 (+2,94) adalah perubahan terbesar. Dummy COVID menandai periode yang salah untuk alasan yang salah; penggantinya adalah efek tahun penuh.
6. **Dinamika waktu.** Persistensi ada (koef lag *within* 0,62), tetapi pertanyaan penelitian #2 tidak dapat dijawab dengan estimator dinamis yang valid pada N = 15. Yang dapat dikatakan: **97,2% gerak *within* IPM dan 67,8% gerak *within* IKP dijelaskan semata oleh tahun**, dan pola itu berskala nasional.

---

## 5. Kesimpulan

1. **Tidak ada variabel penjelas yang teridentifikasi berpengaruh secara robust terhadap IKP dalam desain ini.** Pada spesifikasi yang layak (efek tetap wilayah + efek tetap tahun, dengan IPM dan kemiskinan dikeluarkan dari sisi kanan), tidak satu pun koefisien yang bertahan pada *wild cluster bootstrap*: log(PDRB) p = 0,747; log(Padi) p = 0,249. Pada spesifikasi draft lama, IPM pun hanya mencapai p = 0,109.
2. **Dua dari empat variabel penjelas adalah komponen IKP itu sendiri.** Kemiskinan berbobot 0,15 (kabupaten) / 0,20 (kota) langsung di dalam indeks; angka harapan hidup (0,10/0,13) dan rata-rata lama sekolah perempuan (0,05/0,08) adalah komponen IPM yang juga penyusun IKP. Total 0,30 (kabupaten) / 0,41 (kota) dari indeks berasal dari variabel yang ada di sisi kanan persamaan. Untuk kedua variabel ini, rumusan masalah "apakah berpengaruh" **tidak dapat dijawab** — jawabannya ada di rumus indeks.
3. **Sisanya tidak teridentifikasi terpisah dari tren bersama.** Efek tahun menjelaskan 97,2% variasi *within* IPM; memasukkan efek tahun membalik tanda koefisien IPM (+1,959 → −2,228) dan menghapus signifikansi log(PDRB) (+50,63 → +2,83). Gerakan yang terserap itu berskala nasional (rata-rata 514 kabupaten/kota: +2,59 pada 2023).
4. **Daya uji sangat terbatas dan harus dilaporkan.** MDE untuk IPM setara 5,11 simpangan baku *within*; untuk log(PDRB) setara 608 kali. Karena itu "tidak signifikan" **tidak sama dengan** "tidak berpengaruh", dan pernyataan semacam itu tidak dibuat dalam laporan ini.
5. **IKP bukan satu seri tunggal.** Dua berkas resmi Bapanas berbeda hingga 17,10–18,24 poin untuk tahun yang sama (versi 9/8 indikator vs versi 12 indikator *backcasting*). Naskah wajib menyebut *vintage* yang dipakai. Seri dalam penelitian ini adalah versi 9 indikator kabupaten / 8 indikator kota, dipakai konsisten 2018–2024 dan terverifikasi 15/15 ke publikasi primer BKP 2018 untuk skor **dan** peringkat nasional.
6. **IKP kabupaten dan IKP kota adalah dua instrumen berbeda.** Aspek ketersediaan (bobot 0,30) dihapus untuk kota dan bobotnya dialihkan proporsional, sehingga persentase kemiskinan berbobot 0,15 di kabupaten dan 0,20 di kota. Penggabungan keduanya dalam satu regresi diperlakukan sebagai keterbatasan; estimasi 13 kabupaten dilaporkan terpisah, dan 2 kota hanya deskriptif.

**Rumusan kesimpulan yang dapat dipertahankan:** *Dengan panel 15 kabupaten/kota Provinsi Lampung 2018–2024, tidak ada variabel penjelas yang teridentifikasi berpengaruh secara robust terhadap Indeks Ketahanan Pangan. Dua dari empat variabel penjelas adalah indikator penyusun IKP itu sendiri, sehingga pertanyaan pengaruhnya tidak dapat diuji secara sah dengan desain ini; dua variabel sisanya tidak teridentifikasi terpisah dari tren waktu bersama. Hasil ini berbeda dari temuan awal karena efek tahun — yang menjelaskan 97,2% variasi within IPM dan berskala nasional — dimasukkan ke dalam spesifikasi, dan karena inferensi dengan G = 15 memerlukan wild cluster bootstrap, di mana tidak ada klaim signifikansi yang bertahan.*

---

## 6. Keterbatasan

1. **Tumpang tindih konstruksi.** Kemiskinan dan dua komponen IPM adalah indikator penyusun IKP. Ini adalah keterbatasan **struktural**, bukan keterbatasan sampel, dan tidak dapat diatasi dengan memperbesar N selama variabel tersebut tetap di sisi kanan.
2. **Jumlah klaster sangat kecil (G = 15).** Inferensi asimtotik terlalu optimistis; laporan ini memakai WCB sebagai acuan konservatif. Namun dua koreksi untuk G kecil (WCB vs Driscoll–Kraay) memberi kesimpulan yang berbeda pada sampel ini, dan itu sendiri sebuah keterbatasan.
3. **Daya uji rendah.** MDE setara 5,11 SD *within* untuk IPM dan 608 untuk log(PDRB). "Tidak signifikan" tidak boleh dibaca sebagai "tidak ada efek".
4. ***Vintage* indeks dan komparabilitas.** Seri 2018–2024 hanya dapat dipertanggungjawabkan sebagai satu seri jika metodologi tidak berubah di tengah rentang. **Verifikasi metodologi per tahun 2019–2024 belum dikerjakan**; hanya 2018 yang sudah ditelusuri sampai ke publikasi primer. Ini aksi yang masih terbuka dan wajib.
5. **Komponen ketersediaan dibekukan (angka tetap 2014–2016).** Karena itu produksi padi tahunan tidak dapat menggerakkan Y melalui jalur ketersediaan, dan pilar *stabilitas* belum terwakili sama sekali.
6. **Dua instrumen berbeda.** IKP kota (8 indikator) dan IKP kabupaten (9 indikator) memiliki bobot dan *cut-off* berbeda; keduanya digabung dalam estimasi N = 105. Estimasi terpisah untuk kota tidak layak pada n = 14.
7. **Bukan bukti kausalitas.** Seluruh hasil bersifat asosiasi kondisional; tidak ada strategi identifikasi kausal (instrumen eksternal, eksperimen, atau desain diskontinuitas) yang diterapkan.
8. **Kualitas data mentah.** Berkas asli memiliki masalah pemformatan (header multi-baris, kode wilayah kosong tahun 2019–2024, pemisah desimal campuran koma/titik, satu nilai berkoma ganda `155,711,37` dan satu bertitik ganda `215.987.34`). Parser menangani keduanya dengan benar dan sudah diaudit, tetapi ketergantungan pada pola string adalah kelemahan yang diakui.

---

## 7. Saran

### 7.1 Saran Metodologis untuk Penelitian Lanjutan

1. **Ganti objek studi atau ganti variabel penjelas.** Karena kemiskinan dan komponen IPM adalah penyusun IKP, pertanyaan "determinan IKP" tidak dapat dijawab sementara variabel tersebut ada di sisi kanan. Dua jalur yang layak: (i) jadikan **indikator penyusun** (akses air bersih, *stunting*, RLS perempuan, angka harapan hidup) sebagai variabel dependen dan modelkan terhadap penjelas yang tidak ada di dalamnya; atau (ii) pertahankan IKP sebagai Y tetapi pakai penjelas yang bersih — curah hujan/anomali iklim, akses infrastruktur, harga pangan relatif, produksi non-beras, jarak ke pasar, anggaran pangan daerah.
2. **Sebut *vintage* indeks secara eksplisit** dan jangan mencampur seri 9/8 indikator dengan seri 12 indikator.
3. **Perluas jumlah klaster** bila memungkinkan (misalnya kabupaten/kota se-Sumatera, sekitar 140 unit). Ini memperbaiki inferensi dan sekaligus membuka estimasi dinamis yang sekarang tertutup.
4. **Laporkan MDE berdampingan dengan p-value** pada setiap penelitian panel dengan G kecil.
5. **Verifikasi metodologi IKP per tahun 2019–2024** ke publikasi Bapanas tahunan untuk memastikan seri komparabel.

### 7.2 Saran Kebijakan (dengan Batasan yang Jelas)

Data ini **tidak** mengizinkan peringkat prioritas kebijakan berbasis koefisien regresi, dan laporan ini tidak menyusunnya. Yang dapat dikatakan secara jujur:

1. IKP seluruh kabupaten/kota Lampung bergerak bersama dan searah dengan pergerakan nasional (lompatan 2023 sebesar +2,94 di Lampung vs +2,59 nasional). Ini menunjukkan **faktor penentu utama bergerak di tingkat nasional**, di luar kendali satu kabupaten — dan justru karena itu tidak dapat diidentifikasi dari variasi antarwilayah di dalam satu provinsi.
2. Intervensi pada kemiskinan dan komponen pembangunan manusia (kesehatan, pendidikan) secara definisi akan menaikkan angka IKP karena keduanya **memang** indikator penyusun indeks. Ini penting untuk tidak salah dibaca sebagai hasil analisis sebab-akibat: menaikkan IKP lewat jalur ini adalah **aritmatika indeks**, bukan temuan empiris.
3. Dua kota (Bandar Lampung, Metro) menunjukkan lompatan 2022→2023 sekitar tiga kali rata-rata kabupaten, konsisten dengan perbedaan instrumen indeks (tanpa aspek ketersediaan). Perbandingan langsung skor IKP kota vs kabupaten sebaiknya dihindari dalam komunikasi kebijakan.

---

## Daftar Pustaka

> Catatan: bagian ini **masih perlu diverifikasi penulis** terhadap sumber aslinya.

- Badan Ketahanan Pangan. (2019). *Indeks Ketahanan Pangan Indonesia 2018*. Jakarta: Kementerian Pertanian. *(publikasi primer; dipakai untuk verifikasi 15/15 — berkas: `review/sources/BKP_Indeks_Ketahanan_Pangan_2018.pdf`, SHA256 `2d58a0e9857a7e2299e621373cbf4d789bebd26d3dd7dd399ee48c7133b65fb9`)*
- Badan Pangan Nasional. *Indeks Ketahanan Pangan Kabupaten/Kota 2018–2024* [data terbuka]. Diakses 23 September 2026. *(SHA256 `d5e052955db4f818271e4532f6fb299df409090dd6bd7bfd7632c049255503c8`)*
- Badan Pangan Nasional. *IKP Kabupaten/Kota 2024 (backcasting, 12 indikator)* [data terbuka]. Diakses 23 September 2026. *(SHA256 `b1a8753d6b7746ad8f5e4461bd22fb965221bf82727d0538b6760aab471c015b`)*
- Baltagi, B. H. (2005). *Econometric Analysis of Panel Data* (3rd ed.). John Wiley & Sons. *(perlu diverifikasi)*
- Cameron, A. C., Gelbach, J. B., & Miller, D. L. (2008). Bootstrap-based improvements for inference with clustered errors. *The Review of Economics and Statistics*, 90(3), 414–427.
- Dinas Ketahanan Pangan Provinsi Lampung. *Indeks Ketahanan Pangan Kabupaten/Kota 2019–2024* [data terbuka Satu Data Lampung]. Diakses 23 September 2026. *(SHA256 `d07a4b96b17522f80db860496b021becd38d2e2da6de1903ca57c542e2b8c7d3`)*
- Driscoll, J. C., & Kraay, A. C. (1998). Consistent covariance matrix estimation with spatially dependent panel data. *The Review of Economics and Statistics*, 80(4), 549–560.
- Hoechle, D. (2007). Robust standard errors for panel regressions with cross-sectional dependence. *The Stata Journal*, 7(3), 281–312.
- Mundlak, Y. (1978). On the pooling of time series and cross section data. *Econometrica*, 46(1), 69–85.
- Pesaran, M. H. (2004). *General diagnostic tests for cross section dependence in panels* (CESifo Working Paper No. 1229).
- Roodman, D. (2009). A note on the theme of too many instruments. *Oxford Bulletin of Economics and Statistics*, 71(1), 135–158.
- Wooldridge, J. M. (2010). *Econometric Analysis of Cross Section and Panel Data* (2nd ed.). MIT Press. *(perlu diverifikasi)*
- Wooldridge, J. M. (2002). *Econometric Analysis of Cross Section and Panel Data*. MIT Press.

---

## Lampiran A. Berkas dan Reproduksi

| Berkas | Isi | Status |
|---|---|---|
| `R/11_year_fe_inference.R` | Seluruh estimasi & uji Bab 4 revisi (9 bagian) | **exit 0** |
| `output/11_year_fe.log` | Log mentah R/11 (233+ baris) | Lengkap |
| `output/tabel_4_4_FEcovid.csv` | M1: FE + dummy COVID | Dibuat R/11 |
| `output/tabel_4_4_FEyear.csv` | M2: FE + efek tahun (+ p WCB) | Dibuat R/11 |
| `output/tabel_4_5_mde.csv` | MDE / daya uji per variabel | Dibuat R/11 |
| `output/tabel_4_6_rhs_bersih.csv` | M3: RHS bersih, 3 spesifikasi | Dibuat R/11 |
| `review/DESIGN_REVIEW.md` | Review desain: temuan + bukti + opsi | Sudah ada |
| `review/PLAN.md` | Roadmap + jalur pendek PSD | Sudah ada |
| `review/review_checks.R` + `review/review_output.log` | Reproduksi angka review | exit 0, 249 baris |
| `review/verify_ikp_sources.R` + `review/verify_output.log` | Verifikasi Y ke sumber primer | exit 0 |
| `laporan_draft.md` | Draft lama (19 Sep 2026) | **Tetap ada, tidak diubah** |
| `LAPORAN_rev.md` | Berkas ini | Revisi Bab 3–7 |

**Perintah reproduksi:**

```bash
cd "C:/Akbar/PSD"
"/c/Program Files/R/R-4.5.2/bin/Rscript.exe" R/11_year_fe_inference.R > output/11_year_fe.log 2>&1
echo $?   # harus 0
```

**Kebenaran berkas data (tidak diubah sepanjang revisi):**

| Berkas | SHA256 |
|---|---|
| `Data Fix - DATA.csv` | `ad69f257005795e69fe56006f32e913e8231777a6cb66bcb40782cdd7eea0eb5` |
| `data/lampung_panel_clean.csv` | `becc5801facc6ee6f04a5d1906646a71eaa9e0c45c3cb45c22e6febb506a8431` |

**Catatan tentang `R/11`:** satu bug ditemukan dan diperbaiki saat menjalankan skrip ini untuk pertama kali. Fungsi `wcb()` memakai `vcCL()` yang mengoper klaster sebagai *formula* (`~ kode`); karena `lm()` di dalam fungsi memanggil argumen bernama `dat`, `sandwich::vcovCL()` mengevaluasi ulang formula di frame yang salah dan gagal dengan `object 'dat' not found`. Perbaikannya: klaster dioper sebagai **vektor** (`cluster = dat[["kode"]]`). Perbaikan kedua: indexing `[1:4, ]` pada tabel 13 kabupaten menampilkan dummy wilayah, bukan koefisien substantif — diganti indexing berdasarkan nama.

---

## Lampiran B. Ringkasan Perubahan dari Draft Lama

| # | Klaim draft lama | Status revisi |
|---|---|---|
| 1 | "IPM berpengaruh positif dan signifikan terhadap IKP" | **Diturunkan.** Koef berbalik menjadi −2,228 (p = 0,180) dengan efek tahun; p WCB = 0,109; IPM berbagi komponen dengan IKP |
| 2 | "Kemiskinan berarah negatif sesuai teori namun tidak signifikan" | **Ditafsirkan ulang.** Kemiskinan berbobot 0,15/0,20 **di dalam** IKP → bukan pengujian teori |
| 3 | "PDRB per kapita tidak stabil, terbaur dengan waktu" | **Dikuatkan.** +50,63 → +2,83 → −3,63; SD *within* = 0,041; MDE = 608× SD *within* |
| 4 | "Produksi padi baru signifikan ketika di-lag satu tahun → efek tertunda" | **Dicabut.** Komponen ketersediaan IKP dibekukan 2014–2016; WCB atas 3,675 → p = 0,192 = non-temuan |
| 5 | "Anomali COVID" | **Dijelaskan & digantikan.** 2020–2021 justru tahun dengan perubahan terkecil; efek tahun penuh menggantikan dummy COVID |
| 6 | "Hausman χ² = 57,77 (p = 3,5e-11)" | **Diganti** robust Hausman (Mundlak) W = 24,44; p = 6,5e-05 — bentuk klasik tidak sah karena korelasi serial |
| 7 | "N = 15 (keterbatasan daya statistik)" | **Diperjelas.** Bukan masalah N; jackknife 15/15 tetap signifikan. Masalahnya identifikasi (spesifikasi + konstruksi indeks) dan cara menghitung p-value |
| 8 | Tidak disebut | **Ditambahkan:** *vintage* indeks (dua berkas resmi beda 17,10–18,24 poin), nomor internal vs kode BPS, kode salah tempel di berkas Bapanas `dataset/90`, dan hash SHA256 seluruh berkas sumber |
| 9 | Tidak disebut | **Ditambahkan:** model RHS bersih (M3) sebagai model utama revisi |
| 10 | Tidak disebut | **Ditambahkan:** MDE per variabel dan rasio MDE/SD *within* |
