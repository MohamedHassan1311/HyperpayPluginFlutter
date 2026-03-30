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
