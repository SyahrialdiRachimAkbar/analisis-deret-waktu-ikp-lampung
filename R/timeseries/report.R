# The narrative and tables below are generated from the actual pipeline results.
number_id <- function(x, digits = 2) {
  vapply(x, function(z) if (is.na(z)) "—" else formatC(z, format = "f", digits = digits, decimal.mark = ","), character(1))
}

markdown_table <- function(x, names = colnames(x), digits = 2) {
  numeric_cols <- vapply(x, is.numeric, logical(1))
  formatted <- lapply(x, function(col) {
    if (is.numeric(col)) {
      out <- number_id(col, digits)
    } else out <- ifelse(is.na(col), "—", as.character(col))
    gsub("|", " / ", out, fixed = TRUE)
  })
  formatted <- as.data.frame(formatted, stringsAsFactors = FALSE)
  c(paste0("| ", paste(names, collapse = " | "), " |"),
    paste0("| ", paste(ifelse(numeric_cols, "---:", "---"), collapse = " | "), " |"),
    apply(formatted, 1, function(row) paste0("| ", paste(row, collapse = " | "), " |")))
}

write_report <- function(d, audit, changes, summaries, dispersion, predictions,
                         accuracy_region, accuracy_group, accuracy_year, discrepancies, inputs) {
  county_early <- summaries[summaries$tipe == "Kabupaten" & summaries$tahun_awal == 2018, ]
  county_recent <- summaries[summaries$tipe == "Kabupaten" & summaries$tahun_awal == 2022, ]
  city <- summaries[summaries$tipe == "Kota", ]
  city_accuracy <- accuracy_region[accuracy_region$tipe == "Kota", ]
  group_city <- accuracy_group[accuracy_group$tipe == "Kota", ]
  best <- group_city$metode[group_city$MAE_poin == min(group_city$MAE_poin)]
  valid_changes <- sum(is.finite(changes$perubahan_poin))
  valid_forecasts <- sum(is.finite(predictions$ramalan))
  year_value <- function(year, col) dispersion[dispersion$tahun == year, col]
  stable <- county_early[which.min(county_early$sd_perubahan_poin), ]
  variable <- county_early[which.max(county_early$sd_perubahan_poin), ]
  source_table <- audit[audit$tipe == "Kabupaten", c("tahun", "judul", "url", "komponen_ketersediaan", "batas_sebelum_tahun", "status")]
  source_table$dokumen <- paste0("[", source_table$judul, "](", source_table$url, ")")
  source_table$tahun <- as.character(source_table$tahun)
  annual <- dispersion[c("tahun", "rata_ikp", "sd_ikp", "min_ikp", "max_ikp", "rentang_ikp", "segmen")]
  annual$tahun <- as.character(annual$tahun)
  summary_columns <- c("kabupaten", "ikp_awal", "ikp_akhir", "kenaikan_bersih_poin", "rata_perubahan_poin", "sd_perubahan_poin", "tahun_turun")
  summary_display <- function(x) {
    x <- x[summary_columns]
    x$tahun_turun <- as.character(x$tahun_turun)
    x
  }
  summary_names <- c("Wilayah", "IKP awal", "IKP akhir", "Kenaikan (poin)", "Rata-rata perubahan", "SD perubahan", "Tahun turun")
  group_display <- accuracy_group[c("tipe", "metode", "n_ramalan", "n_tahun_uji", "MAE_poin", "RMSE_poin")]
  group_display$n_ramalan <- as.character(group_display$n_ramalan)
  group_display$n_tahun_uji <- as.character(group_display$n_tahun_uji)
  city_display <- city_accuracy[c("kabupaten", "metode", "n_ramalan", "MAE_poin", "RMSE_poin")]
  city_display$n_ramalan <- as.character(city_display$n_ramalan)
  year_display <- accuracy_year[accuracy_year$tipe == "Kota", c("tahun_target", "metode", "n_ramalan", "MAE_poin", "RMSE_poin")]
  year_display$tahun_target <- as.character(year_display$tahun_target)
  year_display$n_ramalan <- as.character(year_display$n_ramalan)
  mismatch <- discrepancies[!discrepancies$cocok, c("kabupaten", "tahun", "ikp_proyek", "ikp_sumber_provinsi", "selisih_poin")]
  mismatch$tahun <- as.character(mismatch$tahun)
  lines <- c(
    "# Analisis Deret Waktu Indeks Ketahanan Pangan Kabupaten/Kota di Lampung",
    "",
    "**Tren, Stabilitas Perubahan Skor, dan Kesenjangan, 2018–2024**",
    "",
    "Laporan Project Sains Data. Dokumen ini dihasilkan oleh pipeline R dari data yang tersedia; tabel tidak diisi dengan angka perkiraan.",
    "",
    "> **Status interpretasi: eksploratif dan bersyarat.** Audit menemukan perubahan rincian komponen ketersediaan pada dokumen tahunan kabupaten. Pipeline memakai batas konservatif pada 2021, 2022, dan 2024. Seluruh skor tetap ditampilkan, tetapi perubahan dan ramalan tidak melintasi batas tersebut. Harmonisasi penuh seri, khususnya metadata 2019 dan rincian teknis 2024, belum terbukti.",
    "",
    "## Ringkasan",
    "",
    sprintf("Data mencakup %d observasi: 13 kabupaten dan 2 kota, masing-masing tujuh tahun. Kolom IKP dan identitas wilayah cocok 105/105 antara data mentah dan CSV bersih. Dari 90 kandidat perubahan tahunan, %d dihitung di dalam segmen dan %d dikecualikan pada batas definisi komponen.", nrow(d), valid_changes, nrow(changes) - valid_changes),
    "",
    sprintf("Dalam segmen kabupaten 2018–2020, rata-rata sederhana skor meningkat dari %s ke %s; simpangan baku antarwilayah berubah dari %s ke %s. Dalam segmen 2022–2023, rata-rata berubah dari %s ke %s dan simpangan baku dari %s ke %s. Angka ini mendeskripsikan skor pada segmen masing-masing; tidak membuktikan perubahan kausal atau keterbandingan penuh antar-edisi.",
      number_id(year_value(2018, "rata_ikp")), number_id(year_value(2020, "rata_ikp")), number_id(year_value(2018, "sd_ikp")), number_id(year_value(2020, "sd_ikp")),
      number_id(year_value(2022, "rata_ikp")), number_id(year_value(2023, "rata_ikp")), number_id(year_value(2022, "sd_ikp")), number_id(year_value(2023, "sd_ikp"))),
    "",
    sprintf("Evaluasi naïve dan drift menghasilkan %d ramalan uji untuk dua kota; 78 kandidat kabupaten tidak diestimasi karena segmen latihan kurang dari empat tahun. Metode dengan MAE lebih kecil pada gabungan enam pengamatan uji kota adalah **%s**. Temuan ini terbatas pada dua kota dan tiga tahun target, bukan kesimpulan umum untuk Lampung.", valid_forecasts, paste(best, collapse = " dan ")),
    "",
    "## 1. Pendahuluan",
    "",
    "Indeks Ketahanan Pangan (IKP) merupakan skor komposit yang merangkum beberapa indikator ketahanan pangan wilayah. Project ini menggunakan perubahan skor sepanjang waktu untuk memahami perkembangan wilayah, tanpa menaksir pengaruh IPM, kemiskinan, PDRB, atau produksi padi terhadap indeks.",
    "",
    "Pertanyaan penelitian:",
    "",
    "1. Bagaimana perkembangan skor IKP setiap wilayah dalam periode yang dapat dianalisis?",
    "2. Wilayah mana yang memiliki perubahan skor lebih konsisten atau lebih berfluktuasi?",
    "3. Apakah sebaran skor antarkabupaten menyempit di dalam segmen pengamatan?",
    "4. Bagaimana ketepatan naïve dan drift untuk ramalan satu tahun berikutnya pada seri yang memenuhi syarat?",
    "",
    "Istilah **stabilitas** dalam laporan ini hanya berarti kestabilan perubahan skor IKP. Istilah ini tidak mengukur seluruh dimensi stabilitas pangan menurut kerangka ketahanan pangan. Skor yang tidak berubah dapat mencerminkan stagnasi; fluktuasi kecil tidak otomatis lebih baik.",
    "",
    "## 2. Data dan audit keterbandingan",
    "",
    "Input utama adalah `Data Fix - DATA.csv` dan `data/lampung_panel_clean.csv`. Analisis memakai identitas wilayah, tahun, dan IKP. Dataset berisi 15 seri tahunan pendek, bukan satu seri sepanjang 105 tahun. Kolom `kode` adalah ID internal dan tidak digunakan untuk join ke sumber luar.",
    "",
    "### 2.1. Bukti metodologi per tahun",
    "",
    "Matriks di bawah merangkum fakta dokumen primer yang berhasil diperiksa dan bagian yang belum selesai. Lokasi halaman, bobot, tahun input, serta catatan per jenis wilayah tersedia di `output/timeseries/audit_metodologi.csv`.",
    "",
    markdown_table(source_table[c("tahun", "dokumen", "komponen_ketersediaan", "batas_sebelum_tahun", "status")],
      c("Edisi", "Dokumen", "Rincian ketersediaan kabupaten", "Batas sebelum edisi", "Status bukti")),
    "",
    "Dokumen 2020 menyebut empat komoditas. Dokumen 2021 juga menyebut stok beras daerah; 2022 menambahkan sagu; rincian 2023 masih menyebut sagu dan stok. Laporan resmi 2024 juga menyebut bantuan pangan CPP. Perubahan rincian ini menjadi alasan segmentasi konservatif. Audit tersebut **tidak mengukur dampak numerik perubahan definisi** dan tidak membuktikan bahwa setiap lonjakan skor berasal dari perubahan metode. Identitas normalisasi, implementasi pada setiap daerah, dan backcasting seri belum terverifikasi penuh.",
    "",
    "Indeks kota tidak memasukkan komponen ketersediaan. Karena itu, batas yang berasal dari perubahan komponen tersebut tidak langsung diterapkan pada kota. Seri kota tetap bersyarat: tidak ditemukannya batas dari bukti ini bukan bukti bahwa seluruh metode dan sumber inputnya identik.",
    "",
    "Segmentasi yang diterapkan:",
    "",
    "- Kabupaten: 2018–2020, 2021, 2022–2023, dan 2024. Tahun tunggal tidak dipakai untuk menghitung tren atau stabilitas perubahan.",
    "- Kota: 2018–2024 sebagai satu segmen eksploratif bersyarat.",
    "",
    "Skor 2024 versi 12 indikator yang juga tersedia di folder sumber merupakan vintage berbeda dan tidak dicampurkan ke data analisis. Kesamaan jumlah indikator saja tidak membuktikan kesamaan seluruh definisi maupun normalisasi.",
    "",
    "### 2.2. Pencocokan dan selisih sumber",
    "",
    sprintf("Pencocokan ke berkas Satu Data Lampung yang telah tersimpan menghasilkan **%d/%d cocok**, dengan lima selisih berikut. Data proyek dipertahankan; sumber pembanding tidak otomatis menggantikannya.", sum(discrepancies$cocok), nrow(discrepancies)),
    "",
    markdown_table(mismatch, c("Wilayah", "Tahun", "IKP proyek", "IKP sumber provinsi", "Selisih (poin)")),
    "",
    "Untuk IKP 2018, audit tersimpan mencatat 15/15 cocok dengan publikasi primer, termasuk peringkat. Itu bukti audit sebelumnya; isi PDF lokal tidak diekstraksi ulang pada pipeline ini. Pencocokan provinsi dilakukan lewat nama wilayah dengan menghapus awalan `Kota`, bukan lewat ID internal. Metadata geometri dan kode pada sumber lain tidak dipakai sebagai acuan otomatis.",
    "",
    "## 3. Metode analisis deret waktu",
    "",
    "### 3.1. Tren dan perubahan",
    "",
    "Untuk tiap wilayah dan segmen, perubahan tahunan dihitung sebagai `IKP(t) − IKP(t−1)`. Kenaikan bersih adalah skor terakhir dikurangi skor awal segmen. Rata-rata perubahan adalah rata-rata selisih tahunan. Semua ukuran dinyatakan dalam poin IKP, bukan persen. Perubahan pada batas metodologi disimpan sebagai nilai kosong dengan alasan pengecualian.",
    "",
    "### 3.2. Stabilitas dan kesenjangan",
    "",
    "Fluktuasi diukur dengan **simpangan baku sampel perubahan tahunan** (`sd(diff(IKP))`), hanya jika tersedia minimal dua perubahan. Jumlah tahun turun serta perubahan terbesar dan terkecil dilaporkan bersama kenaikan bersih. Dua tahun hanya menyediakan satu perubahan sehingga SD tidak dihitung.",
    "",
    "Kesenjangan menggunakan simpangan baku sampel dan rentang skor 13 kabupaten pada setiap tahun. Rata-ratanya memberi bobot sama pada tiap kabupaten dan **bukan IKP resmi Provinsi Lampung**. Perubahan rata-rata maupun SD hanya dihitung antara tahun bersebelahan dalam segmen yang sama. Tidak ada uji signifikansi tren atau pemeringkatan lintas-segmen dengan panjang berbeda.",
    "",
    "### 3.3. Evaluasi peramalan tambahan",
    "",
    "Naïve memakai skor terakhir sebagai ramalan satu tahun berikutnya. Drift menambahkan `(skor terakhir − skor pertama)/(n−1)` pada skor terakhir, menggunakan hanya nilai latihan dalam segmen yang sama. Ini dua metode sederhana yang dapat menjadi pembanding peramalan. [Forecasting: Principles and Practice — metode sederhana](https://otexts.com/fpp3/simple-methods.html)",
    "",
    "Tahun target ditetapkan 2022, 2023, dan 2024. Latihan diperluas sampai tahun sebelumnya dan disyaratkan minimal empat titik dalam segmen target. Tanpa batas, latihan akan berupa 2018–2021, 2018–2022, dan 2018–2023; batas metodologi mengurangi latihan kabupaten menjadi terlalu pendek. Data tahun target dan masa depan tidak digunakan untuk membentuk ramalan. [Evaluasi dengan rolling forecasting origin](https://otexts.com/fpp3/tscv.html)",
    "",
    "Error didefinisikan sebagai aktual dikurangi ramalan. **MAE = mean(abs(error))** menjadi ukuran utama, **RMSE = sqrt(mean(error²))** sebagai pelengkap. Agregasi kota memakai enam error per metode (dua kota × tiga target); tidak digabung dengan kabupaten yang tidak diestimasi. MAE dan RMSE dinyatakan dalam poin IKP. [Evaluasi ketepatan ramalan](https://otexts.com/fpp3/accuracy.html)",
    "",
    "Tidak ada pemilihan model kompleks, penyetelan berdasarkan tahun target, pemotongan ramalan ke skala 0–100, atau proyeksi jauh ke depan. Ramalan di luar skala akan ditandai dalam CSV. Evaluasi hanya mencakup ramalan historis yang dapat dibandingkan dengan aktual.",
    "",
    "## 4. Hasil dan pembahasan",
    "",
    "### 4.1. Potret tahunan 13 kabupaten",
    "",
    markdown_table(annual, c("Tahun", "Rata-rata", "SD", "Minimum", "Maksimum", "Rentang", "Segmen")),
    "",
    "Angka antar-edisi ditampilkan sebagai potret skor yang tercatat. Perubahan lintas-batas tidak dihitung sebagai tren yang sebanding. Kota tidak masuk tabel rata-rata ini.",
    "",
    "![Potret tahunan kabupaten](output/timeseries/04_rata_rata_dan_kesenjangan.png)",
    "",
    "### 4.2. Tren per wilayah dan segmen",
    "",
    "**Kabupaten 2018–2020.** Setiap wilayah memiliki tiga skor dan dua perubahan. Interpretasi tetap bersyarat karena metodologi 2019 belum sepenuhnya diperiksa.",
    "",
    markdown_table(summary_display(county_early), summary_names),
    "",
    "**Kabupaten 2022–2023.** Setiap wilayah hanya memiliki satu perubahan; simpangan baku perubahan tidak tersedia. Skor 2021 dan 2024 ditampilkan pada grafik dan CSV, tetapi tidak diberi nilai tren dari satu titik.",
    "",
    markdown_table(summary_display(county_recent), summary_names),
    "",
    "**Dua kota 2018–2024.** Keenam perubahan dapat dihitung secara eksploratif di bawah asumsi keterbandingan seri kota.",
    "",
    markdown_table(summary_display(city), summary_names),
    "",
    "![Tren setiap wilayah](output/timeseries/01_tren_wilayah.png)",
    "",
    "![Perubahan tahunan](output/timeseries/02_heatmap_perubahan.png)",
    "",
    "### 4.3. Stabilitas perubahan skor",
    "",
    sprintf("Pada segmen kabupaten 2018–2020, SD perubahan terendah tercatat pada **%s (%s poin)** dan tertinggi pada **%s (%s poin)**. Ukuran tersebut berasal dari hanya dua perubahan per wilayah sehingga dipakai sebagai deskripsi, bukan klasifikasi risiko atau bukti pola jangka panjang.", stable$kabupaten, number_id(stable$sd_perubahan_poin), variable$kabupaten, number_id(variable$sd_perubahan_poin)),
    "",
    "Kenaikan bersih dan fluktuasi dibaca bersama: kenaikan yang konsisten berbeda dari stagnasi, walaupun keduanya dapat memiliki SD rendah. Kabupaten dan kota tidak digabung dalam pemeringkatan stabilitas karena jumlah perubahan dan konstruksi indeks berbeda.",
    "",
    "![Kenaikan dan fluktuasi](output/timeseries/03_kenaikan_dan_stabilitas.png)",
    "",
    "### 4.4. Apakah kesenjangan menyempit?",
    "",
    sprintf("Di dalam segmen 2018–2020, SD antarkabupaten berubah dari %s ke %s, selisih **%s poin**. Di dalam segmen 2022–2023, SD berubah dari %s ke %s, selisih **%s poin**. Pada kedua perbandingan ujung segmen ini, sebaran skor tidak menyempit; ini deskripsi data, bukan uji perbedaan populasi.",
      number_id(year_value(2018, "sd_ikp")), number_id(year_value(2020, "sd_ikp")), number_id(year_value(2020, "sd_ikp") - year_value(2018, "sd_ikp")),
      number_id(year_value(2022, "sd_ikp")), number_id(year_value(2023, "sd_ikp")), number_id(year_value(2023, "sd_ikp") - year_value(2022, "sd_ikp"))),
    "",
    "Pertanyaan apakah kesenjangan sepanjang 2018–2024 menyempit **belum dapat dijawab secara sebanding** dari seri ini tanpa harmonisasi komponen. Karena itu, laporan tidak mengurangkan potret 2018 langsung dari potret 2024 untuk menyatakan perubahan kesenjangan seluruh periode.",
    "",
    "### 4.5. Ketepatan peramalan sederhana",
    "",
    markdown_table(group_display, c("Jenis wilayah", "Metode", "Ramalan dihitung", "Tahun uji", "MAE (poin)", "RMSE (poin)")),
    "",
    "Nilai kosong untuk kabupaten berarti **tidak diestimasi**, bukan error nol. Semua 78 kandidat kabupaten (13 × 3 × 2) tersimpan dengan alasan pengecualian pada tabel backtest. Hasil per kota:",
    "",
    markdown_table(city_display, c("Wilayah", "Metode", "Ramalan uji", "MAE (poin)", "RMSE (poin)")),
    "",
    "Hasil per tahun target, masing-masing dari dua kota:",
    "",
    markdown_table(year_display, c("Target", "Metode", "Ramalan uji", "MAE (poin)", "RMSE (poin)")),
    "",
    sprintf("Metode **%s** memiliki MAE gabungan kota yang lebih rendah pada pengujian ini. Besarnya error per tahun harus ikut dibaca karena lonjakan skor dapat mendominasi ringkasan. Tiga target tidak cukup untuk menyatakan metode terbaik secara umum, apalagi untuk kabupaten yang tidak diestimasi.", paste(best, collapse = " dan ")),
    "",
    "![Error ramalan](output/timeseries/05_error_peramalan.png)",
    "",
    "![Aktual dan ramalan historis kota](output/timeseries/06_aktual_dan_ramalan_kota.png)",
    "",
    "## 5. Keterbatasan dan kesimpulan",
    "",
    "1. Panjang seri hanya tujuh tahun; segmentasi memperpendeknya lagi. Analisis tidak mengidentifikasi pola musiman bulanan atau siklus jangka panjang.",
    "2. Perubahan dokumen komponen tidak memberi ukuran dampak pada skor. Batas konservatif mencegah perbandingan lintas-definisi, tetapi tidak menggantikan seri yang telah diharmonisasi.",
    "3. Metodologi 2019 dan rincian lengkap 2024 belum selesai diverifikasi. Sumber input dan normalisasi yang berganti dapat memengaruhi skor, termasuk seri kota.",
    "4. Lima perbedaan dengan sumber provinsi belum direkonsiliasi. Data dipertahankan dan selisihnya diungkapkan.",
    "5. Evaluasi ramalan hanya menghasilkan tiga target per kota. Keenam error gabungan per metode tidak dianggap sebagai enam tahun observasi independen.",
    "6. Perubahan skor tidak membuktikan pengaruh kebijakan, COVID, atau faktor sosial-ekonomi tertentu. Hasil tidak digunakan sebagai peringkat prioritas intervensi.",
    "",
    "Kesimpulan project adalah bahwa perkembangan dan fluktuasi **skor yang tercatat** dapat dideskripsikan dalam segmen eksploratif yang ditetapkan. Peningkatan rata-rata dalam dua segmen kabupaten tidak disertai penyempitan SD pada ujung segmen. Dua kota menyediakan ilustrasi evaluasi ramalan sederhana. Jawaban tren dan kesenjangan penuh 2018–2024, serta peramalan kabupaten yang sebanding, memerlukan konfirmasi harmonisasi atau tambahan seri yang konsisten.",
    "",
    "## 6. Reproduksi dan berkas hasil",
    "",
    "Jalankan dari root project di PowerShell:",
    "",
    "```powershell",
    '& "C:/Program Files/R/R-4.5.2/bin/Rscript.exe" --vanilla R/timeseries/run.R',
    "```",
    "",
    "Pipeline memakai base R dan ggplot2 yang telah terpasang. Tidak memerlukan jaringan atau pemasangan package. Pipeline menjalankan pemeriksaan rumus, kebocoran waktu, batas metodologi, data invalid, integritas input, serta kelengkapan ekspor sebelum menyatakan selesai.",
    "",
    "Berkas di `output/timeseries/`:",
    "",
    "- `data_analisis.csv`: 105 skor, jenis wilayah, segmen, dan status analisis.",
    "- `audit_metodologi.csv`: bukti per edisi dan jenis wilayah; `audit_sumber_provinsi.csv` serta `selisih_sumber_provinsi.csv`: audit nilai sumber.",
    "- `perubahan_tahunan.csv`: seluruh kandidat perubahan termasuk nilai yang dikecualikan; `ringkasan_wilayah_per_segmen.csv`: ukuran tren dan fluktuasi.",
    "- `kesenjangan_kabupaten.csv`: potret tahunan serta perubahan yang memenuhi batas.",
    "- `backtest_detail.csv`: seluruh kandidat ramalan, jendela latihan, aktual, error, dan status.",
    "- `akurasi_per_wilayah.csv`, `akurasi_per_jenis_wilayah.csv`, `akurasi_per_tahun.csv`: ukuran ketepatan.",
    "- Enam grafik dalam format PNG 300 dpi dan PDF.",
    "- `hash_input_sha256.csv`, `integritas_arsip.csv`, `versi_kode.csv`, `session_info.txt`, dan `run.log`: bukti reproduksi dan integritas.",
    "",
    "Hash SHA256 input:",
    "",
    markdown_table(inputs, c("Input", "SHA256")),
    "",
    "Angka CSV disimpan dengan presisi perhitungan R; laporan menampilkan dua desimal. Selisih kecil akibat pembulatan tabel tidak mengubah perhitungan. Pipeline panel lama dan kedua laporan lama dipertahankan sebagai arsip, bukan sumber kesimpulan deret waktu ini.",
    "",
    "## Referensi metode",
    "",
    "Hyndman, R. J. & Athanasopoulos, G. *Forecasting: Principles and Practice*, edisi ketiga: [metode sederhana](https://otexts.com/fpp3/simple-methods.html), [evaluasi ketepatan](https://otexts.com/fpp3/accuracy.html), [evaluasi berbasis urutan waktu](https://otexts.com/fpp3/tscv.html), dan [seri pendek](https://otexts.com/fpp3/long-short-ts.html). Referensi publikasi IKP tercantum pada matriks sumber di bagian 2.",
    "")
  writeLines(enc2utf8(lines), "LAPORAN_deret_waktu.md", useBytes = TRUE)
  cat("Laporan dibuat dari tabel hasil: LAPORAN_deret_waktu.md\n")
}
