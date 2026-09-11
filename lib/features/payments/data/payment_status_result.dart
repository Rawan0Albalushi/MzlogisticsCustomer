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

  bool get isPaid => status == 'completed' || job != null;
}
