import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_customer_app/features/invoices/data/invoice_model.dart';
import 'package:mz_logistics_customer_app/features/invoices/presentation/invoice_rollup.dart';

void main() {
  test('an issued invoice becomes overdue only after the due date', () {
    final due = DateTime(2026, 9, 20);
    final issued = Invoice(id: 1, status: 'issued', dueAt: due, amount: 10);

    expect(invoiceIsOverdue(issued, DateTime(2026, 9, 20, 23, 30)), isFalse);
    expect(invoiceIsOverdue(issued, DateTime(2026, 9, 21)), isTrue);
    expect(
      invoiceIsOverdue(
        Invoice(id: 2, status: 'paid', dueAt: due),
        DateTime(2026, 9, 21),
      ),
      isFalse,
    );
  });
}
