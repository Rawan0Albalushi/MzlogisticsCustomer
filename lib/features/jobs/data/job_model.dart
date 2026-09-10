import '../../../core/utils/json_utils.dart';
import '../../../shared/models/organization.dart';
import '../../quotations/data/quotation_model.dart';
import '../../shipments/data/shipment_model.dart';
import '../../trips/data/trip_model.dart';

class TransportJob {
  const TransportJob({
    required this.id,
    this.reference,
    this.status,
    this.totalPrice,
    this.currency,
    this.totalQuantity,
    this.deliveredQuantity,
    this.progressPercent,
    this.startedAt,
    this.completedAt,
    this.customer,
    this.provider,
    this.shipment,
    this.quotation,
    this.trips = const [],
    this.createdAt,
  });

  final int id;
  final String? reference;
  final String? status;
  final double? totalPrice;
  final String? currency;
  final double? totalQuantity;
  final double? deliveredQuantity;
  final double? progressPercent;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Organization? customer;
  final Organization? provider;
  final ShipmentRequest? shipment;
  final Quotation? quotation;
  final List<Trip> trips;
  final DateTime? createdAt;

  factory TransportJob.fromJson(Map<String, dynamic> json) {
    return TransportJob(
      id: asInt(json['id']) ?? 0,
      reference: asString(json['reference']),
      status: asString(json['status']),
      totalPrice: asDouble(json['total_price']),
      currency: asString(json['currency']) ?? 'OMR',
      totalQuantity: asDouble(json['total_quantity']),
      deliveredQuantity: asDouble(json['delivered_quantity']),
      progressPercent: asDouble(json['progress_percent']),
      startedAt: asDateTime(json['started_at']),
      completedAt: asDateTime(json['completed_at']),
      customer: json['customer'] is Map
          ? Organization.fromJson(asMap(json['customer']))
          : null,
      provider: json['provider'] is Map
          ? Organization.fromJson(asMap(json['provider']))
          : null,
      shipment: json['shipment'] is Map
          ? ShipmentRequest.fromJson(asMap(json['shipment']))
          : null,
      quotation: json['quotation'] is Map
          ? Quotation.fromJson(asMap(json['quotation']))
          : null,
      trips: asList(json['trips'])
          .whereType<Map>()
          .map((item) => Trip.fromJson(asMap(item)))
          .toList(),
      createdAt: asDateTime(json['created_at']),
    );
  }
}
