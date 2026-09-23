## review/verify_ikp_sources.R
## Verifikasi silang Y (IKP) data proyek vs TIGA sumber resmi.
## Hanya membaca. Tidak menulis ke data/ atau output/.
## Sumber (lihat review/sources/):
##   A. Bapanas  : ikp_kabkota_2018-2024_514.csv  (514 kab/kota x 2018-2024)
##   B. Bapanas  : ikp_kabkota_2024_12indikator.csv (backcasting 12 indikator, 2024)
##   C. Provinsi : lampungprov_ikp_kabkota_2019-2024.csv (Satu Data Lampung)
##   D. PDF      : BKP_Indeks_Ketahanan_Pangan_2018.pdf (Tabel 4 & 5, dasar 9/8 indikator)

stu <- read.csv("data/lampung_panel_clean.csv", stringsAsFactors = FALSE)
A <- read.csv("review/sources/bapanas_ikp_kabkota_2018-2024_514.csv",
              stringsAsFactors = FALSE, check.names = FALSE)
C <- read.csv("review/sources/lampungprov_ikp_kabkota_2019-2024.csv",
              stringsAsFactors = FALSE, check.names = FALSE)
sep <- function(t) cat("\n", strrep("=", 78), "\n== ", t, "\n", strrep("=", 78), "\n", sep = "")

sep("0. KELENGKAPAN SUMBER RESMI (Bapanas A)")
cat("baris:", nrow(A), "| kab/kota unik:", length(unique(A$`Kode Kab/Kota`)),
    "| tahun:", paste(sort(unique(A$Tahun)), collapse = ","), "\n")
cat("514 x 7 =", 514*7, "-> panel seimbang:", nrow(A) == 514*7, "\n")
cat("IKP kosong:", sum(is.na(A$IKP) | A$IKP == ""), "\n")

lamA <- A[A$`Nama Provinsi` == "Lampung", ]
cat("baris Lampung:", nrow(lamA), "| kab/kota:", length(unique(lamA$`Kode Kab/Kota`)), "\n")

sep("1. KODE BPS RESMI vs KODE DI DATA PROYEK")
kode_resmi <- tapply(lamA$`Nama Kabupaten`, lamA$`Kode Kab/Kota`, function(x) x[1])
kode_mhs   <- tapply(stu$kabupaten, stu$kode, function(x) x[1])
cmp <- data.frame(kode = names(kode_resmi), nama_resmi = kode_resmi,
                  nama_proyek = kode_mhs[names(kode_resmi)], row.names = NULL)
cmp$sama <- ifelse(cmp$nama_resmi == cmp$nama_proyek, "YA", "TIDAK")
print(cmp, row.names = FALSE)
cat("kode dgn nama berbeda:", sum(cmp$sama == "TIDAK"), "dari", nrow(cmp), "\n")

sep("2. BANDING NILAI IKP: proyek vs Bapanas (A) menurut NAMA")
sv <- function(k) setNames(stu$ikp[stu$kode == k], as.character(stu$tahun[stu$kode == k]))
names_mhs <- names(kode_mhs); names(names_mhs) <- kode_mhs
tot <- ok <- 0; bad <- list()
for (k in unique(stu$kode)) {
  nm <- kode_mhs[as.character(k)]
  yrs <- as.character(sort(unique(lamA$Tahun)))
  for (y in yrs) {
    if (y == "2018" || TRUE) {
      v <- sv(k)[y]
      a <- lamA$IKP[lamA$`Nama Kabupaten` == nm & lamA$Tahun == y]
      if (length(v) && length(a)) {
        tot <- tot + 1
        if (abs(v - a) < 1e-6) ok <- ok + 1
        else bad[[length(bad)+1]] <- data.frame(nama = nm, kode = k, tahun = y,
                                                proyek = v, bapanas = a, selisih = round(v - a, 2))
      }
    }
  }
}
cat("cocok vs Bapanas (menurut NAMA):", ok, "/", tot, sprintf("(%.0f%%)\n", 100*ok/tot))
cat("\nSELISIH yang ditemukan:\n")
print(do.call(rbind, bad), row.names = FALSE)

sep("3. BANDING NILAI IKP: proyek vs Sumber Provinsi (C), 2019-2024")
prov <- setNames(vector("list", nrow(C)), C$nama_kabupaten_kota)
for (i in seq_len(nrow(C))) {
  prov[[C$nama_kabupaten_kota[i]]] <- setNames(as.numeric(C[i, c("2019","2020","2021","2022","2023","2024")]),
                                               c("2019","2020","2021","2022","2023","2024"))
}
map <- c("Kota Bandar Lampung"="Bandar Lampung", "Kota Metro"="Metro")
tot2 <- ok2 <- 0; bad2 <- list()
for (k in unique(stu$kode)) {
  nm <- unname(kode_mhs[as.character(k)]); pn <- ifelse(nm %in% names(map), map[nm], nm)
  for (y in names(prov[[pn]])) {
    v <- sv(k)[y]; p <- prov[[pn]][[y]]
    if (length(v) && length(p)) {
      tot2 <- tot2 + 1
      if (abs(v - p) < 1e-6) ok2 <- ok2 + 1
      else bad2[[length(bad2)+1]] <- data.frame(nama = nm, tahun = y, proyek = v,
                                                provinsi = p, selisih = round(v - p, 2))
    }
  }
}
cat("cocok vs Provinsi:", ok2, "/", tot2, sprintf("(%.0f%%)\n", 100*ok2/tot2))
print(do.call(rbind, bad2), row.names = FALSE)

sep("4. UJI KUNCI: apakah umur seri proyek = seri NAMA resmi, atau KODE resmi?")
## Untuk tiap unit: berapa tahun yang cocok bila memakai KODE-nya sendiri,
## dan berapa bila memakai KODE resmi milik NAMA-nya.
lamA$key <- paste(lamA$`Kode Kab/Kota`, lamA$Tahun)
valA <- setNames(lamA$IKP, lamA$key)
proper <- setNames(lamA$`Kode Kab/Kota`, lamA$`Nama Kabupaten`)
res <- do.call(rbind, lapply(unique(stu$kode), function(k) {
  nm <- unname(kode_mhs[as.character(k)])
  yrs <- as.character(sort(unique(lamA$Tahun)))
  n_own  <- sum(sapply(yrs, function(y) {
    a <- valA[[paste(k, y)]]; v <- sv(k)[y]
    !is.null(a) && length(v) && abs(v - a) < 1e-6 }))
  pk <- unname(proper[nm])
  n_name <- sum(sapply(yrs, function(y) {
    a <- valA[[paste(pk, y)]]; v <- sv(k)[y]
    !is.null(a) && length(v) && abs(v - a) < 1e-6 }))
  data.frame(nama = nm, kode_proyek = k, kode_resmi_utk_nama = pk,
             cocok_vs_KODE_sendiri = n_own, cocok_vs_KODE_nama = n_name)
}))
print(res, row.names = FALSE)
cat("\nTOTAL cocok vs KODE sendiri:", sum(res$cocok_vs_KODE_sendiri), "/", 7*nrow(res), "\n")
cat("TOTAL cocok vs KODE milik nama:", sum(res$cocok_vs_KODE_nama), "/", 7*nrow(res), "\n")

sep("5. SEAM 2019/2020 -> tiap seri = gabungan dua tempat")
for (k in unique(stu$kode)) {
  nm <- unname(kode_mhs[as.character(k)])
  yrs <- as.character(sort(unique(lamA$Tahun)))
  asal <- sapply(yrs, function(y) {
    v <- sv(k)[y]
    hit <- names(valA)[abs(valA - v) < 1e-6]
    if (!length(hit)) return("?")
    paste(unique(sub(" .*", "", hit)), collapse = "/")
  })
  cat(sprintf("  %-22s kode=%s : %s\n", nm, k, paste(asal, collapse = " ")))
}
cat("\n(kode yang muncul beda dari kode proyek = nilai itu milik wilayah LAIN)\n")

sep("6. APAKAH LOMPATAN 2023 ITU NYATA DI SERI RESMI?")
nat <- do.call(rbind, lapply(sort(unique(A$Tahun)), function(y) {
  v <- A$IKP[A$Tahun == y]
  data.frame(tahun = y, n = length(v), mean_ikp = round(mean(v), 2))
}))
nat$delta <- c(NA, round(diff(nat$mean_ikp), 2))
print(nat, row.names = FALSE)
lam <- do.call(rbind, lapply(sort(unique(lamA$Tahun)), function(y) {
  data.frame(tahun = y, mean_ikp = round(mean(lamA$IKP[lamA$Tahun == y]), 2))
}))
lam$delta <- c(NA, round(diff(lam$mean_ikp), 2))
cat("\nLampung (sumber resmi):\n"); print(lam, row.names = FALSE)
cat("\nKesimpulan: lompatan 2023 muncul di skala nasional -> BUKAN artefak data proyek.\n")

sep("7. N YANG TERSEDIA UNTUK PERLUASAN SAMPEL")
cat("kab/kota di sumber Bapanas:", length(unique(A$`Kode Kab/Kota`)), "\n")
sumprov <- c("Aceh","Sumatera Utara","Sumatera Barat","Riau","Jambi","Sumatera Selatan",
             "Bengkulu","Lampung","Kepulauan Bangka Belitung","Kepulauan Riau")
sub <- A[A$`Nama Provinsi` %in% sumprov, ]
cat("kab/kota di 10 provinsi Sumatera:", length(unique(sub$`Kode Kab/Kota`)),
    "| observasi panel (x7 tahun):", nrow(sub), "\n")
cat("provinsi di sumber:", length(unique(A$`Nama Provinsi`)), "\n")
cat("Catatan: file ini memuat 34 provinsi (belum termasuk pemekaran Papua 2022+).\n")

sep("8. UJI PEMUNGKAS: banding 2018 vs PUBLIKASI PRIMER (PDF BKP 2018, Tabel 4 & 5)")
## Nilai & peringkat dibaca dari: Badan Ketahanan Pangan (2019),
## "Indeks Ketahanan Pangan Indonesia 2018", Tabel 4 (Kabupaten) & Tabel 5 (Kota).
## Ini publikasi primer (9 indikator kabupaten / 8 indikator kota), bukan file open data.
pdf18 <- data.frame(
  nama = c("Tulang Bawang Barat","Mesuji","Pringsewu","Tulang Bawang","Lampung Timur",
           "Lampung Selatan","Lampung Tengah","Way Kanan","Pesawaran","Lampung Utara",
           "Tanggamus","Lampung Barat","Pesisir Barat","Kota Bandar Lampung","Kota Metro"),
  rank = c(45, 44, 84, 90, 110, 132, 158, 199, 225, 232, 236, 256, 285, 59, 71),
  ikp  = c(80.70, 80.82, 78.48, 78.24, 77.43, 76.48, 75.43, 73.63, 72.54, 72.18,
           71.96, 70.76, 67.99, 68.93, 65.98))
ok_pdf <- 0
kode_of_nama <- setNames(names(kode_mhs), unname(kode_mhs))   # nama -> kode proyek
for (i in seq_len(nrow(pdf18))) {
  nm <- pdf18$nama[i]; k <- unname(kode_of_nama[nm]); v <- sv(k)["2018"]
  same <- length(v) && abs(v - pdf18$ikp[i]) < 1e-6
  ok_pdf <- ok_pdf + same
  cat(sprintf("  %-22s PDF rank %3d skor %6.2f | proyek 2018 %6.2f  %s\n",
              nm, pdf18$rank[i], pdf18$ikp[i], v, ifelse(same, "COCOK", "BEDA")))
}
cat(sprintf("\ncocok vs PUBLIKASI PRIMER 2018: %d/15\n", ok_pdf))
cat("-> Bila 15/15: Y tahun 2018 proyek BENAR; file open-data Bapanas yang salah menempelkan nama.\n")

sep("9. VINTAGE SERI: apakah nilai 2024 sama di dua file resmi?")
B <- read.csv("review/sources/bapanas_ikp_kabkota_2024_12indikator.csv",
              stringsAsFactors = FALSE, check.names = FALSE)
bl <- B[B$`Nama Provinsi` == "Lampung", c("Nama Kabupaten","IKP")]
names(bl) <- c("nama","ikp_12indikator")
bl$ikp_ds90 <- lamA$IKP[lamA$Tahun == 2024][match(bl$nama, lamA$`Nama Kabupaten`[lamA$Tahun == 2024])]
bl$ikp_proyek <- sapply(bl$nama, function(n) {
  k <- names(kode_mhs)[match(n, kode_mhs)]; v <- sv(k)["2024"]; if (length(v)) v else NA })
bl <- bl[order(bl$nama), ]
print(bl, row.names = FALSE)
cat("\nSelisih ds90 vs 12-indikator (2024): ",
    paste(unique(round(bl$ikp_ds90 - bl$ikp_12indikator, 2)), collapse = ", "), "\n")
cat("-> Dua file resmi MEMBERI NILAI BERBEDA untuk tahun yang sama => vintage seri berbeda.\n")

sep("SELESAI")

