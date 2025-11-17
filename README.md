# ink_voyage
- Project: `lib/`
- Main screens: `lib/screens/`
- Widgets: `lib/widgets/`
- Theme & styles: `lib/themes/`
- Browse books (Daftar Buku)
- Discover screen with filters (genre + sort) and an empty-state for author uploads
- Vertical book cards, rating & stats
- Firebase-ready models and placeholders (integration docs in `FIREBASE_QUICK_START.md`)
- Flutter SDK (stable)
- Android SDK / Xcode (for device builds)
- Git (for source control)
- Analyze: `flutter analyze`
- Format: `flutter format .`
- Run on emulator/device: `flutter run`
- Build APK: `flutter build apk`
- The `Discover` screen currently shows an empty-state until the author-upload backend/flow is implemented. See `lib/screens/discover_screen.dart` for the UI.
- Vertical card UI is implemented in `lib/widgets/vertical_book_card.dart`.
- Fork the repo, create a feature branch, open a pull request with a concise description and testing steps.
- Keep commits focused and small. Use descriptive commit messages (e.g. `feat(discover): add dropdown filters`).
# ink_voyage

Ink Voyage — Aplikasi mobile untuk menemukan dan membaca karya yang dipublikasikan oleh penulis.

Repositori ini berisi aplikasi Flutter (Android / iOS / web) yang dibuat sebagai mini project pada mata kuliah "Praktikum Pemrograman Sistem Bergerak". Aplikasi berfokus pada pengalaman membaca yang ringan dan alur publikasi berbasis penulis (fitur upload penulis akan dikembangkan kemudian).

Ringkasan lokasi penting
- Kode utama: `lib/`
- Layar utama: `lib/screens/`
- Komponen UI: `lib/widgets/`
- Tema & gaya: `lib/themes/`

Fitur
- Menampilkan daftar buku (Daftar Buku)
- Halaman Discover dengan filter (genre + sort) dan empty-state untuk karya penulis
- Kartu buku vertikal dengan rating & statistik
- Struktur model siap integrasi Firebase (lihat file `FIREBASE_QUICK_START.md` untuk catatan integrasi)

Prasyarat
- Flutter SDK (stable)
- Android SDK atau Xcode (untuk build perangkat)
- Git (untuk kontrol versi)

Instalasi & Menjalankan (Windows / PowerShell)
1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Dari direktori proyek jalankan:

```powershell
flutter pub get
# Untuk menjalankan di emulator/device Android
flutter run
```

Perintah berguna
- Analisis statis: `flutter analyze`
- Format kode: `flutter format .`
- Jalankan aplikasi: `flutter run`
- Build APK: `flutter build apk`

Catatan pengembangan
- Layar `Discover` saat ini sengaja menampilkan empty-state sampai fitur upload karya oleh penulis tersedia. Implementasi UI Discover ada di `lib/screens/discover_screen.dart`.
- Kartu buku vertikal berada di `lib/widgets/vertical_book_card.dart`.

Struktur singkat
- `lib/screens/` — layar (Discover, Daftar Buku, Profil, dsb.)
- `lib/widgets/` — komponen UI dapat dipakai ulang
- `assets/images/` — gambar dan ikon sampel

Kontribusi
- Ingin kontribusi? Fork repo, buat branch fitur, lalu kirim PR dengan deskripsi perubahan dan langkah pengujian singkat.

Catatan lisensi
- Proyek ini dibuat untuk tugas perkuliahan. Jika menggunakan aset eksternal, patuhi lisensi dan berikan atribusi bila diperlukan.