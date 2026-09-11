import '../../jobs/data/job_model.dart';
import '../../payments/data/payment_model.dart';

class QuotationAcceptResult {
  const QuotationAcceptResult({
    required this.requiresCheckout,
    this.paymentLink,
    this.payment,
    this.job,
  });

  final bool requiresCheckout;
  final String? paymentLink;
  final Payment? payment;
  final TransportJob? job;
}
