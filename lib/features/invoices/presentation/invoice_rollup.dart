import '../data/invoice_model.dart';

bool invoiceIsOverdue(Invoice invoice, DateTime now) {
  final due = invoice.dueAt;
  if (invoice.status != 'issued' || due == null) return false;
  final dueLocal = due.toLocal();
  final nowLocal = now.toLocal();
  final dueDay = DateTime(dueLocal.year, dueLocal.month, dueLocal.day);
  final today = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
  return dueDay.isBefore(today);
}
