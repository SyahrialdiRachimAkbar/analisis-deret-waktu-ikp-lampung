# Meaningful checks for forecast correctness, leakage, methodology boundaries,
# invalid data, and metric arithmetic. Invoked by run.R before exporting files.
run_checks <- function(panel, audit) {
  assert(one_step(rep(70, 4), "naive") == 70, "Naive gagal pada seri konstan.")
  assert(one_step(rep(70, 4), "drift") == 70, "Drift gagal pada seri konstan.")
  assert(one_step(c(60, 62, 64, 66), "drift") == 68, "Drift gagal pada tren tetap.")
  assert(one_step(c(60, 62, 64, 66), "naive") == 66, "Naive harus memakai nilai terakhir.")
  d <- attach_methodology(panel, audit)
  no_breaks <- audit; no_breaks$batas_sebelum_tahun <- FALSE
  uninterrupted <- attach_methodology(panel, no_breaks)
  assert(sum(is.finite(backtest(uninterrupted)$ramalan)) == 90L, "Seri tanpa batas harus menghasilkan 90 ramalan.")
  assert(sum(is.finite(annual_changes(uninterrupted)$perubahan_poin)) == 90L, "Seri tanpa batas harus menghasilkan 90 perubahan.")
  p <- backtest(d)
  assert(all(p$latihan_akhir[!is.na(p$latihan_akhir)] < p$tahun_target[!is.na(p$latihan_akhir)]), "Kebocoran tahun target.")
  changed <- d
  changed$ikp[changed$tahun >= 2023] <- changed$ikp[changed$tahun >= 2023] / 2
  p_changed <- backtest(changed)
  assert(isTRUE(all.equal(p$ramalan[p$tahun_target == 2023], p_changed$ramalan[p_changed$tahun_target == 2023])), "Ramalan menggunakan data target/masa depan.")
  c <- annual_changes(d)
  boundary_keys <- paste(d$kode[d$batas_metode], d$tahun[d$batas_metode])
  assert(all(is.na(c$perubahan_poin[paste(c$kode, c$tahun) %in% boundary_keys])), "Perubahan melintasi batas metodologi.")
  assert(all(!is.finite(p$ramalan[p$tipe == "Kabupaten"])), "Backtest kabupaten harus ditahan karena segmen pendek.")
  for (x in split(d, paste(d$kode, d$segmen))) if (nrow(x) > 1) {
    cc <- c[c$kode == x$kode[1] & c$segmen == x$segmen[1], ]
    assert(abs(sum(cc$perubahan_poin, na.rm = TRUE) - (tail(x$ikp, 1) - x$ikp[1])) < 1e-8, "Jumlah perubahan tidak sesuai kenaikan segmen.")
  }
  metric_case <- data.frame(metode = "synthetic", tahun_target = 1:3, error_poin = c(-2, 0, 4))
  m <- forecast_accuracy(metric_case, "metode")
  assert(abs(m$MAE_poin - 2) < 1e-10 && abs(m$RMSE_poin - sqrt(20/3)) < 1e-10, "Perhitungan MAE/RMSE salah.")
  rejects <- function(x) inherits(tryCatch(validate_panel(x), error = identity), "error")
  assert(rejects(panel[c(seq_len(nrow(panel)), 1), ]), "Duplikasi tidak ditolak.")
  assert(rejects(panel[-1, ]), "Tahun hilang tidak ditolak.")
  invalid <- panel; invalid$ikp[1] <- 101
  assert(rejects(invalid), "IKP di luar skala tidak ditolak.")
  cat("LULUS: rumus, batas metode, tanpa kebocoran, agregasi error, dan penolakan data invalid.\n")
  invisible(TRUE)
}
