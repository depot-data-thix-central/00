import 'package:flutter/material.dart';
import '../theme/thix_money_theme.dart';

class MerchantApprovalStatusWidget extends StatelessWidget {
  final String status; // 'approved', 'pending', 'rejected', 'not_requested'

  const MerchantApprovalStatusWidget({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String text;

    switch (status) {
      case 'approved':
        icon = Icons.check_circle;
        color = Colors.green;
        text = 'Compte marchand actif';
        break;
      case 'pending':
        icon = Icons.hourglass_empty;
        color = ThixMoneyTheme.warningColor;
        text = 'Demande en cours';
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        text = 'Demande rejetée';
        break;
      default:
        icon = Icons.storefront;
        color = ThixMoneyTheme.textSecondaryColor;
        text = 'Non demandé';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
