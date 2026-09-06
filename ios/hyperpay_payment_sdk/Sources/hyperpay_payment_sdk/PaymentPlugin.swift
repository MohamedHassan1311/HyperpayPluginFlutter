import Flutter

/// Entry point registered by Flutter's generated plugin registrant
/// (`pluginClass: PaymentPlugin` in pubspec.yaml).
///
/// It used to be an Objective-C shim in `ios/Classes`, but Swift Package
/// Manager does not support targets that mix Objective-C and Swift, so the
/// shim is a Swift class exported to Objective-C under the same name.
@objc(PaymentPlugin)
public class PaymentPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftPaymentPlugin.register(with: registrar)
    }
}
