# Kamus data analisis deret waktu

Satu baris mewakili satu wilayah pada satu tahun edisi IKP; 15 wilayah × 7 tahun.
Tahun edisi bukan jaminan bahwa semua indikator memakai data dari tahun yang sama.

| Kolom | Makna dan aturan |
| --- | --- |
| kode | ID internal berbentuk teks; bukan kode BPS resmi untuk join luar |
| kabupaten | Nama wilayah; awalan Kota membedakan konstruksi indeks |
| tahun | Tahun edisi berupa bilangan bulat 2018–2024; tidak menerima teks/pecahan |
| ikp | Skor analisis 0–100, sesudah keputusan rekonsiliasi |
| ikp_asal | Skor sumber proyek sebelum koreksi |
| dikoreksi | TRUE hanya ketika nilai analisis diubah dengan bukti primer |
| status_nilai | Keputusan sumber dan tingkat bukti; bukan sertifikat harmonisasi |
| tipe | Kabupaten atau Kota; bobot/konstruksi berbeda |
| batas_metode | Batas konservatif sebelum tahun berjalan berdasarkan rincian dokumen |
| segmen | Kelompok temporal analisis; bukan bukti kesamaan seluruh pengukuran |
| status_sumber | Cakupan bukti metadata tahunan; audit lengkap belum tercapai |
| status_analisis | Eksploratif bersyarat |

Selisih, kenaikan, SD, MAE, dan RMSE menggunakan **poin IKP**, bukan persen.
Rata-rata kabupaten memberi bobot sama pada 13 wilayah; bukan IKP resmi provinsi.
Nilai kosong pada perubahan/ramalan berarti tidak dihitung, dengan alasan di kolom
status. Nilai kosong tidak diganti nol.

`rekonsiliasi_nilai.csv` menyimpan lima keputusan, nilai asal/pembanding/analisis,
URL, lokasi bukti, dan keterbatasan akses. `sensitivitas_nilai.csv` membandingkan
input asal, rekonsiliasi, dan pembanding provinsi tanpa mengubah input. Skenario
provinsi tidak otomatis menjadi data yang dianggap benar.

`sensitivitas_tahun_uji.csv` membandingkan semua target dan pengeluaran satu target.
Skenario penuh memakai tiga tahun uji, skenario pengurangan memakai dua. Error
lintas kota pada tahun sama tidak dianggap tahun pengamatan yang independen.
