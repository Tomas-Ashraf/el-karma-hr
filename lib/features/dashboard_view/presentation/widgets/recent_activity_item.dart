import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/initials_avatar.dart';
import 'package:flutter/material.dart';

class RecentActivityItem extends StatelessWidget {
  const RecentActivityItem({super.key, required this.record});

  final ShiftAttendance record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = theme.colorScheme.onSurfaceVariant;
    final checkOut = record.checkOut;

    Widget line(IconData icon, String label, DateTime time) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(icon, size: 14, color: kPrimaryBlue),
            const SizedBox(width: 6),
            Text(
              '$label  ${formatTime(context, time)}',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: Colors.transparent) : null,
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          InitialsAvatar(initials: record.employee.initials),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.employee.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                line(
                  Icons.login_rounded,
                  context.tr('dashboard.check_in'),
                  record.checkIn,
                ),
                if (checkOut != null)
                  line(
                    Icons.logout_rounded,
                    context.tr('dashboard.check_out'),
                    checkOut,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            record.isLate
                ? context.tr('dashboard.late')
                : context.tr('dashboard.on_time'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: record.isLate
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }
}
