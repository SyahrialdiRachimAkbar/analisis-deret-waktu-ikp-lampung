options(stringsAsFactors = FALSE)
suppressPackageStartupMessages(library(plm))

df <- read.csv("data/lampung_panel_clean.csv")
df <- df[order(df$kode, df$tahun), ]

pdat <- pdata.frame(df, index = c("kode", "tahun"))
fml <- ikp ~ ipm + kemiskinan + ln_pdrb + ln_padi + covid

pooled <- plm(fml, data = pdat, model = "pooling")
fe     <- plm(fml, data = pdat, model = "within")
re     <- plm(fml, data = pdat, model = "random")

cat("=== POOLED OLS ===\n")
print(summary(pooled)$coefficients)
cat("R2:", round(summary(pooled)$r.squared[1], 4), "\n\n")

cat("=== FIXED EFFECT (within) ===\n")
print(summary(fe)$coefficients)
cat("R2 within:", round(summary(fe)$r.squared[1], 4), "\n\n")

cat("=== RANDOM EFFECT ===\n")
print(summary(re)$coefficients)
cat("R2:", round(summary(re)$r.squared[1], 4), "\n\n")

cat("=== UJI CHOW (FE vs Pooled) ===\n")
print(pFtest(fe, pooled))

cat("\n=== UJI LM BREUSCH-PAGAN (RE vs Pooled) ===\n")
print(plmtest(pooled, type = "bp"))

cat("\n=== UJI HAUSMAN (FE vs RE) ===\n")
print(phtest(fe, re))

cat("\n=== PLM DIAGNOSTIK ===\n")
cat("pFtest / plmtest / phtest di atas\n")
