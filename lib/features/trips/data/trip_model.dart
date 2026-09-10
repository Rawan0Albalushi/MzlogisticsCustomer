import '../../../core/utils/json_utils.dart';
import '../../../shared/models/user.dart';

class TruckSummary {
  const TruckSummary({
    required this.id,
    this.plateNumber,
    this.type,
    this.capacityTons,
  });

  final int id;
  final String? plateNumber;
  final String? type;
  final double? capacityTons;

  factory TruckSummary.fromJson(Map<String, dynamic> json) {
    return TruckSummary(
      id: asInt(json['id']) ?? 0,
      plateNumber: asString(json['plate_number']),
      type: asString(json['type']),
      capacityTons: asDouble(json['capacity_tons']),
    );
  }
}

class ProofOfDelivery {
  const ProofOfDelivery({
    required this.id,
    this.receiverName,
    this.otpVerified = false,
    this.photoPaths = const [],
    this.receivedQuantity,
    this.signaturePath,
    this.notes,
    this.lat,
    this.lng,
    this.capturedAt,
  });

  final int id;
  final String? receiverName;
  final bool otpVerified;
  final List<String> photoPaths;
  final double? receivedQuantity;
  final String? signaturePath;
  final String? notes;
  final double? lat;
  final double? lng;
  final DateTime? capturedAt;

  factory ProofOfDelivery.fromJson(Map<String, dynamic> json) {
    return ProofOfDelivery(
      id: asInt(json['id']) ?? 0,
      receiverName: asString(json['receiver_name']),
      otpVerified: asBool(json['otp_verified']),
      photoPaths: asList(json['photo_paths']).map((item) => item.toString()).toList(),
      receivedQuantity: asDouble(json['received_quantity']),
      signaturePath: asString(json['signature_path']),
      notes: asString(json['notes']),
      lat: asDouble(json['lat']),
      lng: asDouble(json['lng']),
      capturedAt: asDateTime(json['captured_at']),
    );
  }
}

class Trip {
  const Trip({
    required this.id,
    this.reference,
    this.sequence,
    this.status,
    this.plannedQuantity,
    this.deliveredQuantity,
    this.pickupAddress,
    this.pickupCity,
    this.pickupLat,
    this.pickupLng,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryLat,
    this.deliveryLng,
    this.currentLat,
    this.currentLng,
    this.etaAt,
    this.assignedAt,
    this.arrivedPickupAt,
    this.loadedAt,
    this.inTransitAt,
    this.arrivedAt,
    this.deliveredAt,
    this.completedAt,
    this.jobId,
    this.jobReference,
    this.truck,
    this.driver,
    this.proofOfDelivery,
    this.createdAt,
  });

  final int id;
  final String? reference;
  final int? sequence;
  final String? status;
  final double? plannedQuantity;
  final double? deliveredQuantity;
  final String? pickupAddress;
  final String? pickupCity;
  final double? pickupLat;
  final double? pickupLng;
  final String? deliveryAddress;
  final String? deliveryCity;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? currentLat;
  final double? currentLng;
  final DateTime? etaAt;
  final DateTime? assignedAt;
  final DateTime? arrivedPickupAt;
  final DateTime? loadedAt;
  final DateTime? inTransitAt;
  final DateTime? arrivedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final int? jobId;
  final String? jobReference;
  final TruckSummary? truck;
  final UserAccount? driver;
  final ProofOfDelivery? proofOfDelivery;
  final DateTime? createdAt;

  bool get hasTracking => currentLat != null && currentLng != null;
  bool get hasPod => proofOfDelivery != null;

  factory Trip.fromJson(Map<String, dynamic> json) {
    final job = asMap(json['job']);
    return Trip(
      id: asInt(json['id']) ?? 0,
      reference: asString(json['reference']),
      sequence: asInt(json['sequence']),
      status: asString(json['status']),
      plannedQuantity: asDouble(json['planned_quantity']),
      deliveredQuantity: asDouble(json['delivered_quantity']),
      pickupAddress: asString(json['pickup_address']),
      pickupCity: asString(json['pickup_city']),
      pickupLat: asDouble(json['pickup_lat']),
      pickupLng: asDouble(json['pickup_lng']),
      deliveryAddress: asString(json['delivery_address']),
      deliveryCity: asString(json['delivery_city']),
      deliveryLat: asDouble(json['delivery_lat']),
      deliveryLng: asDouble(json['delivery_lng']),
      currentLat: asDouble(json['current_lat']),
      currentLng: asDouble(json['current_lng']),
      etaAt: asDateTime(json['eta_at']),
      assignedAt: asDateTime(json['assigned_at']),
      arrivedPickupAt: asDateTime(json['arrived_pickup_at']),
      loadedAt: asDateTime(json['loaded_at']),
      inTransitAt: asDateTime(json['in_transit_at']),
      arrivedAt: asDateTime(json['arrived_at']),
      deliveredAt: asDateTime(json['delivered_at']),
      completedAt: asDateTime(json['completed_at']),
      jobId: asInt(job['id']),
      jobReference: asString(job['reference']),
      truck: json['truck'] is Map ? TruckSummary.fromJson(asMap(json['truck'])) : null,
      driver: json['driver'] is Map ? UserAccount.fromJson(asMap(json['driver'])) : null,
      proofOfDelivery: json['proof_of_delivery'] is Map
          ? ProofOfDelivery.fromJson(asMap(json['proof_of_delivery']))
          : null,
      createdAt: asDateTime(json['created_at']),
    );
  }
}
