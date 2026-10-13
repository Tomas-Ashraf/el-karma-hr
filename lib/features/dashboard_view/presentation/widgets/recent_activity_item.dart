import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/models/dashboard_models.dart';
import 'package:flutter/material.dart';

class RecentActivityItem extends StatelessWidget {
  const RecentActivityItem({super.key, required this.activity});

  final RecentActivity activity;

  @override
  Widget build(BuildContext context) {
    final isCheckIn = activity.type == ActivityType.checkIn;
    final status = activity.statusLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
              size: 20,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.employeeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.typeLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.timeLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (status != null) ...[
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: activity.isLate
                        ? const Color(0xFFEF4444)
                        : Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
