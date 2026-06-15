import 'package:flutter/material.dart';
import '../../providers/card_provider.dart';
import '../../providers/merchant_provider.dart';
import '../../widgets/pin_entry_dialog.dart';
import '../../dialogs/request_merchant_approval_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres Thix Money')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle('Carte NFC Thix Pay'),
          _buildTile(
            icon: Icons.credit_card,
            title: 'Gérer ma carte',
            onTap: () => _showCardSettings(context),
          ),
          _buildTile(
            icon: Icons.lock_outline,
            title: 'Modifier le code PIN',
            onTap: () => showDialog(context: context, builder: (_) => const PinEntryDialog()),
          ),
          const Divider(),
          _buildSectionTitle('Mode Marchand'),
          Consumer<MerchantProvider>(
            builder: (ctx, prov, _) {
              if (prov.isApproved) {
                return _buildTile(
                  icon: Icons.store,
                  title: 'Statut : Marchand approuvé',
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                );
              } else if (prov.isPending) {
                return _buildTile(
                  icon: Icons.hourglass_empty,
                  title: 'Demande en attente',
                  trailing: const Icon(Icons.pending, color: Colors.orange),
                );
              } else {
                return _buildTile(
                  icon: Icons.storefront,
                  title: 'Devenir marchand',
                  onTap: () => showDialog(context: context, builder: (_) => const RequestMerchantApprovalDialog()),
                );
              }
            },
          ),
          const Divider(),
          _buildSectionTitle('Sécurité'),
          _buildTile(
            icon: Icons.biometric,
            title: 'Authentification biométrique',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          _buildTile(
            icon: Icons.notifications,
            title: 'Notifications push',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildTile({required IconData icon, required String title, VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showCardSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Gestion carte NFC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Bloquer la carte')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () {}, child: const Text('Définir plafond sans code')),
          ],
        ),
      ),
    );
  }
}
