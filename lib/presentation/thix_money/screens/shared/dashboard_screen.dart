import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/merchant_provider.dart';
import '../../providers/thix_money_provider.dart';
import '../../widgets/mode_switch_widget.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/recent_transactions_list.dart';
import '../../widgets/service_button.dart';
import '../user/accounts_screen.dart';
import '../user/transfer_screen.dart';
import '../user/split_payment_screen.dart';
import '../user/bill_payment_screen.dart';
import '../user/savings_screen.dart';
import '../user/credit_screen.dart';
import '../user/currency_exchange_screen.dart';
import '../user/tontine_screen.dart';
import '../user/donation_screen.dart';
import '../merchant/merchant_dashboard_screen.dart';
import 'transaction_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thix Money'),
        actions: const [ModeSwitchWidget()],
        backgroundColor: ThixMoneyTheme.surfaceColor,
        elevation: 0,
      ),
      body: Consumer<MerchantProvider>(
        builder: (ctx, merchantProv, _) {
          if (merchantProv.isMerchantMode) {
            return const MerchantDashboardScreen();
          } else {
            return const UserDashboardBody();
          }
        },
      ),
    );
  }
}

class UserDashboardBody extends StatelessWidget {
  const UserDashboardBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThixMoneyProvider>(context);
    final totalBalance = provider.totalBalance;

    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(balance: totalBalance),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildServicesGrid(context),
            const SizedBox(height: 24),
            RecentTransactionsList(
              transactions: provider.recentTransactions,
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ServiceButton(
          icon: Icons.send,
          label: 'Envoyer',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen())),
        ),
        ServiceButton(
          icon: Icons.qr_code_scanner,
          label: 'Scanner',
          onTap: () {
            // Implémentez le scan QR
          },
        ),
        ServiceButton(
          icon: Icons.receipt,
          label: 'Factures',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPaymentScreen())),
        ),
      ],
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {'icon': Icons.account_balance_wallet, 'label': 'Comptes', 'screen': AccountsScreen()},
      {'icon': Icons.savings, 'label': 'Épargne', 'screen': SavingsScreen()},
      {'icon': Icons.credit_card, 'label': 'Crédit', 'screen': CreditScreen()},
      {'icon': Icons.currency_exchange, 'label': 'Change', 'screen': CurrencyExchangeScreen()},
      {'icon': Icons.group, 'label': 'Tontine', 'screen': TontineScreen()},
      {'icon': Icons.card_giftcard, 'label': 'Dons', 'screen': DonationScreen()},
      {'icon': Icons.split_screen, 'label': 'Fractionné', 'screen': SplitPaymentScreen()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Services financiers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.9,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: services.length,
          itemBuilder: (ctx, i) {
            final s = services[i];
            return ServiceButton(
              icon: s['icon'] as IconData,
              label: s['label'] as String,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => s['screen'] as Widget)),
            );
          },
        ),
      ],
    );
  }
}
