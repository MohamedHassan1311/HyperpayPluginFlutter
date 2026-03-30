import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enums/brand_type.dart';
import 'extensions/brands_ext.dart';
import 'formatters.dart';
import 'models/card_info.dart';
import 'view_models/checkout_view_model.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late final CheckoutViewModel _viewModel;

  final _formKey = GlobalKey<FormState>();
  final _holderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _viewModel = CheckoutViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    setState(() {});
    final msg = _viewModel.message;
    if (msg != null && !_viewModel.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _holderNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _onPayPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }
    await _viewModel.pay(
      holderName: _holderNameController.text,
      cardNumber: _cardNumberController.text,
      expiry: _expiryController.text,
      cvv: _cvvController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = _viewModel.brandType;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // ── Card Holder ─────────────────────────────────────────
                  TextFormField(
                    controller: _holderNameController,
                    decoration: _inputDecoration(
                      label: 'Card Holder',
                      hint: 'Jane Jones',
                      icon: Icons.account_circle_rounded,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),

                  // ── Card Number ─────────────────────────────────────────
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: _inputDecoration(
                      label: 'Card Number',
                      hint: '0000 0000 0000 0000',
                      icon: brand == BrandType.none
                          ? Icons.credit_card
                          : 'assets/${brand.name}.png',
                    ),
                    onChanged: _viewModel.onCardNumberChanged,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(brand.maxLength),
                      CardNumberInputFormatter(),
                    ],
                    validator: (v) => brand.validateNumber(v ?? ''),
                  ),
                  const SizedBox(height: 10),

                  // ── Expiry Date ─────────────────────────────────────────
                  TextFormField(
                    controller: _expiryController,
                    decoration: _inputDecoration(
                      label: 'Expiry Date',
                      hint: 'MM/YY',
                      icon: Icons.date_range_rounded,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      CardMonthInputFormatter(),
                    ],
                    validator: (v) => CardInfo.validateDate(v ?? ''),
                  ),
                  const SizedBox(height: 10),

                  // ── CVV ─────────────────────────────────────────────────
                  TextFormField(
                    controller: _cvvController,
                    decoration: _inputDecoration(
                      label: 'CVV',
                      hint: '000',
                      icon: Icons.confirmation_number_rounded,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (v) => CardInfo.validateCVV(v ?? ''),
                  ),
                  const SizedBox(height: 30),

                  // ── Pay button ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _viewModel.isLoading ? null : _onPayPressed,
                      child: Text(
                        _viewModel.isLoading
                            ? 'Processing, please wait...'
                            : 'PAY',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_viewModel.isLoading)
            const ColoredBox(
              color: Color(0x55000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? label,
    String? hint,
    required dynamic icon,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      prefixIcon: icon is IconData
          ? Icon(icon)
          : Container(
              padding: const EdgeInsets.all(6),
              width: 10,
              child: Image.asset(icon as String),
            ),
    );
  }
}
