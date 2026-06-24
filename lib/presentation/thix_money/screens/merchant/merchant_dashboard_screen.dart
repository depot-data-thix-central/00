import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/merchant_provider.dart';
import '../../providers/thix_money_provider.dart';
import '../../theme/thix_money_theme.dart';
import '../../widgets/mode_switch_widget.dart';
import '../shared/transaction_history_screen.dart';
import 'merchant_qr_code_screen.dart';
import 'merchant_transactions_screen.dart';
import 'merchant_split_requests_screen.dart';

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final merchantProv = Provider.of<MerchantProvider>(context);
    final thixProv = Provider.of<ThixMoneyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${merchantProv.businessName ?? 'Mon commerce'}'),
        actions: const [ModeSwitchWidget()],
      ),
      body: RefreshIndicator(
        onRefresh: () => thixProv.loadMerchantData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte encaissement du jour
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Encaissements aujourd’hui',
                          style: TextStyle(fontSize: 16, color: ThixMoneyTheme.textSecondaryColor)),
                      const SizedBox(height: 8),
                      Text('${thixProv.todayMerchantRevenue} FC',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions rapides
              const Text('Actions rapides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.qr_code,
                      label: 'QR Code',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MerchantQrCodeScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.history,
                      label: 'Transactions',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MerchantTransactionsScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.split_screen,
                      label: 'Fractionnés',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MerchantSplitRequestsScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Graphique des ventes (simplifié)
              const Text('Ventes des 7 derniers jours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: ThixMoneyTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: ThixMoneyTheme.cardShadow,
                ),
                child: Center(
                  child: Text('📊 Graphique (intégration à venir)',
                      style: TextStyle(color: ThixMoneyTheme.textSecondaryColor)),
                ),
              ),
              const SizedBox(height: 24),

              // Dernières transactions
              const Text('Derniers paiements reçus',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...thixProv.recentMerchantTransactions.take(3).map((tx) => ListTile(
                    leading: const Icon(Icons.payment),
                    title: Text('${tx.amount} FC'),
                    subtitle: Text(tx.customerName ?? 'Client'),
                    trailing: Text(tx.formattedDate),
                  )),
              if (thixProv.recentMerchantTransactions.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MerchantTransactionsScreen())),
                  child: const Text('Voir tout'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ThixMoneyTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ThixMoneyTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: ThixMoneyTheme.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
