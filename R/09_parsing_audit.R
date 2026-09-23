options(stringsAsFactors = FALSE)

clean <- read.csv("data/lampung_panel_clean.csv")
raw <- readLines("Data Fix - DATA.csv", encoding = "UTF-8", warn = FALSE)
datalines <- raw[grepl(",[0-9]{4},", raw)]

fields <- lapply(datalines, function(ln)
  scan(text = ln, what = "", sep = ",", quote = "\"",
       quiet = TRUE, blank.lines.skip = FALSE, encoding = "UTF-8"))
f <- do.call(rbind, fields)

stopifnot(all(trimws(f[, 2]) == clean$kabupaten))
stopifnot(all(as.integer(f[, 3]) == clean$tahun))

pdrb_str <- trimws(f[, 5])
pdp_str  <- trimws(f[, 8])

classify <- function(s) {
  hd <- grepl("\\.", s); hc <- grepl(",", s)
  nd <- lengths(regmatches(s, gregexpr("\\.", s)))
  nc <- lengths(regmatches(s, gregexpr(",", s)))
  cls <- ifelse(hd & hc, "c_dot+comma",
         ifelse(hd, ifelse(nd > 1, "a2_dot_multi", "a1_dot_single"),
         ifelse(hc, ifelse(nc > 1, "b2_comma_multi", "b1_comma_single"), "d_none")))
  cls
}

cat("=== P1: KLASIFIKASI STRING NUMERIK MENTAH ===\n\n")
cat("--- Kolom pdrb (kolom ke-5) ---\n")
print(table(classify(pdrb_str)))
cat("\n--- Kolom produksi_padi (kolom ke-8) ---\n")
print(table(classify(pdp_str)))

cat("\n=== P1: DAFTAR LENGKAP KELAS (c) titik DAN koma ===\n")
idx_c <- which(classify(pdrb_str) == "c_dot+comma" | classify(pdp_str) == "c_dot+comma")
cat("Jumlah baris dengan minimal satu kolom kelas (c):", length(idx_c), "\n")

cat("\n=== P1: DAFTAR TAMBAHAN - pemisah ganda dalam satu jenis (ambigu) ===\n")
amb <- which(classify(pdrb_str) %in% c("a2_dot_multi") |
             classify(pdp_str)  %in% c("b2_comma_multi", "a2_dot_multi"))
cat("Baris ambigu (dot-multi / comma-multi):", length(amb), "\n")

cat("\n=== P2: DETAIL SETIAP BARIS RISIKO (kelas c + ambigu) ===\n")
allrisk <- sort(unique(c(idx_c, amb)))
for (i in allrisk) {
  cat(sprintf("baris %d | %s %d\n", i, clean$kabupaten[i], clean$tahun[i]))
  cat(sprintf("  pdrb   raw=%-14s kelas=%-14s parsed=%s\n",
              pdrb_str[i], classify(pdrb_str)[i], clean$pdrb[i]))
  cat(sprintf("  padi   raw=%-14s kelas=%-14s parsed=%s\n",
              pdp_str[i], classify(pdp_str)[i], clean$produksi_padi[i]))
}

cat("\n=== P4: SANITY CHECK MAGNITUDO ===\n")
clean <- clean[order(clean$kode, clean$tahun), ]
cat("\n--- Lonjakan year-over-year > 60% ---\n")
flag_yoy <- data.frame()
for (k in unique(clean$kode)) {
  d <- clean[clean$kode == k, ]
  d <- d[order(d$tahun), ]
  gy <- c(NA, diff(d$produksi_padi) / head(d$produksi_padi, -1) * 100)
  gp <- c(NA, diff(d$pdrb) / head(d$pdrb, -1) * 100)
  for (j in seq_along(gy)) {
    if (!is.na(gy[j]) && abs(gy[j]) > 60)
      flag_yoy <- rbind(flag_yoy, data.frame(kab = d$kabupaten[j], tahun = d$tahun[j],
        var = "produksi_padi", pct = round(gy[j], 1)))
    if (!is.na(gp[j]) && abs(gp[j]) > 60)
      flag_yoy <- rbind(flag_yoy, data.frame(kab = d$kabupaten[j], tahun = d$tahun[j],
        var = "pdrb", pct = round(gp[j], 1)))
  }
}
if (nrow(flag_yoy) == 0) cat("TIDAK ADA lonjakan >60%.\n") else print(flag_yoy, row.names = FALSE)

cat("\n--- Nilai > 20x atau < 1/20x median kabupaten sendiri ---\n")
flag_med <- data.frame()
for (k in unique(clean$kode)) {
  d <- clean[clean$kode == k, ]
  for (v in c("produksi_padi", "pdrb")) {
    med <- median(d[[v]])
    ratio <- d[[v]] / med
    hit <- which(ratio > 20 | ratio < 1/20)
    if (length(hit)) flag_med <- rbind(flag_med,
      data.frame(kab = d$kabupaten[hit], tahun = d$tahun[hit], var = v,
                 nilai = d[[v]][hit], median = med, rasio = round(ratio[hit], 2)))
  }
}
if (nrow(flag_med) == 0) cat("TIDAK ADA nilai ekstrem vs median kabupaten.\n") else print(flag_med, row.names = FALSE)

cat("\n=== P4b: CEK LANGSUNG KE FILE MENTAH untuk setiap flag YoY ===\n")
if (nrow(flag_yoy) > 0) {
  for (r in seq_len(nrow(flag_yoy))) {
    key_kab <- flag_yoy$kab[r]; key_thn <- flag_yoy$tahun[r]
    i <- which(clean$kabupaten == key_kab & clean$tahun == key_thn)
    cat(sprintf("%s %d: %s\n  RAW: %s\n", key_kab, key_thn, flag_yoy$var[r], datalines[i]))
  }
} else cat("(tidak ada flag untuk dicek)\n")
