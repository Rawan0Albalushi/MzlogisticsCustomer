import '../../../core/utils/json_utils.dart';

class PaymentMethod {
  const PaymentMethod({
    required this.code,
    required this.name,
    this.nameAr,
    this.processor,
    this.isActive = true,
  });

  final String code;
  final String name;
  final String? nameAr;
  final String? processor;
  final bool isActive;

  bool get isThawani => processor == 'thawani';
  bool get isCash => processor == 'cash';

  String displayName(String locale) {
    if (locale == 'ar' && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      code: asString(json['code']) ?? '',
      name: asString(json['name']) ?? asString(json['label']) ?? '',
      nameAr: asString(json['name_ar']),
      processor: asString(json['processor']),
      isActive: asBool(json['is_active'], fallback: true),
    );
  }
}
