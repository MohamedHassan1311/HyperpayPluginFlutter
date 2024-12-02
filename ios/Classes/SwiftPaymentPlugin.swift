import Flutter
import UIKit
import SafariServices

public class SwiftPaymentPlugin: NSObject,FlutterPlugin ,SFSafariViewControllerDelegate, OPPCheckoutProviderDelegate, UIAdaptivePresentationControllerDelegate, OPPThreeDSEventListener  {
    var type:String = "";
    var mode:String = "";
    var checkoutid:String = "";
    var brand:String = "";
    var brandsReadyUi:[String] = [];
    var STCPAY:String = "";
    var number:String = "";
    var holder:String = "";
    var year:String = "";
    var month:String = "";
    var cvv:String = "";
    var pMadaVExp:String = "";
    var prMadaMExp:String = "";
    var brands:String = "";
    var shopperResultURL:String = "";
    var tokenID:String = "";
    var payTypeSotredCard:String = "";
    var applePaybundel:String = "";
    var countryCode:String = "";
    var currencyCode:String = "";
    var setStorePaymentDetailsMode:String = "";
    var lang:String = "";
    var amount:Double = 1;
    var themColorHex:String = "";
    var companyName:String = "";
    var safariVC: SFSafariViewController?
    var transaction: OPPTransaction?
    var provider = OPPPaymentProvider(mode: OPPProviderMode.test)
    var checkoutProvider: OPPCheckoutProvider?
    var Presult:FlutterResult?
    var window: UIWindow?


  public static func register(with registrar: FlutterPluginRegistrar) {
    let flutterChannel:String = "Hyperpay.sdk.fultter/channel";
    let channel = FlutterMethodChannel(name: flutterChannel, binaryMessenger: registrar.messenger())
    let instance = SwiftPaymentPlugin()
    registrar.addApplicationDelegate(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)

  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.Presult = result

        if call.method == "gethyperpayresponse"{
            let args = call.arguments as? Dictionary<String,Any>
            self.type = (args!["type"] as? String)!
            self.mode = (args!["mode"] as? String)!
            self.checkoutid = (args!["checkoutid"] as? String)!
            self.shopperResultURL = (args!["ShopperResultUrl"] as? String)!
            self.lang=(args!["lang"] as? String)!



             if self.type == "ReadyUI" {


//                 if self.brandsReadyUi.contains("APPLEPAY") {
//                     print(self.brandsReadyUi.count)
//                     self.onApplePay()
//
//                }

                self.applePaybundel=(args!["merchantId"] as? String)!
                self.countryCode=(args!["CountryCode"] as? String)!
                self.companyName=(args!["companyName"] as? String)!
                self.brandsReadyUi = (args!["brand"]) as! [String]
                self.themColorHex=(args!["themColorHexIOS"] as? String)!

                self.setStorePaymentDetailsMode=(args!["setStorePaymentDetailsMode"] as? String )!
                DispatchQueue.main.async {
                    self.openCheckoutUI(checkoutId: self.checkoutid, result1: result)
                }
            }
            else if self.type  == "CustomUI"{
                 self.brands = (args!["brand"] as? String)!
                 self.number = (args!["card_number"] as? String)!
                 self.holder = (args!["holder_name"] as? String)!
                 self.year = (args!["year"] as? String)!
                 self.month = (args!["month"] as? String)!
                 self.cvv = (args!["cvv"] as? String)!
                 self.setStorePaymentDetailsMode = (args!["EnabledTokenization"] as? String)!
                 self.openCustomUI(checkoutId: self.checkoutid, result1: result)
            }
            else {
                result(FlutterError(code: "1", message: "Method name is not found", details: ""))
                    }

        } else {
                result(FlutterError(code: "1", message: "Method name is not found", details: ""))
            }
        }


    private func openCheckoutUI(checkoutId: String,result1: @escaping FlutterResult) {

         if self.mode == "live" {
             self.provider = OPPPaymentProvider(mode: OPPProviderMode.live)
         }else{
             self.provider = OPPPaymentProvider(mode: OPPProviderMode.test)
         }
         DispatchQueue.main.async{

             let checkoutSettings = OPPCheckoutSettings()
             checkoutSettings.paymentBrands = self.brandsReadyUi;
             if(self.brandsReadyUi.contains("APPLEPAY")){

//
                     let paymentRequest = OPPPaymentProvider.paymentRequest(withMerchantIdentifier: self.applePaybundel, countryCode: self.countryCode)
                     paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: self.companyName, amount: NSDecimalNumber(value: self.amount))]

                     if #available(iOS 12.1.1, *) {
                         paymentRequest.supportedNetworks = [ PKPaymentNetwork.mada,PKPaymentNetwork.visa, PKPaymentNetwork.masterCard ]
                     }
                     else {
                         // Fallback on earlier versions
                         paymentRequest.supportedNetworks = [ PKPaymentNetwork.visa, PKPaymentNetwork.masterCard ]
                     }
                     checkoutSettings.applePayPaymentRequest = paymentRequest
//                     checkoutSettings.paymentBrands = ["APPLEPAY"]
             }
             checkoutSettings.language = self.lang
             // Set available payment brands for your shop
             checkoutSettings.shopperResultURL = self.shopperResultURL+"://result"
             if self.setStorePaymentDetailsMode=="true"{
                 checkoutSettings.storePaymentDetails = OPPCheckoutStorePaymentDetailsMode.prompt;
             }
             self.setThem(checkoutSettings: checkoutSettings, hexColorString: self.themColorHex)
             self.checkoutProvider = OPPCheckoutProvider(paymentProvider: self.provider, checkoutID: checkoutId, settings: checkoutSettings)!
             self.checkoutProvider?.delegate = self
             self.checkoutProvider?.presentCheckout(forSubmittingTransactionCompletionHandler: {
                 (transaction, error) in
                 guard let transaction = transaction else {
                     // Handle invalid transaction, check error
                     // result1("error")
                     result1(FlutterError.init(code: "1",message: "Error: " + self.transaction.debugDescription,details: nil))
                     return
                 }
                 self.transaction = transaction
                 if transaction.type == .synchronous {
                     // If a transaction is synchronous, just request the payment status
                     // You can use transaction.resourcePath or just checkout ID to do it
                     DispatchQueue.main.async {
                         result1("SYNC")
                     }
                 }
                 else if transaction.type == .asynchronous {
                     NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveAsynchronousPaymentCallback), name: Notification.Name(rawValue: "AsyncPaymentCompletedNotificationKey"), object: nil)
                 }
                 else {
                     // result1("error")
                     result1(FlutterError.init(code: "1",message:"Error : operation cancel",details: nil))
                     // Executed in case of failure of the transaction for any reason
                     print(self.transaction.debugDescription)
                 }
             }
                                                    , cancelHandler: {
                                                     result1("error")
                                                     result1(FlutterError.init(code: "1",message: "Error : operation cancel",details: nil))
                                                        // Executed if the shopper closes the payment page prematurely
                                                        print(self.transaction.debugDescription)
                                                    })
         }

     }

//    private func onApplePay() {
//        // Set payment provider mode
//        self.provider = OPPPaymentProvider(mode: self.mode == "live" ? .live : .test)
//
//        // Create payment request
//        guard let paymentRequest = self.provider.paymentRequest(
//            withMerchantIdentifier: self.applePaybundel,
//            countryCode: self.countryCode
//        ) else {
//            NSLog("Failed to create payment request.")
//            return
//        }
//
//        // Configure payment request
//        paymentRequest.currencyCode = self.currencyCode
//        paymentRequest.paymentSummaryItems = [
//            PKPaymentSummaryItem(label: self.companyName,
//                                 amount: NSDecimalNumber(value: self.amount))
//        ]
//
//        // Check if Apple Pay is supported
//        guard self.provider.canSubmitPaymentRequest(paymentRequest) else {
//            NSLog("Apple Pay is not supported.")
//            return
//        }
//
//        // Present the Apple Pay authorization view controller
//        guard let viewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
//            NSLog("Unable to initialize PKPaymentAuthorizationViewController.")
//            return
//        }
//
//        viewController.delegate = self
//
//        if let topViewController = UIApplication.shared.windows.first?.rootViewController {
//            topViewController.present(viewController, animated: true, completion: nil)
//        } else {
//            NSLog("No root view controller available to present the Apple Pay view.")
//        }
//    }


    private func openCustomUI(checkoutId: String,result1: @escaping FlutterResult) {

        if self.mode == "live" {
            self.provider = OPPPaymentProvider(mode: OPPProviderMode.live)
        }else{
            self.provider = OPPPaymentProvider(mode: OPPProviderMode.test)
        }

             if !OPPCardPaymentParams.isNumberValid(self.number, luhnCheck: true) {
                self.createalart(titletext: "Card Number is Invalid", msgtext: "")
                 result1("error")
            }
            else  if !OPPCardPaymentParams.isHolderValid(self.holder) {
                self.createalart(titletext: "Card Holder is Invalid", msgtext: "")
                                 result1("error")

            }
            else   if !OPPCardPaymentParams.isCvvValid(self.cvv) {
                self.createalart(titletext: "CVV is Invalid", msgtext: "")
                                 result1("error")

            }
            else  if !OPPCardPaymentParams.isExpiryYearValid(self.year) {
                self.createalart(titletext: "Expiry Year is Invalid", msgtext: "")
                                 result1("error")

            }
            else  if !OPPCardPaymentParams.isExpiryMonthValid(self.month) {
                self.createalart(titletext: "Expiry Month is Invalid", msgtext: "")
            }
            else {
                do {
                    let params = try OPPCardPaymentParams(checkoutID: checkoutId, paymentBrand: self.brands, holder: self.holder, number: self.number, expiryMonth: self.month, expiryYear: self.year, cvv: self.cvv)
                    var isEnabledTokenization:Bool = false;
                    if(self.setStorePaymentDetailsMode=="true"){
                        isEnabledTokenization=true;
                    }
                    params.isTokenizationEnabled=isEnabledTokenization;
                    //set tokenization
                    params.shopperResultURL =  self.shopperResultURL+"://result"
                    self.transaction  = OPPTransaction(paymentParams: params)
                    self.provider.submitTransaction(self.transaction!) {
                        (transaction, error) in
                        guard let transaction = self.transaction else {
                            // Handle invalid transaction, check error
                            self.createalart(titletext: error as! String, msgtext: error as! String)
                            return
                        }
                        if transaction.type == .asynchronous {
                            self.safariVC = SFSafariViewController(url: self.transaction!.redirectURL!)
                            self.safariVC?.delegate = self;
                            //    self.present(self.safariVC!, animated: true, completion: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(self.safariVC!, animated: true, completion: nil)
                        }
                        else if transaction.type == .synchronous {
                            // Send request to your server to obtain transaction status
                            result1("success")
                        }
                        else {
                            // Handle the error
                            self.createalart(titletext: error as! String, msgtext: "Plesae try again")
                        }
                    }
                    // Set shopper result URL
                    //    params.shopperResultURL = "com.companyname.appname.payments://result"
                }
                catch let error as NSError {
                    // See error.code (OPPErrorCode) and error.localizedDescription to identify the reason of failure
                    self.createalart(titletext: error.localizedDescription, msgtext: "")
                }
            }
    }

    @objc func didReceiveAsynchronousPaymentCallback(result: @escaping FlutterResult) {
        // Remove notification observer
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "AsyncPaymentCompletedNotificationKey"), object: nil)

        // Dismiss all views, regardless of the payment type
        self.dismissAllPresentedViews {
            DispatchQueue.main.async {
                result("success")
            }
        }
    }

    /// Helper function to dismiss all presented views
    private func dismissAllPresentedViews(completion: @escaping () -> Void) {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            if let presentedViewController = rootViewController.presentedViewController {
                presentedViewController.dismiss(animated: true, completion: completion)
            } else {
                completion()
            }
        } else {
            completion()
        }
    }

     public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
           var handler:Bool = false
           if url.scheme?.caseInsensitiveCompare( self.shopperResultURL) == .orderedSame {
               didReceiveAsynchronousPaymentCallback(result: self.Presult!)
               handler = true
           }

           return handler
       }

       func createalart(titletext:String,msgtext:String){
           DispatchQueue.main.async {
               let alertController = UIAlertController(title: titletext, message:
                                                       msgtext, preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default,handler: {
                   (action) in alertController.dismiss(animated: true, completion: nil)
               }))
               //  alertController.view.tintColor = UIColor.orange
               UIApplication.shared.delegate?.window??.rootViewController?.present(alertController, animated: true, completion: nil)
           }

       }
  public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
      // Dismiss the Apple Pay authorization controller
      controller.dismiss(animated: true) {
          // Once dismissed, return the result and dismiss the checkout view
          self.Presult?("success")

          // Close the presentCheckout view or perform any other necessary actions
          self.checkoutProvider?.dismissCheckout(animated: true, completion: {
                self.Presult?("success")
              // Optionally handle any additional actions here after dismissing the checkout view
          })
      }
  }


    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        // Create Apple Pay payment params
        if let params = try? OPPApplePayPaymentParams(checkoutID: self.checkoutid, tokenData: payment.token.paymentData) as OPPApplePayPaymentParams? {
            self.transaction = OPPTransaction(paymentParams: params)
            self.provider.submitTransaction(self.transaction!, completionHandler: { [weak self] (transaction, error) in
                guard let self = self else { return }
                if let error = error {
                    // Handle error
                    self.createalart(titletext: "Apple Pay Error", msgtext: error.localizedDescription)
                    completion(.failure)
                } else {
                    // Transaction was successful
                    completion(.success)
                    // Notify Flutter and close all views
                    self.Presult?("success")
                    self.dismissAllPresentedViews {}
                }
            })
        } else {
            // Handle failure to create payment params
            completion(.failure)
            self.createalart(titletext: "Payment Error", msgtext: "Failed to create payment parameters")
        }
    }

       func decimal(with string: String) -> NSDecimalNumber {
           //  let formatter = NumberFormatter()
           let formatter = NumberFormatter()
           formatter.minimumFractionDigits = 2
           return formatter.number(from: string) as? NSDecimalNumber ?? 0
       }
  public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.Presult!("canceled")
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.Presult!("canceled")
    }
    func setThem( checkoutSettings :OPPCheckoutSettings,hexColorString :String){
         // General colors of the checkout UI
         checkoutSettings.theme.confirmationButtonColor = UIColor(hexString:hexColorString);
         checkoutSettings.theme.navigationBarBackgroundColor = UIColor(hexString:hexColorString);
         checkoutSettings.theme.cellHighlightedBackgroundColor = UIColor(hexString:hexColorString);
         checkoutSettings.theme.accentColor = UIColor(hexString:hexColorString);
     }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
