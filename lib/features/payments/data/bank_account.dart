import '../../../core/utils/json_utils.dart';

class BankAccount {
  const BankAccount({
    this.bankName = '',
    this.accountName = '',
    this.accountNumber = '',
    this.iban = '',
  });

  final String bankName;
  final String accountName;
  final String accountNumber;
  final String iban;

  bool get hasDetails =>
      bankName.isNotEmpty || accountName.isNotEmpty || accountNumber.isNotEmpty || iban.isNotEmpty;

  factory BankAccount.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BankAccount();
    return BankAccount(
      bankName: asString(json['bank_name']) ?? '',
      accountName: asString(json['account_name']) ?? '',
      accountNumber: asString(json['account_number']) ?? '',
      iban: asString(json['iban']) ?? '',
    );
  }
}
