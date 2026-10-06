# Pemeriksaan revisi — 6 Oktober 2026

## Hasil lokal yang sudah dijalankan

- Pipeline lengkap pada R 4.5.2 selesai exit 0; versi 16 dependensi sesuai manifest.
- Data asal raw/clean cocok 105/105; satu koreksi primer diterapkan tepat sekali pada
  salinan analisis. Lima keputusan rekonsiliasi tersedia; asal tetap 85/90 cocok
  dengan provinsi, analisis menjadi 86/90.
- Tahun pecahan, karakter, infinite, duplikasi, tahun hilang, dan skor di luar skala
  ditolak. Catatan koreksi duplikat/tidak lengkap/nilai asal berbeda ditolak.
- Rumus naïve/drift pada seri sintetis, MAE/RMSE, tidak memakai data target/masa
  depan, pemisahan segmen, serta identitas jumlah perubahan lulus.
- Hash teks LF sama untuk contoh LF/CRLF; perubahan angka membuat hash berbeda.
- Dua salinan baru di direktori temporer memakai seluruh teks LF atau CRLF,
  tanpa hasil deret waktu lama. Keduanya menjalankan pipeline lengkap exit 0 dan
  menghasilkan masing-masing enam PNG dan enam PDF.
- JSON renv.lock cocok dengan seluruh package/version pada manifest CSV.
- Seluruh berkas input/sumber/arsip yang dilindungi identik sebelum/sesudah run.
- Grafik fluktuasi dan kesenjangan sesudah koreksi diperiksa secara visual.

## Batas pemeriksaan

Uji LF/CRLF memakai paket yang sudah tersedia di komputer ini. Restore paket pada
mesin baru dan pengujian Linux dilakukan oleh workflow GitHub Actions setelah
push; status aktual harus diperiksa di Actions, bukan disimpulkan dari uji lokal.
Dokumen ini tidak menyatakan harmonisasi seri atau audit metadata tahunan telah
lengkap. Panjang seri tujuh tahun merupakan batas data yang tidak dihapus oleh tes.

Jejak bukti metode/nilai ada di [SOURCES.md](SOURCES.md); asumsi pembacaan tabel di
[DATA_DICTIONARY.md](DATA_DICTIONARY.md). Log pipeline ada pada output/timeseries/run.log.
