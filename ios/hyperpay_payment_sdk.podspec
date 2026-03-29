#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint payment.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'hyperpay_payment_sdk'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for seamless HyperPay payment gateway integration.'
  s.description      = <<-DESC
A Flutter plugin for seamless HyperPay payment gateway integration.
Supports ReadyUI & CustomUI, VISA, MasterCard, MADA, STC Pay, and Apple Pay on Android & iOS.
                       DESC
  s.homepage         = 'https://github.com/MohamedHassan1311/HyperpayPluginFlutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mohamed Elbaz' => 'mohamedelbaz1311@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency 'hyperpay_sdk' , '~> 6.16.0'

 end
