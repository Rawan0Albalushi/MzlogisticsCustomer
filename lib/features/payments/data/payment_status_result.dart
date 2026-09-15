import '../../jobs/data/job_model.dart';
import 'payment_model.dart';

class PaymentStatusResult {
  const PaymentStatusResult({
    this.status,
    this.payment,
    this.job,
  });

  final String? status;
  final Payment? payment;
  final TransportJob? job;

  bool get isPaid {
    final value = (status ?? payment?.status)?.toLowerCase();
    return value == 'completed' || value == 'paid';
  }

  bool get isInvoicePayment => payment?.invoiceId != null;

  bool get settlesExistingJob => isInvoicePayment || job != null;
}
