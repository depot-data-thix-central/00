// 📁 lib/presentation/admin_hopital/security/widgets/two_factor_setup.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class TwoFactorSetup extends ConsumerStatefulWidget {
  final Function(bool) onToggle;
  final bool initialStatus;

  const TwoFactorSetup({
    Key? key,
    required this.onToggle,
    this.initialStatus = false,
  }) : super(key: key);

  @override
  ConsumerState<TwoFactorSetup> createState() => _TwoFactorSetupState();
}

class _TwoFactorSetupState extends ConsumerState<TwoFactorSetup> {
  late bool _isEnabled;
  String _selectedMethod = 'SMS';
  final List<String> _methods = ['SMS', 'Authenticator App', 'Email'];

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialStatus;
  }

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
              const Icon(Icons.security, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Authentification à deux facteurs',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Switch(
                value: _isEnabled,
                onChanged: (v) {
                  setState(() => _isEnabled = v);
                  widget.onToggle(v);
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.green.shade100,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isEnabled
                ? 'L\'authentification à deux facteurs est activée'
                : 'Activez l\'authentification à deux facteurs pour renforcer la sécurité',
            style: TextStyle(
              fontSize: 13,
              color: _isEnabled ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
          if (_isEnabled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'La double authentification est active',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<String>(
                      value: _selectedMethod,
                      items: _methods.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedMethod = v ?? _selectedMethod),
                      decoration: InputDecoration(
                        labelText: 'Méthode de vérification',
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
                  child: AdminGradientButton(
                    text: 'Configurer',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Configuration de la 2FA'), backgroundColor: Colors.blue),
                      );
                    },
                    height: 38,
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Utilisez $_selectedMethod pour recevoir votre code de vérification.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
