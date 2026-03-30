import 'dart:io';

import 'package:flutter/material.dart';

import 'checkout_view.dart';
import 'view_models/home_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperPay Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

// ── Home View ──────────────────────────────────────────────────────────────────

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HyperPay Demo')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ResultBanner(message: _viewModel.resultMessage),

                // ── Ready UI ─────────────────────────────────────────────
                _SectionTitle('Ready UI'),
                _PayButton(
                  label: 'Pay [VISA, MASTER, MADA, STC_PAY, APPLEPAY]',
                  onTap: _viewModel.payReadyUI,
                ),

                // ── Custom UI ────────────────────────────────────────────
                _SectionTitle('Custom UI'),
                _PayButton(
                  label: 'Pay with Card Form',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutView()),
                  ),
                ),

                // ── STC Pay ──────────────────────────────────────────────
                _SectionTitle('STC Pay'),
                _PayButton(
                  label: 'Pay with STC Pay',
                  color: Colors.red.shade600,
                  onTap: _viewModel.paySTCPay,
                ),

                // ── Google Pay (Android only) ─────────────────────────────
                if (Platform.isAndroid) ...[
                  _SectionTitle('Google Pay (Android)'),
                  _PayButton(
                    label: 'Pay with Google Pay',
                    color: Colors.green.shade700,
                    onTap: _viewModel.payGooglePay,
                  ),
                ],

                // ── Samsung Pay (Android only) ────────────────────────────
                if (Platform.isAndroid) ...[
                  _SectionTitle('Samsung Pay (Android)'),
                  _PayButton(
                    label: 'Pay with Samsung Pay',
                    color: Colors.indigo.shade700,
                    onTap: _viewModel.paySamsungPay,
                  ),
                ],

                // ── BIN Lookup ────────────────────────────────────────────
                _SectionTitle('BIN Lookup / Card Brand Detection'),
                _PayButton(
                  label: 'Detect Card Brand',
                  color: Colors.orange.shade700,
                  onTap: _viewModel.lookupBrands,
                ),

                // ── Apple Pay (iOS only) ──────────────────────────────────
                if (Platform.isIOS) ...[
                  _SectionTitle('Apple Pay (iOS)'),
                  _ApplePayButton(onTap: _viewModel.payApplePay),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_viewModel.isLoading) const _LoadingOverlay(),
        ],
      ),
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        message!,
        style: const TextStyle(fontSize: 15),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blue.shade700,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 15)),
    );
  }
}

class _ApplePayButton extends StatelessWidget {
  const _ApplePayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apple, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Pay with Apple Pay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x55000000),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
