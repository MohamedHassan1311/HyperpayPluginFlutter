import 'package:flutter/foundation.dart';
import 'package:hyperpay_payment_sdk/flutter_hyperpay.dart';
import 'package:hyperpay_payment_sdk/model/custom_ui.dart';

import '../core/constants/app_constants.dart';
import '../data/repositories/payment_repository.dart';
import '../enums/brand_type.dart';
import '../extensions/brands_ext.dart';

class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel({PaymentRepository? repository})
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
  BrandType _brandType = BrandType.none;
  String? _message;
  bool? _isSuccess;

  bool get isLoading => _isLoading;
  BrandType get brandType => _brandType;
  String? get message => _message;
  bool? get isSuccess => _isSuccess;

  // ── Actions ────────────────────────────────────────────────────────────────

  void onCardNumberChanged(String value) {
    final detected = value.detectBrand;
    if (detected != _brandType) {
      _brandType = detected;
      _notify();
    }
  }

  Future<void> pay({
    required String holderName,
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    _isLoading = true;
    _message = null;
    _isSuccess = null;
    _notify();

    try {
      final checkoutId = await _repository.getCheckoutId();
      if (checkoutId == null) {
        _setResult(success: false, message: 'Failed to create a checkout session.');
        return;
      }

      final parts = expiry.split('/');
      final result = await _hyperPay.customUICards(
        customUI: CustomUI(
          brandName: 'MADA',
          checkoutId: checkoutId,
          cardNumber: cardNumber.replaceAll(' ', ''),
          holderName: holderName,
          month: parts[0],
          year: '20${parts[1]}',
          cvv: cvv,
          enabledTokenization: false,
        ),
      );

      switch (result.paymentResult) {
        case PaymentResult.success:
        case PaymentResult.sync:
          final status = await _repository.getPaymentStatus(checkoutId);
          _setResult(success: true, message: 'Payment successful! Status: $status');
          break;
        case PaymentResult.error:
          _setResult(
            success: false,
            message: 'Error [${result.errorCode}]: ${result.errorString}',
          );
          break;
        case PaymentResult.noResult:
          _setResult(success: false, message: 'Payment cancelled.');
          break;
      }
    } catch (e) {
      _setResult(success: false, message: 'Unexpected error: $e');
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _setResult({required bool success, required String message}) {
    _isSuccess = success;
    _message = message;
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
