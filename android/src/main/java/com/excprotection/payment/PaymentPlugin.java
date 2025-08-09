package com.excprotection.payment;

import com.oppwa.mobile.connect.payment.PaymentParams;
import com.oppwa.mobile.connect.payment.card.CardPaymentParams;
import com.oppwa.mobile.connect.payment.stcpay.STCPayPaymentParams;
import com.oppwa.mobile.connect.payment.stcpay.STCPayVerificationOption;
import com.oppwa.mobile.connect.provider.ITransactionListener;
import com.oppwa.mobile.connect.provider.OppPaymentProvider;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import com.oppwa.mobile.connect.checkout.dialog.CheckoutActivity;
import com.oppwa.mobile.connect.checkout.meta.CheckoutSettings;
import com.oppwa.mobile.connect.checkout.meta.CheckoutStorePaymentDetailsMode;
import com.oppwa.mobile.connect.exception.PaymentError;
import com.oppwa.mobile.connect.exception.PaymentException;
import com.oppwa.mobile.connect.payment.BrandsValidation;
import com.oppwa.mobile.connect.payment.CheckoutInfo;
import com.oppwa.mobile.connect.payment.ImagesRequest;
import com.oppwa.mobile.connect.payment.token.TokenPaymentParams;
import com.oppwa.mobile.connect.provider.Connect;
//import com.oppwa.mobile.connect.provider.ITransactionListener;
import com.oppwa.mobile.connect.provider.Transaction;
import com.oppwa.mobile.connect.provider.TransactionType;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import com.oppwa.mobile.connect.provider.ThreeDSWorkflowListener;


public class PaymentPlugin  implements
    PluginRegistry.ActivityResultListener ,ActivityAware
    , FlutterPlugin, MethodCallHandler , PluginRegistry.NewIntentListener, ITransactionListener {

    private  MethodChannel.Result Result;
    private  String mode = "";
    private List<String> brandsReadyUi ;
    private String brands = "" ;
    private String Lang = "";
    private String EnabledTokenization = "";
    private String ShopperResultUrl = "";
    private String setStorePaymentDetailsMode = "";
    private String number, holder, cvv, year, month;
    private String TokenID = "";
    private OppPaymentProvider paymentProvider  = null ;
    private Activity activity;
    private Context context;


    private final Handler handler = new Handler(Looper.getMainLooper());

    /// The MethodChannel that will the communication between Flutter and native Android
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private MethodChannel channel;
    String CHANNEL = "Hyperpay.demo.fultter/channel";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        Result = result;
        if (call.method.equals("gethyperpayresponse")) {

            String checkoutId = call.argument("checkoutid");
            String type = call.argument("type");
            mode = call.argument("mode");
            Lang = call.argument("lang");
            ShopperResultUrl = call.argument("ShopperResultUrl");

            // Debug: Show the expected redirect URL
//            sendDebugLogToFlutter("🚀 Payment Started",
//                "Expected redirect: " + ShopperResultUrl + "://result");

            switch (type != null ? type : "NullType") {
                case "ReadyUI" :
                    brandsReadyUi = call.argument("brand");
                    setStorePaymentDetailsMode = call.argument("setStorePaymentDetailsMode");
                    openCheckoutUI(checkoutId) ;
                    break;
                case "StoredCards" :
                    cvv = call.argument("cvv");
                    TokenID = call.argument("TokenID");
                    storedCardPayment(checkoutId);
                    break;

                case "CustomUI" :
                    brands = call.argument("brand");
                    number = call.argument("card_number");
                    holder = call.argument("holder_name");
                    year = call.argument("year");
                    month = call.argument("month");
                    cvv = call.argument("cvv");
                    EnabledTokenization = call.argument("EnabledTokenization");
                    openCustomUI(checkoutId);
                    break;

                case "CustomUISTC":
                    number = call.argument("phone_number");
                    openCustomUISTC(checkoutId);
                    break;

                default : error("1", "THIS TYPE NO IMPLEMENT" + type, "");
            }

        } else {
            notImplemented();
        }

    }

    private void openCheckoutUI(String checkoutId) {

        Set<String> paymentBrands = new LinkedHashSet<>(brandsReadyUi);
        // CHECK PAYMENT MODE
        CheckoutSettings checkoutSettings;
        if (mode.equals("live")) {
            //LIVE MODE
            checkoutSettings = new CheckoutSettings(checkoutId, paymentBrands,
                Connect.ProviderMode.LIVE);


        } else {
            // TEST MODE
            checkoutSettings = new CheckoutSettings(checkoutId, paymentBrands,
                Connect.ProviderMode.TEST);
        }

        // SET LANG
        checkoutSettings.setLocale(Lang);

        checkoutSettings.setPaymentFormListener(new CustomFormListener());

        // SHOW TOTAL PAYMENT AMOUNT IN BUTTON
        // checkoutSettings.setTotalAmountRequired(true);

        //SET SHOPPER
        //checkoutSettings.setShopperResultUrl(ShopperResultUrl + "://result");

        //SAVE PAYMENT CARDS FOR NEXT
        if (setStorePaymentDetailsMode.equals("true")) {
            checkoutSettings.setStorePaymentDetailsMode(CheckoutStorePaymentDetailsMode.PROMPT);
        }else{
            checkoutSettings.setStorePaymentDetailsMode(CheckoutStorePaymentDetailsMode.NEVER);
        }

        //CHANGE THEME
        checkoutSettings.setThemeResId(R.style.NewCheckoutTheme);

        // CHECKOUT BROADCAST RECEIVER
        ComponentName componentName = new ComponentName(
            context.getPackageName(), CheckoutBroadcastReceiver.class.getName());

        // SET UP THE INTENT AND START THE CHECKOUT ACTIVITY

        Intent intent = new Intent(context.getApplicationContext(), CheckoutActivity.class);
        intent.putExtra(CheckoutActivity.CHECKOUT_SETTINGS, checkoutSettings);
        intent.putExtra(CheckoutActivity.CHECKOUT_RECEIVER, componentName);

        // START ACTIVITY
        activity.startActivityForResult(intent, 242);

    }

    private void storedCardPayment(String checkoutId) {

        try {

            TokenPaymentParams paymentParams = new TokenPaymentParams(checkoutId, TokenID, brands, cvv);

            paymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

            Transaction transaction = new Transaction(paymentParams);

            //Set Mode;
            boolean resultMode = mode.equals("test");
            Connect.ProviderMode providerMode ;

            if (resultMode) {
                providerMode =  Connect.ProviderMode.TEST ;
            } else {
                providerMode =  Connect.ProviderMode.LIVE ;
            }

            paymentProvider = new OppPaymentProvider(activity.getBaseContext(), providerMode);

            //Submit Transaction
            //Listen for transaction Completed - transaction Failed
            paymentProvider.submitTransaction(transaction, this);

        } catch (PaymentException e) {
            e.printStackTrace();

        }


    }

    private void openCustomUI(String checkoutId) {

        Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
            ? "Please Waiting.."
            : "برجاء الانتظار..", Toast.LENGTH_SHORT).show();

        if (!CardPaymentParams.isNumberValid(number , true)) {
            Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
                    ? "Card number is not valid for brand"
                    : "رقم البطاقة غير صالح",
                Toast.LENGTH_SHORT).show();
        } else if (!CardPaymentParams.isHolderValid(holder)) {
            Toast.makeText(activity.getApplicationContext(),  Lang.equals("en_US")
                    ? "Holder name is not valid"
                    : "اسم المالك غير صالح"
                , Toast.LENGTH_SHORT).show();
        } else if (!CardPaymentParams.isExpiryYearValid(year)) {
            Toast.makeText(activity.getApplicationContext(),  Lang.equals("en_US")
                    ? "Expiry year is not valid"
                    : "سنة انتهاء الصلاحية غير صالحة" ,
                Toast.LENGTH_SHORT).show();
        } else if (!CardPaymentParams.isExpiryMonthValid(month)) {
            Toast.makeText(activity.getApplicationContext(),  Lang.equals("en_US")
                    ? "Expiry month is not valid"
                    : "شهر انتهاء الصلاحية غير صالح"
                , Toast.LENGTH_SHORT).show();
        } else if (!CardPaymentParams.isCvvValid(cvv)) {
            Toast.makeText(activity.getApplicationContext(),  Lang.equals("en_US")
                    ? "CVV is not valid"
                    : "CVV غير صالح"
                , Toast.LENGTH_SHORT).show();
        } else {

            boolean EnabledTokenizationTemp = EnabledTokenization.equals("true");
            try {
                PaymentParams paymentParams = new CardPaymentParams(
                    checkoutId, brands, number, holder, month, year, cvv
                ).setTokenizationEnabled(EnabledTokenizationTemp);//Set Enabled TokenizationTemp

                paymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

                Transaction transaction = new Transaction(paymentParams);
                paymentProvider.setThreeDSWorkflowListener(new ThreeDSWorkflowListener() {
                    @Override
                    public Activity onThreeDSChallengeRequired() {
                        return activity;
                    }
                });

                //Set Mode;
                boolean resultMode = mode.equals("test");
                Connect.ProviderMode providerMode ;

                if (resultMode) {
                    providerMode =  Connect.ProviderMode.TEST ;
                } else {
                    providerMode =  Connect.ProviderMode.LIVE ;
                }

                paymentProvider = new OppPaymentProvider(activity.getBaseContext(), providerMode);

                //Submit Transaction
                //Listen for transaction Completed - transaction Failed
                paymentProvider.submitTransaction(transaction, this);

            } catch (PaymentException e) {
                error("0.1", e.getLocalizedMessage(), "");
            }
        }
    }

    private void openCustomUISTC(String checkoutId) {

        Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
            ? "Please Waiting.."
            : "برجاء الانتظار..", Toast.LENGTH_SHORT).show();
        try {
            //Set Mode
            boolean resultMode = mode.equals("test");
            Connect.ProviderMode providerMode ;

            if (resultMode) {
                providerMode =  Connect.ProviderMode.TEST ;
            } else {
                providerMode =  Connect.ProviderMode.LIVE ;
            }

            STCPayPaymentParams stcPayPaymentParams = new STCPayPaymentParams(checkoutId, STCPayVerificationOption.MOBILE_PHONE);

            stcPayPaymentParams.setMobilePhoneNumber(number);

            stcPayPaymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

            Transaction transaction = new Transaction(stcPayPaymentParams);

            paymentProvider = new OppPaymentProvider(activity.getBaseContext(), providerMode);

            //Submit Transaction
            //Listen for transaction Completed - transaction Failed
            paymentProvider.submitTransaction(transaction, this);

        } catch (PaymentException e) {
            e.printStackTrace();
        }

    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (resultCode) {
            case CheckoutActivity.RESULT_OK :
                /* transaction completed */
                Transaction transaction = data.getParcelableExtra(CheckoutActivity.CHECKOUT_RESULT_TRANSACTION);


                /* resource path if needed */
                // String resourcePath = data.getStringExtra(CheckoutActivity.CHECKOUT_RESULT_RESOURCE_PATH);
                if (transaction.getTransactionType() == TransactionType.SYNC) {
                    /* check the result of synchronous transaction */
                    success("SYNC");
                }

                break ;
            case CheckoutActivity.RESULT_CANCELED :
                /* shopper canceled the checkout process */
                error("2", "Canceled", "");
                break ;

            case CheckoutActivity.RESULT_ERROR :
                /* shopper error the checkout process */
                error("3", "Checkout Result Error", "");
                break ;

        }

        return  true ;
    }

    public void success(final Object result) {
        handler.post(
            () -> Result.success(result));
    }

    public void error(
        @NonNull final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(
            () -> Result.error(errorCode, errorMessage, errorDetails));
    }

    public void notImplemented() {
        handler.post(
            () -> Result.notImplemented());
    }

    private void sendDebugLogToFlutter(String title, String message) {
        handler.post(() -> {
            try {
                // Show Toast message on Android device
                String toastMessage = title + ": " + message;
                Toast.makeText(context, toastMessage, Toast.LENGTH_LONG).show();

                // Log to Android logcat
                android.util.Log.d("PaymentPlugin", "🔧 " + title + " - " + message);

                // Also send to Flutter (if Flutter is listening)
                java.util.Map<String, Object> debugData = new java.util.HashMap<>();
                debugData.put("title", title);
                debugData.put("message", message);
                debugData.put("timestamp", System.currentTimeMillis());
                channel.invokeMethod("onDebugLog", debugData);

            } catch (Exception e) {
                android.util.Log.e("PaymentPlugin", "Failed to send debug log", e);
                // Fallback toast for errors
                Toast.makeText(context, "Debug Error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    public boolean onNewIntent(@NonNull Intent intent) {
        // TO BACK TO VIEW
        String scheme = intent.getScheme();
        String intentData = intent.getDataString();

        android.util.Log.d("PaymentPlugin", "🔥 onNewIntent called with scheme: " + scheme);
        android.util.Log.d("PaymentPlugin", "Expected ShopperResultUrl: " + ShopperResultUrl);
        android.util.Log.d("PaymentPlugin", "Intent data: " + intentData);

        // Send debug info as Toast (visible without Flutter code)
        sendDebugLogToFlutter("🔥 Payment Redirect Attempt",
            "Got: " + scheme + "\nExpected: " + ShopperResultUrl);

        if (scheme != null && scheme.equals(ShopperResultUrl)) {
            android.util.Log.d("PaymentPlugin", "✅ Payment redirect successful - calling success");
            sendDebugLogToFlutter("✅ Payment Redirect SUCCESS", "Scheme matched! Redirecting to Flutter");
            success("success");
            return true;
        }
        android.util.Log.d("PaymentPlugin", "❌ Scheme mismatch - not handling this intent");
        sendDebugLogToFlutter("❌ Payment Redirect FAILED", "Expected: " + ShopperResultUrl + " Got: " + scheme);
        return false;
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener(this);
        binding.addOnNewIntentListener(this); // TO LISTEN ON NEW INTENT OPEN

    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void transactionCompleted(@NonNull Transaction transaction) {
        if (transaction == null) {
            android.util.Log.w("PaymentPlugin", "Transaction is null");
            sendDebugLogToFlutter("⚠️ Transaction Null", "No transaction data received");
            return;
        }

        android.util.Log.d("PaymentPlugin", "Transaction completed with type: " + transaction.getTransactionType());

        if (transaction.getTransactionType() == TransactionType.SYNC) {
            android.util.Log.d("PaymentPlugin", "SYNC transaction - calling success immediately");
            sendDebugLogToFlutter("Transaction Complete", "SYNC transaction - success immediate");
            success("SYNC");
        } else {
            String redirectUrl = transaction.getRedirectUrl();
            android.util.Log.d("PaymentPlugin", "ASYNC transaction - opening browser with URL: " + redirectUrl);

            sendDebugLogToFlutter("🌐 Opening Browser",
                "URL: " + redirectUrl + "\nWaiting for redirect to: " + ShopperResultUrl + "://result");

            try {
                Uri uri = Uri.parse(redirectUrl);
                Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                activity.startActivity(intent);

                sendDebugLogToFlutter("✅ Browser Opened",
                    "Complete payment in browser. App should auto-open when done.");
            } catch (Exception e) {
                sendDebugLogToFlutter("❌ Browser Error", "Failed to open browser: " + e.getMessage());
            }
        }
    }

    @Override
    public void transactionFailed(@NonNull Transaction transaction, @NonNull PaymentError paymentError) {
        error("transactionFailed", paymentError.getErrorMessage(), "transactionFailed"
        );
    }

    @Override
    public void brandsValidationRequestSucceeded(@NonNull BrandsValidation brandsValidation) {
        ITransactionListener.super.brandsValidationRequestSucceeded(brandsValidation);
    }

    @Override
    public void brandsValidationRequestFailed(@NonNull PaymentError error) {
        ITransactionListener.super.brandsValidationRequestFailed(error);
    }

    @Override
    public void paymentConfigRequestSucceeded(@NonNull CheckoutInfo checkoutInfo) {
        ITransactionListener.super.paymentConfigRequestSucceeded(checkoutInfo);
    }

    @Override
    public void paymentConfigRequestFailed(@NonNull PaymentError error) {
        ITransactionListener.super.paymentConfigRequestFailed(error);
    }

    @Override
    public void imagesRequestSucceeded(@NonNull ImagesRequest imagesRequest) {
        ITransactionListener.super.imagesRequestSucceeded(imagesRequest);
    }

    @Override
    public void imagesRequestFailed() {
        ITransactionListener.super.imagesRequestFailed();
    }

    @Override
    public void binRequestSucceeded(@NonNull String[] brands) {
        ITransactionListener.super.binRequestSucceeded(brands);
    }

    @Override
    public void binRequestFailed() {
        ITransactionListener.super.binRequestFailed();
    }
}
