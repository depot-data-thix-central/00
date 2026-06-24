// 📁 lib/presentation/admin_hopital/security/widgets/encryption_status.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class EncryptionStatus extends ConsumerStatefulWidget {
  final bool isEnabled;
  final String encryptionType;
  final DateTime lastRotation;

  const EncryptionStatus({
    Key? key,
    required this.isEnabled,
    required this.encryptionType,
    required this.lastRotation,
  }) : super(key: key);

  @override
  ConsumerState<EncryptionStatus> createState() => _EncryptionStatusState();
}

class _EncryptionStatusState extends ConsumerState<EncryptionStatus> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final daysSinceRotation = DateTime.now().difference(widget.lastRotation).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isEnabled ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.isEnabled ? Icons.lock_outline : Icons.lock_open_outlined,
                size: 20,
                color: widget.isEnabled ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              const Text(
                'Chiffrement des données',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isEnabled ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.isEnabled ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.isEnabled ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(Icons.key, 'Type: ${widget.encryptionType}'),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.refresh, 'Rotation: $daysSinceRotation jours'),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _showDetails = !_showDetails),
            child: Row(
              children: [
                Text(
                  _showDetails ? 'Masquer les détails' : 'Voir les détails',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  _showDetails ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.blue.shade700,
                ),
              ],
            ),
          ),
          if (_showDetails) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Algorithme', 'AES-256-GCM'),
                  _buildDetailRow('Mode', 'Chiffrement en vol et au repos'),
                  _buildDetailRow('Certificat', 'Validé par l\'ANSSI'),
                  _buildDetailRow('Dernière rotation', '${widget.lastRotation.day}/${widget.lastRotation.month}/${widget.lastRotation.year}'),
                  _buildDetailRow('Prochaine rotation', '${widget.lastRotation.add(const Duration(days: 90)).day}/${widget.lastRotation.add(const Duration(days: 90)).month}/${widget.lastRotation.add(const Duration(days: 90)).year}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AdminGradientButton(
              text: 'Renouveler les clés',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Renouvellement des clés'), backgroundColor: Colors.blue),
                );
              },
              height: 34,
              width: 160,
              gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
