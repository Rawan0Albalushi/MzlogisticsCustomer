import 'bank_account.dart';

class TransferPendingArgs {
  const TransferPendingArgs({
    required this.reference,
    required this.bankAccount,
    this.paymentId,
    this.invoicePayment = false,
    this.receiptUploaded = false,
  });

  final String reference;
  final BankAccount bankAccount;
  final int? paymentId;
  final bool invoicePayment;
  final bool receiptUploaded;

  static TransferPendingArgs fromExtra(Object? extra) {
    if (extra is TransferPendingArgs) return extra;
    return const TransferPendingArgs(reference: '', bankAccount: BankAccount());
  }
}
