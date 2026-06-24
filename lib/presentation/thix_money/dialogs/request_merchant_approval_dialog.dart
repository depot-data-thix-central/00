 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/merchant_provider.dart';
import '../theme/thix_money_theme.dart';

class RequestMerchantApprovalDialog extends StatefulWidget {
  const RequestMerchantApprovalDialog({Key? key}) : super(key: key);

  @override
  State<RequestMerchantApprovalDialog> createState() => _RequestMerchantApprovalDialogState();
}

class _RequestMerchantApprovalDialogState extends State<RequestMerchantApprovalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _taxIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Devenir marchand'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Remplissez ce formulaire pour demander l\'approbation.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(labelText: 'Nom du commerce'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _businessTypeController,
                decoration: const InputDecoration(labelText: 'Type d\'activité'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _taxIdController,
                decoration: const InputDecoration(labelText: 'Numéro d\'identification fiscale (optionnel)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone de contact'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isSubmitting = true);
                    final merchantProv = Provider.of<MerchantProvider>(context, listen: false);
                    final success = await merchantProv.requestMerchantApproval({
                      'businessName': _businessNameController.text,
                      'businessType': _businessTypeController.text,
                      'taxId': _taxIdController.text,
                      'phone': _phoneController.text,
                    });
                    setState(() => _isSubmitting = false);
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demande envoyée ! Un administrateur va l\'examiner.')),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur lors de l\'envoi. Réessayez.')),
                      );
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: ThixMoneyTheme.primaryColor,
          ),
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Envoyer la demande'),
        ),
      ],
    );
  }
}
