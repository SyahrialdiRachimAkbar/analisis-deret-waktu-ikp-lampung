options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(plm)
  library(lmtest)
  library(sandwich)
})

df <- read.csv("data/lampung_panel_clean.csv")
df <- df[order(df$kode, df$tahun), ]
pdat <- pdata.frame(df, index = c("kode", "tahun"))
fml <- ikp ~ ipm + kemiskinan + ln_pdrb + ln_padi + covid

fe <- plm(fml, data = pdat, model = "within")

cat("=== FE: SE default vs cluster-robust (cluster kabupaten) ===\n")
print(summary(fe)$coefficients)

ct <- coeftest(fe, vcov = function(x)
  vcovHC(x, method = "arellano", type = "HC3", cluster = "group"))
cat("\n=== FE dengan cluster-robust SE ===\n")
print(ct)

cat("\n=== R2 within:", round(summary(fe)$r.squared[1], 4),
    "| R2 adjusted:", round(summary(fe)$r.squared[2], 4), "\n")

cat("\n=== VIF (dihitung manual, data within-demeaned) ===\n")
dm <- function(x, g) as.numeric(x) - ave(as.numeric(x), g, FUN = function(z) mean(z))
X <- data.frame(
  ipm = df$ipm, kemiskinan = df$kemiskinan,
  ln_pdrb = df$ln_pdrb, ln_padi = df$ln_padi, covid = df$covid
)
Xd <- as.data.frame(lapply(X, dm, g = df$kode))
vif_manual <- function(mat) {
  sapply(colnames(mat), function(v) {
    r2 <- summary(lm(mat[, v] ~ . - 1, data = mat[, setdiff(colnames(mat), v), drop = FALSE]))$r.squared
    1 / (1 - r2)
  })
}
print(round(vif_manual(X), 3))
cat("VIF pada data within-demeaned:\n")
print(round(vif_manual(Xd), 3))

cat("\n=== Uji Wooldridge AR(1) (pwartest) ===\n")
print(pwartest(fe))

cat("\n=== Uji heteroskedastisitas Breusch-Pagan (residual within) ===\n")
res <- as.numeric(residuals(fe))
fit <- as.numeric(fitted(fe))
print(bptest(res ~ fit))

cat("\n=== Uji normalitas residual (Shapiro-Wilk) ===\n")
print(shapiro.test(res))

cat("\n=== Ringkasan model (cluster-robust) ===\n")
print(ct)
