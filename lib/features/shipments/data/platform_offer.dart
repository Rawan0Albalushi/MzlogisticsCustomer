import '../../../core/utils/json_utils.dart';

class PlatformOffer {
  const PlatformOffer({
    required this.id,
    this.reference,
    this.shipmentRequestId,
    this.customerPrice,
    this.currency,
    this.truckCount,
    this.truckType,
    this.truckTypeLabel,
    this.tripCount,
    this.durationDays,
    this.transportStartDate,
    this.conditions,
    this.validUntil,
    this.status,
  });

  final int id;
  final String? reference;
  final int? shipmentRequestId;
  final double? customerPrice;
  final String? currency;
  final int? truckCount;
  final String? truckType;
  final String? truckTypeLabel;
  final int? tripCount;
  final int? durationDays;
  final DateTime? transportStartDate;
  final String? conditions;
  final DateTime? validUntil;
  final String? status;

  bool get canAccept => status == 'published';

  factory PlatformOffer.fromJson(Map<String, dynamic> json) {
    return PlatformOffer(
      id: asInt(json['id']) ?? 0,
      reference: asString(json['reference']),
      shipmentRequestId: asInt(json['shipment_request_id']),
      customerPrice: asDouble(json['customer_price']),
      currency: asString(json['currency']) ?? 'OMR',
      truckCount: asInt(json['truck_count']),
      truckType: asString(json['truck_type']),
      truckTypeLabel: asString(json['truck_type_label']),
      tripCount: asInt(json['trip_count']),
      durationDays: asInt(json['duration_days']),
      transportStartDate: asDateTime(json['transport_start_date']),
      conditions: asString(json['conditions']),
      validUntil: asDateTime(json['valid_until']),
      status: asString(json['status']),
    );
  }
}
