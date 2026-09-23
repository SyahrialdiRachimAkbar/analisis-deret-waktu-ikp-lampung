# PLAN — Proyek Ketahanan Pangan: dari "beresin laporan" ke karya yang bisa dipertahankan

**Tanggal:** 2026-09-23
**Sifat:** rencana kerja (roadmap), disusun dari sisi "kalau ini proyek gw, gw mau hasilnya maksimal"
**Reproduksi bukti:** `review/verify_ikp_sources.R` → `review/verify_output.log`; `review/review_checks.R` → `review/review_output.log`
**Berkas sumber resmi:** `review/sources/` (4 berkas, hash tercatat di Bagian 5)

---

## 0. Kabar baik lebih dulu: data lo LOLOS verifikasi

Gw uji Y (IKP) lo ke **publikasi primer** — bukan ke file turunan.

| Uji | Hasil |
|---|---|
| IKP 2018 vs publikasi BKP 2018, Tabel 4 & 5 (skor **dan** peringkat) | **15/15 COCOK PERSIS** |
| IKP 2019–2024 vs Satu Data Lampung (Dinas Ketahanan Pangan Prov.) | **85/90 cocok (94%)** |

Termasuk peringkat nasionalnya cocok: Mesuji rank 44 (80,82), Tulang Bawang Barat rank 45 (80,70), Lampung Barat rank 256 (70,76), Kota Metro rank 71 (65,98). Data lo **bukan** karangan dan **bukan** salah salin. Itu fondasi yang bagus.

**Catatan proses yang perlu lo tahu (biar lo nggak kaget kalau ada yang bilang data lo salah):** di tengah pengecekan gw sempat menemukan bahwa kolom `kode` di data lo (`1801`…`1813`) itu **bukan kode BPS**. Kode BPS yang benar: `1801` = Lampung Selatan, `1804` = Lampung Barat; sedangkan di data lo `1801` = Lampung Barat. Ternyata itu **nomor urut internal**, bukan error: nama dan nilai lo konsisten sepanjang 7 tahun dan cocok dengan publikasi. Jadi `kode` aman dipakai sebagai ID unit — **asalkan jangan pernah dipakai untuk join ke data BPS lain**. Kalau nanti lo gabung data luar, join-nya **wajib lewat nama**, bukan kode.

Yang lebih penting: **file open-data Bapanas justru yang cacat.** Di `dataset/90` (IKP kab/kota 2018–2024), 8 dari 15 unit Lampung punya **nama yang salah tempel** — nilainya benar, kodenya benar, namanya tertukar. Contoh: file itu menulis kode `1804` = "Lampung Barat" padahal `1804` = Lampung Timur dan nilainya (77,43) memang Lampung Timur. Kalau lo memakai file itu sebagai acuan, lo akan menyimpulkan data lo salah padahal data lo benar. Bukti: `review/verify_output.log` Bagian 8 & 9.

---

## 1. Temuan baru yang mengubah bentuk plannya

### 1.1 Ada versi indeks yang berbeda, dan selisihnya besar

Dua file resmi Bapanas memberi nilai **berbeda jauh** untuk tahun yang sama:

| Wilayah | Bapanas `dataset/90` (2024) | Bapanas `backcasting` 12-indikator (2024) | Selisih |
|---|---|---|---|
| Tulang Bawang | 88,78 | 71,68 | **17,10** |
| Mesuji | 88,18 | 70,69 | **17,49** |
| Kota Bandar Lampung | 84,64 | 67,05 | **17,59** |
| Lampung Tengah | 84,93 | 70,15 | 14,78 |
| Way Kanan | 79,61 | 77,12 | 2,49 |

Ini **bukan kesalahan** — ini dua **vintage indeks** yang berbeda (versi lama 9/8 indikator vs versi 12 indikator hasil backcasting). Selisih 17 poin itu setara satu setengah kali simpangan baku IKP antarwilayah. Artinya: **tidak ada satu "nilai IKP yang benar" tunggal** — yang ada adalah nilai per versi metodologi.

Konsekuensi untuk naskah lo:
1. Lo **wajib menyebutkan versi** indeks yang dipakai di Bab 3, dan tidak boleh mencampur dua vintage dalam satu seri.
2. Seri 2018–2024 lo saat ini konsisten satu vintage (bagus) — yang harus dipastikan adalah vintage mana, dan apakah ada perubahan metodologi di dalam rentang itu.
3. Ini **bukan** lagi "keterbatasan kecil". Ini fakta metodologis yang, ditangani dengan benar, justru menaikkan kualitas naskah.

### 1.2 Lompatan 2023 itu nyata dan berskala nasional

Gw sempat menduga lompatan 2023 di Lampung itu artefak atau salah input. Ternyata bukan:

| Tahun | Rata-rata IKP 514 kab/kota | Δ |
|---|---|---|
| 2018 | 69,09 | — |
| 2019 | 71,29 | +2,21 |
| 2020 | 71,82 | +0,53 |
| 2021 | 72,14 | +0,32 |
| 2022 | 71,84 | **−0,30** |
| 2023 | 74,43 | **+2,59** |
| 2024 | 75,11 | +0,68 |

Pola Lampung identik dengan pola nasional. **Ini memperkuat temuan "year FE wajib"**: lompatan 2023 adalah gerakan serentak se-Indonesia, jadi koefisien tanpa efek tahun memang menyerap gerakan itu. Dummy COVID (2020–2021) justru menandai tahun-tahun dengan perubahan **terkecil** (+0,53 / +0,32 di tingkat nasional). Temuan ini sekarang punya bukti eksternal, bukan cuma bukti internal.

### 1.3 N besar ternyata tersedia

Data IKP resmi mencakup **514 kabupaten/kota × 7 tahun = 3.598 observasi** (panel seimbang, 0 nilai kosong, 34 provinsi). Untuk **10 provinsi Sumatera**: **140 kabupaten/kota** → panel ~980 observasi. Ini membuka pintu yang sebelumnya terkunci (GMM/dinamis ditolak karena N=15).

---

## 2. Diagnosis jujur: apa yang membuat proyek ini belum maksimal

Empat hal, diurutkan dari yang paling menentukan:

| # | Masalah | Kenapa fatal untuk kualitas |
|---|---|---|
| 1 | **Tumpang tindih X–Y.** Kemiskinan (bobot 15%) dan komponen IPM (AHH 10%, RLS perempuan 5%) adalah indikator **penyusun** IKP | Pertanyaan "apakah kemiskinan memengaruhi IKP?" tidak bisa dijawab — sebagian jawabannya ada di rumus indeks. R² melompat 0,603→0,805 hanya dengan satu variabel ini |
| 2 | **Spesifikasi tanpa efek tahun**, padahal 97% gerak within IPM = tren bersama. Koef IPM +1,96 → **−2,23 (p=0,18)** begitu year FE masuk | Klaim utama tidak bertahan di spesifikasi yang benar |
| 3 | **N=15 menutup metode dinamis**, padahal pertanyaan penelitian #2 lo persis tentang itu (efek waktu/lag) | Pertanyaan #2 jadi tidak terjawab padahal bisa |
| 4 | **Inferensi dengan G=15** terlalu optimistis: p asymptotik 0,0000 → **p wild bootstrap 0,109** | Signifikansi yang dilaporkan tidak bertahan di uji yang tepat |

Yang **bukan** masalah (jangan buang energi ke sini): kualitas data (lolos verifikasi), penolakan GMM pada N=15 (keputusan tepat), lagged-X alih-alih FE+lag-Y (tepat), dan rantai pipeline satu arah (rapi).

---

## 3. Target akhir yang gw kejar

> **"Determinan Ketahanan Pangan Kabupaten/Kota di Sumatera, 2018–2024"**
> Panel seimbang N ≈ 140, T = 7. Y dari satu vintage indeks resmi yang eksplisit. Model efek tetap wilayah + efek tahun, dengan inferensi yang valid untuk jumlah klaster menengah. Indikator penyusun indeks **dikeluarkan dari sisi kanan** (atau dijadikan objek studi), sehingga pertanyaan "apa determinannya" benar-benar bisa dijawab. Ditutup dengan evaluasi prediktif yang memberi nilai kebijakan.

Kenapa target ini yang membuat hasilnya maksimal:

| Yang diperbaiki | Caranya |
|---|---|
| Tumpang tindih X–Y | Ganti RHS ke variabel yang **tidak** ada di dalam indeks (iklim, infrastruktur, harga, produksi non-beras, akses) |
| Spesifikasi | Year FE sejak model utama, F gabungan dilaporkan |
| Pertanyaan #2 (dinamis) | N ≈ 140 membuka lag-Y/GMM secara defensible — pertanyaan yang tadinya dipaksa ditolak |
| Inferensi | Wild cluster bootstrap + Driscoll–Kraay berdampingan dengan asymptotik, plus MDE |
| Nilai kebijakan | Evaluasi out-of-sample: apakah model bisa memprioritaskan wilayah rawan |

---

## 4. Roadmap — 6 fase, urut, dengan gerbang keputusan

### FASE 0 — Tutup buku status lama (½ hari) · **bisa dikerjakan sekarang, tanpa pembimbing**

1. Jalankan & arsipkan `review/review_checks.R` + `review/verify_ikp_sources.R` (sudah jalan, exit 0).
2. Tulis `review/DESIGN_REVIEW.md` sebagai lampiran audit — **jangan hapus** temuan lama; itu jejak proses.
3. Sinkronkan `project_context.md` vs `CHANGELOG.md`: hapus klaim "Fase 1–7 SELESAI", ganti "Fase 1–7 selesai untuk desain lama; desain dirancang ulang setelah review 23 Sep 2026".
4. `git init` + `git config --local user.name/email` (identitas global lo sengaja kosong). Commit apa adanya dulu — termasuk hasil yang sekarang sudah tidak dipakai. Riwayat yang jujur lebih berharga daripada repo bersih.
5. Berhenti melaporkan angka IPM +1,96 ke mana pun sampai Fase 2 selesai.

**Gerbang:** kalau lo cuma butuh menyelesaikan tugas PSD dan berhenti di sini → lompat ke "Jalur Pendek" di Bagian 6.

### FASE 1 — Tetapkan vintage indeks & bangun dataset baru (2–3 hari) · **butuh keputusan pembimbing**

1. **Putuskan vintage**: versi 9/8 indikator (seri lo sekarang, 2018–2024, konsisten) **atau** versi 12 indikator backcasting. Rekomendasi gw: **versi yang seri lo pakai sekarang**, karena (a) sudah terverifikasi ke publikasi primer, (b) mencakup 2018–2024 tanpa perubahan definisi di tengah.
2. **Verifikasi metodologi per tahun**: cek publikasi Bapanas tahunan 2019–2024 apakah ada perubahan indikator/cut-off. Ini aksi yang **belum gw kerjakan** dan tetap wajib.
3. Bangun `data/sumatra_panel.csv`: 140 kab/kota × 7 tahun, dengan `kode_bps` yang **benar** (join lewat nama, bukan nomor urut), nama wilayah, tipe (Kabupaten/Kota), tahun.
4. Catat vintage + tanggal unduh + hash di header berkas.

**Gerbang:** kalau data X tidak bisa dilengkapi → **Opsi B** (tetap Lampung, tapi ganti objek studi ke indikator komponen). Lihat Bagian 5.

### FASE 2 — Perbaiki spesifikasi (1–2 hari)

Ini yang membuat hasil lama jujur, dan jadi robustness di naskah akhir.

1. Year FE sebagai model utama; buang dummy COVID; laporkan F gabungan year dummies.
2. Hausman klasik → robust Hausman/Mundlak (Wald klaster).
3. WCB (Rademacher, klaster) + Driscoll–Kraay berdampingan dengan asymptotik.
4. MDE / daya uji dilaporkan; tandai variabel dengan var(within) nyaris nol.
5. Estimasi terpisah Kabupaten vs Kota (bobot indeksnya beda).

### FASE 3 — Kumpulkan X yang tidak tumpang tindih (3–5 hari) · **ini inti perbaikan mutu**

Ganti/ tambah RHS dengan variabel yang **tidak** merupakan indikator penyusun IKP. Kandidat, diurut kemudahan:

| Variabel | Sumber | Kenapa bagus |
|---|---|---|
| Curah hujan & anomali iklim | CHIRPS / ERA5 (gratis, grid) | Eksogen, tidak ada di dalam indeks |
| Akses infrastruktur (jalan, listrik, air) | BPS / Kementerian PUPR | Jalur nyata ke pemanfaatan pangan |
| Harga pangan relatif & anomali harga | Bapanas (Indikator Anomali Harga) | Tepat menyasar aspek keterjangkauan |
| Produksi non-beras (jagung, ubi, hortikultura) | BPS | Ketersediaan versi indeks memakai angka tetap, jadi ini bebas |
| Jarak/akses ke pasar & ibukota | Perhitungan sendiri | Proksi keterjangkauan yang bersih |
| Anggaran pangan daerah | APBD / DJPK | Variabel kebijakan — nilai tulis yang tinggi |

Minimal 3 variabel baru. Untuk IPM/kemiskinan: **keluarkan dari RHS model utama**, atau pertahankan dalam blok terpisah berlabel jelas "model indikator penyusun (untuk perbandingan, bukan estimasi pengaruh)".

**Akses data:** BPS punya WebAPI (514 domain kabupaten). Gw sudah uji: butuh **API key gratis** dari `webapi.bps.go.id/developer` — pakai email, tanpa biaya. Tanpa key, permintaan diblokir WAF (sudah gw buktikan). Ini pekerjaan lo, bukan gw, karena butuh email pribadi lo.

### FASE 4 — Estimasi utama (2 hari)

1. Pooled / FE / RE dengan year FE, klaster pada kabupaten.
2. **Pertanyaan #2 akhirnya bisa dijawab**: uji konsistensi/validitas instrumen untuk lag-Y, dan pastikan jumlah instrumen ≤ jumlah grup (aturan Roodman yang sudah lo pahami). Kalau tetap tidak terpenuhi, jalankan **lagged-X** sebagai jalur utama dan GMM sebagai robustness — sekarang posisinya kuat karena N jauh lebih besar dari 15.
3. Uji cross-sectional dependence (Pesaran CD) pada sampel besar — dengan 140 klaster, hasilnya lebih bermakna daripada z=0,128 pada N=15.

### FASE 5 — Evaluasi prediktif (2–3 hari) · **pembeda yang menaikkan nilai**

1. Split temporal: latih 2018–2022, uji 2023–2024 (atau leave-one-year-out).
2. Laporkan RMSE/MAE, dan **Recall@K**: kalau model dipakai memprioritaskan K wilayah paling rawan, berapa persen wilayah rawan yang benar tertangkap?
3. Bandingkan dengan baseline naif (peringkat tahun sebelumnya, rata-rata tiga tahun). Kalau model tidak mengalahkan baseline, itu temuan yang jujur dan tetap layak dilaporkan.

Ini yang mengubah naskah dari "analisis determinan" biasa menjadi "alat prioritas yang dievaluasi" — dan lo sudah punya keterampilan Recall@K dari proyek Decision Making.

### FASE 6 — Penulisan (3–4 hari)

Bab 3 wajib memuat: vintage indeks + sumber + hash, catatan bobot 9/8 indikator, alasan mengeluarkan variabel penyusun dari RHS, dan penjelasan efek tahun. Bab 4: tabel FE+YearFE, WCB, DK, MDE, Kab-vs-Kota. Bab 5: interpretasi konservatif + apa yang tidak bisa disimpulkan. Bab 6: evaluasi Recall@K.

---

## 5. Opsi cadangan (kalau Fase 3 tidak bisa dijalankan)

**Opsi B — tetap N=15, ganti objek studi.** Jangan jadikan IKP agregat sebagai Y. Jadikan **indikator komponennya** (aspek pemanfaatan: akses air bersih, stunting, RLS perempuan, angka harian hidup) sebagai Y, dengan penjelas yang bersih. Hanya 15 unit × 7 tahun, tapi pertanyaannya menjadi sah dan tidak tautologis. Ini pilihan terbaik kalau waktu/akses data terbatas.

**Opsi C — perluas N tanpa memperbaiki tumpang tindih.** Naikkan N, tapi tetap pakai kemiskinan/IPM sebagai RHS. **Jangan.** Memperbesar sampel tidak menghapus identitas indeks; lo cuma akan mengestimasi koefisien yang sama dengan presisi lebih tinggi. Ini jebakan paling mudah dan paling sering diteduhkan di jurnal.

---

## 6. Jalur pendek (kalau ini hanya tugas PSD, bukan TA)

1. Fase 0 (½ hari).
2. Fase 2 saja (1–2 hari) — year FE, WCB, robust Hausman, estimasi terpisah kab/kota, MDE.
3. Tulis ulang Bab 4–5: dari "IPM berpengaruh positif signifikan" → **"tidak ada variabel yang teridentifikasi berpengaruh robust; dua dari empat X adalah komponen IKP itu sendiri; sisanya tidak teridentifikasi terpisah dari tren bersama"**.
4. Tambahkan satu paragraf di Bab 3 soal vintage indeks + fakta bahwa dua file resmi berbeda 17 poin untuk tahun yang sama. Ini memperlihatkan lo membaca sumber primer, bukan menyalin file.
5. Selesai. Nilai plusnnya datang dari kejujuran metodologis, bukan dari hasil yang "positif".

---

## 7. Prioritas kalau waktu terbatas (urutan emas)

| Prioritas | Aksi | Alasan |
|---|---|---|
| **1** | Year FE masuk model utama | Tanpa ini, seluruh Bab 4 salah |
| **2** | Keluarkan kemiskinan (dan IPM) dari RHS utama | Menghapus klaim tautologis |
| **3** | Pisahkan Kabupaten vs Kota | Dua instrumen berbeda |
| **4** | WCB / inferensi G kecil–sedang | Signifikansi yang dilaporkan sekarang tidak bertahan |
| **5** | Verifikasi vintage indeks per tahun | Menentukan seri lo komparabel atau tidak |
| **6** | Perluas N ke Sumatera | Membuka pertanyaan #2 + nilai generalisasi |
| **7** | Evaluasi Recall@K | Pembeda untuk nilai tulis |
| **8** | X baru yang bersih | Memperbaiki mutu paling dalam, tapi paling mahal |

Kerjakan 1–4 lebih dulu: itu mengubah laporan dari "rapi tapi salah" menjadi "jujur dan bisa dipertahankan". 5 menentukan apakah datanya sah. 6–8 yang membuatnya *maksimal*.

---

## 8. Yang gw butuh dari lo / pembimbing

| # | Keputusan | Kenapa harus lo yang putuskan |
|---|---|---|
| D1 | Ini tugas PSD saja, atau kandidat TA? | Menentukan **Jalur Pendek** vs roadmap penuh |
| D2 | Vintage indeks mana yang dipakai? | Keputusan akademik; memengaruhi seluruh Bab 3–4 |
| D3 | Boleh tidak mengubah pertanyaan penelitian (buang kemiskinan dari RHS)? | Ini mengubah judul & rumusan masalah — perlu persetujuan pembimbing |
| D4 | N diperluas ke Sumatera atau tetap Lampung? | Menentukan beban pengumpulan data (140 vs 15 unit) |
| D5 | Apakah ada bantuan akses data (API key BPS / data Dinas Pangan)? | Akses administratif, gw tidak bisa menggantikan |

---

## 9. Berkas yang sudah gw buat (dan statusnya)

| Berkas | Isi | Status |
|---|---|---|
| `review/DESIGN_REVIEW.md` | Review desain: 4 temuan + bukti + opsi | Selesai, sudah dijalankan |
| `review/review_checks.R` + `.log` | Reproduksi semua angka review (F, WCB, jackknife, R², CD) | exit 0, 249 baris |
| `review/verify_ikp_sources.R` + `.log` | Verifikasi silang Y ke 3 sumber resmi + publikasi primer | exit 0 |
| `review/sources/*.csv`, `*.pdf` | Berkas sumber resmi (Bapanas, Satu Data Lampung, publikasi BKP 2018) | 4 berkas, hash tercatat |

**Hash berkas sumber:** Bapanas 514 kab `d5e05295…503c8` · Bapanas 12-indikator `b1a8753d…015b` · Satu Data Lampung `d07a4b96…c7d3` · PDF BKP 2018 `2d58a0e9…5fb9`

**Tidak diubah:** `data/lampung_panel_clean.csv` (`becc5801…8431`), `Data Fix - DATA.csv` (`ad69f257…0eb5`), `R/01`–`R/10`, `output/`, `laporan_draft.md` — semua masih bertanggal 19 Sep 2026.

---

## 10. Aturan yang gw pakai untuk diri gw sendiri selama mengerjakan ini

1. **Verifikasi ke sumber primer, bukan ke file turunan.** Pelajaran hari ini: file open-data Bapanas punya nama salah tempel; kalau gw berhenti di file itu, gw akan melaporkan data lo salah padahal benar.
2. **Setiap angka yang masuk naskah harus bisa direproduksi oleh script yang jalan.** Tidak ada "kayaknya" dan tidak ada angka yang gw ketik tangan tanpa dicatat sumbernya.
3. **Pisahkan bukti dari tafsir.** Di `DESIGN_REVIEW.md` ada bagian "yang tidak gw verifikasi" — bagian itu harus tetap ada.
4. **Jangan mengubah berkas yang sedang dipertanggungjawabkan.** Semua kerja review masuk folder `review/`, hash data asli dijaga.
5. **Kalau hasil tidak mendukung klaim, turunkan klaim — jangan cari spesifikasi yang mendukungnya.** Ini aturan yang membedakan analisis dari pembenaran.
