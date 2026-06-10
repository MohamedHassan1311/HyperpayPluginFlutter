# HyperPay Payment SDK for Flutter

A Flutter plugin that makes integrating the **HyperPay payment gateway** into your mobile app quick and straightforward. Supports ready-made and custom payment UIs, Google Pay, Samsung Pay, BIN lookup, and structured error codes.

[![Pub Version](https://img.shields.io/badge/pub.dev-hyperpay__payment__sdk-blue)](https://pub.dev)
[![GitHub](https://img.shields.io/badge/Github-MohamedHassan1311-blue?logo=github)](https://github.com/MohamedHassan1311)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)]()

> **Built on HyperPay Mobile SDK 7.11.0** (Android & iOS). This release is the
> mandatory update for the Mastercard 3D Secure certificate renewal — merchants
> must ship it **before 2026-07-07** to keep Mastercard 3DS authentication and
> transactions working. The native SDK binaries are bundled inside the plugin
> (Android `.aar` files and iOS `.xcframework`s), so you don't need to add any
> external HyperPay pod or AAR yourself.

### Requirements

| | Minimum |
|---|---|
| Android | JDK 17 · `compileSdk 35` · `minSdkVersion 24` |
| iOS | Xcode 26 · iOS 13.0 deployment target |

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
  hyperpay_payment_sdk: ^1.2.0
```

Then run:

```bash
flutter pub get
```

---

## Android Setup

The HyperPay SDK binaries (`oppwa.mobile`, `ipworks3ds_sdk`) are bundled inside
the plugin, so you **don't** need to add the SDK AARs or HyperPay dependencies
yourself. You only need to meet the build requirements and register the redirect
URL scheme.

### 1. Build configuration

In `android/app/build.gradle`, make sure your app targets JDK 17 and the required
SDK levels (the plugin requires `minSdkVersion 24`):

```gradle
android {
    compileSdk 35

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    defaultConfig {
        minSdkVersion 24
    }
}
```

> Build with **JDK 17** and **Android Gradle Plugin 8.x** (Gradle 8.x).

### 2. Add Intent Filter

Add the `intent-filter` inside your launcher `<activity>` in `AndroidManifest.xml`
and set the activity `launchMode` to `singleTop` (or `singleTask`) so the app is
brought back to the foreground after a redirect:

```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTop"
    ... >

    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="com.testpayment.payment" android:host="result" />
    </intent-filter>
</activity>
```

> **Important:** The `scheme` value must exactly match `InAppPaymentSetting.shopperResultUrl`.
>
> For **ReadyUI** on SDK 7.x the checkout activity handles the 3DS challenge and
> the shopper-result redirect internally — the intent-filter is only needed for
> the **CustomUI / STC Pay** flows, but keeping it is harmless.

---

## iOS Setup

The HyperPay SDK frameworks (`OPPWAMobile.xcframework` and
`ipworks3ds_sdk.xcframework`) are vendored inside the plugin, so **no extra pod
is required** — just run `pod install`. If you are upgrading from an older
version, remove any previous HyperPay pod wiring from your `ios/Podfile`:

```ruby
# ❌ Remove these — no longer needed in SDK 7.11.0:
# pod 'hyperpay_sdk', :git => 'https://github.com/MohamedHassan1311/hyperpaysdkIOS.git'
# $static_framework = ['hyperpay_payment_sdk']
# pre_install do |installer| ... end
```

Requirements: **Xcode 26**, an **iOS 13.0+** deployment target, and
`use_frameworks!` in your `Podfile` (the Flutter default).

```bash
cd ios
pod install
```

### Add a URL Scheme in Xcode

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

Google Pay support (`play-services-wallet`) is bundled with the plugin — no extra
dependency is required. Just make sure Google Pay is set up on the test device.

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
