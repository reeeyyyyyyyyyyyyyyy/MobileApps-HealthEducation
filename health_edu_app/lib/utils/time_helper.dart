class TimeHelper {
  /// Mengembalikan waktu saat ini dalam zona waktu WIB (UTC+7)
  static DateTime nowWIB() {
    final nowUtc = DateTime.now().toUtc();
    return nowUtc.add(const Duration(hours: 7));
  }
}
