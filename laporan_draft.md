# Pengaruh IPM, Kemiskinan, PDRB per Kapita, dan Produksi Padi terhadap Indeks Ketahanan Pangan Kabupaten/Kota di Provinsi Lampung, 2018–2024

**Draft laporan — PSD / calon topik TA**

---

## Abstrak

Penelitian ini menganalisis faktor-faktor yang memengaruhi Indeks Ketahanan Pangan (IKP) kabupaten/kota di Provinsi Lampung. Menggunakan data panel seimbang dari 15 kabupaten/kota selama periode 2018–2024 (105 observasi), penelitian ini mengestimasi pengaruh Indeks Pembangunan Manusia (IPM), persentase penduduk miskin, PDRB per kapita, dan produksi padi terhadap IKP. Pemilihan model dilakukan melalui uji Chow, uji Lagrange Multiplier Breusch–Pagan, dan uji Hausman, yang semuanya mengarah pada model **Fixed Effect (FE)**. Estimasi menggunakan *cluster-robust standard error* untuk mengatasi autokorelasi dan heteroskedastisitas. Hasil menunjukkan bahwa **IPM merupakan satu-satunya variabel yang secara konsisten dan signifikan berpengaruh positif terhadap IKP** di seluruh spesifikasi. Kemiskinan memiliki arah negatif sesuai teori namun tidak signifikan; PDRB per kapita dan produksi padi tidak menunjukkan pengaruh yang robust. Produksi padi baru signifikan ketika di-lag satu tahun, mengindikasikan kemungkinan efek tertunda. Efek dinamis lemah, sehingga model panel statis dengan *lagged-X* dipandang memadai. Pendekatan *dynamic panel GMM* tidak digunakan karena jumlah unit cross-section (N=15) terlalu kecil untuk membentuk instrumen yang valid.

**Kata kunci:** ketahanan pangan, data panel, fixed effect, IPM, Provinsi Lampung

---

## 1. Pendahuluan

### 1.1 Latar Belakang
Ketahanan pangan merupakan salah satu prioritas pembangunan nasional dan termuat dalam Tujuan Pembangunan Berkelanjutan (SDGs), khususnya tujuan kedua (tanpa kelaparan). Ketahanan pangan bersifat multidimensi dan mencakup empat pilar: **ketersediaan** (*availability*), **akses** (*access*), **pemanfaatan** (*utilization*), dan **stabilitas** (*stability*). Pemerintah mengukur capaian ketahanan pangan salah satunya melalui Indeks Ketahanan Pangan (IKP) yang disusun oleh Badan Pangan Nasional (Bapanas).

Provinsi Lampung merupakan salah satu lumbung pangan nasional, namun capaian IKP antarwilayahnya beragam. Perbedaan karakteristik geografis, tingkat pembangunan manusia, daya beli, dan kapasitas produksi pertanian diduga menjadi penyebab variasi tersebut. Memahami determinan IKP secara empiris penting untuk merumuskan kebijakan pangan yang tepat sasaran.

### 1.2 Rumusan Masalah
1. Apakah IPM, persentase kemiskinan, PDRB per kapita, dan produksi padi berpengaruh terhadap Indeks Ketahanan Pangan kabupaten/kota di Provinsi Lampung?
2. Apakah terdapat efek dimensi waktu, yaitu apakah kondisi tahun sebelumnya memengaruhi kondisi tahun berjalan?

### 1.3 Tujuan
1. Menganalisis pengaruh IPM, kemiskinan, PDRB per kapita, dan produksi padi terhadap IKP.
2. Menguji keberadaan efek dinamis (persistensi waktu) pada IKP.
3. Menyusun rekomendasi kebijakan berbasis temuan empiris.

### 1.4 Manfaat
Secara akademik, penelitian ini memperkaya literatur empiris tentang determinan ketahanan pangan pada level daerah dengan pendekatan data panel. Secara praktis, hasilnya dapat menjadi masukan bagi pemerintah daerah dan provinsi dalam merancang intervensi peningkatan ketahanan pangan.

---

## 2. Tinjauan Pustaka dan Kerangka Teori

### 2.1 Ketahanan Pangan dan IKP
Ketahanan pangan didefinisikan sebagai kondisi terpenuhinya pangan bagi negara sampai perseorangan, yang tercermin dari tersedianya pangan yang cukup, baik jumlah maupun mutunya, aman, beragam, bergizi, merata, dan terjangkau. IKP mengoperasionalkan konsep ini dalam skala 0–100, di mana nilai yang lebih tinggi mencerminkan kondisi ketahanan pangan yang lebih baik.

### 2.2 Determinan yang Diuji
- **IPM** mencerminkan dimensi pendidikan, kesehatan, dan standar hidup layak. IPM yang lebih tinggi diasosiasikan dengan kesadaran gizi dan pola pemanfaatan pangan yang lebih baik (pilar *utilization*).
- **Kemiskinan** membatasi daya beli rumah tangga sehingga menghambat akses terhadap pangan (pilar *access*).
- **PDRB per kapita** mencerminkan kemampuan ekonomi wilayah dan daya beli masyarakat; peningkatan PDRB diasosiasikan dengan akses pangan yang lebih baik.
- **Produksi padi** merupakan proksi ketersediaan pangan lokal (pilar *availability*); pasokan yang melimpah diharapkan menopang ketahanan pangan.

### 2.3 Efek Waktu (Dinamika)
Kondisi ketahanan pangan suatu wilayah cenderung persisten karena bersifat struktural. Kondisi tahun sebelumnya dapat memengaruhi tahun berjalan, baik melalui ketersediaan infrastruktur, kebiasaan konsumsi, maupun kondisi sosial-ekonomi yang lambat berubah. Karena itu, dimensi waktu perlu diuji secara empiris dan tidak diasumsikan.

### 2.4 Catatan Kerangka
Keempat variabel yang diuji baru mencakup pilar ketersediaan, akses, dan pemanfaatan; pilar **stabilitas** belum terwakili secara eksplisit. Variabel seperti inflasi/indeks harga pangan dapat dipertimbangkan pada pengembangan penelitian selanjutnya. Pendekatan ekonometrika data panel mengacu pada Baltagi (2005) dan Wooldridge (2010), sedangkan aturan penggunaan instrumen pada GMM mengacu pada Roodman (2009).

---

## 3. Metode Penelitian

### 3.1 Jenis dan Sumber Data
Penelitian menggunakan **data panel seimbang** (*balanced panel*) dengan unit cross-section 15 kabupaten/kota di Provinsi Lampung (N=15) selama 7 tahun (T=7), sehingga total observasi 105. Data IKP bersumber dari Bapanas, sedangkan IPM, kemiskinan, PDRB per kapita, dan produksi padi bersumber dari BPS Provinsi Lampung.

### 3.2 Definisi Operasional Variabel

| Variabel | Simbol | Deskripsi | Skala |
|---|---|---|---|
| Indeks Ketahanan Pangan | `ikp` | Variabel terikat (Y) | 0–100 |
| IPM | `ipm` | Indeks Pembangunan Manusia | 0–100 |
| Kemiskinan | `kemiskinan` | Persentase penduduk miskin | persen |
| PDRB per kapita | `ln_pdrb` | Logaritma natural PDRB per kapita | rasio |
| Produksi padi | `ln_padi` | Logaritma natural produksi padi | rasio |
| COVID | `covid` | Dummy 1 untuk 2020–2021, 0 lainnya | 0/1 |

PDRB per kapita dan produksi padi ditransformasi ke logaritma natural untuk meredam skala besar dan distribusi yang miring serta agar koefisien dapat diinterpretasikan sebagai elastisitas (semi-elastisitas untuk model log-level).

### 3.3 Model Dasar
Model panel statis yang diestimasi:

```
ikp_it = α + β1·ipm_it + β2·kemiskinan_it + β3·ln_pdrb_it + β4·ln_padi_it + β5·covid_t + μ_i + ε_it
```

dengan `μ_i` adalah efek individu wilayah dan `ε_it` galat.

### 3.4 Strategi Pemilihan Model
Tiga model diestimasi: *Pooled OLS*, *Fixed Effect* (FE), dan *Random Effect* (RE). Pemilihan dilakukan melalui:
- **Uji Chow** (FE vs Pooled): menguji keberadaan efek individu.
- **Uji Lagrange Multiplier Breusch–Pagan** (RE vs Pooled).
- **Uji Hausman** (FE vs RE): jika signifikan, FE lebih konsisten.

### 3.5 Penanganan Isu Ekonometrika
Estimasi utama menggunakan **cluster-robust standard error** (clustering per kabupaten) untuk mengakomodasi autokorelasi antar-tahun dan potensi heteroskedastisitas. Diagnostik mencakup **VIF** untuk multikolinearitas, **uji Wooldridge** untuk autokorelasi, uji **Breusch–Pagan** untuk heteroskedastisitas, dan uji normalitas residual.

### 3.6 Mengapa Bukan Dynamic Panel GMM
Rencana awal menggunakan *System GMM* untuk menangkap dinamika. Namun, dengan N=15, jumlah instrumen yang terbentuk dari lag variabel akan tumbuh cepat dan berpotensi melampaui jumlah grup. Sesuai Roodman (2009), jumlah instrumen tidak boleh melebihi jumlah grup; pelanggaran menyebabkan *overfitting* instrumen dan membuat uji Hansen/Sargan kehilangan daya (p-value mendekati 1,0 adalah pertanda buruk, bukan validasi). Karena itu GMM dinilai tidak dapat dipertanggungjawabkan dan tidak digunakan. Sebagai gantinya, model statis FE diperkuat dengan **lagged-X** (variabel penjelas di-lag satu tahun) sebagai pemeriksaan ketahanan.

### 3.7 Tahapan Analisis
1. Pembersihan dan penataan data ke format panel (long format) serta transformasi log dan pembuatan dummy COVID.
2. *Reality check* dinamika melalui korelasi/regresi IKP(t) terhadap IKP(t−1).
3. Estimasi Pooled/FE/RE dan uji pemilihan model.
4. Estimasi utama FE dengan cluster-robust SE dan diagnostik.
5. Pemeriksaan ketahanan (*robustness check*): tanpa COVID, tanpa tahun 2020–2021, dan dengan lagged-X.

---

## 4. Hasil dan Pembahasan

### 4.1 Statistik Deskriptif
Selama 2018–2024, rata-rata IKP kabupaten/kota di Lampung adalah **78,48** dengan rentang 65,98 hingga 88,78. Rata-rata IKP terus meningkat dari **74,10** (2018) menjadi **82,58** (2024). Wilayah dengan IKP rata-rata tertinggi adalah **Mesuji (84,55)**, Tulang Bawang (84,35), dan Pringsewu (84,05); sementara terendah adalah **Pesisir Barat (72,61)**, Lampung Utara (73,54), dan Lampung Barat (73,73).

| Variabel | Mean | SD | Min | Max |
|---|---|---|---|---|
| ikp | 78,478 | 5,116 | 65,980 | 88,780 |
| ipm | 69,219 | 3,927 | 62,880 | 79,190 |
| kemiskinan | 11,511 | 3,279 | 6,310 | 20,850 |
| pdrb (ribu) | 26.478,4 | 6.559,4 | 15.759,0 | 40.472,0 |
| produksi_padi (ton) | 171.675,0 | 159.765,6 | 2.318,2 | 614.016,7 |

Secara pooled, korelasi IKP–IPM hanya **0,088**, sedangkan korelasi IKP dengan kemiskinan **−0,485** dan dengan ln(PDRB) **0,453**. Korelasi pooled yang rendah antara IKP dan IPM ini penting: secara *antarwilayah*, kota dengan IPM tinggi (mis. Bandar Lampung, Metro) tidak otomatis memiliki IKP tinggi. Hal ini menjadi alasan mengapa analisis *within* (FE) lebih tepat daripada pooled.

### 4.2 Reality Check: Statis atau Dinamis?
Korelasi pooled IKP(t) dengan IKP(t−1) sebesar **0,879**, namun ukuran ini mencampur perbedaan antarwilayah. Setelah mengendalikan efek individu (within/FE), koefisien lag IKP(t−1) turun menjadi **0,619** (p < 0,001) dengan R² *within* sebesar 0,43. Nilai ini menunjukkan persistensi moderat-kuat. Dengan demikian, dinamika tidak dapat diabaikan sepenuhnya, tetapi tidak cukup kuat untuk mewajibkan model dinamis penuh. Keputusan: **model utama tetap panel statis FE**, dilengkapi spesifikasi *lagged-X* sebagai pemeriksaan ketahanan.

### 4.3 Pemilihan Model
Hasil uji pemilihan model:

| Uji | Statistik | p-value | Keputusan |
|---|---|---|---|
| Chow (FE vs Pooled) | F = 9,94 | 1,0e-12 | Efek individu ada |
| LM Breusch–Pagan (RE vs Pooled) | χ² = 21,88 | 2,9e-06 | Tolak Pooled |
| **Hausman (FE vs RE)** | **χ² = 57,77** | **3,5e-11** | **FE lebih tepat** |

Ketiga uji konsisten mendukung **Fixed Effect**. Ini masuk akal karena karakteristik bawaan wilayah (geografis, kesuburan lahan, struktur ekonomi) berkorelasi dengan variabel penjelas, sehingga estimator FE lebih konsisten dibanding RE.

### 4.4 Estimasi Utama (FE + Cluster-Robust SE)

| Variabel | Koefisien | Cluster SE | t | p-value |
|---|---|---|---|---|
| IPM | **1,959** | 0,414 | 4,73 | **< 0,001** |
| Kemiskinan | −0,489 | 0,455 | −1,08 | 0,285 |
| ln(PDRB) | 13,377 | 9,455 | 1,41 | 0,161 |
| ln(Padi) | 1,557 | 1,081 | 1,44 | 0,153 |
| COVID | 1,242 | 0,665 | 1,87 | 0,065 |

R² *within* = 0,631.

Interpretasi utama: peningkatan IPM sebesar **satu poin** berasosiasi dengan kenaikan **IKP sekitar 1,96 poin** dalam wilayah yang sama, *ceteris paribus*. Koefisien ln(PDRB) sebesar 13,38 berarti kenaikan PDRB per kapita sebesar 1% berasosiasi dengan kenaikan IKP sekitar 0,134 poin (namun tidak signifikan).

### 4.5 Diagnostik
- **Multikolinearitas:** VIF pada data *within-demeaned* sebesar 5,32 (IPM), 5,06 (kemiskinan), 2,30 (ln PDRB), 1,07 (ln Padi), 1,56 (COVID) — semuanya < 10, sehingga tidak ada multikolinearitas serius. (VIF pada data level sangat besar karena efek antarwilayah, tetapi tidak relevan untuk estimator FE.)
- **Autokorelasi:** uji Wooldridge menunjukkan p = 0,005 → terdapat autokorelasi. Ini membenarkan penggunaan cluster-robust SE.
- **Heteroskedastisitas:** uji Breusch–Pagan p = 0,968 → tidak ada bukti heteroskedastisitas.
- **Normalitas residual:** Shapiro–Wilk p = 0,025 → residual tidak sepenuhnya normal; dengan N=105 dan estimasi berdasarkan asimtotik, hal ini tidak terlalu kritis untuk inferensi.

### 4.6 Pemeriksaan Ketahanan (Robustness)

| Variabel | Main FE | Tanpa COVID | Tanpa 2020–21 | Lagged-X (t−1) |
|---|---|---|---|---|
| IPM | **1,96*** | **2,14*** | **2,13**** | **1,26**** |
| Kemiskinan | −0,49 | −0,33 | −0,32 | −1,09 (p=0,067) |
| ln(PDRB) | 13,38 | 4,70 | 13,55 | 4,83 |
| ln(Padi) | 1,56 | 1,50 (p=0,093) | 1,24 | **3,16*** |
| COVID | 1,24 (p=0,065) | — | — | −0,73 |

Keterangan: *p<0,05; **p<0,01; ***p<0,001.

### 4.7 Pembahasan
1. **IPM adalah pendorong utama yang robust.** Koefisien IPM tetap positif dan signifikan di seluruh spesifikasi, menunjukkan bahwa peningkatan kualitas pembangunan manusia berhubungan erat dengan peningkatan ketahanan pangan. Dari sisi pilar FAO, IPM paling dekat mewakili dimensi *pemanfaatan* pangan.

2. **Kemiskinan berarah negatif sesuai teori, namun tidak signifikan.** Arah negatif konsisten (kecuali pada model lagged-X yang justru lebih besar), mengindikasikan daya beli berperan, tetapi dalam sampel ini efeknya belum cukup presisi untuk disimpulkan signifikan.

3. **PDRB per kapita tidak stabil.** Koefisien berubah cukup drastis ketika dummy COVID dihilangkan/dipertahankan, menandakan efek PDRB terbaur dengan tren waktu. Karena PDRB dan waktu berkorelasi tinggi, identifikasi *within* menjadi lemah.

4. **Produksi padi menunjukkan indikasi efek tertunda.** Produksi padi baru signifikan ketika di-lag satu tahun (p = 0,042), konsisten dengan dugaan bahwa peningkatan ketersediaan pangan butuh waktu untuk tercermin pada IKP. Ini juga mendukung keputusan menyertakan spesifikasi *lagged-X*.

5. **Anomali COVID.** Dummy COVID positif marginal pada model utama. Ini tampaknya mencerminkan bahwa secara rata-rata IKP nasional/daerah justru meningkat pada 2020–2021, bukan bahwa pandemi memperbaiki ketahanan pangan. Temuan ini perlu ditafsirkan hati-hati dan menjadi alasan dilakukannya pemeriksaan robust tanpa COVID.

---

## 5. Kesimpulan

1. Dengan data panel 15 kabupaten/kota Provinsi Lampung 2018–2024, **model Fixed Effect** terpilih secara konsisten melalui uji Chow, LM, dan Hausman.
2. **IPM berpengaruh positif dan signifikan terhadap IKP** dan merupakan satu-satunya variabel yang robust di seluruh spesifikasi.
3. **Kemiskinan** berarah negatif namun tidak signifikan; **PDRB per kapita** tidak stabil; **produksi padi** signifikan hanya ketika di-lag satu tahun, mengindikasikan efek tertunda.
4. Terdapat **persistensi waktu moderat** pada IKP (koef lag *within* 0,62), namun tidak cukup kuat untuk mewajibkan model dinamis penuh.

## 6. Keterbatasan
- Jumlah unit cross-section kecil (N=15) dan periode relatif pendek (T=7), sehingga daya statistik terbatas dan **tidak memungkinkan penggunaan GMM** secara valid.
- Variabel belum mewakili pilar **stabilitas** ketahanan pangan (mis. inflasi pangan).
- Potensi endogenitas (mis. IPM dan IKP saling memengaruhi) belum ditangani secara kausal; temuan bersifat **indikasi pengaruh**, bukan bukti kausalitas.
- Residual tidak sepenuhnya normal dan terdapat autokorelasi, meskipun telah ditangani dengan cluster-robust SE.

## 7. Saran
- Prioritas kebijakan diarahkan pada peningkatan **kualitas pembangunan manusia** (pendidikan, kesehatan, gizi), karena variabel ini paling konsisten terkait dengan ketahanan pangan.
- Penelitian lanjutan dapat memperluas cakupan wilayah (mis. se-Sumatera, N≫15) untuk memungkinkan pendekatan dinamis/GMM, serta menambahkan proksi pilar stabilitas.

---

## Daftar Pustaka (perlu dilengkapi & diverifikasi)

> Catatan: bagian ini **wajib dilengkapi oleh penulis** dengan sumber asli. Nama berikut disebut dalam naskah:

- Baltagi, B. H. (2005). *Econometric Analysis of Panel Data*. John Wiley & Sons. *(perlu diverifikasi)*
- Roodman, D. (2009). A Note on the Theme of Too Many Instruments. *Oxford Bulletin of Economics and Statistics*, 71(1), 135–158.
- Wooldridge, J. M. (2010). *Econometric Analysis of Cross Section and Panel Data*. MIT Press. *(perlu diverifikasi)*
- Badan Pangan Nasional. *Indeks Ketahanan Pangan.*
- Badan Pusat Statistik Provinsi Lampung. *Statistik Provinsi Lampung.*
- Bruno, G. S. F. (2005). Approximating the Bias of the LSDV Estimator for Dynamic Unbalanced Panel Data Models. *Economics Letters*. *(opsional, jika Fase 5 Opsi B dipakai)*
