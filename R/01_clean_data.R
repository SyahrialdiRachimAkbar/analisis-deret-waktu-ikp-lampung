options(stringsAsFactors = FALSE)

raw_path <- "Data Fix - DATA.csv"
out_path <- "data/lampung_panel_clean.csv"

lines <- readLines(raw_path, encoding = "UTF-8", warn = FALSE)

parse_id <- function(s) {
  s <- gsub('"', "", s)
  s <- gsub("[^0-9.,-]", "", s)
  if (!nzchar(s)) return(NA_real_)
  nd <- gregexpr("\\.", s)[[1]]
  nd <- if (nd[1] == -1) integer(0) else nd
  nc <- gregexpr(",", s)[[1]]
  nc <- if (nc[1] == -1) integer(0) else nc
  last_dot <- if (length(nd)) max(nd) else -1
  last_com <- if (length(nc)) max(nc) else -1
  if (last_com > last_dot) {
    s <- gsub("\\.", "", s)
    pos <- gregexpr(",", s)[[1]]
    if (length(pos) > 1) {
      last <- max(pos)
      prefix <- gsub(",", "", substr(s, 1, last - 1))
      suffix <- substr(s, last + 1, nchar(s))
      s <- paste0(prefix, ".", suffix)
    } else {
      s <- sub(",", ".", s, fixed = TRUE)
    }
  } else {
    pos <- gregexpr("\\.", s)[[1]]
    if (length(pos) > 1) {
      last <- max(pos)
      prefix <- gsub("\\.", "", substr(s, 1, last - 1))
      suffix <- substr(s, last + 1, nchar(s))
      s <- paste0(prefix, ".", suffix)
    }
  }
  as.numeric(s)
}

recs <- list()
for (ln in lines) {
  if (!grepl(",[0-9]{4},", ln)) next
  f <- scan(text = ln, what = "", sep = ",", quote = "\"",
            quiet = TRUE, blank.lines.skip = FALSE, encoding = "UTF-8")
  f <- trimws(f)
  if (length(f) < 8) next
  recs[[length(recs) + 1]] <- data.frame(
    kode = f[1],
    kabupaten = f[2],
    tahun = as.integer(f[3]),
    ikp = parse_id(f[4]),
    pdrb = parse_id(f[5]) * 1000,
    ipm = parse_id(f[6]),
    kemiskinan = parse_id(f[7]),
    produksi_padi = parse_id(f[8])
  )
}

df <- do.call(rbind, recs)

run_kode <- NA_character_
for (i in seq_len(nrow(df))) {
  if (!is.na(df$kode[i]) && nzchar(df$kode[i])) {
    run_kode <- df$kode[i]
  }
  df$kode[i] <- run_kode
}

df <- df[order(df$kode, df$tahun), ]
rownames(df) <- NULL

df$ln_pdrb <- log(df$pdrb)
df$ln_padi <- log(df$produksi_padi)
df$covid <- as.integer(df$tahun %in% c(2020, 2021))

write.csv(df, out_path, row.names = FALSE, fileEncoding = "UTF-8")

cat("Baris:", nrow(df), "\n")
cat("Wilayah:", length(unique(df$kode)), "\n")
cat("Tahun:", paste(sort(unique(df$tahun)), collapse = ", "), "\n")
cat("NA ikp:", sum(is.na(df$ikp)), " pdrb:", sum(is.na(df$pdrb)),
    " ipm:", sum(is.na(df$ipm)), " kemiskinan:", sum(is.na(df$kemiskinan)),
    " padi:", sum(is.na(df$produksi_padi)), "\n")
cat("\n")
print(df)
