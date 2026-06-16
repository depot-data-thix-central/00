// 📁 lib/presentation/admin_hopital/security/widgets/signature_pad.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import '../../../common/widgets/admin_gradient_button.dart';

class SignaturePad extends ConsumerStatefulWidget {
  final Function(Uint8List?) onSignatureSaved;
  final String documentTitle;
  final String signerName;
  final VoidCallback? onCancel;

  const SignaturePad({
    Key? key,
    required this.onSignatureSaved,
    required this.documentTitle,
    required this.signerName,
    this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends ConsumerState<SignaturePad> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isSigned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_document, size: 20, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'Signature électronique',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                widget.documentTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Signataire: ${widget.signerName}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                onPressed: () {
                  _controller.clear();
                  setState(() => _isSigned = false);
                },
                tooltip: 'Effacer',
              ),
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.grey),
                onPressed: () {
                  _controller.undo();
                },
                tooltip: 'Annuler',
              ),
              const Spacer(),
              if (_controller.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Signature enregistrée',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AdminGradientButton(
                  text: 'Valider la signature',
                  onPressed: _controller.isNotEmpty ? _saveSignature : null,
                  icon: Icons.check_circle,
                  gradient: const LinearGradient(colors: [Colors.indigo, Colors.indigoAccent]),
                ),
              ),
              if (widget.onCancel != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Annuler', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveSignature() async {
    final data = await _controller.toPngBytes();
    widget.onSignatureSaved(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signature validée'), backgroundColor: Colors.green),
    );
  }
}
