import '../../jobs/data/job_model.dart';
import '../../payments/data/bank_account.dart';
import '../../payments/data/payment_model.dart';

class QuotationAcceptResult {
  const QuotationAcceptResult({
    required this.requiresCheckout,
    this.awaitingTransfer = false,
    this.paymentLink,
    this.payment,
    this.job,
    this.bankAccount = const BankAccount(),
  });

  final bool requiresCheckout;
  final bool awaitingTransfer;
  final String? paymentLink;
  final Payment? payment;
  final TransportJob? job;
  final BankAccount bankAccount;
}
