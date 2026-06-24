// 📁 lib/data/repositories/billing_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../base_repository.dart';
import '../../models/thix_sante/hospital/invoice_model.dart';

class BillingRepository extends BaseRepository {
  // ==================== RÉCUPÉRATION ====================

  /// Récupère toutes les factures
  Future<List<InvoiceModel>> getInvoices() async {
    return execute(() async {
      final response = await client
          .from('invoices')
          .select('*')
          .order('date', ascending: false);
      return response.map((json) => InvoiceModel.fromJson(json)).toList();
    }, operationName: 'getInvoices');
  }

  /// Récupère les factures d'un patient
  Future<List<InvoiceModel>> getInvoicesByPatient(String patientId) async {
    return execute(() async {
      final response = await client
          .from('invoices')
          .select('*')
          .eq('patient_id', patientId)
          .order('date', ascending: false);
      return response.map((json) => InvoiceModel.fromJson(json)).toList();
    }, operationName: 'getInvoicesByPatient');
  }

  // ==================== CRUD ====================

  /// Crée une facture
  Future<InvoiceModel?> createInvoice(InvoiceModel invoice) async {
    return execute(() async {
      final response = await client
          .from('invoices')
          .insert(invoice.toJson())
          .select()
          .single();
      return InvoiceModel.fromJson(response);
    }, operationName: 'createInvoice');
  }

  /// Marque une facture comme payée
  Future<bool> markAsPaid(String invoiceId) async {
    return execute(() async {
      await client
          .from('invoices')
          .update({'status': 'paid'})
          .eq('id', invoiceId);
      return true;
    }, operationName: 'markAsPaid');
  }
}
