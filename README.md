# Analisis Deret Waktu IKP Lampung

Project Sains Data: tren, stabilitas perubahan skor, dan kesenjangan IKP
15 kabupaten/kota selama 2018–2024. Evaluasi naïve dan drift menjadi tambahan.

Mulai dari [laporan deret waktu](LAPORAN_deret_waktu.md).

## Jalankan analisis

Dari root project di PowerShell:

```powershell
& "C:/Program Files/R/R-4.5.2/bin/Rscript.exe" --vanilla R/timeseries/run.R
```

Jika Rscript tersedia di PATH:

```text
Rscript --vanilla R/timeseries/run.R
```

Lingkungan acuan adalah **R 4.5.2**, **ggplot2 4.0.1** dan 15 dependensi transitif
yang dikunci dalam [renv.lock](renv.lock). Pipeline memeriksa versi sesuai
[manifest dependensi](review/timeseries/dependensi.csv).

Untuk komputer baru, pasang R 4.5.2 dari [CRAN](https://cran.r-project.org/).
Penyiapan berikut memerlukan internet dan dilakukan sekali dari root repo:

```r
install.packages("renv", repos = "https://cloud.r-project.org")
```

```text
Rscript --vanilla R/timeseries/setup.R
Rscript --vanilla R/timeseries/run.R
```

Pada PowerShell tanpa Rscript di PATH, gunakan path Rscript pada contoh di atas,
dengan mengganti nama skrip menjadi `R/timeseries/setup.R` untuk penyiapan.
Restore memakai versi terkunci di `.library/`, yang tidak masuk Git. Analisis
menggunakan library tersebut bila tersedia. Komputer ini sudah memiliki versi
yang sesuai sehingga analisis juga dapat berjalan tanpa restore.
Tidak ada pemasangan package atau akses jaringan otomatis saat analisis.
Hash memerlukan `certutil` di Windows atau `sha256sum`/`shasum` di Linux/macOS.

Pipeline membaca CSV mentah/bersih yang sudah tersedia, memeriksa integritas,
menjalankan pemeriksaan logika analisis, lalu membuat ulang laporan dan hasil
di [output/timeseries](output/timeseries/). Rerun menimpa hasil deret waktu yang
dibangkitkan otomatis; edit narasi melalui `R/timeseries/report.R`.

## Cara membaca hasil

- Data berisi **15 seri sepanjang tujuh tahun**, bukan satu seri 105 titik waktu.
- Input asli tetap tersedia; satu koreksi Tanggamus 2020 menjadi **74,67** diterapkan
  pada salinan analisis melalui [catatan rekonsiliasi](review/timeseries/rekonsiliasi_nilai.csv).
  Kelima selisih dengan provinsi memiliki keputusan dan tingkat bukti.
- Perubahan rincian komponen ketersediaan kabupaten pada dokumen 2021, 2022,
  dan 2024 menjadi batas konservatif. Garis grafik dan perubahan tidak melintasi batas.
- Tersedia 51 perubahan tahunan; 39 kandidat dikecualikan dan tersimpan alasannya.
- Tersedia 12 ramalan uji untuk dua kota. Sebanyak 78 kandidat kabupaten tidak
  diestimasi karena segmen latihan terlalu pendek; nilai kosong bukan error nol.
- Semua interpretasi **eksploratif dan bersyarat**. Rincian sumber dan bagian yang
  belum terverifikasi ada pada [jejak audit sumber](review/timeseries/SOURCES.md).
- Uji sensitivitas pilihan nilai dan pengeluaran satu tahun target disertakan.
  Metode dengan MAE terendah dapat berubah menurut tahun uji; RMSE juga memberi
  urutan berbeda. SD dari dua perubahan tidak menjadi klasifikasi risiko.

Hasil mencakup tabel CSV dengan presisi penuh, enam grafik PNG 300 dpi dan PDF,
log eksekusi, versi perangkat lunak, serta bukti hash input dan arsip.

## Integritas dan pemeriksaan otomatis

Hash byte lokal dicatat untuk pelacakan; validasi memakai SHA256 teks dengan
normalisasi CRLF ke LF. Perubahan angka tetap ditolak. `.gitattributes` menetapkan
format LF untuk CSV, sehingga download ZIP dan clone tidak gagal hanya karena
perubahan akhir baris. Input mentah memiliki akhir baris campuran di salinan lama;
normalisasi hash tidak menulis ulang berkas itu.

[GitHub Actions](https://github.com/SyahrialdiRachimAkbar/analisis-deret-waktu-ikp-lampung/actions) menjalankan pipeline dari checkout bersih pada
Windows dan Linux dengan R 4.5.2 dan paket terkunci. Workflow memeriksa tahun
bulat, koreksi terlacak, rumus, kebocoran waktu, batas segmen, integritas sumber,
dan ekspor. Keberadaan workflow tidak menyatakan run CI sudah lulus; periksa
status aktual di tab **Actions**. Grafik/laporan hasil CI tersedia sebagai artifact.

Kamus data dan keputusan interpretasi ada di [DATA_DICTIONARY.md](review/timeseries/DATA_DICTIONARY.md).

## Riwayat project

Skrip bernomor di folder `R/`, `laporan_draft.md`, dan `LAPORAN_rev.md` adalah
arsip analisis panel sebelumnya. Desain yang aktif dijelaskan di
[project_context.md](project_context.md) dan [CHANGELOG.md](CHANGELOG.md).
Pipeline deret waktu tidak mengubah data atau mengeksekusi skrip panel lama.
