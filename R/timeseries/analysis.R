options(stringsAsFactors = FALSE)

assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

validate_panel <- function(d, years = 2018:2024, n_regions = 15L) {
  assert(all(c("kode", "kabupaten", "tahun", "ikp") %in% names(d)), "Kolom wajib tidak lengkap.")
  assert(!anyNA(d[c("kode", "kabupaten", "tahun", "ikp")]), "Ada NA pada kolom wajib.")
  assert(all(nzchar(trimws(d$kode))) && all(nzchar(trimws(d$kabupaten))), "ID/nama kosong.")
  assert(is.numeric(d$ikp) && all(is.finite(d$ikp)) && all(d$ikp >= 0 & d$ikp <= 100), "IKP harus numerik dan dalam 0-100.")
  assert(!anyDuplicated(paste(d$kode, d$tahun)), "Kunci wilayah-tahun duplikat.")
  assert(length(unique(d$kode)) == n_regions && nrow(d) == n_regions * length(years), "Ukuran panel tidak sesuai.")
  groups <- split(d, d$kode)
  assert(all(vapply(groups, function(x) identical(sort(as.integer(x$tahun)), as.integer(years)), logical(1))), "Tahun per wilayah tidak lengkap.")
  assert(all(vapply(groups, function(x) length(unique(x$kabupaten)) == 1L, logical(1))), "Nama wilayah berubah untuk ID yang sama.")
  assert(length(unique(d$kabupaten)) == n_regions, "Nama wilayah dipakai oleh lebih dari satu ID.")
  invisible(TRUE)
}

read_raw_ikp <- function(path) {
  lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
  lines <- lines[grepl(",20[0-9]{2},", lines)]
  fields <- lapply(lines, function(line) scan(text = line, what = "", sep = ",", quote = '"', quiet = TRUE))
  assert(length(fields) > 0 && all(lengths(fields) == 8L), "Struktur CSV mentah tidak sesuai delapan kolom.")
  f <- do.call(rbind, fields)
  code <- trimws(f[, 1])
  for (i in seq_along(code)) if (!nzchar(code[i]) && i > 1) code[i] <- code[i - 1]
  data.frame(kode = code, kabupaten = trimws(f[, 2]), tahun = as.integer(f[, 3]),
    ikp = as.numeric(sub(",", ".", trimws(f[, 4]), fixed = TRUE)))
}

attach_methodology <- function(d, audit) {
  assert(!anyDuplicated(paste(audit$tipe, audit$tahun)), "Metadata metodologi duplikat.")
  assert(!anyNA(audit$batas_sebelum_tahun), "Status batas metodologi kosong.")
  d <- d[order(d$kode, d$tahun), c("kode", "kabupaten", "tahun", "ikp")]
  d$tipe <- ifelse(grepl("^Kota ", d$kabupaten), "Kota", "Kabupaten")
  idx <- match(paste(d$tipe, d$tahun), paste(audit$tipe, audit$tahun))
  assert(!anyNA(idx), "Metadata metodologi tidak mencakup semua tahun/jenis wilayah.")
  d$batas_metode <- audit$batas_sebelum_tahun[idx]
  d$status_sumber <- audit$status[idx]
  d$segmen <- ave(as.integer(d$batas_metode), d$kode, FUN = function(x) cumsum(x) + 1L)
  d$segmen <- paste(d$tipe, d$segmen, sep = "_")
  d$status_analisis <- "eksploratif_bersyarat"
  rownames(d) <- NULL
  d
}

annual_changes <- function(d) {
  out <- lapply(split(d, d$kode), function(x) {
    x <- x[order(x$tahun), ]
    j <- 2:nrow(x)
    ok <- x$segmen[j] == x$segmen[j - 1]
    changes <- rep(NA_real_, length(j))
    changes[ok] <- x$ikp[j[ok]] - x$ikp[j[ok] - 1]
    data.frame(kode = x$kode[j], kabupaten = x$kabupaten[j], tipe = x$tipe[j],
      tahun = x$tahun[j], segmen = x$segmen[j], perubahan_poin = changes,
      status = ifelse(ok, "eksploratif_bersyarat", "dikecualikan_batas_metode"))
  })
  do.call(rbind, out)
}

region_summaries <- function(d) {
  out <- lapply(split(d, paste(d$kode, d$segmen)), function(x) {
    x <- x[order(x$tahun), ]
    dy <- diff(x$ikp)
    n <- nrow(x)
    data.frame(kode = x$kode[1], kabupaten = x$kabupaten[1], tipe = x$tipe[1],
      segmen = x$segmen[1], tahun_awal = x$tahun[1], tahun_akhir = x$tahun[n],
      n_tahun = n, n_perubahan = length(dy), ikp_awal = x$ikp[1], ikp_akhir = x$ikp[n],
      kenaikan_bersih_poin = if (n > 1) x$ikp[n] - x$ikp[1] else NA_real_,
      rata_perubahan_poin = if (n > 1) mean(dy) else NA_real_,
      sd_perubahan_poin = if (length(dy) > 1) sd(dy) else NA_real_,
      tahun_turun = if (n > 1) sum(dy < 0) else NA_integer_,
      perubahan_min_poin = if (n > 1) min(dy) else NA_real_,
      perubahan_max_poin = if (n > 1) max(dy) else NA_real_,
      status = if (n == 1) "satu_titik_tanpa_tren" else "eksploratif_bersyarat")
  })
  out <- do.call(rbind, out)
  out[order(out$tipe, out$kode, out$tahun_awal), ]
}

county_dispersion <- function(d) {
  d <- d[d$tipe == "Kabupaten", ]
  out <- lapply(split(d, d$tahun), function(x) data.frame(tahun = x$tahun[1],
    segmen = x$segmen[1], n_wilayah = nrow(x), rata_ikp = mean(x$ikp),
    sd_ikp = sd(x$ikp), min_ikp = min(x$ikp), max_ikp = max(x$ikp),
    rentang_ikp = diff(range(x$ikp)), status = "potret_tahunan_bersyarat"))
  out <- do.call(rbind, out)
  out <- out[order(out$tahun), ]
  out$perubahan_sd_poin <- NA_real_
  out$perubahan_rata_poin <- NA_real_
  for (i in 2:nrow(out)) if (out$segmen[i] == out$segmen[i - 1]) {
    out$perubahan_sd_poin[i] <- out$sd_ikp[i] - out$sd_ikp[i - 1]
    out$perubahan_rata_poin[i] <- out$rata_ikp[i] - out$rata_ikp[i - 1]
  }
  out
}

one_step <- function(values, method) {
  assert(length(values) >= 2 && all(is.finite(values)), "Ramalan memerlukan minimal dua nilai valid.")
  last <- tail(values, 1)
  switch(method, naive = last, drift = last + (last - values[1]) / (length(values) - 1),
    stop("Metode tidak dikenal.", call. = FALSE))
}

backtest <- function(d, targets = 2022:2024, min_train = 4L) {
  out <- list()
  for (x in split(d, d$kode)) {
    x <- x[order(x$tahun), ]
    for (target in targets) {
      actual <- x[x$tahun == target, ]
      assert(nrow(actual) == 1L, "Tahun target tidak ditemukan/duplikat.")
      train <- x[x$tahun < target & x$segmen == actual$segmen, ]
      eligible <- nrow(train) >= min_train
      for (method in c("naive", "drift")) {
        pred <- if (eligible) one_step(train$ikp, method) else NA_real_
        out[[length(out) + 1L]] <- data.frame(kode = actual$kode, kabupaten = actual$kabupaten,
          tipe = actual$tipe, segmen = actual$segmen, metode = method,
          tahun_target = target, latihan_awal = if (nrow(train)) min(train$tahun) else NA_integer_,
          latihan_akhir = if (nrow(train)) max(train$tahun) else NA_integer_, n_latihan = nrow(train),
          aktual = actual$ikp, ramalan = pred, error_poin = if (eligible) actual$ikp - pred else NA_real_,
          di_luar_skala = if (eligible) pred < 0 || pred > 100 else NA,
          status = if (eligible) "eksploratif_bersyarat" else "dikecualikan_latihan_segmen_kurang_dari_4")
      }
    }
  }
  do.call(rbind, out)
}

forecast_accuracy <- function(predictions, keys) {
  grouping <- do.call(paste, c(predictions[keys], sep = "|"))
  out <- lapply(split(predictions, grouping), function(x) {
    e <- x$error_poin[is.finite(x$error_poin)]
    cbind(x[1, keys, drop = FALSE], data.frame(n_ramalan = length(e),
      n_tahun_uji = length(unique(x$tahun_target[is.finite(x$error_poin)])),
      MAE_poin = if (length(e)) mean(abs(e)) else NA_real_,
      RMSE_poin = if (length(e)) sqrt(mean(e^2)) else NA_real_,
      status = if (length(e)) "eksploratif_bersyarat" else "tidak_diestimasi"))
  })
  do.call(rbind, out)
}

source_discrepancies <- function(d, province_path) {
  p <- read.csv(province_path, check.names = FALSE, fileEncoding = "UTF-8")
  names_only <- sub("^Kota ", "", d$kabupaten)
  audit <- list()
  for (i in which(d$tahun >= 2019)) {
    idx <- match(names_only[i], p$nama_kabupaten_kota)
    assert(!is.na(idx), "Nama wilayah tidak ditemukan di sumber provinsi.")
    value <- as.numeric(p[idx, as.character(d$tahun[i])])
    assert(is.finite(value), "Nilai sumber provinsi kosong.")
    audit[[length(audit) + 1L]] <- data.frame(kode = d$kode[i], kabupaten = d$kabupaten[i],
      tahun = d$tahun[i], ikp_proyek = d$ikp[i], ikp_sumber_provinsi = value,
      selisih_poin = d$ikp[i] - value, cocok = abs(d$ikp[i] - value) < 1e-8)
  }
  do.call(rbind, audit)
}

sha256 <- function(path) {
  if (.Platform$OS.type == "windows") {
    result <- system2("certutil", c("-hashfile", shQuote(normalizePath(path)), "SHA256"), stdout = TRUE, stderr = TRUE)
    match <- grep("^[a-fA-F0-9]{64}$", trimws(result), value = TRUE)
  } else {
    result <- system2("sha256sum", shQuote(path), stdout = TRUE)
    match <- substr(result, 1, 64)
  }
  assert(length(match) == 1L && grepl("^[a-fA-F0-9]{64}$", match), "SHA256 tidak dapat dihitung.")
  tolower(match)
}
