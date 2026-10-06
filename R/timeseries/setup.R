# Explicit setup only. Run after installing renv, with internet access.
if (!file.exists("renv.lock")) stop("Jalankan dari root repository.", call. = FALSE)
if (!requireNamespace("renv", quietly = TRUE)) {
  stop("Pasang renv terlebih dahulu sesuai README; setup tidak memasang bootstrap otomatis.", call. = FALSE)
}
dir.create(".library", showWarnings = FALSE)
renv::restore(project = getwd(), lockfile = "renv.lock", library = normalizePath(".library"), prompt = FALSE)
cat("Lingkungan siap di .library/. Jalankan Rscript --vanilla R/timeseries/run.R.\n")
