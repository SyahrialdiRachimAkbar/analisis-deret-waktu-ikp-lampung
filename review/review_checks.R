## review/review_checks.R
## Reproduksi seluruh angka pada DESIGN_REVIEW.md
## Jalankan dari root proyek:  Rscript.exe review/review_checks.R
## TIDAK menulis apa pun ke data/ atau output/. Hanya membaca.
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({library(plm); library(lmtest); library(sandwich)})

df <- read.csv("data/lampung_panel_clean.csv")
df <- df[order(df$kode, df$tahun), ]
df$kode_f <- factor(df$kode); df$tahun_f <- factor(df$tahun)
G <- length(unique(df$kode)); N <- nrow(df)
vc <- function(m) vcovCL(m, cluster = ~ kode, type = "HC1")
cl <- function(m) coeftest(m, vcov = vc(m))
dm <- function(v) as.numeric(df[[v]]) - ave(as.numeric(df[[v]]), df$kode, FUN = mean)
sep <- function(t) cat("\n", strrep("=", 72), "\n== ", t, "\n", strrep("=", 72), "\n", sep = "")

sep("0. IDENTITAS DATA")
cat("N =", N, "| G =", G, "| T =", length(unique(df$tahun)),
    "| range tahun:", min(df$tahun), "-", max(df$tahun), "\n")
cat("NA total:", sum(is.na(df)), "\n")

sep("1. TRACEABILITY: IKP 2018 vs publikasi resmi BKP (9 indikator)")
## Sumber: Badan Ketahanan Pangan (2019) "Indeks Ketahanan Pangan Indonesia 2018",
##         Tabel 4 (Kabupaten) & Tabel 5 (Kota)
resmi <- c("Lampung Barat"=70.76, "Tanggamus"=71.96, "Lampung Selatan"=76.48,
           "Lampung Timur"=77.43, "Lampung Tengah"=75.43, "Lampung Utara"=72.18,
           "Way Kanan"=73.63, "Tulang Bawang"=78.24, "Pesawaran"=72.54,
           "Pringsewu"=78.48, "Mesuji"=80.82, "Tulang Bawang Barat"=80.70,
           "Pesisir Barat"=67.99, "Kota Bandar Lampung"=68.93, "Kota Metro"=65.98)
d18 <- df[df$tahun == 2018, c("kabupaten", "ikp")]
d18$resmi <- resmi[d18$kabupaten]
d18$cocok <- abs(d18$ikp - d18$resmi) < 1e-6
d18$ikp <- round(d18$ikp, 2)
print(d18, row.names = FALSE)
cat("COCOK:", sum(d18$cocok), "dari", nrow(d18), "unit\n")

sep("2. BOBOT INDIKATOR PENYUSUN IKP (dari dokumen resmi)")
cat("IKP KABUPATEN (9 indikator, 3 aspek):\n")
bob_kab <- data.frame(
  indikator = c("Rasio konsumsi normatif vs ketersediaan bersih",
                "Persentase penduduk di bawah garis kemiskinan",
                "RT pengeluaran pangan >65%",
                "RT tanpa akses listrik",
                "Rata-rata lama sekolah perempuan >15 th",
                "RT tanpa akses air bersih",
                "Penduduk per tenaga kesehatan",
                "Prevalensi balita stunting",
                "Angka harapan hidup saat lahir"),
  bobot = c(0.30, 0.15, 0.075, 0.075, 0.05, 0.15, 0.05, 0.05, 0.10),
  tumpang_tindih = c("", "X2 proyek ini", "", "", "komponen IPM", "", "", "", "komponen IPM"))
print(bob_kab, row.names = FALSE)
cat("TOTAL bobot:", sum(bob_kab$bobot), "\n")
cat("\nIKP KOTA (8 indikator, aspek ketersediaan DIHAPUS, bobot 0.30 dialihkan):\n")
cat("  kemiskinan 0.20 | pengeluaran pangan 0.125 | tanpa listrik 0.125\n")
cat("  RLS perempuan 0.08 | tanpa air bersih 0.18 | tenaga kesehatan 0.08\n")
cat("  stunting 0.08 | AHH 0.13  -> total 1.00\n")

sep("3. SEBERAPA BESAR MODEL DIJELASKAN 'MEKANIS' OLEH KOMPONEN INDEKS")
f <- function(lbl, fml) { m <- lm(fml, data = df)
  cat(sprintf("  %-36s R2=%.4f  adjR2=%.4f\n", lbl, summary(m)$r.squared, summary(m)$adj.r.squared)) }
cat("Semua model sudah memuat dummies wilayah (FE), N=105\n")
f("FE saja",                              ikp ~ kode_f)
f("FE + kemiskinan (komponen IKP)",        ikp ~ kode_f + kemiskinan)
f("FE + ipm (komponen via AHH/RLS)",       ikp ~ kode_f + ipm)
f("FE + produksi_padi",                    ikp ~ kode_f + produksi_padi)
f("FE + pdrb",                             ikp ~ kode_f + pdrb)
f("FE + MODEL UTAMA (5 var + covid)",      ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid)
f("FE + MODEL UTAMA + year FE",            ikp ~ kode_f + tahun_f + ipm + kemiskinan + ln_pdrb + ln_padi)
cat("\nSelisih R2: FE->FE+kemiskinan =",
    round(summary(lm(ikp ~ kode_f + kemiskinan, df))$r.squared -
          summary(lm(ikp ~ kode_f, df))$r.squared, 4), "\n")
cat("Selisih R2: (FE+kemiskinan)->(FE+model utama 5 var) =",
    round(summary(lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid, df))$r.squared -
          summary(lm(ikp ~ kode_f + kemiskinan, df))$r.squared, 4), "\n")

sep("4. EFEK TAHUN: seberapa besar dinamika yang sebenarnya 'tren bersama'")
cat("R2 variasi within (deviasi dari rata-rata wilayah) yang dijelaskan year dummies:\n")
for (v in c("ikp", "ipm", "kemiskinan", "ln_pdrb", "ln_padi")) {
  cat(sprintf("  %-11s var(within)=%8.4f | R2 thd tahun=%.4f | var sisa=%9.5f\n",
      v, var(dm(v)), summary(lm(dm(v) ~ df$tahun_f))$r.squared,
      var(residuals(lm(dm(v) ~ df$tahun_f)))))
}
cat("\nProfil within IKP per tahun (deviasi dari rata-rata wilayah):\n")
print(round(tapply(dm("ikp"), df$tahun, mean), 3))
cat("\nRata-rata per tahun + perubahan YoY:\n")
agg <- aggregate(cbind(ikp, ipm, kemiskinan) ~ tahun, data = df, FUN = mean)
agg[2:4] <- round(agg[2:4], 2); agg$d_ikp <- c(NA, round(diff(agg$ikp), 2))
print(agg, row.names = FALSE)

sep("5. UJI F: year dummies wajib? + SPESIFIKASI UTAMA")
m0 <- lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid, data = df)
m1 <- lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi, data = df)
m2 <- lm(ikp ~ kode_f + tahun_f + ipm + kemiskinan + ln_pdrb + ln_padi, data = df)
cat("F gabungan year dummies (FE+tanpa covid vs FE+yearFE):\n")
print(waldtest(m1, m2, vcov = function(x) vc(x), test = "F"))
cat("\nFE + COVID (spesifikasi laporan), cluster-robust:\n")
print(round(cl(m0)[c("ipm","kemiskinan","ln_pdrb","ln_padi","covid"), c(1,2,4)], 4))
cat("\nFE + YEAR FE, cluster-robust:\n")
print(round(cl(m2)[c("ipm","kemiskinan","ln_pdrb","ln_padi"), c(1,2,4)], 4))
cat("\nFirst difference murni:\n")
dv <- function(x) c(NA, diff(x)); g <- df$kode
fd <- data.frame(kode = g, tahun = df$tahun, d_ikp = ave(df$ikp,g,FUN=dv), d_ipm = ave(df$ipm,g,FUN=dv),
                 d_kem = ave(df$kemiskinan,g,FUN=dv), d_lp = ave(df$ln_pdrb,g,FUN=dv), d_lpd = ave(df$ln_padi,g,FUN=dv))
fd <- fd[!is.na(fd$d_ikp), ]
print(round(coeftest(lm(d_ikp ~ d_ipm + d_kem + d_lp + d_lpd, fd),
      vcov = vcovCL(lm(d_ikp ~ d_ipm + d_kem + d_lp + d_lpd, fd), cluster = ~ kode, type = "HC1"))[1:4, c(1,2,4)], 4))
cat("\nFD + year dummies:\n")
mfd2 <- lm(d_ikp ~ d_ipm + d_kem + d_lp + d_lpd + factor(tahun), fd)
print(round(coeftest(mfd2, vcov = vcovCL(mfd2, cluster = ~ kode, type = "HC1"))[1:4, c(1,2,4)], 4))

sep("6. KOTA vs KABUPATEN: IKP-nya definisi berbeda")
j23 <- sapply(split(df, df$kode), function(d) d$ikp[d$tahun==2023] - d$ikp[d$tahun==2022])
k23 <- sapply(split(df, df$kode), function(d) d$kemiskinan[d$tahun==2023] - d$kemiskinan[d$tahun==2022])
cat("Delta 2022->2023:\n")
print(data.frame(kode = names(j23), d_ikp = round(j23,2), d_kemiskinan = round(k23,2)), row.names = FALSE)
cat(sprintf("IKP naik di %d/%d unit | kemiskinan turun di %d/%d unit\n",
    sum(j23>0), length(j23), sum(k23<0), length(k23)))
cat(sprintf("rata-rata delta IKP: kabupaten=%.2f | kota=%.2f\n",
    mean(j23[!names(j23) %in% c("1871","1872")]), mean(j23[c("1871","1872")])))
cat("\nPadi: dokumen BKP menyatakan produksi padi/jagung/ubi memakai ANGKA TETAP 2014-2016.\n")
cat("Bukti data: variasi produksi_padi di dalam wilayah relatif kecil.\n")
cat(sprintf("  var(within) produksi_padi = %.1f | var(within) ikp = %.3f\n",
    var(dm("produksi_padi")), var(dm("ikp"))))

sep("7. INFERENSI DENGAN G=15")
cat("Pesaran CD (dependensi lintas wilayah):\n")
fe0 <- plm(ikp ~ ipm + kemiskinan + ln_pdrb + ln_padi + covid,
           data = pdata.frame(df, index = c("kode","tahun")), model = "within")
print(pcdtest(fe0, test = "cd"))

cat("\nRobust Hausman (Mundlak: pooled + rata-rata kelompok, Wald klaster):\n")
for (v in c("ipm","kemiskinan","ln_pdrb","ln_padi","covid")) df[[paste0("m_",v)]] <- ave(df[[v]], df$kode)
mpool <- lm(ikp ~ ipm + kemiskinan + ln_pdrb + ln_padi + covid +
              m_ipm + m_kemiskinan + m_ln_pdrb + m_ln_padi, data = df)
bb <- coef(mpool); V <- vc(mpool)
tm <- c("m_ipm","m_kemiskinan","m_ln_pdrb","m_ln_padi"); ii <- match(tm, names(bb))
W <- as.numeric(t(bb[ii]) %*% solve(V[ii, ii, drop = FALSE]) %*% bb[ii])
cat(sprintf("  W = %.2f | df = %d | p = %.4g  (H0=RE cukup; tolak -> FE)\n",
    W, length(ii), pchisq(W, length(ii), lower.tail = FALSE)))
cat("  (Hausman klasik pada laporan: chi2 = 57.774, p = 3.5e-11)\n")

cat("\nJackknife per tahun (koef IPM, FE+COVID):\n")
for (y in sort(unique(df$tahun))) {
  d <- df[df$tahun != y, ]; d$kode_f <- factor(d$kode)
  ct <- coeftest(lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid, d),
                 vcov = vcovCL(lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid, d),
                               cluster = ~ kode, type = "HC1"))
  cat(sprintf("  tanpa %d : ipm = %6.3f (SE %.3f, p=%.4f)\n", y, ct["ipm",1], ct["ipm",2], ct["ipm",4]))
}
cat("\nJackknife per kabupaten (koef IPM, FE+COVID):\n")
res <- do.call(rbind, lapply(unique(df$kode), function(k) {
  d <- df[df$kode != k, ]; d$kode_f <- factor(d$kode)
  m <- lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid, d)
  ct <- coeftest(m, vcov = vcovCL(m, cluster = ~ kode, type = "HC1"))
  data.frame(kab = df$kabupaten[df$kode == k][1], ipm = round(ct["ipm",1],3), p = round(ct["ipm",4],4)) }))
res <- res[order(res$ipm), ]; print(res, row.names = FALSE)
cat(sprintf("range koef IPM: %.3f s.d. %.3f | p<0.05 pada %d/%d drop\n",
    min(res$ipm), max(res$ipm), sum(res$p < 0.05), nrow(res)))

cat("\nWild cluster bootstrap (Rademacher, klaster kabupaten, B=999):\n")
wcb <- function(fml, B = 999, seed = 1093) {
  X <- model.matrix(fml, data = df); y <- model.response(model.frame(fml, data = df))
  k <- which(colnames(X) == "ipm"); p <- ncol(X)
  bread <- solve(crossprod(X)); adj <- G/(G-1) * (N-1)/(N-p)
  meat <- function(r) { M <- matrix(0, p, p)
    for (c in unique(df$kode)) { i <- which(df$kode == c)
      s <- crossprod(X[i,,drop=FALSE], r[i]); M <- M + tcrossprod(s) }; M }
  tv <- function(b, r) as.numeric(b[k] / sqrt((bread %*% (meat(r)*adj) %*% bread)[k,k]))
  m <- lm(fml, data = df); t_obs <- tv(coef(m), residuals(m))
  Xr <- X[,-k,drop=FALSE]; fr <- lm.fit(Xr, y); yhat <- as.vector(X %*% coef(m))
  set.seed(seed); cnt <- 0
  for (b in seq_len(B)) {
    w <- setNames(sample(c(-1,1), G, TRUE), unique(df$kode))
    fb <- lm.fit(X, yhat + fr$residuals * w[as.character(df$kode)])
    if (abs(tv(fb$coefficients, fb$residuals)) >= abs(t_obs)) cnt <- cnt + 1 }
  c(p_asym = coeftest(m, vcov = vc(m))["ipm",4], p_wcb = (cnt+1)/(B+1))
}
r1 <- wcb(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid)
cat(sprintf("  FE+COVID  : p_cluster(HC1) = %.4f | p_WCB = %.4f\n", r1["p_asym"], r1["p_wcb"]))
r2 <- wcb(ikp ~ kode_f + tahun_f + ipm + kemiskinan + ln_pdrb + ln_padi)
cat(sprintf("  FE+YearFE : p_cluster(HC1) = %.4f | p_WCB = %.4f\n", r2["p_asym"], r2["p_wcb"]))

sep("8. ESTIMASI TERPISAH: 13 KABUPATEN vs 2 KOTA")
d13 <- df[df$kode < 1870, ]; d13$kode_f <- factor(d13$kode)
m13 <- lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid, data = d13)
cat(sprintf("13 KABUPATEN (n=%d) FE+COVID:\n", nrow(d13)))
print(round(coeftest(m13, vcov = vcovCL(m13, cluster = ~ kode, type = "HC1"))[c("ipm","kemiskinan","ln_pdrb","ln_padi","covid"), c(1,2,4)], 4))
m13y <- lm(ikp ~ kode_f + factor(tahun) + ipm + kemiskinan + ln_pdrb + ln_padi, data = d13)
cat("\n13 KABUPATEN FE+YearFE:\n")
print(round(coeftest(m13y, vcov = vcovCL(m13y, cluster = ~ kode, type = "HC1"))[c("ipm","kemiskinan","ln_pdrb","ln_padi"), c(1,2,4)], 4))
cat("\n2 KOTA: hanya 14 observasi -> FE dengan 5 koefisien + 2 dummies tidak bermakna.\n")
dk <- df[df$kode >= 1870, c("kabupaten","tahun","ikp","kemiskinan","ipm")]
print(dk, row.names = FALSE)

sep("SELESAI")
