import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_customer_app/core/i18n/i18n_controller.dart';
import 'package:mz_logistics_customer_app/features/payments/data/bank_account.dart';
import 'package:mz_logistics_customer_app/features/payments/data/payment_model.dart';
import 'package:mz_logistics_customer_app/features/payments/data/transfer_pending_args.dart';
import 'package:mz_logistics_customer_app/features/payments/presentation/transfer_pending_screen.dart';

void main() {
  test('bank transfer payments can carry a customer receipt', () {
    const pending = Payment(id: 4, method: 'bank_transfer', status: 'pending');
    const uploaded = Payment(
      id: 4,
      method: 'bank_transfer',
      status: 'pending',
      hasReceipt: true,
    );
    const card = Payment(id: 5, method: 'thawani', status: 'pending');

    expect(pending.canUploadReceipt, isTrue);
    expect(pending.hasReceipt, isFalse);
    expect(uploaded.canUploadReceipt, isTrue);
    expect(card.canUploadReceipt, isFalse);
  });

  testWidgets('bank transfer screen asks for a receipt photo', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const bundle = I18nBundle(
      locale: Locale('en'),
      strings: {
        'payment.transferTitle': 'Awaiting bank transfer',
        'payment.transferBody': 'Upload a photo of the receipt.',
        'payment.transferAccount': 'Transfer to',
        'payment.bankName': 'Bank',
        'payment.accountName': 'Account name',
        'payment.accountNumber': 'Account number',
        'payment.iban': 'IBAN',
        'common.reference': 'Reference',
        'payment.receiptLabel': 'Transfer receipt',
        'payment.receiptHint': 'Upload a clear photo of the bank transfer receipt.',
        'payment.chooseReceipt': 'Choose image',
        'payment.submitReceipt': 'Submit receipt',
        'payment.viewPayments': 'View payments',
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          i18nControllerProvider.overrideWith(() => _FixedI18n(bundle)),
        ],
        child: const MaterialApp(
          home: TransferPendingScreen(
            args: TransferPendingArgs(
              paymentId: 9,
              reference: 'PAY-9',
              bankAccount: BankAccount(
                bankName: 'Bank Muscat',
                accountName: 'MZ Logistics',
                accountNumber: '0123456789',
                iban: 'OM123',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Upload a photo of the receipt.'), findsOneWidget);
    expect(find.text('Bank Muscat'), findsOneWidget);
    expect(find.text('Choose image'), findsOneWidget);
    expect(find.text('Submit receipt'), findsOneWidget);

    final submit = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Submit receipt'),
    );
    expect(submit.onPressed, isNull);
  });
}

class _FixedI18n extends I18nController {
  _FixedI18n(this.bundle);

  final I18nBundle bundle;

  @override
  Future<I18nBundle> build() async => bundle;
}
