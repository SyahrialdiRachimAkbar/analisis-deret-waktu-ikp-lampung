options(stringsAsFactors = FALSE)
df <- read.csv("data/lampung_panel_clean.csv")

df <- df[order(df$kode, df$tahun), ]
df$ikp_lag <- ave(df$ikp, df$kode, FUN = function(x) c(NA, head(x, -1)))

dat <- df[!is.na(df$ikp_lag), ]

cat("=== Korelasi IKP(t) vs IKP(t-1) ===\n")
cat("Pooled (raw)   :", round(cor(dat$ikp, dat$ikp_lag), 4), "\n")

m_fe <- lm(ikp ~ 0 + factor(kode) + ikp_lag, data = dat)
cat("Within (FE) koef lag:", round(coef(m_fe)["ikp_lag"], 4), "\n")

cat("\n=== Regresi pooled ===\n")
print(summary(lm(ikp ~ ikp_lag, data = dat))$coefficients)

cat("\n=== Regresi within (FE, demean manual) ===\n")
dm <- function(x, g) x - ave(x, g, FUN = function(z) mean(z, na.rm = TRUE))
d_ikp <- dm(dat$ikp, dat$kode)
d_lag <- dm(dat$ikp_lag, dat$kode)
m2 <- lm(d_ikp ~ 0 + d_lag)
print(summary(m2)$coefficients)
cat("Within R2:", round(summary(m2)$r.squared, 4), "\n")

cat("\n=== IKP persisten per wilayah (min/max/mean) ===\n")
print(aggregate(ikp ~ kode, data = df, FUN = function(x)
  c(min = min(x), max = max(x), mean = round(mean(x), 2))))

pdf("output/fase2_ikp_lag.pdf", width = 6, height = 6)
plot(dat$ikp_lag, dat$ikp, pch = 19, col = "steelblue",
     xlab = "IKP(t-1)", ylab = "IKP(t)", main = "Reality Check: Dinamika IKP")
abline(lm(ikp ~ ikp_lag, data = dat), col = "red", lwd = 2)
dev.off()
cat("\nPlot: output/fase2_ikp_lag.pdf\n")
