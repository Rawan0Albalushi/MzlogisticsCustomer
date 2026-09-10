import '../../../core/utils/json_utils.dart';

class DashboardSummary {
  const DashboardSummary({
    this.shipmentsOpen = 0,
    this.shipmentsTotal = 0,
    this.quotationsPending = 0,
    this.jobsActive = 0,
    this.jobsCompleted = 0,
    this.tripsActive = 0,
    this.tripsInTransit = 0,
    this.paymentsCompletedAmount = 0,
    this.invoicesCount = 0,
  });

  final int shipmentsOpen;
  final int shipmentsTotal;
  final int quotationsPending;
  final int jobsActive;
  final int jobsCompleted;
  final int tripsActive;
  final int tripsInTransit;
  final double paymentsCompletedAmount;
  final int invoicesCount;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      shipmentsOpen: asInt(json['shipments_open']) ?? 0,
      shipmentsTotal: asInt(json['shipments_total']) ?? 0,
      quotationsPending: asInt(json['quotations_pending']) ?? 0,
      jobsActive: asInt(json['jobs_active']) ?? 0,
      jobsCompleted: asInt(json['jobs_completed']) ?? 0,
      tripsActive: asInt(json['trips_active']) ?? 0,
      tripsInTransit: asInt(json['trips_in_transit']) ?? 0,
      paymentsCompletedAmount: asDouble(json['payments_completed_amount']) ?? 0,
      invoicesCount: asInt(json['invoices_count']) ?? 0,
    );
  }
}
