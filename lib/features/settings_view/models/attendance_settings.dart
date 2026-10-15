class AttendanceSettings {
  const AttendanceSettings({
    required this.lateMinutes,
    required this.leaveEarlyMinutes,
    required this.deductionPerMinute,
  });

  /// سماح التأخير بالدقايق.
  final int lateMinutes;

  /// سماح الانصراف المبكر بالدقايق من غير خصم.
  final int leaveEarlyMinutes;

  /// قيمة الخصم بالجنيه عن كل دقيقة تأخير.
  final double deductionPerMinute;

  /// القيم الافتراضية لو الأدمن لسه ما حفظش إعدادات.
  factory AttendanceSettings.defaults() => const AttendanceSettings(
    lateMinutes: 15,
    leaveEarlyMinutes: 15,
    deductionPerMinute: 0,
  );

  factory AttendanceSettings.fromMap(Map<String, dynamic> map) {
    final defaults = AttendanceSettings.defaults();
    return AttendanceSettings(
      lateMinutes:
          (map['late_minutes'] as num?)?.toInt() ?? defaults.lateMinutes,
      leaveEarlyMinutes:
          (map['leave_early_minutes'] as num?)?.toInt() ??
          defaults.leaveEarlyMinutes,
      deductionPerMinute:
          (map['deduction_per_minute'] as num?)?.toDouble() ??
          defaults.deductionPerMinute,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'late_minutes': lateMinutes,
      'leave_early_minutes': leaveEarlyMinutes,
      'deduction_per_minute': deductionPerMinute,
    };
  }
}
