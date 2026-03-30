import 'package:flutter/foundation.dart';
import 'package:hyperpay_payment_sdk/flutter_hyperpay.dart';
import 'package:hyperpay_payment_sdk/model/custom_ui_stc.dart';
import 'package:hyperpay_payment_sdk/model/google_pay_ui.dart';
import 'package:hyperpay_payment_sdk/model/ready_ui.dart';
import 'package:hyperpay_payment_sdk/model/samsung_pay_ui.dart';

import '../core/constants/app_constants.dart';
import '../data/repositories/payment_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({PaymentRepository? repository})
      : _repository = repository ?? const PaymentRepository(),
        _hyperPay = FlutterHyperPay(
          shopperResultUrl: AppConstants.shopperResultUrl,
          paymentMode: PaymentMode.test,
          lang: AppConstants.lang,
        );

  final PaymentRepository _repository;
  final FlutterHyperPay _hyperPay;

  bool _disposed = false;
  bool _isLoading = false;
  String? _resultMessage;

  bool get isLoading => _isLoading;
  String? get resultMessage => _resultMessage;

  // ── Public payment actions ─────────────────────────────────────────────────

  Future<void> payReadyUI() => _runPayment(() async {
        final checkoutId = await _requireCheckoutId();
        if (checkoutId == null) return;

        final result = await _hyperPay.readyUICards(
          readyUI: ReadyUI(
            brandsName: const ['VISA', 'MASTER', 'MADA', 'STC_PAY', 'APPLEPAY'],
            checkoutId: checkoutId,
            merchantIdApplePayIOS: AppConstants.merchantId,
            countryCodeApplePayIOS: AppConstants.countryCode,
            companyNameApplePayIOS: 'Test Co',
            themColorHexIOS: '#000000',
            setStorePaymentDetailsMode: false,
            supportedNetworksApplePayIOS: const ['visa', 'masterCard', 'mada'],
          ),
        );
        await _resolveResult(result, checkoutId);
      });

  Future<void> paySTCPay() => _runPayment(() async {
        final checkoutId = await _requireCheckoutId();
        if (checkoutId == null) return;

        final result = await _hyperPay.customUISTC(
          customUISTC: CustomUISTC(
            checkoutId: checkoutId,
            phoneNumber: '5055555555',
          ),
        );
        await _resolveResult(result, checkoutId);
      });

  Future<void> payGooglePay() => _runPayment(() async {
        final checkoutId = await _requireCheckoutId();
        if (checkoutId == null) return;

        final result = await _hyperPay.googlePayUI(
          googlePayUI: GooglePayUI(
            checkoutId: checkoutId,
            googlePayMerchantId: 'YOUR_GOOGLE_PAY_MERCHANT_ID',
            gatewayMerchantId: 'YOUR_HYPERPAY_ENTITY_ID',
            countryCode: 'SA',
            currencyCode: 'SAR',
            amount: '10.00',
            allowedCardNetworks: const ['VISA', 'MASTERCARD', 'MADA'],
            allowedCardAuthMethods: const ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
          ),
        );
        await _resolveResult(result, checkoutId);
      });

  Future<void> paySamsungPay() => _runPayment(() async {
        final checkoutId = await _requireCheckoutId();
        if (checkoutId == null) return;

        final result = await _hyperPay.samsungPayUI(
          samsungPayUI: SamsungPayUI(
            checkoutId: checkoutId,
            merchantName: 'Test Store',
            serviceId: 'YOUR_SAMSUNG_PAY_SERVICE_ID',
            orderNumber: 'ORDER_001',
            amount: '10.00',
          ),
        );
        await _resolveResult(result, checkoutId);
      });

  Future<void> payApplePay() => _runPayment(() async {
        final checkoutId = await _requireCheckoutId();
        if (checkoutId == null) return;

        final result = await _hyperPay.readyUICards(
          readyUI: ReadyUI(
            checkoutId: checkoutId,
            brandsName: const ['APPLEPAY'],
            merchantIdApplePayIOS: AppConstants.merchantId,
            countryCodeApplePayIOS: AppConstants.countryCode,
            companyNameApplePayIOS: 'Test Co',
            themColorHexIOS: '#000000',
            supportedNetworksApplePayIOS: const ['visa', 'masterCard', 'mada'],
          ),
        );
        await _resolveResult(result, checkoutId);
      });

  Future<void> lookupBrands() => _runPayment(() async {
        final checkoutId = await _requireCheckoutId();
        if (checkoutId == null) return;

        final brands = await _hyperPay.requestBrands(checkoutId: checkoutId);
        _setResult(
          brands.isEmpty
              ? 'No brand detected.'
              : 'Detected brands: ${brands.join(', ')}',
        );
      });

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _runPayment(Future<void> Function() action) async {
    _setLoading(true);
    try {
      await action();
    } catch (e) {
      _setResult('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> _requireCheckoutId() async {
    final id = await _repository.getCheckoutId();
    if (id == null) _setResult('Failed to create a checkout session.');
    return id;
  }

  Future<void> _resolveResult(
      PaymentResultData result, String checkoutId) async {
    switch (result.paymentResult) {
      case PaymentResult.success:
        final status = await _repository.getPaymentStatus(checkoutId);
        _setResult('Payment successful! Status: $status');
        break;
      case PaymentResult.sync:
        final status = await _repository.getPaymentStatus(checkoutId);
        _setResult('Payment processing (SYNC). Status: $status');
        break;
      case PaymentResult.error:
        _setResult('Error [${result.errorCode}]: ${result.errorString}');
        break;
      case PaymentResult.noResult:
        _setResult('Payment cancelled.');
        break;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _notify();
  }

  void _setResult(String message) {
    _resultMessage = message;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
