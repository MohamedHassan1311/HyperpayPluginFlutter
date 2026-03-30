# HyperPay Payment SDK for Flutter

A Flutter plugin that makes integrating the **HyperPay payment gateway** into your mobile app quick and straightforward. Supports ready-made and custom payment UIs, Google Pay, Samsung Pay, BIN lookup, and structured error codes.

[![Pub Version](https://img.shields.io/badge/pub.dev-hyperpay__payment__sdk-blue)](https://pub.dev)
[![GitHub](https://img.shields.io/badge/Github-MohamedHassan1311-blue?logo=github)](https://github.com/MohamedHassan1311)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)]()

---

## Supported Payment Methods

| Method | Android | iOS |
|--------|---------|-----|
| VISA (ReadyUI & CustomUI) | ✅ | ✅ |
| MasterCard (ReadyUI & CustomUI) | ✅ | ✅ |
| MADA *(Saudi Arabia)* | ✅ | ✅ |
| STC Pay | ✅ | ✅ |
| Apple Pay | — | ✅ |
| Google Pay | ✅ | — |
| Samsung Pay | ✅ | — |
| Stored Cards (Tokenized) | ✅ | ✅ |

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  hyperpay_payment_sdk: ^1.1.0
```

Then run:

```bash
flutter pub get
```

---

## Android Setup

### 1. Add SDK dependencies

Open `android/app/build.gradle` and add:

```gradle
implementation(name: "oppwa.mobile-release", ext: 'aar')
debugImplementation(name: "ipworks3ds_sdk", ext: 'aar')
releaseImplementation(name: "ipworks3ds_sdk_deploy", ext: 'aar')
implementation "com.google.android.material:material:1.6.1"
implementation "androidx.appcompat:appcompat:1.5.1"
implementation 'com.google.android.gms:play-services-wallet:19.1.0'
implementation "androidx.browser:browser:1.4.0"
```

> `play-services-wallet:19.1.0` is required for Google Pay.

### 2. Set minimum SDK version

In `app/build.gradle`, ensure:

```gradle
minSdkVersion 21
```

### 3. Add Intent Filter

Open `AndroidManifest.xml` and add the `intent-filter` inside your `<activity>` tag:

```xml
<activity>
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.BROWSABLE" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.LAUNCHER" />
        <data android:scheme="com.testpayment.payment" />
    </intent-filter>
</activity>
```

> **Important:** The `scheme` value must exactly match `InAppPaymentSetting.shopperResultUrl`.

---

## iOS Setup

### 1. Update your Podfile

Open `ios/Podfile` and add:

```ruby
pod 'hyperpay_sdk', :git => 'https://github.com/MohamedHassan1311/hyperpaysdkIOS.git'

$static_framework = ['hyperpay_payment_sdk']
pre_install do |installer|
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
  installer.pod_targets.each do |pod|
    if $static_framework.include?(pod.name)
      def pod.build_type
        Pod::BuildType.static_library
      end
    end
  end
end
```

### 2. Add a URL Scheme in Xcode

1. Open your project in **Xcode**.
2. Select your app **Target** → go to the **Info** tab.
3. Scroll down to **URL Types** and click the **+** button.
4. Fill in:
   - **Identifier**: your bundle ID (e.g. `com.testpayment.payment`)
   - **URL Schemes**: the same value as `InAppPaymentSetting.shopperResultUrl`

> The URL Scheme must exactly match `InAppPaymentSetting.shopperResultUrl`.

---

## Configuration

Define a settings class in your app:

```dart
class InAppPaymentSetting {
  // Must match the scheme in AndroidManifest and Xcode URL Types
  static const String shopperResultUrl = "com.testpayment.payment";
  static const String merchantId = "YOUR_MERCHANT_ID"; // Apple Pay only
  static const String countryCode = "SA";

  static String getLang() {
    if (Platform.isIOS) {
      return "en"; // use "ar" for Arabic
    } else {
      return "en_US"; // use "ar_AR" for Arabic
    }
  }
}
```

Initialize the plugin:

```dart
late FlutterHyperPay flutterHyperPay;

flutterHyperPay = FlutterHyperPay(
  shopperResultUrl: InAppPaymentSetting.shopperResultUrl,
  paymentMode: PaymentMode.test, // switch to PaymentMode.live for production
  lang: InAppPaymentSetting.getLang(),
);
```

---

## Getting a Checkout ID

Before initiating any payment, fetch a checkout ID from your backend:

```dart
Future<String?> getCheckoutId() async {
  final url = Uri.parse('https://your-backend.com/checkout');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body)['id'];
  }
  return null;
}
```

---

## Usage

### Ready UI (Pre-built payment screen)

```dart
PaymentResultData result = await flutterHyperPay.readyUICards(
  readyUI: ReadyUI(
    brandsName: ["VISA", "MASTER", "MADA", "STC_PAY", "APPLEPAY"],
    checkoutId: checkoutId,
    merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
    countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
    companyNameApplePayIOS: "My Company",
    themColorHexIOS: "#000000",
    setStorePaymentDetailsMode: true,
    supportedNetworksApplePayIOS: ["visa", "masterCard", "mada"],
  ),
);
```

### Custom UI (Your own card form)

```dart
PaymentResultData result = await flutterHyperPay.customUICards(
  customUI: CustomUI(
    brandName: "VISA",
    checkoutId: checkoutId,
    cardNumber: "4111111111111111",
    holderName: "John Doe",
    month: 12,
    year: 2025,
    cvv: 123,
    enabledTokenization: false,
  ),
);
```

### STC Pay

```dart
PaymentResultData result = await flutterHyperPay.customUISTC(
  customUISTC: CustomUISTC(
    checkoutId: checkoutId,
    phoneNumber: "5055555555",
  ),
);
```

### Stored Cards (Tokenized payments)

```dart
PaymentResultData result = await flutterHyperPay.payWithSoredCards(
  storedCards: StoredCards(
    brandName: "VISA",
    checkoutId: checkoutId,
    tokenId: tokenId,
    cvv: 123,
  ),
);
```

---

## Google Pay (Android only)

### Prerequisites

Make sure `play-services-wallet:19.1.0` is in your `android/app/build.gradle` (see Android Setup above).

### Usage

```dart
PaymentResultData result = await flutterHyperPay.googlePayUI(
  googlePayUI: GooglePayUI(
    checkoutId: checkoutId,
    googlePayMerchantId: "YOUR_GOOGLE_PAY_MERCHANT_ID",
    gatewayMerchantId: "YOUR_HYPERPAY_ENTITY_ID",
    countryCode: "SA",
    currencyCode: "SAR",
    amount: "10.00",
    // optional — defaults shown:
    allowedCardNetworks: ["VISA", "MASTERCARD", "MADA"],
    allowedCardAuthMethods: ["PAN_ONLY", "CRYPTOGRAM_3DS"],
  ),
);

if (result.paymentResult == PaymentResult.success) {
  // Payment confirmed
} else if (result.paymentResult == PaymentResult.error) {
  print("Error: ${result.errorCode} — ${result.errorString}");
}
```

> **iOS:** Calling `googlePayUI()` on iOS returns `PaymentResult.error` with `errorCode = "PLATFORM_NOT_SUPPORTED"`. No crash.

---

## Samsung Pay (Android only)

```dart
PaymentResultData result = await flutterHyperPay.samsungPayUI(
  samsungPayUI: SamsungPayUI(
    checkoutId: checkoutId,
    merchantName: "My Store",
    serviceId: "YOUR_SAMSUNG_PAY_SERVICE_ID",
    orderNumber: "ORDER_001",
    amount: "10.00",
  ),
);
```

> **iOS:** Calling `samsungPayUI()` on iOS returns `PaymentResult.error` with `errorCode = "PLATFORM_NOT_SUPPORTED"`. No crash.

---

## BIN Lookup / Card Brand Detection

Detect the card brand from a partial card number in real time, without starting a payment session.

```dart
final brands = await flutterHyperPay.requestBrands(
  checkoutId: checkoutId,
);

if (brands.contains("MADA")) {
  // Show MADA logo
} else if (brands.contains("VISA")) {
  // Show VISA logo
}
```

Works on both **Android** and **iOS**.

---

## Handling Payment Results

```dart
void handleResult(PaymentResultData result) {
  switch (result.paymentResult) {
    case PaymentResult.success:
      print("Payment successful!");
      break;
    case PaymentResult.sync:
      print("Payment is being processed...");
      break;
    case PaymentResult.error:
      print("Error [${result.errorCode}]: ${result.errorString}");
      break;
    case PaymentResult.noResult:
      print("Payment cancelled.");
      break;
  }
}
```

### Error Codes Reference

| Code | Meaning | Flow |
|------|---------|------|
| `"PLATFORM_NOT_SUPPORTED"` | Feature called on wrong platform | Google Pay / Samsung Pay on iOS |
| `"GOOGLE_PAY_NOT_AVAILABLE"` | Google Pay not set up on device | Google Pay |
| `"GOOGLE_PAY_CANCELED"` | User dismissed Google Pay sheet | Google Pay |
| `"GOOGLE_PAY_ERROR"` | Transaction submission failed | Google Pay |
| `"SAMSUNG_PAY_NOT_AVAILABLE"` | Samsung Pay not set up on device | Samsung Pay |
| `"SAMSUNG_PAY_ERROR"` | Transaction submission failed | Samsung Pay |
| `"BIN_LOOKUP_ERROR"` | Brand validation request failed | requestBrands |
| `"PAYMENT_ERROR"` | Card payment error | CustomUI / StoredCards |
| `"STC_ERROR"` | STC Pay transaction error | STC Pay |

---

## Apple Pay — Supported Networks

| Network | Value |
|---------|-------|
| Visa | `"visa"` |
| MasterCard | `"masterCard"` |
| Mada | `"mada"` |
| American Express | `"amex"` |
| Maestro | `"maestro"` |
| Discover | `"discover"` |
| JCB | `"jcb"` |
| China UnionPay | `"chinaUnionPay"` |

Default: `["visa", "masterCard", "mada"]`

---

## Customizing ReadyUI Colors (Android)

Open `android/app/src/main/res/values/colors.xml` and override:

```xml
<color name="headerBackground">#000000</color>
<color name="cancelButtonTintColor">#FFFFFF</color>
<color name="listMarkTintColor">#000000</color>
<color name="cameraTintColor">#000000</color>
<color name="checkboxButtonTintColor">#000000</color>
```

---

## License

MIT License — © 2023 Mohamed Elbaz
