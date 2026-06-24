// 📁 lib/presentation/admin_hopital/common/providers/admin_billing_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/hospital/invoice_model.dart';
import '../../../../data/repositories/hospital/billing_repository.dart';
import '../../../../core/utils/logger.dart';

final billingRepositoryProvider = Provider((ref) => BillingRepository());

class BillingState {
  final List<InvoiceModel> invoices;
  final double totalRevenue;
  final double pendingAmount;
  final bool isLoading;
  final String? error;

  BillingState({
    this.invoices = const [],
    this.totalRevenue = 0,
    this.pendingAmount = 0,
    this.isLoading = false,
    this.error,
  });

  BillingState copyWith({
    List<InvoiceModel>? invoices,
    double? totalRevenue,
    double? pendingAmount,
    bool? isLoading,
    String? error,
  }) {
    return BillingState(
      invoices: invoices ?? this.invoices,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final adminBillingProvider = StateNotifierProvider<AdminBillingNotifier, BillingState>((ref) {
  final repo = ref.watch(billingRepositoryProvider);
  return AdminBillingNotifier(repo);
});

class AdminBillingNotifier extends StateNotifier<BillingState> {
  final BillingRepository _repository;

  AdminBillingNotifier(this._repository) : super(BillingState(isLoading: true)) {
    loadBillingData();
  }

  Future<void> loadBillingData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invoices = await _repository.getInvoices();
      final total = invoices.fold(0.0, (sum, inv) => sum + inv.amount);
      final pending = invoices.where((inv) => inv.status == 'pending').fold(0.0, (sum, inv) => sum + inv.amount);
      state = BillingState(
        invoices: invoices,
        totalRevenue: total,
        pendingAmount: pending,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Erreur chargement facturation', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<InvoiceModel?> createInvoice(InvoiceModel invoice) async {
    state = state.copyWith(isLoading: true);
    try {
      final created = await _repository.createInvoice(invoice);
      if (created != null) {
        final updatedList = [...state.invoices, created];
        final total = updatedList.fold(0.0, (sum, inv) => sum + inv.amount);
        final pending = updatedList.where((inv) => inv.status == 'pending').fold(0.0, (sum, inv) => sum + inv.amount);
        state = BillingState(
          invoices: updatedList,
          totalRevenue: total,
          pendingAmount: pending,
          isLoading: false,
        );
        return created;
      }
      return null;
    } catch (e) {
      Logger.error('Erreur création facture', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> markAsPaid(String invoiceId) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.markAsPaid(invoiceId);
      if (success) {
        final updatedList = state.invoices.map((inv) {
          if (inv.id == invoiceId) return inv.copyWith(status: 'paid');
          return inv;
        }).toList();
        final total = updatedList.fold(0.0, (sum, inv) => sum + inv.amount);
        final pending = updatedList.where((inv) => inv.status == 'pending').fold(0.0, (sum, inv) => sum + inv.amount);
        state = BillingState(
          invoices: updatedList,
          totalRevenue: total,
          pendingAmount: pending,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Erreur paiement facture', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
