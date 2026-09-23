options(stringsAsFactors = FALSE)

cat("=== Q4: FILE INFO (size, mtime, ctime) ===\n")
fi <- file.info(c("R/01_clean_data.R",
                  "data/lampung_panel_clean.csv",
                  "Data Fix - DATA.csv"))
print(fi[, c("size", "mtime", "ctime")])

cat("\n=== Q1/Q5: checksum algoritma BERBEDA dari SATU file yang sama ===\n")
cat("-- MD5 --\n")
print(tools::md5sum(c("data/lampung_panel_clean.csv", "Data Fix - DATA.csv")))
cat("-- SHA256 (via digest bila ada, kalau tidak pakai sha256sum OS) --\n")
sha <- tryCatch({
  if (requireNamespace("digest", quietly = TRUE)) {
    digest::digest("data/lampung_panel_clean.csv", algo = "sha256", file = TRUE)
  } else "paket digest tidak ada"
}, error = function(e) conditionMessage(e))
cat("SHA256 clean CSV:", sha, "\n")

cat("\n=== V1: statistik deskriptif dari file SAAT INI ===\n")
df <- read.csv("data/lampung_panel_clean.csv")
vars <- c("ikp", "ipm", "kemiskinan", "pdrb", "produksi_padi")
tab <- data.frame(
  mean = sapply(df[vars], mean),
  sd   = sapply(df[vars], sd),
  min  = sapply(df[vars], min),
  max  = sapply(df[vars], max)
)
print(round(tab, 3))

cat("\n=== V2: raw vs parsed (validasi tidak ada desimal hilang) ===\n")
raw <- readLines("Data Fix - DATA.csv", encoding = "UTF-8", warn = FALSE)
dl <- grep(",[0-9]{4},", raw, value = TRUE)
cat("Jumlah baris data mentah:", length(dl), "| data.frame:", nrow(df), "\n")
for (i in c(1, 8, 52, 104)) {
  cat("\nRAW baris ke-", i, ":\n  ", dl[i], "\n", sep = "")
  cat("PARSED:\n")
  print(df[i, c("kabupaten", "tahun", "pdrb", "produksi_padi")], row.names = FALSE)
}

cat("\n=== V2b: cari nilai mentah yang mengandung titik berlebih / anomali ===\n")
print(grep("215\\.987\\.34|29\\.992,775|155,711,37|81\\.355,00", dl, value = TRUE))
