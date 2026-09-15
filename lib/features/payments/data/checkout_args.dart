class CheckoutArgs {
  const CheckoutArgs({
    this.paymentLink,
    this.jobId,
    this.invoicePayment = false,
  });

  final String? paymentLink;
  final int? jobId;
  final bool invoicePayment;

  static CheckoutArgs fromExtra(Object? extra) {
    if (extra is CheckoutArgs) return extra;
    if (extra is String && extra.isNotEmpty) {
      return CheckoutArgs(paymentLink: extra);
    }
    return const CheckoutArgs();
  }
}
