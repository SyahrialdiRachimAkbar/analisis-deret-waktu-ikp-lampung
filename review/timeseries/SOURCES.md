# Jejak pemeriksaan sumber IKP untuk analisis deret waktu

Tanggal pemeriksaan: **6 Oktober 2026**. Pemeriksaan daring dilakukan saat
implementasi; pipeline analisis berjalan offline menggunakan matriks kurasi
di `R/timeseries/methodology.R`. Matriks yang diekspor berada di
[audit_metodologi.csv](../../output/timeseries/audit_metodologi.csv).

## Bukti yang diperiksa

| Edisi | Sumber primer dan lokasi | Temuan ringkas |
| --- | --- | --- |
| 2018 | PDF lokal `review/sources/BKP_Indeks_Ketahanan_Pangan_2018.pdf`; audit tersimpan `review/verify_output.log` bagian 8 | Audit sebelumnya mencatat 15/15 skor dan peringkat cocok. Isi PDF lokal tidak berhasil diekstraksi ulang pada sesi ini; statusnya audit tersimpan. |
| 2019 | [Publikasi IKP 2019](https://badanpangan.go.id/storage/app/media/Bahan%202020/IKP%202019%20FINAL.pdf) | URL ditemukan tetapi isi gagal diakses. Rincian indikator, bobot, dan normalisasi belum diverifikasi. |
| 2020 | [IKP 2020](https://badanpangan.go.id/storage/app/media/2021/ikp-2020-20210120fix.pdf), PDF halaman 7–10, terutama Tabel 1–2 | Empat komoditas pada ketersediaan; input produksi dan Susenas 2019; 9 indikator kabupaten, 8 kota. |
| 2021 | [IKP 2021](https://repository.pertanian.go.id/server/api/core/bitstreams/0700d4be-634a-4f89-820c-dbd06fe686b5/content), PDF halaman 10 dan 13–14 | Komponen ketersediaan juga mencakup stok beras daerah; input produksi 2020. |
| 2022 | [IKP 2022](https://badanpangan.go.id/storage/app/media/2023/Buku%20Digital/Buku%20Indeks%20Ketahanan%20Pangan%202022%20Signed.pdf), PDF halaman 12 dan 15–16 | Sagu juga tercantum pada komponen ketersediaan; input produksi 2021. |
| 2023 | [IKP 2023](https://data.badanpangan.go.id/nfs_storage/public/publication/documents/1728546912.pdf), PDF halaman 12–15 | Komponen memuat sagu dan stok daerah; Susenas dan SSGI 2022. |
| 2024 | [Laporan Kinerja Deputi Bidang Kerawanan Pangan dan Gizi 2024](https://esakip.badanpangan.go.id/dok/pk/dok_202541754360657.pdf), PDF halaman 34 dan 36–37 | Struktur 9/8 indikator; komponen ketersediaan juga menyebut bantuan pangan CPP. Bobot lengkap dan normalisasi belum diaudit di publikasi teknis. |

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
