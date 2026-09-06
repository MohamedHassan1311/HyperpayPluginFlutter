#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint payment.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'hyperpay_payment_sdk'
  s.version          = '1.3.0'
  s.summary          = 'A Flutter plugin for seamless HyperPay payment gateway integration.'
  s.description      = <<-DESC
A Flutter plugin for seamless HyperPay payment gateway integration.
Supports ReadyUI & CustomUI, VISA, MasterCard, MADA, STC Pay, and Apple Pay on Android & iOS.
                       DESC
  s.homepage         = 'https://github.com/MohamedHassan1311/HyperpayPluginFlutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mohamed Elbaz' => 'mohamedelbaz1311@gmail.com' }
  s.source           = { :path => '.' }
  # Sources live in the Swift Package Manager layout so that CocoaPods and
  # Swift Package Manager build the exact same files.
  s.source_files = 'hyperpay_payment_sdk/Sources/hyperpay_payment_sdk/**/*.swift'
  s.dependency 'Flutter'
  # HyperPay Mobile SDK 7.11.0 requires iOS 13.0 (OPPWAMobile.framework MinimumOSVersion).
  s.platform = :ios, '13.0'

  # HyperPay Mobile SDK 7.11.0 frameworks, vendored directly (Mastercard 3DS
  # certificate update, mandatory before 2026-07-07). OPPWAMobile bundles its
  # resources inside the framework, and ipworks3ds_sdk is the production
  # ("deploy") 3DS SDK that OPPWAMobile links against at runtime.
  s.vendored_frameworks = 'hyperpay_payment_sdk/Frameworks/OPPWAMobile.xcframework', 'hyperpay_payment_sdk/Frameworks/ipworks3ds_sdk.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

 end
