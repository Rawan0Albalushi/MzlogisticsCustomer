import '../../../shared/models/user.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final UserAccount user;
}

class RegisterCustomerPayload {
  const RegisterCustomerPayload({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.companyName,
    this.phone,
    this.locale = 'en',
  });

  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String companyName;
  final String? phone;
  final String locale;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'account_type': 'company',
      'company_name': companyName,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      'locale': locale,
    };
  }
}
