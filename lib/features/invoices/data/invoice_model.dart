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
    this.tripId,
    this.tripReference,
    this.payment,
    this.payable = false,
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
  final int? tripId;
  final String? tripReference;
  final Payment? payment;
  final bool payable;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final job = asMap(json['job']);
    final trip = asMap(json['trip']);
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
      tripId: asInt(json['trip_id']) ?? asInt(trip['id']),
      tripReference: asString(trip['reference']),
      payment: json['payment'] is Map ? Payment.fromJson(asMap(json['payment'])) : null,
      payable: asBool(json['payable']),
    );
  }
}
