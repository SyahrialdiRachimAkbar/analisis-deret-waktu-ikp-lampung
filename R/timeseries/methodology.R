# Curated evidence, checked 2026-10-06. These are documentary facts, not
# estimated effects of measurement changes on Lampung's scores.
# 2019 and full 2024 indicator definitions remain incompletely verified.
methodology_audit <- function() {
  urls <- c(
    "https://repository.pertanian.go.id/browse/title?scope=6db25a25-f282-4a1b-8271-4cc09bc4d9cb",
    "https://badanpangan.go.id/storage/app/media/Bahan%202020/IKP%202019%20FINAL.pdf",
    "https://badanpangan.go.id/storage/app/media/2021/ikp-2020-20210120fix.pdf",
    "https://repository.pertanian.go.id/server/api/core/bitstreams/0700d4be-634a-4f89-820c-dbd06fe686b5/content",
    "https://badanpangan.go.id/storage/app/media/2023/Buku%20Digital/Buku%20Indeks%20Ketahanan%20Pangan%202022%20Signed.pdf",
    "https://data.badanpangan.go.id/nfs_storage/public/publication/documents/1728546912.pdf",
    "https://esakip.badanpangan.go.id/dok/pk/dok_202541754360657.pdf"
  )
  titles <- c("IKP Indonesia 2018 (PDF lokal dan audit sumber tersimpan)",
    "IKP Indonesia 2019 (URL ditemukan; isi tidak berhasil diakses)",
    "IKP 2020", "IKP 2021", "IKP 2022", "IKP 2023",
    "Laporan Kinerja Deputi Bidang Kerawanan Pangan dan Gizi 2024")
  pages <- c("PDF lokal: Tabel 4-5; review/verify_output.log bagian 8",
    "Belum diperiksa", "PDF hlm 7-10 (cetak 3-6)",
    "PDF hlm 10-14 (cetak 3-7)", "PDF hlm 12-16 (cetak 3-7)",
    "PDF hlm 12-15 (cetak 3-6)", "PDF hlm 34 dan 36-37 (cetak 25 dan 27-28)")
  inputs <- c("Produksi 2014-2016; sumber lain tidak diaudit ulang",
    "Belum terverifikasi", "Produksi dan Susenas 2019; SSGBI 2019",
    "Produksi dan Susenas 2020; sumber lain lihat publikasi",
    "Produksi dan Susenas 2021; SSGI 2021",
    "Padi dan Susenas 2022; SSGI 2022; tahun komoditas lain tidak dirinci",
    "Belum diaudit lengkap pada publikasi teknis tahunan")
  availability <- c("Padi, jagung, ubi kayu, ubi jalar",
    "Belum terverifikasi", "Padi, jagung, ubi kayu, ubi jalar",
    "Padi, jagung, ubi kayu, ubi jalar, stok beras daerah",
    "Padi, jagung, ubi kayu, ubi jalar, sagu, stok beras daerah",
    "Padi, jagung, ubi kayu, ubi jalar, sagu, stok beras daerah",
    "Padi, jagung, ubi kayu, ubi jalar, sagu, stok/CPPD, bantuan pangan CPP")
  notes <- c("Skor 2018: audit sebelumnya mencatat 15/15 cocok ke PDF primer. Pemeriksaan ulang isi PDF lokal tidak tersedia tanpa alat ekstraksi tambahan.",
    "URL primer tidak berhasil dibaca; jumlah indikator dan rincian definisi tidak diasumsikan telah terverifikasi.",
    "Jumlah indikator, bobot, dan sumber input diperiksa di publikasi primer.",
    "Stok beras daerah tercantum pada komponen ketersediaan, berbeda dari dokumen 2020. Batas konservatif untuk kabupaten.",
    "Sagu tercantum pada komponen ketersediaan, berbeda dari dokumen 2021. Batas konservatif untuk kabupaten.",
    "Komponen ketersediaan dan bobot selaras dengan dokumen 2022; harmonisasi seluruh input belum dibuktikan.",
    "Laporan resmi 2024 menambahkan bantuan pangan CPP pada komponen ketersediaan. Bobot lengkap dan metadata normalisasi belum diperiksa.")
  rows <- lapply(c("Kabupaten", "Kota"), function(type) {
    county <- type == "Kabupaten"
    weights <- if (county) "0.30;0.15;0.075;0.075;0.05;0.15;0.05;0.05;0.10" else
      "0;0.20;0.125;0.125;0.08;0.18;0.08;0.08;0.13"
    data.frame(tahun = 2018:2024, tipe = type, judul = titles, url = urls,
      lokasi_bukti = pages, jumlah_indikator = c(if (county) 9L else 8L, NA_integer_, rep(if (county) 9L else 8L, 5)),
      bobot_urutan_indikator = c(weights, NA, rep(weights, 4), NA),
      tahun_input = inputs,
      komponen_ketersediaan = if (county) availability else rep("Tidak masuk indeks kota", 7),
      batas_sebelum_tahun = county & (2018:2024 %in% c(2021, 2022, 2024)),
      status = c("audit_tersimpan", "belum_terverifikasi", rep("terverifikasi_parsial", 5)),
      catatan = if (county) notes else paste(notes, "Perubahan komponen ketersediaan tidak langsung berlaku pada indeks kota; tidak ada batas kota yang ditetapkan dari bukti ini."),
      tanggal_pemeriksaan = "2026-10-06", stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}
