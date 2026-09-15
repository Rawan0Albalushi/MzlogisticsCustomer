import '../../../core/utils/json_utils.dart';
import '../../../shared/models/organization.dart';

class Quotation {
  const Quotation({
    required this.id,
    this.reference,
    this.shipmentRequestId,
    this.totalPrice,
    this.currency,
    this.truckCount,
    this.truckType,
    this.truckTypeLabel,
    this.truckCapacityTons,
    this.tripCount,
    this.quantityPerTrip,
    this.durationDays,
    this.additionalCosts,
    this.conditions,
    this.validUntil,
    this.status,
    this.provider,
    this.createdAt,
  });

  final int id;
  final String? reference;
  final int? shipmentRequestId;
  final double? totalPrice;
  final String? currency;
  final int? truckCount;
  final String? truckType;
  final String? truckTypeLabel;
  final double? truckCapacityTons;
  final int? tripCount;
  final double? quantityPerTrip;
  final int? durationDays;
  final double? additionalCosts;
  final String? conditions;
  final DateTime? validUntil;
  final String? status;
  final Organization? provider;
  final DateTime? createdAt;

  bool get canAccept => status == 'submitted';
  bool get isAccepted => status == 'accepted';
  bool get isSubmitted => status == 'submitted';

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: asInt(json['id']) ?? 0,
      reference: asString(json['reference']),
      shipmentRequestId: asInt(json['shipment_request_id']),
      totalPrice: asDouble(json['total_price']),
      currency: asString(json['currency']) ?? 'OMR',
      truckCount: asInt(json['truck_count']),
      truckType: asString(json['truck_type']),
      truckTypeLabel: asString(json['truck_type_label']),
      truckCapacityTons: asDouble(json['truck_capacity_tons']),
      tripCount: asInt(json['trip_count']),
      quantityPerTrip: asDouble(json['quantity_per_trip']),
      durationDays: asInt(json['duration_days']),
      additionalCosts: asDouble(json['additional_costs']),
      conditions: asString(json['conditions']),
      validUntil: asDateTime(json['valid_until']),
      status: asString(json['status']),
      provider: json['provider'] is Map
          ? Organization.fromJson(asMap(json['provider']))
          : null,
      createdAt: asDateTime(json['created_at']),
    );
  }
}
