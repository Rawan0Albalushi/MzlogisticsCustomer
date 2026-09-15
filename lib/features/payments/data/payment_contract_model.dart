import '../../../core/i18n/i18n_controller.dart';
import '../../../core/utils/json_utils.dart';

class PaymentTermsSnapshot {
  const PaymentTermsSnapshot({
    this.billingTrigger = 'on_award',
    this.dueDays = 0,
    this.prepaid = true,
    this.billingUnit = 'job',
    this.contractId,
  });

  final String billingTrigger;
  final int dueDays;
  final bool prepaid;
  final String billingUnit;
  final int? contractId;

  String label(I18nBundle i18n) {
    if (prepaid || billingTrigger == 'on_award') {
      return i18n.t('paymentContract.onAward');
    }
    if (billingUnit == 'trip') {
      if (dueDays <= 0) {
        return i18n.t('paymentContract.perTripImmediate');
      }
      return i18n.t('paymentContract.perTripNetDays', {'days': '$dueDays'});
    }
    if (dueDays <= 0) {
      return i18n.t('paymentContract.fullImmediate');
    }
    return i18n.t('paymentContract.fullNetDays', {'days': '$dueDays'});
  }

  factory PaymentTermsSnapshot.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const PaymentTermsSnapshot();
    }
    final trigger = asString(json['billing_trigger']) ?? 'on_award';
    final dueDays = asInt(json['due_days']) ?? 0;
    return PaymentTermsSnapshot(
      billingTrigger: trigger,
      dueDays: dueDays,
      prepaid: asBool(json['prepaid'], fallback: trigger == 'on_award'),
      billingUnit: asString(json['billing_unit']) ?? 'job',
      contractId: asInt(json['contract_id']),
    );
  }
}

class PaymentContract {
  const PaymentContract({
    required this.id,
    this.organizationId,
    this.billingTrigger = 'on_award',
    this.dueDays = 0,
    this.prepaid = true,
    this.billingUnit = 'job',
    this.pendingBillingTrigger,
    this.pendingDueDays,
    this.pendingBillingUnit,
    this.pendingStatus,
    this.rejectionReason,
  });

  final int id;
  final int? organizationId;
  final String billingTrigger;
  final int dueDays;
  final bool prepaid;
  final String billingUnit;
  final String? pendingBillingTrigger;
  final int? pendingDueDays;
  final String? pendingBillingUnit;
  final String? pendingStatus;
  final String? rejectionReason;

  bool get hasPendingRequest => pendingStatus == 'pending';

  PaymentTermsSnapshot get effectiveTerms => PaymentTermsSnapshot(
        billingTrigger: billingTrigger,
        dueDays: dueDays,
        prepaid: prepaid,
        billingUnit: billingUnit,
      );

  PaymentTermsSnapshot? get pendingTerms {
    if (pendingBillingTrigger == null) return null;
    return PaymentTermsSnapshot(
      billingTrigger: pendingBillingTrigger!,
      dueDays: pendingDueDays ?? 0,
      prepaid: pendingBillingTrigger == 'on_award',
      billingUnit: pendingBillingUnit ?? 'job',
    );
  }

  factory PaymentContract.fromJson(Map<String, dynamic> json) {
    final trigger = asString(json['billing_trigger']) ?? 'on_award';
    return PaymentContract(
      id: asInt(json['id']) ?? 0,
      organizationId: asInt(json['organization_id']),
      billingTrigger: trigger,
      dueDays: asInt(json['due_days']) ?? 0,
      prepaid: asBool(json['prepaid'], fallback: trigger == 'on_award'),
      billingUnit: asString(json['billing_unit']) ?? 'job',
      pendingBillingTrigger: asString(json['pending_billing_trigger']),
      pendingDueDays: asInt(json['pending_due_days']),
      pendingBillingUnit: asString(json['pending_billing_unit']),
      pendingStatus: asString(json['pending_status']),
      rejectionReason: asString(json['rejection_reason']),
    );
  }
}
