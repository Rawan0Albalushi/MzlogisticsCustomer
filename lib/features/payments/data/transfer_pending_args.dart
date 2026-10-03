import 'bank_account.dart';

class TransferPendingArgs {
  const TransferPendingArgs({
    required this.reference,
    required this.bankAccount,
    this.invoicePayment = false,
  });

  final String reference;
  final BankAccount bankAccount;
  final bool invoicePayment;

  static TransferPendingArgs fromExtra(Object? extra) {
    if (extra is TransferPendingArgs) return extra;
    return const TransferPendingArgs(reference: '', bankAccount: BankAccount());
  }
}
