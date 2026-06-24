// 📁 lib/presentation/admin_hopital/settings/screens/settings_general_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/settings_general_form.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/widgets/admin_gradient_button.dart';

class SettingsGeneralScreen extends ConsumerStatefulWidget {
  const SettingsGeneralScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsGeneralScreen> createState() => _SettingsGeneralScreenState();
}

class _SettingsGeneralScreenState extends ConsumerState<SettingsGeneralScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Données mockées (à remplacer par le provider)
  final Map<String, dynamic> _generalSettings = {
    'name': 'Hôpital Central',
    'address': '12 rue de la République',
    'city': 'Paris',
    'zipCode': '75000',
    'country': 'France',
    'phone': '01 23 45 67 89',
    'email': 'contact@central-hospital.fr',
    'website': 'www.central-hospital.fr',
    'openingHours': 'Lun-Ven: 08h-18h, Sam: 09h-12h',
    'language': 'fr',
    'timezone': 'Europe/Paris',
    'sendNotifications': true,
    'allowSms': false,
    'allowEmail': true,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSettings(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    try {
      // Simuler la sauvegarde
      await Future.delayed(const Duration(seconds: 1));
      // Ici, appeler le provider pour sauvegarder
      // final success = await ref.read(adminSettingsProvider.notifier).updateGeneralSettings(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres enregistrés avec succès'), backgroundColor: Colors.green),
        );
        setState(() => _isSaving = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres généraux'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (_isSaving)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isLoading,
        message: 'Chargement des paramètres...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SettingsGeneralForm(
            initialData: _generalSettings,
            onSave: _saveSettings,
            onCancel: () {
              // Réinitialiser les modifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Modifications annulées'), backgroundColor: Colors.orange),
              );
            },
          ),
        ),
      ),
    );
  }
}
