options(stringsAsFactors = FALSE)
df <- read.csv("data/lampung_panel_clean.csv")

vars <- c("ikp", "ipm", "kemiskinan", "pdrb", "produksi_padi", "ln_pdrb", "ln_padi")
desc <- data.frame(
  Variabel = vars,
  Mean = sapply(df[vars], mean),
  SD = sapply(df[vars], sd),
  Min = sapply(df[vars], min),
  Max = sapply(df[vars], max)
)
desc[-1] <- round(desc[-1], 3)
cat("=== Statistik Deskriptif (N=105) ===\n")
print(desc, row.names = FALSE)

cat("\n=== Rata-rata IKP per Tahun ===\n")
print(round(aggregate(ikp ~ tahun, data = df, FUN = mean), 2))

cat("\n=== Korelasi antar variabel ===\n")
print(round(cor(df[c("ikp", "ipm", "kemiskinan", "ln_pdrb", "ln_padi")]), 3))

cat("\n=== Top & Bottom wilayah (rata-rata IKP 2018-2024) ===\n")
rk <- aggregate(ikp ~ kabupaten, data = df, FUN = mean)
rk <- rk[order(-rk$ikp), ]
rk$ikp <- round(rk$ikp, 2)
print(rk, row.names = FALSE)

pdf("output/fase1_tren_ikp.pdf", width = 8, height = 5)
par(mar = c(4, 4, 3, 1))
plot(NA, xlim = range(df$tahun), ylim = range(df$ikp),
     xlab = "Tahun", ylab = "Indeks Ketahanan Pangan",
     main = "Tren IKP 15 Kabupaten/Kota Provinsi Lampung 2018-2024")
cols <- rainbow(length(unique(df$kode)))
for (i in seq_along(unique(df$kode))) {
  k <- unique(df$kode)[i]
  sub <- df[df$kode == k, ]
  lines(sub$tahun, sub$ikp, col = cols[i], lwd = 1.6)
  points(sub$tahun, sub$ikp, col = cols[i], pch = 19, cex = 0.6)
}
abline(v = c(2020, 2021), lty = 2, col = "gray40")
legend("bottomright", legend = unique(df$kabupaten), col = cols,
       lty = 1, lwd = 1.6, cex = 0.62, ncol = 2, bty = "n")
dev.off()
cat("\nPlot: output/fase1_tren_ikp.pdf\n")
