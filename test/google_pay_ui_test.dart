import 'package:flutter_test/flutter_test.dart';
import 'package:hyperpay_payment_sdk/model/google_pay_ui.dart';

void main() {
  group('GooglePayUI', () {
    test('constructs with required fields', () {
      const model = GooglePayUI(
        checkoutId: 'checkout_123',
        googlePayMerchantId: 'gpay_merchant_id',
        gatewayMerchantId: 'gateway_merchant_id',
        countryCode: 'SA',
        currencyCode: 'SAR',
        amount: '10.00',
      );

      expect(model.checkoutId, 'checkout_123');
      expect(model.googlePayMerchantId, 'gpay_merchant_id');
      expect(model.gatewayMerchantId, 'gateway_merchant_id');
      expect(model.countryCode, 'SA');
      expect(model.currencyCode, 'SAR');
      expect(model.amount, '10.00');
    });

    test('has correct default allowedCardNetworks', () {
      const model = GooglePayUI(
        checkoutId: 'c',
        googlePayMerchantId: 'g',
        gatewayMerchantId: 'gw',
        countryCode: 'SA',
        currencyCode: 'SAR',
        amount: '1.00',
      );

      expect(model.allowedCardNetworks, ['VISA', 'MASTERCARD', 'MADA']);
    });

    test('has correct default allowedCardAuthMethods', () {
      const model = GooglePayUI(
        checkoutId: 'c',
        googlePayMerchantId: 'g',
        gatewayMerchantId: 'gw',
        countryCode: 'SA',
        currencyCode: 'SAR',
        amount: '1.00',
      );

      expect(model.allowedCardAuthMethods, ['PAN_ONLY', 'CRYPTOGRAM_3DS']);
    });

    test('accepts custom allowedCardNetworks and allowedCardAuthMethods', () {
      const model = GooglePayUI(
        checkoutId: 'c',
        googlePayMerchantId: 'g',
        gatewayMerchantId: 'gw',
        countryCode: 'SA',
        currencyCode: 'SAR',
        amount: '1.00',
        allowedCardNetworks: ['VISA'],
        allowedCardAuthMethods: ['PAN_ONLY'],
      );

      expect(model.allowedCardNetworks, ['VISA']);
      expect(model.allowedCardAuthMethods, ['PAN_ONLY']);
    });
  });
}
