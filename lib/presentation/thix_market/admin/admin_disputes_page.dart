import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_provider.dart';

class AdminDisputesPage extends StatefulWidget {
  const AdminDisputesPage({super.key});

  @override
  State<AdminDisputesPage> createState() => _AdminDisputesPageState();
}

class _AdminDisputesPageState extends State<AdminDisputesPage> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDisputes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Gestion des litiges'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminProvider>().loadDisputes(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filtrer par statut:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous')),
                    DropdownMenuItem(value: 'open', child: Text('Ouverts')),
                    DropdownMenuItem(value: 'mediation', child: Text('Médiation')),
                    DropdownMenuItem(value: 'resolved', child: Text('Résolus')),
                    DropdownMenuItem(value: 'closed', child: Text('Fermés')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value!);
                    context.read<AdminProvider>().setStatusFilter(value!);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.disputes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.disputes.isEmpty) {
                  return const Center(child: Text('Aucun litige'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.disputes.length,
                  itemBuilder: (context, index) {
                    final dispute = provider.disputes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text('Litige #${dispute['id']} - Commande #${dispute['order']?['id']}'),
                        subtitle: Text('Statut: ${dispute['status']} - ${dispute['user']?['name']}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Motif: ${dispute['reason']}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    DropdownButton<String>(
                                      value: dispute['status'],
                                      items: const [
                                        DropdownMenuItem(value: 'open', child: Text('Ouvert')),
                                        DropdownMenuItem(value: 'mediation', child: Text('Médiation')),
                                        DropdownMenuItem(value: 'resolved', child: Text('Résolu')),
                                        DropdownMenuItem(value: 'closed', child: Text('Fermé')),
                                      ],
                                      onChanged: (value) => provider.updateDisputeStatus(dispute['id'], value!),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () => _showMediationDialog(context, dispute),
                                      child: const Text('Assigner médiateur'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMediationDialog(BuildContext context, Map<String, dynamic> dispute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assigner un médiateur'),
        content: const Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }
}
