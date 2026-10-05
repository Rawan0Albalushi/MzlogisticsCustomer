import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../jobs/data/job_model.dart';
import 'bank_account.dart';
import 'payment_model.dart';
import 'payment_status_result.dart';

class PaymentRepository {
  PaymentRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<Payment>> list({int page = 1}) async {
    final envelope = await _api.get('/payments', query: {'page': page});
    return PagedResult(
      items: envelope.list
          .whereType<Map>()
          .map((item) => Payment.fromJson(asMap(item)))
          .toList(),
      meta: PaginationMeta.fromJson(envelope.meta.isEmpty ? envelope.map : envelope.meta),
    );
  }

  Future<BankAccount> bankAccount() async {
    final envelope = await _api.get('/settings/bank-account');
    return BankAccount.fromJson(envelope.map);
  }

  Future<Payment> uploadReceipt({
    required int id,
    required Uint8List bytes,
    required String filename,
  }) async {
    final form = FormData.fromMap({
      'receipt': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final envelope = await _api.post('/payments/$id/receipt', data: form);
    return Payment.fromJson(asMap(envelope.map['payment']));
  }

  Future<PaymentStatusResult> status(int id) async {
    final envelope = await _api.get('/payments/$id/status');
    final map = envelope.map;
    return PaymentStatusResult(
      status: asString(map['status']),
      payment: map['payment'] is Map ? Payment.fromJson(asMap(map['payment'])) : null,
      job: map['job'] is Map ? TransportJob.fromJson(asMap(map['job'])) : null,
    );
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});
