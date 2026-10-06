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
    "https://data.badanpangan.go.id/download/document/publication/76/1738309499.pdf/pdf"
  )
  titles <- c("IKP Indonesia 2018 (PDF lokal dan audit sumber tersimpan)",
    "IKP Indonesia 2019 (cuplikan primer terindeks; akses PDF penuh belum berhasil)",
    "IKP 2020", "IKP 2021", "IKP 2022", "IKP 2023",
    "FSVA Nasional 2024 (publikasi teknis primer; halaman terpilih diperiksa)")
  pages <- c("PDF lokal hlm 7-10 (cetak 3-6); skor: audit tersimpan Tabel 4-5",
    "Cuplikan primer terindeks: jumlah indikator dan rumus umum; akses penuh belum berhasil", "PDF hlm 7-10 (cetak 3-6)",
    "PDF hlm 10-14 (cetak 3-7)", "PDF hlm 12-16 (cetak 3-7)",
    "PDF hlm 12-15 (cetak 3-6)", "PDF hlm 36-37 dan 39-40 (cetak 32-33 dan 35-36)")
  inputs <- c("Produksi tetap 2014-2016; Susenas 2017; metodologi PDF lokal diperiksa ulang",
    "Belum terverifikasi", "Produksi dan Susenas 2019; SSGBI 2019",
    "Produksi dan Susenas 2020; sumber lain lihat publikasi",
    "Produksi dan Susenas 2021; SSGI 2021",
    "Padi dan Susenas 2022; SSGI 2022; tahun komoditas lain tidak dirinci",
    "Produksi dan Susenas 2023; CPPD/bantuan CPP 2023; stunting SKI 2023")
  availability <- c("Padi, jagung, ubi kayu, ubi jalar",
    "Belum terverifikasi", "Padi, jagung, ubi kayu, ubi jalar",
    "Padi, jagung, ubi kayu, ubi jalar, stok beras daerah",
    "Padi, jagung, ubi kayu, ubi jalar, sagu, stok beras daerah",
    "Padi, jagung, ubi kayu, ubi jalar, sagu, stok beras daerah",
    "Padi, jagung, ubi kayu, ubi jalar, sagu, stok/CPPD, bantuan pangan CPP")
  notes <- c("Metodologi PDF lokal diperiksa ulang dengan pdfminer.six: komoditas; Susenas 2017; bobot 9/8; z-score/distance to scale. Skor 2018 memakai audit tersimpan 15/15. Vintage input berbeda tidak membuktikan kesamaan pengukuran antar-edisi.",
    "PDF primer penuh belum dapat dibaca. Cuplikan primer terindeks mendukung 9/8 indikator dan rumus z-score/distance to scale; Metro 75.85 juga didukung RPJPD Kota Metro. Rincian lengkap bobot dan input belum diverifikasi.",
    "Jumlah indikator, bobot, dan sumber input diperiksa di publikasi primer.",
    "Stok beras daerah tercantum pada komponen ketersediaan, berbeda dari dokumen 2020. Batas konservatif untuk kabupaten.",
    "Sagu tercantum pada komponen ketersediaan, berbeda dari dokumen 2021. Batas konservatif untuk kabupaten.",
    "Komponen ketersediaan dan bobot selaras dengan dokumen 2022; harmonisasi seluruh input belum dibuktikan.",
    "Halaman publikasi teknis primer diperiksa melalui HTTP range dan pdfminer.six: definisi, tahun input 2023, bobot 9/8 dan rumus umum z-score/distance to scale. Tabel definisi menyebut sagu; tabel bobot meringkas komoditas tanpa sagu. Parameter normalisasi identik antar-edisi/harmonisasi belum terbukti.")
  rows <- lapply(c("Kabupaten", "Kota"), function(type) {
    county <- type == "Kabupaten"
    weights <- if (county) "0.30;0.15;0.075;0.075;0.05;0.15;0.05;0.05;0.10" else
      "0;0.20;0.125;0.125;0.08;0.18;0.08;0.08;0.13"
    data.frame(tahun = 2018:2024, tipe = type, judul = titles, url = urls,
      lokasi_bukti = pages, jumlah_indikator = rep(if (county) 9L else 8L, 7),
      bobot_urutan_indikator = c(weights, NA, rep(weights, 5)),
      urutan_indikator_kanonis = "ketersediaan;kemiskinan;pangsa_pengeluaran;listrik;sekolah_perempuan;air_bersih;tenaga_kesehatan;stunting;harapan_hidup",
      urutan_dokumen_2024 = "ketersediaan;kemiskinan;pangsa_pengeluaran;listrik;air_bersih;harapan_hidup;sekolah_perempuan;tenaga_kesehatan;stunting",
      tahun_input = inputs,
      komponen_ketersediaan = if (county) availability else rep("Tidak masuk indeks kota", 7),
      batas_sebelum_tahun = county & (2018:2024 %in% c(2021, 2022, 2024)),
      status = c("metodologi_primer_dan_audit_skor_tersimpan", "cuplikan_primer_terindeks", rep("terverifikasi_parsial", 5)),
      normalisasi_dokumen = c("z-score dan distance to scale 0-100 (PDF lokal diperiksa ulang)", "z-score/distance to scale (cuplikan primer terindeks)",
        rep("z-score dan distance to scale 0-100", 5)),
      parameter_normalisasi_identik_terverifikasi = FALSE,
      harmonisasi_terverifikasi = FALSE,
      catatan = if (county) notes else paste(notes, "Perubahan komponen ketersediaan tidak langsung berlaku pada indeks kota; tidak ada batas kota yang ditetapkan dari bukti ini."),
      tanggal_pemeriksaan = "2026-10-06", stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}
