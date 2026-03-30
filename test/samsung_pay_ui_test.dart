import 'package:flutter_test/flutter_test.dart';
import 'package:hyperpay_payment_sdk/model/samsung_pay_ui.dart';

void main() {
  group('SamsungPayUI', () {
    test('constructs with all required fields', () {
      const model = SamsungPayUI(
        checkoutId: 'checkout_123',
        merchantName: 'My Store',
        serviceId: 'samsung_service_id',
        orderNumber: 'ORDER_001',
        amount: '10.00',
      );

      expect(model.checkoutId, 'checkout_123');
      expect(model.merchantName, 'My Store');
      expect(model.serviceId, 'samsung_service_id');
      expect(model.orderNumber, 'ORDER_001');
      expect(model.amount, '10.00');
    });
  });
}
