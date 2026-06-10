## 1.2.0
* **Upgraded to HyperPay Mobile SDK 7.11.0** (Android & iOS) — mandatory update for the
  Mastercard 3D Secure certificate renewal (deadline 2026-07-07).
* **Android:** bundled SDK 7.11.0 AARs; raised to JDK 17, `compileSdk 35`, `minSdkVersion 24`;
  aligned dependency versions (material 1.12.0, appcompat 1.7.0, browser 1.8.0, fragment-ktx 1.8.6,
  constraintlayout 2.2.1, webkit 1.13.0, gson 2.11.0, lifecycle-viewmodel-ktx 2.8.7,
  play-services-wallet 19.4.0).
* **Android:** fixed ReadyUI not returning a result for **ASYNC (3DS) transactions** — the
  Flutter call now completes for both SYNC and ASYNC checkouts so the app no longer hangs
  after a successful 3DS payment.
* **iOS:** vendored `OPPWAMobile.xcframework` + `ipworks3ds_sdk.xcframework` directly in the
  plugin — the external `hyperpay_sdk` pod and the static-framework Podfile workaround are no
  longer needed. Requires Xcode 26 and an iOS 13.0+ deployment target.

## 1.1.2
* Refactored example app to MVVM architecture (ViewModels, PaymentRepository, AppConstants)
* Improved code structure and separation of concerns in the example

## 1.1.1
* Added Google Pay support on Android (`googlePayUI()`)
* Added Samsung Pay support on Android (`samsungPayUI()`)
* Added BIN lookup / card brand detection (`requestBrands()`)
* Added structured error codes: `PaymentResultData.errorCode` field now populated from `PlatformException.code` on all payment flows
* iOS returns `PLATFORM_NOT_SUPPORTED` error for Google Pay and Samsung Pay calls

## 1.1.0
* Refactor browser redirection and error handling

## 1.0.0
* update IOS SDK 6.14.0
