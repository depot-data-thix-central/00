// lib/presentation/chat/read_receipts/read_receipts_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/read_receipt_provider.dart';
import 'read_by_list.dart';

class ReadReceiptsView extends StatefulWidget {
  final String messageId;
  final String messageContent;

  const ReadReceiptsView({
    super.key,
    required this.messageId,
    required this.messageContent,
  });

  @override
  State<ReadReceiptsView> createState() => _ReadReceiptsViewState();
}

class _ReadReceiptsViewState extends State<ReadReceiptsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ReadReceiptProvider>(context, listen: false);
    await provider.loadReceipts(widget.messageId);
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReadReceiptProvider>(context);
    final delivered = provider.deliveredUsers;
    final read = provider.readUsers;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Message aperçu
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Message',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.messageContent,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFD4AF37),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFD4AF37),
            tabs: [
              Tab(text: 'Livré (${delivered.length})'),
              Tab(text: 'Lu (${read.length})'),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      ReadByList(users: delivered, type: 'delivered'),
                      ReadByList(users: read, type: 'read'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
