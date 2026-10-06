# Apply documented decisions to an analysis copy; never rewrite source inputs.
reconcile_values <- function(panel, province_audit, ledger) {
  required <- c("kabupaten", "tahun", "ikp_asal", "ikp_provinsi", "ikp_analisis", "keputusan", "tingkat_bukti", "url", "lokasi_bukti", "catatan")
  assert(all(required %in% names(ledger)) && !anyNA(ledger[required]), "Catatan rekonsiliasi tidak lengkap.")
  keys <- paste(ledger$kabupaten, ledger$tahun)
  assert(!anyDuplicated(keys), "Keputusan rekonsiliasi duplikat.")
  mismatches <- province_audit[!province_audit$cocok, ]
  assert(setequal(keys, paste(mismatches$kabupaten, mismatches$tahun)), "Seluruh selisih sumber harus memiliki keputusan rekonsiliasi.")
  i <- match(keys, paste(panel$kabupaten, panel$tahun))
  p <- match(keys, paste(province_audit$kabupaten, province_audit$tahun))
  assert(!anyNA(i) && all(abs(panel$ikp[i] - ledger$ikp_asal) < 1e-8), "Nilai asal tidak sesuai catatan koreksi.")
  assert(all(abs(province_audit$ikp_sumber_provinsi[p] - ledger$ikp_provinsi) < 1e-8), "Nilai pembanding berubah; audit ulang sumber.")
  assert(all(ledger$keputusan %in% c("koreksi", "pertahankan")), "Keputusan tidak dikenal.")
  assert(all(is.finite(ledger$ikp_analisis) & ledger$ikp_analisis >= 0 & ledger$ikp_analisis <= 100), "Nilai analisis invalid.")
  corrected <- ledger$keputusan == "koreksi"
  assert(all(ledger$tingkat_bukti[corrected] == "primer_pdf"), "Koreksi memerlukan bukti primer yang diperiksa.")
  assert(all(ledger$ikp_analisis[!corrected] == ledger$ikp_asal[!corrected]), "Keputusan pertahankan mengubah nilai.")
  panel$ikp_asal <- panel$ikp
  panel$dikoreksi <- FALSE
  panel$status_nilai <- "asal_tanpa_selisih_tercatat"
  panel$ikp[i] <- ledger$ikp_analisis
  panel$dikoreksi[i] <- corrected
  panel$status_nilai[i] <- paste(ledger$keputusan, ledger$tingkat_bukti, sep = "_")
  validate_panel(panel)
  panel
}

forecast_sensitivity <- function(predictions) {
  targets <- sort(unique(predictions$tahun_target))
  scenarios <- c(list(semua_target = targets), setNames(lapply(targets, function(t) setdiff(targets, t)), paste0("tanpa_target_", targets)))
  do.call(rbind, lapply(names(scenarios), function(name) {
    result <- forecast_accuracy(predictions[predictions$tipe == "Kota" & predictions$tahun_target %in% scenarios[[name]], ], c("tipe", "metode"))
    data.frame(skenario = name, result, row.names = NULL)
  }))
}

value_sensitivity <- function(original, corrected, province, audit) {
  alternative <- original
  ix <- match(paste(alternative$kabupaten, alternative$tahun), paste(province$kabupaten, province$tahun))
  alternative$ikp[!is.na(ix)] <- province$ikp_sumber_provinsi[ix[!is.na(ix)]]
  scenarios <- list(asli = original, rekonsiliasi = corrected, pembanding_provinsi = alternative)
  do.call(rbind, lapply(names(scenarios), function(name) {
    d <- attach_methodology(scenarios[[name]], audit)
    s <- region_summaries(d)
    early <- s[s$tipe == "Kabupaten" & s$tahun_awal == 2018, ]
    most <- early[which.max(early$sd_perubahan_poin), ]
    spread <- county_dispersion(d)
    city <- forecast_accuracy(backtest(d), c("tipe", "metode"))
    city <- city[city$tipe == "Kota", ]
    data.frame(skenario = name, rata_kabupaten_2020 = spread$rata_ikp[spread$tahun == 2020],
      sd_kabupaten_2020 = spread$sd_ikp[spread$tahun == 2020],
      wilayah_sd_perubahan_tertinggi = most$kabupaten, sd_perubahan_tertinggi = most$sd_perubahan_poin,
      MAE_naive_kota = city$MAE_poin[city$metode == "naive"], MAE_drift_kota = city$MAE_poin[city$metode == "drift"])
  }))
}
