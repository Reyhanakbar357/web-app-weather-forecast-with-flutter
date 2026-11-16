// File stub untuk Workmanager di platform web.
// Menggantikan package workmanager dengan versi kosong
// agar aplikasi tidak crash saat dibuka di browser.

class Workmanager {
  static final Workmanager _instance = Workmanager._internal();
  factory Workmanager() => _instance;
  Workmanager._internal();

  Future<void> initialize(Function callbackDispatcher) async {}
  Future<void> registerPeriodicTask(String uniqueName, String taskName,
      {Duration? frequency, dynamic constraints, dynamic existingWorkPolicy}) async {}
  Future<void> cancelByUniqueName(String uniqueName) async {}
  Future<void> cancelAll() async {}
  Future<void> executeTask(dynamic callback) async {}
}

class Constraints {
  const Constraints({dynamic networkType});
}

class NetworkType {
  static const connected = NetworkType._();
  const NetworkType._();
}

class ExistingPeriodicWorkPolicy {
  static const replace = ExistingPeriodicWorkPolicy._();
  const ExistingPeriodicWorkPolicy._();
}
