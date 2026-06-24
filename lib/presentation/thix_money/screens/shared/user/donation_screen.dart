import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/donation_viewmodel.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DonationViewmodel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dons & Contributions')),
      body: ListView(
        children: [
          ...vm.campaigns.map((campaign) => ListTile(
                title: Text(campaign.name),
                subtitle: Text('${campaign.collected}/${campaign.target} FC'),
                trailing: ElevatedButton(
                  onPressed: () => _showDonateDialog(context, vm, campaign.id),
                  child: const Text('Donner'),
                ),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showCreateCampaignDialog(context, vm),
            child: const Text('Créer une collecte'),
          ),
        ],
      ),
    );
  }

  void _showDonateDialog(BuildContext context, DonationViewmodel vm, String campaignId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Montant du don'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Montant (FC)'),
          keyboardType: TextInputType.number,
          onChanged: (v) => vm.donationAmount = double.tryParse(v) ?? 0,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await vm.donate(campaignId);
              Navigator.pop(context);
            },
            child: const Text('Donner'),
          ),
        ],
      ),
    );
  }

  void _showCreateCampaignDialog(BuildContext context, DonationViewmodel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouvelle collecte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nom'),
              onChanged: (v) => vm.newCampaignName = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Objectif (FC)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => vm.newCampaignTarget = double.tryParse(v) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await vm.createCampaign();
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
