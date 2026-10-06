make_figures <- function(d, changes, summaries, dispersion, predictions, accuracy_region, out_dir) {
  suppressPackageStartupMessages(library(ggplot2))
  colours <- c(Kabupaten = "#0F766E", Kota = "#B45309", naive = "#1C3353", drift = "#0F766E")
  theme_set(theme_minimal(base_size = 11, base_family = "sans") +
    theme(plot.title = element_text(size = 18, face = "bold", colour = "#172B4D"),
      plot.subtitle = element_text(colour = "#475569", margin = margin(b = 14)),
      plot.caption = element_text(colour = "#64748B", hjust = 0, margin = margin(t = 12)),
      panel.grid.minor = element_blank(), strip.text = element_text(face = "bold", colour = "#172B4D"),
      plot.margin = margin(18, 22, 18, 18), legend.position = "bottom", legend.title = element_blank()))
  save <- function(name, plot, width, height) {
    ggsave(file.path(out_dir, paste0(name, ".png")), plot = plot, width = width, height = height, dpi = 300, bg = "white")
    ggsave(file.path(out_dir, paste0(name, ".pdf")), plot = plot, width = width, height = height, bg = "white")
  }
  wrap <- function(x, width = 22) vapply(x, function(z) paste(strwrap(z, width), collapse = "\n"), character(1))
  d$label <- factor(wrap(d$kabupaten), levels = unique(wrap(d$kabupaten)))
  line_d <- d[ave(d$tahun, paste(d$kode, d$segmen), FUN = length) >= 2, ]
  boundaries <- d[d$batas_metode, ]
  p1 <- ggplot(d, aes(tahun, ikp)) +
    geom_vline(data = boundaries, aes(xintercept = tahun - 0.5), colour = "#CBD5E1", linetype = "dashed", linewidth = 0.4) +
    geom_line(data = line_d, aes(group = interaction(kode, segmen), colour = tipe), linewidth = 0.8) +
    geom_point(aes(colour = tipe), size = 2) + facet_wrap(vars(label), ncol = 4) +
    scale_colour_manual(values = colours) + scale_x_continuous(breaks = c(2018, 2020, 2022, 2024)) +
    scale_y_continuous(limits = c(65, 90), breaks = seq(65, 90, 5)) +
    labs(title = "Perjalanan skor IKP di 15 wilayah Lampung", subtitle = "2018-2024 | satu panel per wilayah, skala yang sama",
      x = NULL, y = "Skor IKP", caption = "Garis tidak melintasi batas definisi komponen kabupaten (2021, 2022, 2024). Seluruh hasil eksploratif dan bersyarat.")
  save("01_tren_wilayah", p1, 14, 11)

  changes$label <- factor(wrap(changes$kabupaten, 25), levels = rev(unique(wrap(d$kabupaten, 25))))
  maximum <- max(abs(changes$perubahan_poin), na.rm = TRUE)
  changes$text <- ifelse(is.na(changes$perubahan_poin), "-", sprintf("%.2f", changes$perubahan_poin))
  changes$text_colour <- ifelse(!is.na(changes$perubahan_poin) & abs(changes$perubahan_poin) >= maximum * 0.6, "white", "#172B4D")
  p2 <- ggplot(changes, aes(factor(tahun), label, fill = perubahan_poin)) +
    geom_tile(colour = "white", linewidth = 0.8) + geom_text(aes(label = text, colour = text_colour), size = 3.4) +
    scale_colour_identity() + scale_fill_gradient2(low = "#B45309", mid = "#F8FAFC", high = "#0F766E", midpoint = 0,
      limits = c(-maximum, maximum), na.value = "#E2E8F0", name = "Poin IKP") +
    facet_grid(tipe ~ ., scales = "free_y", space = "free_y") +
    labs(title = "Perubahan tahunan: kenaikan dan penurunan skor", subtitle = "Selisih skor terhadap tahun sebelumnya, dalam poin IKP",
      x = "Tahun berjalan", y = NULL, caption = "Sel abu-abu (-) dikecualikan karena melintasi batas definisi komponen. Bukan perubahan nol.") +
    theme(panel.grid = element_blank(), axis.text.y = element_text(size = 10))
  save("02_heatmap_perubahan", p2, 12, 9.5)

  stability <- summaries[is.finite(summaries$sd_perubahan_poin), ]
  stability$periode <- paste(stability$tipe, paste(stability$tahun_awal, stability$tahun_akhir, sep = "-"), sep = " | ")
  selected <- unlist(lapply(split(seq_len(nrow(stability)), stability$periode), function(ii)
    unique(c(ii[which.max(stability$sd_perubahan_poin[ii])], ii[which.min(stability$sd_perubahan_poin[ii])], ii[which.max(stability$kenaikan_bersih_poin[ii])]))))
  p3 <- ggplot(stability, aes(kenaikan_bersih_poin, sd_perubahan_poin, colour = tipe)) +
    geom_point(size = 3.5, alpha = 0.85) +
    geom_text(data = stability[selected, ], aes(label = wrap(kabupaten, 20)), nudge_y = 0.22, size = 3.2, check_overlap = TRUE, show.legend = FALSE) +
    facet_wrap(vars(periode), ncol = 1, scales = "free") + scale_colour_manual(values = colours) +
    scale_y_continuous(expand = expansion(mult = c(0.12, 0.35))) +
    scale_x_continuous(expand = expansion(mult = c(0.18, 0.25))) +
    labs(title = "Kenaikan skor dan fluktuasi perubahannya", subtitle = "Dihitung di dalam segmen; periode antar-panel berbeda dan tidak diperingkatkan bersama",
      x = "Kenaikan bersih dalam segmen (poin IKP)", y = "SD perubahan tahunan (poin IKP)",
      caption = "Kabupaten 2018-2020 hanya memiliki dua perubahan; kota 2018-2024 memiliki enam. SD kecil tidak otomatis berarti lebih baik.")
  save("03_kenaikan_dan_stabilitas", p3, 11, 8)

  long <- rbind(data.frame(dispersion[c("tahun", "segmen")], indikator = "Rata-rata sederhana skor 13 kabupaten", nilai = dispersion$rata_ikp),
    data.frame(dispersion[c("tahun", "segmen")], indikator = "Simpangan baku antar-13 kabupaten", nilai = dispersion$sd_ikp))
  long$label_y <- long$nilai + ave(long$nilai, long$indikator, FUN = function(x) diff(range(x)) * 0.08)
  line_g <- long[ave(long$tahun, paste(long$segmen, long$indikator), FUN = length) >= 2, ]
  p4 <- ggplot(long, aes(tahun, nilai)) +
    geom_vline(xintercept = c(2020.5, 2021.5, 2023.5), linetype = "dashed", colour = "#CBD5E1") +
    geom_line(data = line_g, aes(group = interaction(segmen, indikator)), linewidth = 1, colour = "#0F766E") +
    geom_point(size = 3, colour = "#0F766E") + geom_text(aes(y = label_y, label = sprintf("%.2f", nilai)), size = 3.5) +
    facet_wrap(vars(indikator), scales = "free_y", ncol = 1) + scale_x_continuous(breaks = 2018:2024) +
    scale_y_continuous(expand = expansion(mult = c(0.15, 0.25))) +
    labs(title = "Potret tahunan rata-rata dan kesenjangan", subtitle = "13 kabupaten | bobot setiap wilayah sama | kota dianalisis tersendiri",
      x = NULL, y = "Poin IKP", caption = "Rata-rata ini bukan IKP resmi Provinsi Lampung. Perubahan antartahun hanya dihitung dalam segmen yang sama.")
  save("04_rata_rata_dan_kesenjangan", p4, 11, 8)

  available <- accuracy_region[accuracy_region$n_ramalan > 0, ]
  p5 <- ggplot(available, aes(MAE_poin, kabupaten, fill = metode)) +
    geom_col(position = position_dodge(width = 0.65), width = 0.58) +
    geom_text(aes(label = sprintf("%.2f", MAE_poin)), position = position_dodge(width = 0.65), hjust = -0.15, size = 4) +
    scale_fill_manual(values = colours, labels = c(drift = "Drift", naive = "Naive")) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.2))) +
    labs(title = "Ketepatan ramalan satu tahun ke depan", subtitle = "MAE per kota pada 2022, 2023, dan 2024 | lebih kecil berarti kesalahan lebih rendah",
      x = "MAE (poin IKP)", y = NULL,
      caption = "Kabupaten tidak diestimasi: segmen latihan kurang dari empat tahun. Setiap kota/metode hanya memiliki tiga ramalan uji.")
  save("05_error_peramalan", p5, 11, 5.5)

  actual <- d[d$tipe == "Kota", ]
  available_p <- predictions[is.finite(predictions$ramalan), ]
  p6 <- ggplot(actual, aes(tahun, ikp)) +
    geom_line(colour = "#64748B", linewidth = 0.8) + geom_point(colour = "#64748B", size = 2) +
    geom_line(data = available_p, aes(tahun_target, ramalan, colour = metode, group = metode), inherit.aes = FALSE, linewidth = 0.8, linetype = "dashed") +
    geom_point(data = available_p, aes(tahun_target, ramalan, colour = metode), inherit.aes = FALSE, size = 2.5) +
    facet_wrap(vars(kabupaten), ncol = 2) + scale_colour_manual(values = colours, labels = c(drift = "Drift", naive = "Naive")) +
    scale_x_continuous(breaks = 2018:2024) +
    labs(title = "Skor aktual dan ramalan historis dua kota", subtitle = "Garis abu-abu: aktual | garis putus-putus: ramalan yang dibuat dari tahun sebelumnya",
      x = NULL, y = "Poin IKP", caption = "Setiap target memakai latihan yang diperluas; garis ramalan bukan ramalan tiga tahun dari satu titik asal.")
  save("06_aktual_dan_ramalan_kota", p6, 12, 5.5)
  cat("Grafik: 6 PNG (300 dpi) dan 6 PDF.\n")
}
