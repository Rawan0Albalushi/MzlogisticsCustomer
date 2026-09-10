import '../../core/utils/json_utils.dart';

class Organization {
  const Organization({
    required this.id,
    this.type,
    this.accountType,
    this.name,
    this.nameAr,
    this.commercialRegister,
    this.taxNumber,
    this.email,
    this.phone,
    this.city,
    this.country,
    this.address,
    this.status,
  });

  final int id;
  final String? type;
  final String? accountType;
  final String? name;
  final String? nameAr;
  final String? commercialRegister;
  final String? taxNumber;
  final String? email;
  final String? phone;
  final String? city;
  final String? country;
  final String? address;
  final String? status;

  String displayName(String locale) {
    if (locale == 'ar' && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name ?? '—';
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: asInt(json['id']) ?? 0,
      type: asString(json['type']),
      accountType: asString(json['account_type']),
      name: asString(json['name']),
      nameAr: asString(json['name_ar']),
      commercialRegister: asString(json['commercial_register']),
      taxNumber: asString(json['tax_number']),
      email: asString(json['email']),
      phone: asString(json['phone']),
      city: asString(json['city']),
      country: asString(json['country']),
      address: asString(json['address']),
      status: asString(json['status']),
    );
  }
}
