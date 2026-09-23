options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(plm)
  library(lmtest)
  library(sandwich)
})

df <- read.csv("data/lampung_panel_clean.csv")
df <- df[order(df$kode, df$tahun), ]
pdat <- pdata.frame(df, index = c("kode", "tahun"))

robust <- function(m) coeftest(m, vcov = function(x)
  vcovHC(x, method = "arellano", type = "HC3", cluster = "group"))

fml_main <- ikp ~ ipm + kemiskinan + ln_pdrb + ln_padi + covid
fml_nocv <- ikp ~ ipm + kemiskinan + ln_pdrb + ln_padi
fml_lag  <- ikp ~ lag(ipm) + lag(kemiskinan) + lag(ln_pdrb) + lag(ln_padi) + covid

m_main <- plm(fml_main, data = pdat, model = "within")
m_nocv <- plm(fml_nocv, data = pdat, model = "within")
m_lag  <- plm(fml_lag,  data = pdat, model = "within")

sub <- pdat[!(pdat$tahun %in% c(2020, 2021)), ]
m_excv <- plm(fml_main, data = sub, model = "within")

cat("=== [1] FE utama (cluster-robust) ===\n"); print(robust(m_main))
cat("\n=== [2] FE tanpa dummy COVID ===\n"); print(robust(m_nocv))
cat("\n=== [3] FE tanpa tahun 2020-2021 (T=5) ===\n"); print(robust(m_excv))
cat("\n=== [4] FE + lagged X (t-1) ===\n"); print(robust(m_lag))

cat("\n=== Perbandingan koefisien (Estimate) ===\n")
allv <- c("ipm", "lag(ipm)", "kemiskinan", "lag(kemiskinan)",
          "ln_pdrb", "lag(ln_pdrb)", "ln_padi", "lag(ln_padi)", "covid")
tab <- sapply(list(main = m_main, no_covid = m_nocv, no_2020 = m_excv, lagged = m_lag),
  function(m) { cf <- coef(m); out <- setNames(rep(NA_real_, length(allv)), allv); out[names(cf)] <- cf; out })
print(round(tab, 3))

cat("\n=== p-value (cluster-robust) ===\n")
ptab <- sapply(list(main = m_main, no_covid = m_nocv, no_2020 = m_excv, lagged = m_lag),
  function(m) { ct <- robust(m); out <- setNames(rep(NA_real_, length(allv)), allv)
    out[rownames(ct)] <- ct[, 4]; out })
print(round(ptab, 4))
