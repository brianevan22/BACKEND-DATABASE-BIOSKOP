
# Bioskop Kelompok 1 — Backend & Flutter Setup (Updated)

## Backend (Laravel)
- Base URL dev:
  - Android emulator: `http://10.0.2.2:8000`
  - iOS/Web: `http://127.0.0.1:8000`
  - Device fisik: `http://<IP-LAPTOP>:8000` (jalankan `php artisan serve --host=0.0.0.0 --port=8000`)
- Pastikan route dinamis aktif di `routes/api.php` (film/genre/jadwal/kursi/studio/tiket/transaksi/detail_transaksi/customer/kasir/komentar).
- CORS (`config/cors.php`) sudah di-set untuk dev.

## Flutter
1) Install dependencies
```
flutter pub get
```
2) Jalankan
```
flutter run
```
3) Demo sederhana: `lib/main.dart` (List + Add Film)

## Catatan
- `lib/api_service.dart` berisi CRUD generik & helper `films()`.
- AndroidManifest ditambah `INTERNET` & `usesCleartextTraffic`.
- iOS Info.plist ditambah ATS (dev only).
