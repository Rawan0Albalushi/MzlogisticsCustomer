import '../../core/utils/json_utils.dart';
import 'organization.dart';

class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.locale,
    this.userType,
    this.isActive = true,
    this.organizationId,
    this.organization,
    this.roles = const [],
    this.permissions = const [],
    this.lastLoginAt,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? locale;
  final String? userType;
  final bool isActive;
  final int? organizationId;
  final Organization? organization;
  final List<String> roles;
  final List<String> permissions;
  final DateTime? lastLoginAt;

  bool get canManageCompany =>
      permissions.contains('company.manage') || roles.contains('Company Admin');

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: asInt(json['id']) ?? 0,
      name: asString(json['name']) ?? '',
      email: asString(json['email']) ?? '',
      phone: asString(json['phone']),
      locale: asString(json['locale']),
      userType: asString(json['user_type']),
      isActive: asBool(json['is_active'], fallback: true),
      organizationId: asInt(json['organization_id']),
      organization: json['organization'] is Map
          ? Organization.fromJson(asMap(json['organization']))
          : null,
      roles: asList(json['roles']).map((item) => item.toString()).toList(),
      permissions: asList(json['permissions']).map((item) => item.toString()).toList(),
      lastLoginAt: asDateTime(json['last_login_at']),
    );
  }
}
