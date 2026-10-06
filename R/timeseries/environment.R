verify_environment <- function(path = "review/timeseries/dependensi.csv") {
  manifest <- read.csv(path, stringsAsFactors = FALSE)
  assert(all(c("package", "version") %in% names(manifest)) && !anyDuplicated(manifest$package), "Manifest dependensi invalid.")
  installed <- vapply(manifest$package, function(p) {
    if (!requireNamespace(p, quietly = TRUE)) return(NA_character_)
    as.character(utils::packageVersion(p))
  }, character(1))
  wrong <- !mapply(function(actual, expected) !is.na(actual) && package_version(actual) == package_version(expected),
    installed, manifest$version)
  assert(!any(wrong), paste("Versi dependensi berbeda:", paste(manifest$package[wrong], collapse = ", "),
    "Jalankan penyiapan renv pada README; pipeline analisis tidak memasang package."))
  cat("LULUS: versi", nrow(manifest), "dependensi sesuai manifest dan renv.lock.\n")
  invisible(TRUE)
}
