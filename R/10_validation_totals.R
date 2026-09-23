options(stringsAsFactors = FALSE)

clean <- read.csv("data/lampung_panel_clean.csv")
raw <- readLines("Data Fix - DATA.csv", encoding = "UTF-8", warn = FALSE)
dl <- raw[grepl(",[0-9]{4},", raw)]
f <- do.call(rbind, lapply(dl, function(ln)
  scan(text = ln, what = "", sep = ",", quote = "\"",
       quiet = TRUE, blank.lines.skip = FALSE, encoding = "UTF-8")))
pdrb_str <- trimws(f[, 5]); pdp_str <- trimws(f[, 8])

nsep <- function(s, ch) lengths(regmatches(s, gregexpr(ch, s, fixed = TRUE)))
classify <- function(s) {
  hd <- nsep(s, ".") > 0; hc <- nsep(s, ",") > 0
  ifelse(hd & hc, "c", ifelse(hd, "a", ifelse(hc, "b", "d")))
}
digit_stats <- function(s) {
  first <- sapply(s, function(z) {
    p <- c(as.integer(gregexpr("\\.", z)[[1]]), as.integer(gregexpr(",", z)[[1]]))
    p <- p[p > 0]; if (!length(p)) NA_integer_ else min(p) - 1L
  })
  last <- sapply(s, function(z) {
    p <- c(as.integer(gregexpr("\\.", z)[[1]]), as.integer(gregexpr(",", z)[[1]]))
    p <- p[p > 0]; if (!length(p)) NA_integer_ else nchar(z) - max(p)
  })
  list(int_min = min(first, na.rm = TRUE), int_max = max(first, na.rm = TRUE),
       dec_min = min(last, na.rm = TRUE), dec_max = max(last, na.rm = TRUE))
}

cat("=== T1a: KELAS & JUMLAH DIGIT ===\n")
for (nm in c("pdrb", "produksi_padi")) {
  s <- if (nm == "pdrb") pdrb_str else pdp_str
  tb <- table(classify(s))
  cat(sprintf("\n%s:\n", nm))
  for (k in c("a", "b", "c", "d")) cat(sprintf("  kelas %s: %d\n", k, ifelse(k %in% names(tb), tb[[k]], 0L)))
  ds <- digit_stats(s)
  cat(sprintf("  digit sebelum pemisah pertama: min=%d max=%d\n", ds$int_min, ds$int_max))
  cat(sprintf("  digit sesudah pemisah terakhir : min=%d max=%d\n", ds$dec_min, ds$dec_max))
}

cat("\n=== T1b: SEMUA 105 RAW STRING pdrb ===\n")
for (i in seq_along(pdrb_str)) {
  cat(sprintf("%s ", pdrb_str[i]))
  if (i %% 12 == 0) cat("\n")
}
cat("\nJumlah unik:", length(unique(pdrb_str)), "\n")
cat("Nilai unik pdrb (sorted):\n")
print(sort(unique(pdrb_str)))

cat("\n=== T1c: JEJAK 3 SEL pdrb (raw -> aturan pemisah -> x1000 -> tersimpan) ===\n")
for (i in c(1, 50, 29)) {
  s <- pdrb_str[i]; after <- as.numeric(s); stored <- clean$pdrb[i]
  cat(sprintf("baris %d %s %d | raw='%s' -> aturan='%s' -> x1000=%s -> CSV=%s\n",
              i, clean$kabupaten[i], clean$tahun[i], s, after, after * 1000, stored))
}

cat("\n=== T1d: SIMULASI sel pdrb '15759' (tanpa titik) ===\n")
if (FALSE) {}
parse_id_old <- function(s) {
  s <- gsub("[^0-9.,-]", "", s)
  if (!nzchar(s)) return(NA_real_)
  nd <- gregexpr("\\.", s)[[1]]; nd <- if (nd[1] == -1) integer(0) else nd
  nc <- gregexpr(",", s)[[1]];  nc <- if (nc[1] == -1) integer(0) else nc
  last_dot <- if (length(nd)) max(nd) else -1
  last_com <- if (length(nc)) max(nc) else -1
  if (last_com > last_dot) {
    s <- gsub("\\.", "", s)
    pos <- gregexpr(",", s)[[1]]
    if (length(pos) > 1) { last <- max(pos)
      s <- paste0(gsub(",", "", substr(s, 1, last - 1)), ".", substr(s, last + 1, nchar(s)))
    } else s <- sub(",", ".", s, fixed = TRUE)
  } else {
    pos <- gregexpr("\\.", s)[[1]]
    if (length(pos) > 1) { last <- max(pos)
      s <- paste0(gsub("\\.", "", substr(s, 1, last - 1)), ".", substr(s, last + 1, nchar(s)))
    }
  }
  as.numeric(s)
}
cat(sprintf("parser LAMA: parse_id('15759')=%s -> x1000 = %s (seharusnya 15759) -> galat %sx\n",
            parse_id_old("15759"), parse_id_old("15759") * 1000, parse_id_old("15759") * 1000 / 15759))

robust_parse <- function(s) {
  s <- gsub("[^0-9.,-]", "", s)
  if (!nzchar(s)) return(NA_real_)
  nd <- nsep(s, "."); nc <- nsep(s, ",")
  split_dec <- function(x, ch) {
    pos <- gregexpr(ch, x, fixed = TRUE)[[1]]; last <- max(pos)
    paste0(gsub(ch, "", substr(x, 1, last - 1), fixed = TRUE), ".", substr(x, last + 1, nchar(x)))
  }
  if (nd > 0 && nc > 0) {
    ld <- max(gregexpr("\\.", s)[[1]]); lc <- max(gregexpr(",", s)[[1]])
    if (lc > ld) return(as.numeric(split_dec(gsub("\\.", "", s), ",")))
    return(as.numeric(split_dec(gsub(",", "", s), ".")))
  }
  if (nc > 0) {
    if (nc > 1) return(as.numeric(split_dec(s, ",")))
    return(as.numeric(sub(",", ".", s, fixed = TRUE)))
  }
  if (nd == 1) {
    dotpos <- as.integer(gregexpr("\\.", s)[[1]]); da <- nchar(s) - dotpos
    if (da == 3 && dotpos > 1) return(as.numeric(gsub("\\.", "", s)))
    return(as.numeric(s))
  }
  if (nd > 1) return(as.numeric(split_dec(s, ".")))
  as.numeric(s)
}
parse_pdrb_robust <- function(s) {
  s2 <- gsub("[^0-9.,-]", "", s)
  nd <- nsep(s2, "."); nc <- nsep(s2, ",")
  if (nd + nc == 0) return(as.numeric(s2))
  if (nd == 1 && nc == 0) {
    dotpos <- as.integer(gregexpr("\\.", s2)[[1]]); da <- nchar(s2) - dotpos
    if (da == 3 && dotpos > 1) return(as.numeric(gsub("\\.", "", s2)))
    return(as.numeric(s2) * 1000)
  }
  robust_parse(s2) * 1000
}
cat(sprintf("parser BARU (digit-based): parse_pdrb('15759')=%s ; parse_pdrb('15.759')=%s ; parse_pdrb('16.44')=%s\n",
            parse_pdrb_robust("15759"), parse_pdrb_robust("15.759"), parse_pdrb_robust("16.44")))

cat("\n=== T1d2: APAKAH parser BARU mereproduksi nilai LAMA untuk SEMUA 105 sel? ===\n")
rob_pdrb <- sapply(pdrb_str, parse_pdrb_robust)
rob_pdp  <- sapply(pdp_str, robust_parse)
rob_ikp  <- sapply(trimws(f[, 4]), robust_parse)
rob_ipm  <- sapply(trimws(f[, 6]), robust_parse)
rob_kem  <- sapply(trimws(f[, 7]), robust_parse)
cat("pdrb identik   :", isTRUE(all.equal(as.numeric(rob_pdrb), clean$pdrb)), "\n")
cat("padi identik   :", isTRUE(all.equal(as.numeric(rob_pdp), clean$produksi_padi)), "\n")
cat("ikp identik    :", isTRUE(all.equal(as.numeric(rob_ikp), clean$ikp)), "\n")
cat("ipm identik    :", isTRUE(all.equal(as.numeric(rob_ipm), clean$ipm)), "\n")
cat("kemiskinan sama:", isTRUE(all.equal(as.numeric(rob_kem), clean$kemiskinan)), "\n")

cat("\n=== T2a: sanity 5x median per kabupaten ===\n")
flag <- data.frame()
for (k in unique(clean$kode)) {
  d <- clean[clean$kode == k, ]
  for (v in c("produksi_padi", "pdrb")) {
    med <- median(d[[v]]); ratio <- d[[v]] / med
    hit <- which(ratio > 5 | ratio < 1/5)
    if (length(hit)) flag <- rbind(flag, data.frame(kab = d$kabupaten[hit], tahun = d$tahun[hit],
      var = v, nilai = d[[v]][hit], median = med, rasio = round(ratio[hit], 2)))
  }
}
if (nrow(flag) == 0) cat("TIDAK ADA nilai di luar 5x median.\n") else print(flag, row.names = FALSE)

cat("\n=== T2b: seri lengkap Kota Metro & Kota Bandar Lampung ===\n")
for (k in c(1872, 1871)) {
  d <- clean[clean$kode == k, c("kabupaten", "tahun", "pdrb", "produksi_padi")]
  cat("\n"); print(d, row.names = FALSE)
  cat(sprintf("  pdrb: min=%s max=%s rasio=%.1fx | padi: min=%s max=%s rasio=%.1fx\n",
      min(d$pdrb), max(d$pdrb), max(d$pdrb)/min(d$pdrb),
      min(d$produksi_padi), max(d$produksi_padi), max(d$produksi_padi)/min(d$produksi_padi)))
}

cat("\n=== T2c: nilai MINIMUM produksi_padi + raw mentah ===\n")
i <- which.min(clean$produksi_padi)
cat(sprintf("kabupaten=%s tahun=%d nilai=%s\n", clean$kabupaten[i], clean$tahun[i], clean$produksi_padi[i]))
cat("RAW:", dl[i], "\n")

cat("\n=== T3: TOTAL PROVINSI PER TAHUN ===\n")
tot <- aggregate(cbind(produksi_padi, pdrb) ~ tahun, data = clean, FUN = sum)
tot$produksi_padi <- round(tot$produksi_padi, 2)
tot$pdrb <- round(tot$pdrb, 0)
print(tot, row.names = FALSE)
