import '../../../core/utils/json_utils.dart';

class Payment {
  const Payment({
    required this.id,
    this.reference,
    this.amount,
    this.commissionAmount,
    this.providerAmount,
    this.currency,
    this.method,
    this.status,
    this.gateway,
    this.gatewayReference,
    this.paymentLink,
    this.paidAt,
    this.createdAt,
  });

  final int id;
  final String? reference;
  final double? amount;
  final double? commissionAmount;
  final double? providerAmount;
  final String? currency;
  final String? method;
  final String? status;
  final String? gateway;
  final String? gatewayReference;
  final String? paymentLink;
  final DateTime? paidAt;
  final DateTime? createdAt;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: asInt(json['id']) ?? 0,
      reference: asString(json['reference']),
      amount: asDouble(json['amount']),
      commissionAmount: asDouble(json['commission_amount']),
      providerAmount: asDouble(json['provider_amount']),
      currency: asString(json['currency']) ?? 'OMR',
      method: asString(json['method']),
      status: asString(json['status']),
      gateway: asString(json['gateway']),
      gatewayReference: asString(json['gateway_reference']),
      paymentLink: asString(json['payment_link']),
      paidAt: asDateTime(json['paid_at']),
      createdAt: asDateTime(json['created_at']),
    );
  }
}
