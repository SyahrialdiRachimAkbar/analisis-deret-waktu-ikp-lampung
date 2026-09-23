options(stringsAsFactors = FALSE)

df <- read.csv("data/lampung_panel_clean.csv")

cat("=== STEP 2: STRUKTUR DATA ===\n")
cat("File: data/lampung_panel_clean.csv\n")
cat("Dimensi: ", nrow(df), " baris x ", ncol(df), " kolom\n\n", sep = "")

cat("=== NAMA & TIPE KOLOM ===\n")
print(data.frame(kolom = names(df), tipe = sapply(df, class), row.names = NULL),
      row.names = FALSE)

cat("\n=== JUMLAH NA PER KOLOM ===\n")
print(sapply(df, function(x) sum(is.na(x))))

cat("\n=== OBSERVASI PER WILAYAH ===\n")
print(table(df$kabupaten))

cat("\n=== OBSERVASI PER TAHUN ===\n")
print(table(df$tahun))

cat("\n=== CEK PANEL SEIMBANG ===\n")
cat("Jumlah wilayah unik :", length(unique(df$kode)), "\n")
cat("Jumlah tahun unik   :", length(unique(df$tahun)), "\n")
cat("Tiap wilayah 7 tahun?:", all(table(df$kode) == 7), "\n")
cat("Total obs = 15 x 7  :", 15 * 7 == nrow(df), " (", nrow(df), " )\n", sep = "")

cat("\n=== KOMBINASI WILAYAH x TAHUN (harus 105 unik) ===\n")
cat("Unik pasangan kode-tahun:", nrow(unique(df[, c("kode", "tahun")])), "\n")

cat("\n=== RINGKASAN STATISTIK ===\n")
print(summary(df[, c("ikp", "ipm", "kemiskinan", "pdrb",
                     "produksi_padi", "ln_pdrb", "ln_padi", "covid")]))

cat("\n=== STRUKTUR OBJEK (str) ===\n")
str(df)

cat("\n=== HEAD & TAIL ===\n")
print(head(df, 3))
print(tail(df, 3))

cat("\n=== CHECKSUM FILE (via tools::md5sum) ===\n")
print(tools::md5sum("data/lampung_panel_clean.csv"))
