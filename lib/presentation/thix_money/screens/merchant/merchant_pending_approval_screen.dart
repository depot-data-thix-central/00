import 'package:flutter/material.dart';
import '../../theme/thix_money_theme.dart';

class MerchantPendingApprovalScreen extends StatelessWidget {
  const MerchantPendingApprovalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demande marchand')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 80, color: ThixMoneyTheme.warningColor),
              const SizedBox(height: 24),
              const Text(
                'Votre demande pour devenir marchand est en cours de traitement.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                'Un administrateur va vérifier vos informations sous 48h.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ThixMoneyTheme.textSecondaryColor),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Retour à l’accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
