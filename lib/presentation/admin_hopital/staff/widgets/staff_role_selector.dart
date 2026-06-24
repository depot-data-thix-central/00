// 📁 lib/presentation/admin_hopital/staff/widgets/staff_role_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/hospital/staff_model.dart';

class StaffRoleSelector extends StatefulWidget {
  final Function(List<StaffRole>) onRolesChanged;
  final List<StaffRole>? initialRoles;
  final bool isMultiSelect;

  const StaffRoleSelector({
    Key? key,
    required this.onRolesChanged,
    this.initialRoles,
    this.isMultiSelect = true,
  }) : super(key: key);

  @override
  State<StaffRoleSelector> createState() => _StaffRoleSelectorState();
}

class _StaffRoleSelectorState extends State<StaffRoleSelector> {
  List<StaffRole> _selectedRoles = [];

  final List<StaffRole> _availableRoles = [
    StaffRole(name: 'Médecin', icon: Icons.local_hospital, color: Colors.green, description: 'Consultations, prescriptions'),
    StaffRole(name: 'Infirmier', icon: Icons.health_and_safety, color: Colors.blue, description: 'Soins, transmissions'),
    StaffRole(name: 'Chirurgien', icon: Icons.surgery, color: Colors.purple, description: 'Interventions chirurgicales'),
    StaffRole(name: 'Anesthésiste', icon: Icons.medical_services, color: Colors.deepPurple, description: 'Anesthésie per-opératoire'),
    StaffRole(name: 'Radiologue', icon: Icons.image, color: Colors.indigo, description: 'Imagerie médicale'),
    StaffRole(name: 'Biologiste', icon: Icons.science, color: Colors.orange, description: 'Analyses biologiques'),
    StaffRole(name: 'Pharmacien', icon: Icons.medication, color: Colors.teal, description: 'Gestion des médicaments'),
    StaffRole(name: 'Secrétaire', icon: Icons.assignment, color: Colors.brown, description: 'Accueil, administratif'),
    StaffRole(name: 'Administrateur', icon: Icons.settings, color: Colors.red, description: 'Gestion de l\'établissement'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialRoles != null && widget.initialRoles!.isNotEmpty) {
      _selectedRoles = widget.initialRoles!;
    } else if (!widget.isMultiSelect && _availableRoles.isNotEmpty) {
      // Sélectionner le premier par défaut si pas de sélection et mode mono
      _selectedRoles = [_availableRoles.first];
    }
  }

  @override
  void didUpdateWidget(covariant StaffRoleSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoles != oldWidget.initialRoles && widget.initialRoles != null) {
      setState(() {
        _selectedRoles = widget.initialRoles!;
      });
    }
  }

  void _toggleRole(StaffRole role) {
    setState(() {
      if (widget.isMultiSelect) {
        if (_selectedRoles.contains(role)) {
          _selectedRoles.remove(role);
        } else {
          _selectedRoles.add(role);
        }
      } else {
        _selectedRoles = [role];
      }
      widget.onRolesChanged(_selectedRoles);
    });
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
              const Icon(Icons.people, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                widget.isMultiSelect ? 'Rôles et permissions' : 'Rôle principal',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (widget.isMultiSelect && _selectedRoles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedRoles.length} sélectionné${_selectedRoles.length > 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.isMultiSelect)
            const Text(
              'Sélectionnez les rôles de ce membre du personnel',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          else
            const Text(
              'Sélectionnez le rôle principal de ce membre',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const SizedBox(height: 12),
          ..._availableRoles.map((role) {
            final isSelected = _selectedRoles.contains(role);
            return InkWell(
              onTap: () => _toggleRole(role),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? role.color.withOpacity(0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? role.color : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? role.color : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(role.icon, size: 18, color: isSelected ? Colors.white : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                role.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? role.color : Colors.grey.shade800,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            role.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? role.color.withOpacity(0.8) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isMultiSelect)
                      Radio<bool>(
                        value: true,
                        groupValue: isSelected ? true : null,
                        onChanged: (_) => _toggleRole(role),
                        activeColor: role.color,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isMultiSelect
                        ? 'Les permissions sont cumulatives. Un médecin peut aussi avoir des droits administratifs.'
                        : 'Le rôle principal détermine les permissions par défaut.',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modèle de rôle (peut être déplacé dans un fichier séparé)
class StaffRole {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  StaffRole({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffRole && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
