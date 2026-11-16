// File ini digunakan saat aplikasi dijalankan di Flutter Web.
// Workmanager tidak mendukung platform web, sehingga semua fungsinya
// digantikan dengan versi kosong (no-op) agar aplikasi tidak crash.

const String backgroundWeatherTask = "backgroundWeatherTask";

/// Tidak melakukan apa-apa di platform web.
void initializeWorkmanager() {}

/// Tidak melakukan apa-apa di platform web.
void callbackDispatcher() {}
