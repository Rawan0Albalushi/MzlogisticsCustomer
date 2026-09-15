import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_customer_app/features/jobs/data/job_model.dart';
import 'package:mz_logistics_customer_app/features/payments/data/payment_model.dart';
import 'package:mz_logistics_customer_app/features/payments/data/payment_status_result.dart';

void main() {
  const job = TransportJob(id: 41, reference: 'JOB-41');

  test('pending invoice checkout is not treated as paid just because a job exists', () {
    const result = PaymentStatusResult(
      status: 'processing',
      payment: Payment(id: 9, status: 'processing'),
      job: job,
    );

    expect(result.isPaid, isFalse);
  });

  test('invoice payments are identified from invoice_id or an existing job', () {
    const withInvoice = PaymentStatusResult(
      status: 'processing',
      payment: Payment(id: 9, invoiceId: 17, status: 'processing'),
    );
    const withJob = PaymentStatusResult(
      status: 'processing',
      payment: Payment(id: 10, status: 'processing'),
      job: job,
    );
    const quotationCheckout = PaymentStatusResult(
      status: 'processing',
      payment: Payment(id: 11, status: 'processing'),
    );

    expect(withInvoice.isInvoicePayment, isTrue);
    expect(withInvoice.settlesExistingJob, isTrue);
    expect(withJob.isPaid, isFalse);
    expect(withJob.settlesExistingJob, isTrue);
    expect(quotationCheckout.settlesExistingJob, isFalse);
  });

  test('completed payments are paid even when the job payload is missing', () {
    const result = PaymentStatusResult(status: 'completed');

    expect(result.isPaid, isTrue);
  });
}
