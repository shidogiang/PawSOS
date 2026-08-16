class AppConfig {
  // 🔴 Bật true khi đi thi/chấm điểm,  false khi release thật
  static const bool isDemoMode = true;

  // (Tuần) = 2 Phút
  // (Tuần) = 7 Ngày
  static Duration get trackingStageDuration {
    if (isDemoMode) {
      return const Duration(minutes: 2);
    }
    return const Duration(days: 7);
  }
}