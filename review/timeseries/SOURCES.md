# Jejak pemeriksaan sumber IKP untuk analisis deret waktu

Tanggal pemeriksaan: **6 Oktober 2026**. Pemeriksaan daring dilakukan saat
implementasi; pipeline analisis berjalan offline menggunakan matriks kurasi
di `R/timeseries/methodology.R`. Matriks yang diekspor berada di
[audit_metodologi.csv](../../output/timeseries/audit_metodologi.csv).

## Bukti yang diperiksa

| Edisi | Sumber primer dan lokasi | Temuan ringkas |
| --- | --- | --- |
| 2018 | PDF lokal `review/sources/BKP_Indeks_Ketahanan_Pangan_2018.pdf`, PDF hlm 7–10; audit skor tersimpan `review/verify_output.log` bagian 8 | Metodologi berhasil diekstraksi ulang dengan pdfminer.six: komoditas, produksi tetap 2014–2016, Susenas 2017, bobot 9/8 dan standardisasi. Audit skor sebelumnya mencatat 15/15 cocok. |
| 2019 | [Publikasi IKP 2019](https://badanpangan.go.id/storage/app/media/Bahan%202020/IKP%202019%20FINAL.pdf) | Cuplikan primer terindeks mendukung 9/8 indikator, rumus z-score/distance to scale dan Metro 75,85. Akses PDF penuh gagal; rincian bobot dan input belum diperiksa lengkap. |
| 2020 | [IKP 2020](https://badanpangan.go.id/storage/app/media/2021/ikp-2020-20210120fix.pdf), PDF halaman 7–10, terutama Tabel 1–2 | Empat komoditas pada ketersediaan; input produksi dan Susenas 2019; 9 indikator kabupaten, 8 kota. |
| 2021 | [IKP 2021](https://repository.pertanian.go.id/server/api/core/bitstreams/0700d4be-634a-4f89-820c-dbd06fe686b5/content), PDF halaman 10 dan 13–14 | Komponen ketersediaan juga mencakup stok beras daerah; input produksi 2020. |
| 2022 | [IKP 2022](https://badanpangan.go.id/storage/app/media/2023/Buku%20Digital/Buku%20Indeks%20Ketahanan%20Pangan%202022%20Signed.pdf), PDF halaman 12 dan 15–16 | Sagu juga tercantum pada komponen ketersediaan; input produksi 2021. |
| 2023 | [IKP 2023](https://data.badanpangan.go.id/nfs_storage/public/publication/documents/1728546912.pdf), PDF halaman 12–15 | Komponen memuat sagu dan stok daerah; Susenas dan SSGI 2022. |
| 2024 | [FSVA Nasional 2024](https://data.badanpangan.go.id/download/document/publication/76/1738309499.pdf/pdf), PDF halaman 36–37 dan 39–40 (cetak 32–33 dan 35–36) | Halaman teknis primer diperiksa: definisi, input 2023, bobot 9/8, standardisasi z-score/distance to scale. Sagu tercantum pada tabel definisi; tabel bobot meringkas komoditas tanpa sagu. Bantuan CPP/CPPD dan stunting SKI 2023 tercantum. |

Nomor halaman di atas adalah posisi halaman PDF (mulai dari 1), bukan nomor
halaman tercetak. Kurasi menyimpan keduanya bila tersedia. Catatan merupakan
parafrasa pemeriksaan, bukan kutipan panjang dokumen.

## Kebijakan analisis dan batas buktinya

Perbedaan rincian komponen pada dokumen resmi **terkonfirmasi**. Besarnya dampak
perubahan pada skor Lampung, praktik implementasi setiap wilayah, serta apakah
seluruh skor historis pernah diharmonisasi **belum terkonfirmasi**.

Karena belum ada bukti harmonisasi, pipeline memberi batas konservatif kabupaten
sebelum 2021, 2022, dan 2024. Tidak ada klaim bahwa tahun-tahun tersebut merupakan
structural break ekonomi, atau bahwa lonjakan tertentu pasti disebabkan metode.
Skor tetap disimpan; perhitungan lintas-batas dikecualikan, bukan diganti nol.

Komponen ketersediaan tidak masuk indeks kota, sehingga perubahan komponen itu
tidak dipakai untuk menetapkan batas kota. Seri kota masih eksploratif bersyarat:
ketiadaan batas yang terkonfirmasi bukan bukti kesamaan seluruh pengukuran.

Jika kelak tersedia seri resmi yang telah diharmonisasi, kurasi harus diperbarui
berdasarkan bukti sebelum mengubah batas. Menghapus batas hanya agar ramalan
kabupaten dapat dihitung tidak dibenarkan oleh hasil pemeriksaan ini.

## Nilai sumber pembanding

Berkas Satu Data Lampung yang sudah tersimpan dibandingkan lewat nama wilayah,
bukan kode. Hasilnya 85/90 cocok; lima perbedaan disimpan di
[selisih_sumber_provinsi.csv](../../output/timeseries/selisih_sumber_provinsi.csv).
Data proyek tetap dipakai, tanpa koreksi otomatis dari sumber pembanding.

### Revisi sesudah evaluasi

Kalimat di atas menggambarkan pemeriksaan awal. Analisis aktif sekarang memakai
[rekonsiliasi_nilai.csv](rekonsiliasi_nilai.csv): lima keputusan dengan tingkat bukti.
Tanggamus 2020 diubah **pada salinan analisis** dari 76,67 menjadi 74,67 karena
publikasi IKP 2020 mencatat 74,67 pada dua tempat: tabel peringkat (PDF hlm 15)
dan Lampiran 1 (PDF hlm 29). Lampung Barat 2020 tetap 74,02 pada Lampiran 1;
Metro 2020 tetap 76,76 pada Lampiran 2 (PDF hlm 43).

Metro 2019 sebesar 75,85 didukung cuplikan primer terindeks dan
[RPJPD Kota Metro 2025–2045](https://bappeda.metrokota.go.id/wp-content/uploads/2025/11/RPJPD_KOTA-METRO_2025-2045.pdf),
Tabel 2.7, halaman cetak II-11. Lampung Selatan 2024 sebesar 84,46 didukung
[dokumen pemerintah Provinsi Lampung](https://bappeda.lampungprov.go.id/index.php/berkas/uploads/n5PoPB1JTmtfmMl4t2cJMk8QnWaKthusWh9kfrxI.pdf),
tabel IKP kabupaten/kota 2024. Saat pemeriksaan awal kedua dokumen terakhir hanya
terbaca melalui cuplikan terindeks. Lampung Selatan 2024 kini juga terkonfirmasi
**84,46 pada publikasi primer**, PDF hlm 60 (cetak 56), Tabel 4.1, peringkat 84.
Posisi nama dan nilai diperiksa pada baris yang sama. Metro 2019 tetap berbukti parsial.
Input asal tetap 85/90 cocok; nilai analisis sesudah satu koreksi 86/90 cocok.

Publikasi teknis [FSVA Nasional 2024](https://data.badanpangan.go.id/statisticpublications/pke)
ditemukan dengan [tautan unduh resmi](https://data.badanpangan.go.id/download/document/publication/76/1738309499.pdf/pdf).
Pembaca web menolak ukuran sekitar 31 MB. Pemeriksaan lokal akhirnya berhasil
dengan HTTP Range dari URL resmi, mengambil awalan dokumen, tabel xref, dan objek
font. pdfminer.six membaca halaman terpilih dengan batas maxpages, bukan seluruh
dokumen yang bagian lainnya belum diunduh. Definisi/input diperiksa pada PDF hlm
36–37; bobot/rumus pada hlm 39–40; peringkat pada hlm 60 dan 65. Ini pemeriksaan
halaman primer, bukan klaim bahwa seluruh halaman/input pembentuk indeks diaudit.
Cache parsial tidak dimasukkan ke repo atau dianggap salinan lengkap untuk hash.

Bobot metadata ditulis dalam urutan indikator kanonis. Publikasi 2024 memindahkan
urutan air bersih, harapan hidup, dan sekolah perempuan; pencocokan berdasarkan
nama indikator. Kedua urutan tercantum pada matriks audit. Katalog 2019 memiliki
tombol baca yang mengarah ke login; URL lama mengembalikan 404 pada unduhan lokal.
Cuplikan primer terindeks tetap menjadi bukti parsial. Parameter normalisasi identik
dan harmonisasi tetap FALSE; rumus umum sama tidak membuktikan acuan yang sama.

Sensitivitas memakai tiga skenario nilai dan pengeluaran satu tahun target.
Pengeluaran target 2022 mengubah metode dengan MAE lebih kecil menjadi drift.
Ukuran sampel tujuh tahun tidak ditambah secara artifisial; SD dua perubahan dan
ramalan tiga target tetap dilaporkan sebagai deskripsi dengan keterbatasan.

Seri [IKP kabupaten/kota edisi lama](https://data.badanpangan.go.id/datasetpublications/frq/ikp-kab-kota-2024)
dan [seri 12 indikator](https://data.badanpangan.go.id/datasetpublications/cky/ikp-kabupaten-kota-2024-2026)
tidak dicampur. Sumber resmi terbuka dapat memiliki revisi, perbedaan vintage,
atau masalah label; keberadaan URL resmi saja tidak menjamin satu seri yang identik.

## Referensi metode dan visualisasi

- [Metode naïve dan drift](https://otexts.com/fpp3/simple-methods.html).
- [Evaluasi dengan rolling forecasting origin](https://otexts.com/fpp3/tscv.html).
- [MAE dan RMSE](https://otexts.com/fpp3/accuracy.html).
- [Keterbatasan seri sangat pendek](https://otexts.com/fpp3/long-short-ts.html).
- Dokumentasi ggplot2 diperiksa melalui Context7: [facet_wrap](https://ggplot2.tidyverse.org/reference/facet_wrap.html) dan [ggsave](https://ggplot2.tidyverse.org/reference/ggsave.html).
