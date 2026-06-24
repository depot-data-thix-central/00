import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/merchant_provider.dart';
import '../dialogs/request_merchant_approval_dialog.dart';

class ModeSwitchWidget extends StatelessWidget {
  const ModeSwitchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final merchantProv = Provider.of<MerchantProvider>(context);
    final isApproved = merchantProv.isApproved;
    final isPending = merchantProv.isPending;

    return GestureDetector(
      onTap: () {
        if (isApproved) {
          merchantProv.switchMode();
        } else if (isPending) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demande en cours d’approbation')),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => const RequestMerchantApprovalDialog(),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              merchantProv.isMerchantMode ? Icons.store : Icons.person,
              size: 18,
              color: merchantProv.isMerchantMode
                  ? const Color(0xFF2D6A4F)
                  : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              merchantProv.isMerchantMode ? 'Mode Marchand' : 'Mode Utilisateur',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: merchantProv.isMerchantMode
                    ? const Color(0xFF2D6A4F)
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}
