import '../../../core/utils/json_utils.dart';
import '../../payments/data/payment_model.dart';

class Invoice {
  const Invoice({
    required this.id,
    this.reference,
    this.type,
    this.amount,
    this.currency,
    this.status,
    this.issuedAt,
    this.dueAt,
    this.jobReference,
    this.jobId,
    this.payment,
  });

  final int id;
  final String? reference;
  final String? type;
  final double? amount;
  final String? currency;
  final String? status;
  final DateTime? issuedAt;
  final DateTime? dueAt;
  final String? jobReference;
  final int? jobId;
  final Payment? payment;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final job = asMap(json['job']);
    return Invoice(
      id: asInt(json['id']) ?? 0,
      reference: asString(json['reference']),
      type: asString(json['type']),
      amount: asDouble(json['amount']),
      currency: asString(json['currency']) ?? 'OMR',
      status: asString(json['status']),
      issuedAt: asDateTime(json['issued_at']),
      dueAt: asDateTime(json['due_at']),
      jobReference: asString(job['reference']),
      jobId: asInt(job['id']),
      payment: json['payment'] is Map ? Payment.fromJson(asMap(json['payment'])) : null,
    );
  }
}
