enum ActivityType { checkIn, checkOut }

/// أرقام الكروت الأربعة في الداشبورد (إجمالي موظفين النهاردة).
class DashboardStats {
  const DashboardStats({
    required this.checkedIn,
    required this.checkedOut,
    required this.late,
    required this.onTime,
  });

  final int checkedIn;
  final int checkedOut;
  final int late;
  final int onTime;
}

/// سطر واحد في قائمة Recent (حضور أو انصراف موظف النهاردة).
class RecentActivity {
  const RecentActivity({
    required this.employeeName,
    required this.type,
    required this.time,
    this.isLate = false,
  });

  final String employeeName;
  final ActivityType type;
  final DateTime time;

  /// بيتستخدم مع الحضور بس.
  final bool isLate;

  String get typeLabel =>
      type == ActivityType.checkIn ? 'Check In' : 'Check Out';

  /// "On Time" / "Late" للحضور، و null للانصراف.
  String? get statusLabel {
    if (type == ActivityType.checkOut) return null;
    return isLate ? 'Late' : 'On Time';
  }

  /// مثال: 10:00 am
  String get timeLabel {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'pm' : 'am';
    return '$hour12:$minute $period';
  }
}

// ============================================================
// بيانات تجريبية مؤقتة، امسحها لما نربط الداشبورد بـ Firestore
// ============================================================

const sampleStats = DashboardStats(
  checkedIn: 18,
  checkedOut: 12,
  late: 3,
  onTime: 15,
);

List<RecentActivity> sampleRecentActivities() {
  final now = DateTime.now();
  DateTime at(int hour, int minute) =>
      DateTime(now.year, now.month, now.day, hour, minute);

  return [
    RecentActivity(
      employeeName: 'Mina Samy',
      type: ActivityType.checkOut,
      time: at(17, 2),
    ),
    RecentActivity(
      employeeName: 'Sara Adel',
      type: ActivityType.checkIn,
      time: at(9, 20),
      isLate: true,
    ),
    RecentActivity(
      employeeName: 'Ahmed Hany',
      type: ActivityType.checkIn,
      time: at(9, 5),
    ),
    RecentActivity(
      employeeName: 'Mariam Nabil',
      type: ActivityType.checkIn,
      time: at(8, 58),
    ),
    RecentActivity(
      employeeName: 'Omar Khaled',
      type: ActivityType.checkIn,
      time: at(8, 45),
    ),
  ];
}
