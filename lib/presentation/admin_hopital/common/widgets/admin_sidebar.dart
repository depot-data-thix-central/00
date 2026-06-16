// 📁 lib/presentation/admin_hopital/common/widgets/admin_sidebar.dart

import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final List<SidebarItem> items;
  final String selectedRoute;
  final Function(String) onItemTap;
  final String? hospitalName;
  final Widget? header;

  const AdminSidebar({
    Key? key,
    required this.items,
    required this.selectedRoute,
    required this.onItemTap,
    this.hospitalName,
    this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          // En-tête (logo / nom)
          if (header != null)
            header!
          else
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_hospital, color: Colors.green),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hospitalName ?? 'THIX HÔPITAL',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 0),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedRoute == item.route;
                return _SidebarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onItemTap(item.route),
                );
              },
            ),
          ),
          const Divider(height: 0),
          // Footer (déconnexion, etc.)
          Container(
            padding: const EdgeInsets.all(12),
            child: TextButton.icon(
              onPressed: () {
                // Déconnexion : à gérer par le provider
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Déconnexion'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badgeCount;

  const SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount,
  });
}

class _SidebarItem extends StatelessWidget {
  final SidebarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.green.shade50,
      splashColor: Colors.green.shade100,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? Colors.green : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: isSelected ? Colors.green : Colors.grey.shade700,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.green : Colors.grey.shade800,
                ),
              ),
            ),
            if (item.badgeCount != null && item.badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.badgeCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
