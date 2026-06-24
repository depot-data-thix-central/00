// 📁 lib/presentation/admin_hopital/dashboard/widgets/dashboard_activity_feed.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/providers/admin_dashboard_provider.dart';
import '../../../../data/models/hospital/activity_model.dart';

class DashboardActivityFeed extends ConsumerWidget {
  final int maxItems;

  const DashboardActivityFeed({Key? key, this.maxItems = 5}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(adminDashboardProvider);
    final activities = dashboardState.activities ?? [];

    if (dashboardState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Aucune activité récente',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      );
    }

    final displayed = activities.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Activité récente',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        ...displayed.map((activity) => _ActivityItem(activity: activity)),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityModel activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(activity.type),
              size: 18,
              color: _getColor(activity.type),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            activity.timeAgo,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'admission':
        return Icons.person_add;
      case 'consultation':
        return Icons.medical_services;
      case 'prescription':
        return Icons.medication;
      case 'exam':
        return Icons.science;
      case 'surgery':
        return Icons.local_hospital;
      case 'discharge':
        return Icons.exit_to_app;
      default:
        return Icons.notification_important;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'admission':
        return Colors.green;
      case 'consultation':
        return Colors.blue;
      case 'prescription':
        return Colors.purple;
      case 'exam':
        return Colors.orange;
      case 'surgery':
        return Colors.red;
      case 'discharge':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
