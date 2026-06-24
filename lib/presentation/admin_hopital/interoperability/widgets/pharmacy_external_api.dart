// 📁 lib/presentation/admin_hopital/interoperability/widgets/pharmacy_external_api.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class PharmacyExternalApi extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onUpdate;

  const PharmacyExternalApi({Key? key, required this.onUpdate}) : super(key: key);

  @override
  ConsumerState<PharmacyExternalApi> createState() => _PharmacyExternalApiState();
}

class _PharmacyExternalApiState extends ConsumerState<PharmacyExternalApi> {
  bool _isEnabled = false;
  bool _isSyncing = false;
  String _status = 'Désactivé';
  String _syncInterval = '15 min';
  String _endpoint = 'https://api.externe-pharmacie.fr/orders';
  String _apiKey = 'pharm_****';
  List<String> _connectedPharmacies = ['Pharmacie Dubois', 'Pharmacie Bernard'];
  String _lastSync = 'Jamais';
  bool _autoValidate = false;

  final List<String> _syncIntervals = ['5 min', '15 min', '30 min', '1h', '2h', 'Manuel'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEnabled ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_pharmacy, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Pharmacies externes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isEnabled ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _isEnabled ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isEnabled,
                    onChanged: (v) {
                      setState(() {
                        _isEnabled = v;
                        _status = v ? 'Actif' : 'Désactivé';
                      });
                      widget.onUpdate({'enabled': v});
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Endpoint
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'URL du service',
                    hintText: 'https://api.externe-pharmacie.fr',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (v) => setState(() => _endpoint = v),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'API: $_apiKey',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Synchronisation
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: DropdownButtonFormField<String>(
                    value: _syncInterval,
                    items: _syncIntervals.map((i) {
                      return DropdownMenuItem(
                        value: i,
                        child: Text('Synchro: $i', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: _isEnabled
                        ? (v) => setState(() => _syncInterval = v ?? _syncInterval)
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Fréquence de synchronisation',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _autoValidate,
                      onChanged: (v) => setState(() => _autoValidate = v ?? false),
                      activeColor: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Auto-validation',
                      style: TextStyle(
                        fontSize: 12,
                        color: _autoValidate ? Colors.green : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Pharmacies connectées
          const Text(
            'Pharmacies connectées',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _connectedPharmacies.map((pharmacy) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            pharmacy,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                AdminGradientButton(
                  text: 'Ajouter',
                  onPressed: () {
                    setState(() {
                      _connectedPharmacies.add('Pharmacie ${_connectedPharmacies.length + 1}');
                    });
                  },
                  height: 30,
                  width: 80,
                  gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Dernière synchronisation
          Row(
            children: [
              const Icon(Icons.history, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Dernière synchronisation: $_lastSync',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const Spacer(),
              AdminGradientButton(
                text: _isSyncing ? 'Synchro en cours...' : 'Synchroniser',
                onPressed: _isEnabled && !_isSyncing ? _syncNow : null,
                height: 30,
                width: 120,
                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
      _status = 'Synchronisation...';
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isSyncing = false;
        _status = 'Actif';
        _lastSync = DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 16);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Synchronisation terminée'), backgroundColor: Colors.green),
      );
      widget.onUpdate({'synced': DateTime.now()});
    }
  }
}
