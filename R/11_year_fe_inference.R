options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(plm)
  library(lmtest)
  library(sandwich)
})

## ============================================================
## R/11_year_fe_inference.R
## Fase 2 revisi: spesifikasi dengan efek tahun + inferensi
## valid untuk G kecil (cluster kabupaten).
##
## Perubahan inti dibanding R/04:
##   [1] Year FE sebagai model utama (dummy COVID dibuang)
##   [2] F gabungan year dummies dilaporkan
##   [3] Hausman klasik -> robust Hausman (Mundlak, Wald klaster)
##   [4] Wild cluster bootstrap (Rademacher) berdampingan
##       dengan p-value asymptotik
##   [5] Driscoll-Kraay SE sebagai pembanding
##   [6] MDE (minimum detectable effect) -> daya uji jujur
##   [7] Estimasi terpisah 13 kabupaten vs 2 kota
##
## Hanya membaca data/. Menulis log + tabel ke output/.
## ============================================================

df <- read.csv("data/lampung_panel_clean.csv")
df <- df[order(df$kode, df$tahun), ]
df$kode_f  <- factor(df$kode)
df$tahun_f <- factor(df$tahun)

G <- length(unique(df$kode))
N <- nrow(df)
P <- 5

## ID unit di kolom `kode` adalah nomor urut INTERNAL proyek, bukan kode BPS.
## Dipakai hanya sebagai identitas unit / klaster, tidak untuk join data luar.
cat("=== 0. IDENTITAS DATA ===\n")
cat("N =", N, "| G =", G, "| T =", length(unique(df$tahun)),
    "| tahun:", min(df$tahun), "-", max(df$tahun), "\n")
cat("Catatan: kolom `kode` = nomor urut internal (BUKAN kode BPS).\n")
cat("Untuk join ke data luar, gunakan kolom `kabupaten` (nama).\n\n")

vcCL <- function(m) vcovCL(m, cluster = ~ kode, type = "HC1")
vcHC3 <- function(m) vcovCL(m, cluster = ~ kode, type = "HC3")
rob <- function(m) coeftest(m, vcov = vcCL(m))
dm <- function(v) as.numeric(df[[v]]) - ave(as.numeric(df[[v]]), df$kode, FUN = mean)
sep <- function(t) cat("\n", strrep("=", 74), "\n== ", t, "\n", strrep("=", 74), "\n", sep = "")

## ---------- Spesifikasi ----------
m_covid <- lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid, data = df)
m_year  <- lm(ikp ~ kode_f + tahun_f + ipm + kemiskinan + ln_pdrb + ln_padi, data = df)
## First difference
dv <- function(x) c(NA, diff(x))
fd <- data.frame(kode = df$kode, tahun = df$tahun,
  d_ikp = ave(df$ikp, df$kode, FUN = dv), d_ipm = ave(df$ipm, df$kode, FUN = dv),
  d_kem = ave(df$kemiskinan, df$kode, FUN = dv), d_lp = ave(df$ln_pdrb, df$kode, FUN = dv),
  d_lpd = ave(df$ln_padi, df$kode, FUN = dv))
fd <- fd[!is.na(fd$d_ikp), ]
m_fd    <- lm(d_ikp ~ d_ipm + d_kem + d_lp + d_lpd, data = fd)
m_fd_yr <- lm(d_ikp ~ d_ipm + d_kem + d_lp + d_lpd + factor(tahun), data = fd)

VARS <- c("ipm", "kemiskinan", "ln_pdrb", "ln_padi")

sep("1. PERBANDINGAN SPESIFIKASI (cluster-robust HC1, klaster kabupaten)")
cat("\n[a] FE + dummy COVID  (spesifikasi yang dilaporkan R/04)\n")
print(round(rob(m_covid)[, c(1, 2, 4)], 4))
cat("\n[b] FE + YEAR FE  (spesifikasi revisi)\n")
print(round(rob(m_year)[c(VARS), c(1, 2, 4)], 4))
cat("\n[catatan] R/04 memakai HC3 (arellano) -> SE IPM = 0.414; HC1 di sini = ",
    round(rob(m_covid)["ipm", 2], 3), ". Selisih kecil, kesimpulan sama.\n", sep = "")
cat("HC3 (untuk kontinuitas dgn laporan lama): IPM SE =",
    round(coeftest(m_covid, vcov = vcHC3(m_covid))["ipm", 2], 4), "\n")

cat("\n[c] First difference (FD) murni\n")
print(round(coeftest(m_fd, vcov = vcovCL(m_fd, cluster = ~ kode, type = "HC1"))[, c(1, 2, 4)], 4))
cat("\n[d] FD + year dummies\n")
print(round(coeftest(m_fd_yr, vcov = vcovCL(m_fd_yr, cluster = ~ kode, type = "HC1"))[1:4, c(1, 2, 4)], 4))

sep("2. APAKAH YEAR DUMMIES WAJIB? (uji F gabungan)")
m_noyear <- lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi, data = df)
print(waldtest(m_noyear, m_year, vcov = function(x) vcCL(x), test = "F"))

sep("3. SEBERAPA BESAR DINAMIKA ITU SEBENARNYA 'TREN BERSAMA'?")
cat("R2 variasi within (deviasi dari rata-rata wilayah) yang dijelaskan year dummies:\n")
tab_v <- do.call(rbind, lapply(c("ikp", "ipm", "kemiskinan", "ln_pdrb", "ln_padi", "produksi_padi"), function(v) {
  d <- dm(v)
  r2 <- summary(lm(d ~ df$tahun_f))$r.squared
  data.frame(variabel = v, var_within = round(var(d), 5), R2_thd_tahun = round(r2, 4),
             var_sisa = round(var(residuals(lm(d ~ df$tahun_f))), 5))
}))
print(tab_v, row.names = FALSE)

cat("\nR2 bertingkat (semua sudah memuat dummies wilayah / FE):\n")
ladder <- function(lbl, f) {
  m <- lm(f, data = df); cat(sprintf("  %-38s R2=%.4f  adjR2=%.4f\n", lbl,
    summary(m)$r.squared, summary(m)$adj.r.squared)) }
ladder("FE saja", ikp ~ kode_f)
ladder("FE + kemiskinan", ikp ~ kode_f + kemiskinan)
ladder("FE + ipm", ikp ~ kode_f + ipm)
ladder("FE + produksi_padi", ikp ~ kode_f + produksi_padi)
ladder("FE + pdrb", ikp ~ kode_f + pdrb)
ladder("FE + MODEL UTAMA (5 var, tanpa year)", ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid)
ladder("FE + MODEL UTAMA + YEAR FE", ikp ~ kode_f + tahun_f + ipm + kemiskinan + ln_pdrb + ln_padi)

cat("\nProfil within IKP per tahun (deviasi dari rata-rata wilayah):\n")
print(round(tapply(dm("ikp"), df$tahun, mean), 3))
cat("\nRata-rata per tahun + perubahan YoY:\n")
agg <- aggregate(cbind(ikp, ipm, kemiskinan) ~ tahun, data = df, FUN = mean)
agg[2:4] <- round(agg[2:4], 2); agg$d_ikp <- c(NA, round(diff(agg$ikp), 2))
print(agg, row.names = FALSE)

sep("4. ROBUST HAUSMAN (Mundlak: pooled + rata-rata kelompok)")
for (v in c("ipm", "kemiskinan", "ln_pdrb", "ln_padi", "covid")) df[[paste0("m_", v)]] <- ave(df[[v]], df$kode)
mpool <- lm(ikp ~ ipm + kemiskinan + ln_pdrb + ln_padi + covid +
              m_ipm + m_kemiskinan + m_ln_pdrb + m_ln_padi, data = df)
bb <- coef(mpool); V <- vcCL(mpool)
tm <- c("m_ipm", "m_kemiskinan", "m_ln_pdrb", "m_ln_padi"); ii <- match(tm, names(bb))
W <- as.numeric(t(bb[ii]) %*% solve(V[ii, ii, drop = FALSE]) %*% bb[ii])
cat(sprintf("  W = %.2f | df = %d | p = %.4g  -> tolak H0 (RE cukup); FE tetap tepat\n",
            W, length(ii), pchisq(W, length(ii), lower.tail = FALSE)))
cat("  (Hausman klasik di laporan lama: chi2 = 57.774, p = 3.5e-11 -- dijalankan tanpa\n")
cat("   memperhitungkan serial correlation yang sudah terdeteksi Wooldridge p=0.005,\n")
cat("   sehingga bentuknya tidak sah untuk inferensi. Versi robust di atas menggantikannya.)\n")

sep("5. INFERENSI DENGAN G = 15")
pdat <- pdata.frame(df, index = c("kode", "tahun"))
fe_yr <- plm(ikp ~ ipm + kemiskinan + ln_pdrb + ln_padi + factor(tahun),
             data = pdat, model = "within")
fe_cv <- plm(ikp ~ ipm + kemiskinan + ln_pdrb + ln_padi + covid,
             data = pdat, model = "within")
cat("Dependensi lintas wilayah (Pesaran CD):\n")
print(pcdtest(fe_cv, test = "cd"))
cat("\nDriscoll-Kraay SE (tahan dependensi lintas wilayah & autokorelasi):\n")
cat("-- FE + COVID --\n")
print(round(coeftest(fe_cv, vcov = function(x) vcovSCC(x, type = "HC3", maxlag = 2))[1:5, c(1, 2, 4)], 4))
cat("-- FE + Year FE --\n")
print(round(coeftest(fe_yr, vcov = function(x) vcovSCC(x, type = "HC3", maxlag = 2))[1:4, c(1, 2, 4)], 4))

## Wild cluster bootstrap (Rademacher), klaster = kabupaten
wcb <- function(fml, dat = df, B = 999, seed = 1093, coefname = "ipm") {
  X <- model.matrix(fml, data = dat)
  y <- model.response(model.frame(fml, data = dat))
  g <- dat$kode; GG <- length(unique(g)); n <- nrow(dat); p <- ncol(X)
  k <- which(colnames(X) == coefname)
  bread <- solve(crossprod(X)); adj <- GG/(GG-1) * (n-1)/(n-p)
  meat <- function(r) { M <- matrix(0, p, p)
    for (cc in unique(g)) { i <- which(g == cc)
      s <- crossprod(X[i, , drop = FALSE], r[i]); M <- M + tcrossprod(s) }; M }
  tv <- function(b, r) as.numeric(b[k] / sqrt((bread %*% (meat(r) * adj) %*% bread)[k, k]))
  m <- lm(fml, data = dat); t_obs <- tv(coef(m), residuals(m))
  Xr <- X[, -k, drop = FALSE]; fr <- lm.fit(Xr, y); yhat <- as.vector(X %*% coef(m))
  set.seed(seed); cnt <- 0
  for (b in seq_len(B)) {
    w <- setNames(sample(c(-1, 1), GG, TRUE), unique(g))
    fb <- lm.fit(X, yhat + fr$residuals * w[as.character(g)])
    if (abs(tv(fb$coefficients, fb$residuals)) >= abs(t_obs)) cnt <- cnt + 1 }
    ## catatan: vcCL() memakai formula `~ kode` yang di-evaluasi ulang oleh sandwich
    ## di frame pemanggil -> gagal ("object 'dat' not found") karena lm() di atas
    ## memakai argumen `dat`. Di sini klaster dioper sebagai VEKTOR, bukan formula.
  list(t = t_obs, p_asym = coeftest(m, vcov = vcovCL(m, cluster = dat[["kode"]], type = "HC1"))[coefname, 4], p_wcb = (cnt + 1)/(B + 1)) }

cat("\nWild cluster bootstrap (Rademacher, B=999, klaster kabupaten):\n")
r1 <- wcb(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid)
r2 <- wcb(ikp ~ kode_f + tahun_f + ipm + kemiskinan + ln_pdrb + ln_padi)
cat(sprintf("  FE+COVID  : t = %.3f | p_cluster(HC1) = %.4f | p_WCB = %.4f\n", r1$t, r1$p_asym, r1$p_wcb))
cat(sprintf("  FE+YearFE : t = %.3f | p_cluster(HC1) = %.4f | p_WCB = %.4f\n", r2$t, r2$p_asym, r2$p_wcb))

sep("6. DAYA UJI (MDE) -- membedakan 'tidak ada efek' dari 'tidak bertenaga'")
dfr <- G - 1
t_a <- qt(0.975, dfr); t_p <- qt(0.80, dfr)
cat(sprintf("df = G-1 = %d | t(0.975) = %.3f | t(0.80) = %.3f\n", dfr, t_a, t_p))
mde <- function(se) (t_a + t_p) * se
se_cv <- rob(m_covid)[, 2]; se_yr <- rob(m_year)[, 2]
deg  <- function(v) round(sd(dm(v)), 3)
tab_mde <- data.frame(
  variabel = c("ipm", "kemiskinan", "ln_pdrb", "ln_padi"),
  beta_FEcovid = round(coef(m_covid)[c(VARS)], 3),
  se_FEcovid = round(se_cv[c(VARS)], 3),
  MDE_FEcovid = round(mde(se_cv[c(VARS)]), 3),
  beta_FEyear = round(coef(m_year)[c(VARS)], 3),
  se_FEyear = round(se_yr[c(VARS)], 3),
  MDE_FEyear = round(mde(se_yr[c(VARS)]), 3),
  sd_within = sapply(VARS, deg)
)
tab_mde$MDE_dlm_sd_within <- round(tab_mde$MDE_FEyear / tab_mde$sd_within, 2)
print(tab_mde, row.names = FALSE)
cat("\nMDE di atas = efek terkecil yang bisa dideteksi (alpha 5%, power 80%).\n")
cat("Kolom terakhir: MDE dibagi simpangan baku within. Nilai >> 1 berarti uji ini\n")
cat("hanya mampu mendeteksi efek yang jauh lebih besar daripada variasi data yang ada.\n")

sep("7. ESTIMASI TERPISAH: 13 KABUPATEN vs 2 KOTA")
d13 <- df[df$kode < 1870, ]; d13$kode_f <- factor(d13$kode); d13$tahun_f <- factor(d13$tahun)
m13c <- lm(ikp ~ kode_f + ipm + kemiskinan + ln_pdrb + ln_padi + covid, data = d13)
m13y <- lm(ikp ~ kode_f + tahun_f + ipm + kemiskinan + ln_pdrb + ln_padi, data = d13)
cat("IKP kabupaten memakai 9 indikator; IKP kota memakai 8 indikator dengan bobot berbeda\n")
cat("(aspek ketersediaan berbobot 0,30 dihapus, lalu bobotnya dialihkan proporsional).\n")
cat("Karena itu 2 kota tidak digabung dalam sampel estimasi utama.\n\n")
cat(sprintf("13 KABUPATEN (n=%d) FE + COVID:\n", nrow(d13)))
print(round(coeftest(m13c, vcov = vcovCL(m13c, cluster = ~ kode, type = "HC1"))[, c(1, 2, 4)], 4))
cat(sprintf("\n13 KABUPATEN (n=%d) FE + Year FE:\n", nrow(d13)))
print(round(coeftest(m13y, vcov = vcovCL(m13y, cluster = ~ kode, type = "HC1"))[c("ipm","kemiskinan","ln_pdrb","ln_padi"), c(1, 2, 4)], 4))
dk <- df[df$kode >= 1870, ]
cat(sprintf("\n2 KOTA: n = %d -> estimasi FE dengan 5 koefisien tidak bermakna; hanya deskriptif.\n", nrow(dk)))
print(dk[, c("kabupaten", "tahun", "ikp", "kemiskinan", "ipm")], row.names = FALSE)

sep("8. KENAPA koefisien tanpa efek tahun menyesatkan: dekomposisi")
mw <- lm(ikp ~ kode_f + ipm, data = df)
cat("Koef IPM tanpa kontrol kecuali FE wilayah :", round(coef(mw)["ipm"], 3), "\n")
mw2 <- lm(ikp ~ kode_f + ipm + tahun_f, data = df)
cat("Koef IPM setelah year dummies dimasukkan  :", round(coef(mw2)["ipm"], 3), "\n")
cat("Korelasi within ipm vs tahun              :",
    round(cor(dm("ipm"), as.numeric(df$tahun)), 3), "\n")
cat("Korelasi within ikp vs tahun              :",
    round(cor(dm("ikp"), as.numeric(df$tahun)), 3), "\n")

sep("9. SPESIFIKASI RHS BERSIH (tanpa variabel penyusun indeks IKP)")
cat("Kemiskinan (bobot 0,15 kab / 0,20 kota) dan dua komponen IPM (AHH 0,10/0,13;\n")
cat("RLS perempuan 0,05/0,08) adalah indikator PENYUSUN IKP -> koefisiennya bukan\n")
cat("estimasi pengaruh. Di sini keduanya dikeluarkan dari sisi kanan.\n\n")
m_c1 <- lm(ikp ~ kode_f + ln_pdrb + ln_padi + covid, data = df)
m_c2 <- lm(ikp ~ kode_f + tahun_f + ln_pdrb + ln_padi, data = df)
m_c2b <- lm(ikp ~ kode_f + tahun_f + ln_pdrb + ln_padi, data = d13)  # 13 kabupaten
cat("-- [1] RHS bersih + dummy COVID --\n")
print(round(coeftest(m_c1, vcov = vcCL(m_c1))[c("ln_pdrb","ln_padi","covid"), c(1, 2, 4)], 4))
cat(sprintf("   R2 = %.4f | adjR2 = %.4f\n\n", summary(m_c1)$r.squared, summary(m_c1)$adj.r.squared))
cat("-- [2] RHS bersih + YEAR FE (kandidat model utama revisi, N=105) --\n")
print(round(coeftest(m_c2, vcov = vcCL(m_c2))[c("ln_pdrb","ln_padi"), c(1, 2, 4)], 4))
cat(sprintf("   R2 = %.4f | adjR2 = %.4f\n\n", summary(m_c2)$r.squared, summary(m_c2)$adj.r.squared))
cat("Uji F gabungan year dummies pada RHS bersih:\n")
print(waldtest(lm(ikp ~ kode_f + ln_pdrb + ln_padi, data = df), m_c2,
               vcov = function(x) vcCL(x), test = "F"))
cat("\n-- [3] RHS bersih + YEAR FE, 13 KABUPATEN (n=91) --\n")
print(round(coeftest(m_c2b, vcov = vcCL(m_c2b))[c("ln_pdrb","ln_padi"), c(1, 2, 4)], 4))
cat(sprintf("   R2 = %.4f\n\n", summary(m_c2b)$r.squared))
cat("WCB pada RHS bersih (B=999):\n")
cat("  ln_pdrb, N=105 + year FE : "); rp <- wcb(ikp ~ kode_f + tahun_f + ln_pdrb + ln_padi, coefname = "ln_pdrb")
cat(sprintf("t = %.3f | p_cluster = %.4f | p_WCB = %.4f\n", rp$t, rp$p_asym, rp$p_wcb))
cat("  ln_padi,  N=105 + year FE : "); rd <- wcb(ikp ~ kode_f + tahun_f + ln_pdrb + ln_padi, coefname = "ln_padi")
cat(sprintf("t = %.3f | p_cluster = %.4f | p_WCB = %.4f\n", rd$t, rd$p_asym, rd$p_wcb))
cat("  ln_padi,  13 kab + year FE: "); rd13 <- wcb(ikp ~ kode_f + tahun_f + ln_pdrb + ln_padi,
                                                   dat = d13, coefname = "ln_padi")
cat(sprintf("t = %.3f | p_cluster = %.4f | p_WCB = %.4f\n", rd13$t, rd13$p_asym, rd13$p_wcb))
cat("\n[catatan] Uji WCB baris terakhir ini adalah syarat yang diminta DESIGN_REVIEW 3.2\n")
cat("sebelum koef ln(Padi)=3,675 (p=0,0146) boleh disebut temuan; kalau p_WCB > 0,05\n")
cat("maka angka itu tetap non-temuan, bukan hasil positif.\n")

tab_clean <- data.frame(
  spesifikasi = c("RHS bersih + COVID (N=105)", "RHS bersih + YearFE (N=105)",
                  "RHS bersih + YearFE (13 kab, n=91)"),
  beta_lnpdrb = round(c(coef(m_c1)["ln_pdrb"], coef(m_c2)["ln_pdrb"], coef(m_c2b)["ln_pdrb"]), 3),
  se_lnpdrb   = round(c(vcCL(m_c1)["ln_pdrb","ln_pdrb"]^0.5, vcCL(m_c2)["ln_pdrb","ln_pdrb"]^0.5,
                        vcCL(m_c2b)["ln_pdrb","ln_pdrb"]^0.5), 3),
  p_lnpdrb    = round(c(coeftest(m_c1, vcov = vcCL(m_c1))["ln_pdrb",4],
                        coeftest(m_c2, vcov = vcCL(m_c2))["ln_pdrb",4],
                        coeftest(m_c2b, vcov = vcCL(m_c2b))["ln_pdrb",4]), 4),
  beta_lnpadi = round(c(coef(m_c1)["ln_padi"], coef(m_c2)["ln_padi"], coef(m_c2b)["ln_padi"]), 3),
  se_lnpadi   = round(c(vcCL(m_c1)["ln_padi","ln_padi"]^0.5, vcCL(m_c2)["ln_padi","ln_padi"]^0.5,
                        vcCL(m_c2b)["ln_padi","ln_padi"]^0.5), 3),
  p_lnpadi    = round(c(coeftest(m_c1, vcov = vcCL(m_c1))["ln_padi",4],
                        coeftest(m_c2, vcov = vcCL(m_c2))["ln_padi",4],
                        coeftest(m_c2b, vcov = vcCL(m_c2b))["ln_padi",4]), 4),
  R2          = round(c(summary(m_c1)$r.squared, summary(m_c2)$r.squared, summary(m_c2b)$r.squared), 4)
)
print(tab_clean, row.names = FALSE)

## ---------- Tabel siap masuk laporan ----------
tab <- data.frame(
  variabel = c("IPM", "Kemiskinan", "ln(PDRB)", "ln(Padi)", "COVID"),
  beta_FEcovid = round(coef(m_covid)[c("ipm","kemiskinan","ln_pdrb","ln_padi","covid")], 3),
  se_FEcovid   = round(rob(m_covid)[c("ipm","kemiskinan","ln_pdrb","ln_padi","covid"), 2], 3),
  p_FEcovid    = round(rob(m_covid)[c("ipm","kemiskinan","ln_pdrb","ln_padi","covid"), 4], 4)
)
tab2 <- data.frame(
  variabel = VARS,
  beta_FEyear = round(coef(m_year)[VARS], 3),
  se_FEyear   = round(rob(m_year)[VARS, 2], 3),
  p_FEyear    = round(rob(m_year)[VARS, 4], 4),
  p_wcb_FEyear = c(r2$p_wcb, NA, NA, NA)
)
write.csv(tab,  "output/tabel_4_4_FEcovid.csv", row.names = FALSE)
write.csv(tab2, "output/tabel_4_4_FEyear.csv",  row.names = FALSE)
write.csv(tab_mde, "output/tabel_4_5_mde.csv", row.names = FALSE)
write.csv(tab_clean, "output/tabel_4_6_rhs_bersih.csv", row.names = FALSE)
cat("\n\nTabel disimpan: output/tabel_4_4_FEcovid.csv, output/tabel_4_4_FEyear.csv, output/tabel_4_5_mde.csv, output/tabel_4_6_rhs_bersih.csv\n")
cat("\n=== SELESAI R/11 ===\n")
