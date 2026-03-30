package com.excprotection.payment;

import com.oppwa.mobile.connect.payment.PaymentParams;
import com.oppwa.mobile.connect.payment.card.CardPaymentParams;
import com.oppwa.mobile.connect.checkout.dialog.GooglePayHelper;
import com.oppwa.mobile.connect.payment.googlepay.GooglePayPaymentParams;
import com.oppwa.mobile.connect.payment.samsungpay.SamsungPayPaymentParams;
import com.oppwa.mobile.connect.payment.stcpay.STCPayPaymentParams;
import com.oppwa.mobile.connect.payment.stcpay.STCPayVerificationOption;
import com.oppwa.mobile.connect.provider.ITransactionListener;
import com.oppwa.mobile.connect.provider.OppPaymentProvider;
import com.google.android.gms.wallet.AutoResolveHelper;
import com.google.android.gms.wallet.PaymentData;
import com.google.android.gms.wallet.PaymentDataRequest;
import com.google.android.gms.wallet.PaymentsClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import androidx.annotation.NonNull;
import androidx.activity.result.ActivityResultLauncher;
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
import com.oppwa.mobile.connect.checkout.meta.CheckoutActivityResult;
import com.oppwa.mobile.connect.checkout.meta.CheckoutActivityResultContract;
import com.oppwa.mobile.connect.exception.PaymentError;
import com.oppwa.mobile.connect.exception.PaymentException;
import com.oppwa.mobile.connect.payment.BrandsValidation;
import com.oppwa.mobile.connect.payment.CheckoutInfo;
import com.oppwa.mobile.connect.payment.ImagesRequest;
import com.oppwa.mobile.connect.payment.token.TokenPaymentParams;
import com.oppwa.mobile.connect.provider.Connect;
import com.oppwa.mobile.connect.provider.Transaction;
import com.oppwa.mobile.connect.provider.TransactionType;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import com.oppwa.mobile.connect.provider.ThreeDSWorkflowListener;

public class PaymentPlugin implements
    PluginRegistry.ActivityResultListener, ActivityAware, FlutterPlugin, MethodCallHandler, PluginRegistry.NewIntentListener, ITransactionListener {

    private MethodChannel.Result Result;
    private String mode = "";
    private List<String> brandsReadyUi;
    private String brands = "";
    private String Lang = "";
    private String EnabledTokenization = "";
    private String ShopperResultUrl = "";
    private String setStorePaymentDetailsMode = "";
    private String number, holder, cvv, year, month;
    private String TokenID = "";
    private OppPaymentProvider paymentProvider = null;
    private Activity activity;
    private Context context;
    private CheckoutSettings checkoutSettings;
    private ActivityResultLauncher<CheckoutSettings> checkoutLauncher;
    private boolean isWaitingForBrowserResult = false;

    // Google Pay fields
    private String googlePayMerchantId = "";
    private String gatewayMerchantId = "";
    private String countryCode = "";
    private String currencyCode = "";
    private String amount = "";
    private List<String> allowedCardNetworks;
    private List<String> allowedCardAuthMethods;
    private String googlePayCheckoutId = "";

    // Samsung Pay fields
    private String merchantName = "";
    private String serviceId = "";
    private String orderNumber = "";
    private String samsungPayCheckoutId = "";
    private String samsungPayAmount = "";

    private final Handler handler = new Handler(Looper.getMainLooper());

    private MethodChannel channel;
    String CHANNEL = "com.hyperpay.sdk/channel";

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
            sendDebugLogToFlutter("🚀 Payment Started",
                "Expected redirect: " + ShopperResultUrl + "://result");

            switch (type != null ? type : "NullType") {
                case "ReadyUI":
                    brandsReadyUi = call.argument("brand");
                    setStorePaymentDetailsMode = call.argument("setStorePaymentDetailsMode");
                    openCheckoutUI(checkoutId);
                    break;
                case "StoredCards":
                    cvv = call.argument("cvv");
                    TokenID = call.argument("TokenID");
                    storedCardPayment(checkoutId);
                    break;
                case "CustomUI":
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
                case "GooglePayUI":
                    googlePayCheckoutId = checkoutId;
                    googlePayMerchantId = call.argument("googlePayMerchantId");
                    gatewayMerchantId = call.argument("gatewayMerchantId");
                    countryCode = call.argument("countryCode");
                    currencyCode = call.argument("currencyCode");
                    amount = call.argument("amount");
                    allowedCardNetworks = call.argument("allowedCardNetworks");
                    allowedCardAuthMethods = call.argument("allowedCardAuthMethods");
                    openGooglePayUI();
                    break;
                case "SamsungPayUI":
                    samsungPayCheckoutId = checkoutId;
                    merchantName = call.argument("merchantName");
                    serviceId = call.argument("serviceId");
                    orderNumber = call.argument("orderNumber");
                    samsungPayAmount = call.argument("amount");
                    openSamsungPayUI();
                    break;
                case "RequestBrands":
                    Connect.ProviderMode brandsProviderMode = (mode != null && mode.equals("live")) ?
                        Connect.ProviderMode.LIVE : Connect.ProviderMode.TEST;
                    paymentProvider = new OppPaymentProvider(context, brandsProviderMode);
                    paymentProvider.requestBrandsValidation(checkoutId, new String[]{}, this);
                    break;
                default:
                    error("1", "THIS TYPE NO IMPLEMENT" + type, "");
            }

        } else {
            notImplemented();
        }
    }

    private void openCheckoutUI(String checkoutId) {
        Set<String> paymentBrands = new LinkedHashSet<>(brandsReadyUi);

        // CHECK PAYMENT MODE
        Connect.ProviderMode providerMode;
        if (mode.equals("live")) {
            providerMode = Connect.ProviderMode.LIVE;
        } else {
            providerMode = Connect.ProviderMode.TEST;
        }

        checkoutSettings = new CheckoutSettings(checkoutId, paymentBrands, providerMode);

        // SET LANG
        if (Lang != null && !Lang.isEmpty()) {
            checkoutSettings.setLocale(Lang);
        }

        // SHOW TOTAL PAYMENT AMOUNT IN BUTTON
        // checkoutSettings.setTotalAmountRequired(true);

        //SET SHOPPER - Note: CheckoutSettings doesn't have setShopperResultUrl
        // The redirect is handled automatically via onNewIntent when using ReadyUI
        //checkoutSettings.setShopperResultUrl(ShopperResultUrl + "://result");

        // SAVE PAYMENT CARDS FOR NEXT
        if ("true".equals(setStorePaymentDetailsMode)) {
            checkoutSettings.setStorePaymentDetailsMode(CheckoutStorePaymentDetailsMode.PROMPT);
        } else {
            checkoutSettings.setStorePaymentDetailsMode(CheckoutStorePaymentDetailsMode.NEVER);
        }

        // CHANGE THEME
        try {
            checkoutSettings.setThemeResId(R.style.NewCheckoutTheme);
        } catch (Exception e) {
            Log.w("PaymentPlugin", "Theme not found, using default");
        }

        // Start checkout using the modern approach
        startCheckout();
    }

    private void startCheckout() {
        if (checkoutLauncher != null) {
            sendDebugLogToFlutter("🚀 Launching Checkout", "Using modern launcher");
            checkoutLauncher.launch(checkoutSettings);
        } else {
            sendDebugLogToFlutter("⚠️ Fallback to Legacy", "Using legacy checkout method");
            // Fallback to legacy method
            startLegacyCheckout();
        }
    }

    private void startLegacyCheckout() {
        try {
            ComponentName componentName = new ComponentName(
                context.getPackageName(), CheckoutBroadcastReceiver.class.getName());

            Intent intent = new Intent(activity, CheckoutActivity.class);
            intent.putExtra(CheckoutActivity.CHECKOUT_SETTINGS, checkoutSettings);
            intent.putExtra(CheckoutActivity.CHECKOUT_RECEIVER, componentName);

            activity.startActivityForResult(intent, 242);
            sendDebugLogToFlutter("✅ Legacy Checkout Started", "Checkout activity launched");
        } catch (Exception e) {
            sendDebugLogToFlutter("❌ Legacy Checkout Failed", e.getMessage());
            error("CHECKOUT_ERROR", "Failed to start checkout: " + e.getMessage(), "");
        }
    }

    private void handleCheckoutResult(@NonNull CheckoutActivityResult result) {
        if (result.isCanceled()) {
            sendDebugLogToFlutter("⏸️ Checkout Pending", "User closed the payment");
            error("PENDING", "Pending", null);
            return;
        }

        if (result.isErrored()) {
            PaymentError error = result.getPaymentError();
            String errorMessage = error != null ? error.getErrorMessage() : "Unknown error";
            sendDebugLogToFlutter("❌ Checkout Error", errorMessage);
            error("3", "Checkout Result Error: " + errorMessage, null);
            return;
        }

        Transaction transaction = result.getTransaction();
        String resourcePath = result.getResourcePath();

        if (transaction != null) {
            if (transaction.getTransactionType() == TransactionType.SYNC) {
                sendDebugLogToFlutter("✅ SYNC Transaction", "Payment completed synchronously");
                success("SYNC");
            } else {
                // For ASYNC transactions, the redirect will be handled in onNewIntent
                sendDebugLogToFlutter("⏳ ASYNC Transaction", "Waiting for redirect callback");
            }
        }
    }

    private void storedCardPayment(String checkoutId) {
        try {
            TokenPaymentParams paymentParams = new TokenPaymentParams(checkoutId, TokenID, brands, cvv);
            paymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

            Transaction transaction = new Transaction(paymentParams);

            // Set Mode
            Connect.ProviderMode providerMode = mode.equals("test") ?
                Connect.ProviderMode.TEST : Connect.ProviderMode.LIVE;

            paymentProvider = new OppPaymentProvider(context, providerMode);
            paymentProvider.setThreeDSWorkflowListener(new ThreeDSWorkflowListener() {
                @Override
                public Activity onThreeDSChallengeRequired() {
                    return activity;
                }
            });

            // Submit Transaction
            paymentProvider.submitTransaction(transaction, this);

        } catch (PaymentException e) {
            error("PAYMENT_ERROR", e.getLocalizedMessage(), "");
        }
    }

    private void openCustomUI(String checkoutId) {
        String waitingMessage = Lang.equals("en_US") ? "Please Waiting.." : "برجاء الانتظار..";
        Toast.makeText(context, waitingMessage, Toast.LENGTH_SHORT).show();

        // Validate card details
        if (!CardPaymentParams.isNumberValid(number, true)) {
            String errorMsg = Lang.equals("en_US") ? "Card number is not valid" : "رقم البطاقة غير صالح";
            Toast.makeText(context, errorMsg, Toast.LENGTH_SHORT).show();
            error("INVALID_CARD", errorMsg, "");
            return;
        }

        if (!CardPaymentParams.isHolderValid(holder)) {
            String errorMsg = Lang.equals("en_US") ? "Holder name is not valid" : "اسم المالك غير صالح";
            Toast.makeText(context, errorMsg, Toast.LENGTH_SHORT).show();
            error("INVALID_HOLDER", errorMsg, "");
            return;
        }

        if (!CardPaymentParams.isExpiryYearValid(year)) {
            String errorMsg = Lang.equals("en_US") ? "Expiry year is not valid" : "سنة انتهاء الصلاحية غير صالحة";
            Toast.makeText(context, errorMsg, Toast.LENGTH_SHORT).show();
            error("INVALID_YEAR", errorMsg, "");
            return;
        }

        if (!CardPaymentParams.isExpiryMonthValid(month)) {
            String errorMsg = Lang.equals("en_US") ? "Expiry month is not valid" : "شهر انتهاء الصلاحية غير صالح";
            Toast.makeText(context, errorMsg, Toast.LENGTH_SHORT).show();
            error("INVALID_MONTH", errorMsg, "");
            return;
        }

        if (!CardPaymentParams.isCvvValid(cvv)) {
            String errorMsg = Lang.equals("en_US") ? "CVV is not valid" : "CVV غير صالح";
            Toast.makeText(context, errorMsg, Toast.LENGTH_SHORT).show();
            error("INVALID_CVV", errorMsg, "");
            return;
        }

        try {
            boolean enabledTokenization = "true".equals(EnabledTokenization);
            PaymentParams paymentParams = new CardPaymentParams(
                checkoutId, brands, number, holder, month, year, cvv
            ).setTokenizationEnabled(enabledTokenization);

            paymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

            Transaction transaction = new Transaction(paymentParams);

            // Set Mode
            Connect.ProviderMode providerMode = mode.equals("test") ?
                Connect.ProviderMode.TEST : Connect.ProviderMode.LIVE;

            paymentProvider = new OppPaymentProvider(context, providerMode);
            paymentProvider.setThreeDSWorkflowListener(new ThreeDSWorkflowListener() {
                @Override
                public Activity onThreeDSChallengeRequired() {
                    return activity;
                }
            });

            // Submit Transaction
            paymentProvider.submitTransaction(transaction, this);

        } catch (PaymentException e) {
            error("PAYMENT_ERROR", e.getLocalizedMessage(), "");
        }
    }

    private void openCustomUISTC(String checkoutId) {
        String waitingMessage = Lang.equals("en_US") ? "Please Waiting.." : "برجاء الانتظار..";
        Toast.makeText(context, waitingMessage, Toast.LENGTH_SHORT).show();

        try {
            // Set Mode
            Connect.ProviderMode providerMode = mode.equals("test") ?
                Connect.ProviderMode.TEST : Connect.ProviderMode.LIVE;

            STCPayPaymentParams stcPayPaymentParams = new STCPayPaymentParams(checkoutId, STCPayVerificationOption.MOBILE_PHONE);
            stcPayPaymentParams.setMobilePhoneNumber(number);
            stcPayPaymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

            Transaction transaction = new Transaction(stcPayPaymentParams);

            paymentProvider = new OppPaymentProvider(context, providerMode);
            paymentProvider.setThreeDSWorkflowListener(new ThreeDSWorkflowListener() {
                @Override
                public Activity onThreeDSChallengeRequired() {
                    return activity;
                }
            });

            // Submit Transaction
            paymentProvider.submitTransaction(transaction, this);

        } catch (PaymentException e) {
            error("STC_ERROR", e.getLocalizedMessage(), "");
        }
    }

    private void openGooglePayUI() {
        Connect.ProviderMode providerMode = (mode != null && mode.equals("live")) ?
            Connect.ProviderMode.LIVE : Connect.ProviderMode.TEST;

        try {
            String paymentRequestJson = buildGooglePayRequest().toString();
            GooglePayHelper.isReadyToPayWithGoogle(activity, providerMode, paymentRequestJson, task -> {
                if (task.isSuccessful() && Boolean.TRUE.equals(task.getResult())) {
                    requestGooglePayPayment(providerMode);
                } else {
                    error("GOOGLE_PAY_NOT_AVAILABLE", "Google Pay is not available on this device", null);
                }
            });
        } catch (JSONException e) {
            error("GOOGLE_PAY_ERROR", "Failed to build Google Pay request: " + e.getMessage(), null);
        } catch (com.oppwa.mobile.connect.exception.PaymentException e) {
            error("GOOGLE_PAY_ERROR", e.getLocalizedMessage(), null);
        }
    }

    private JSONObject buildGooglePayRequest() throws JSONException {
        JSONArray allowedAuthMethods = new JSONArray();
        if (allowedCardAuthMethods != null) {
            for (String method : allowedCardAuthMethods) {
                allowedAuthMethods.put(method);
            }
        }

        JSONArray allowedNetworks = new JSONArray();
        if (allowedCardNetworks != null) {
            for (String network : allowedCardNetworks) {
                allowedNetworks.put(network);
            }
        }

        JSONObject tokenizationSpec = new JSONObject()
            .put("type", "PAYMENT_GATEWAY")
            .put("parameters", new JSONObject()
                .put("gateway", "aciworldwide")
                .put("gatewayMerchantId", gatewayMerchantId));

        JSONObject cardPaymentMethod = new JSONObject()
            .put("type", "CARD")
            .put("parameters", new JSONObject()
                .put("allowedAuthMethods", allowedAuthMethods)
                .put("allowedCardNetworks", allowedNetworks))
            .put("tokenizationSpecification", tokenizationSpec);

        JSONObject transactionInfo = new JSONObject()
            .put("totalPrice", amount)
            .put("totalPriceStatus", "FINAL")
            .put("countryCode", countryCode)
            .put("currencyCode", currencyCode);

        JSONObject merchantInfo = new JSONObject()
            .put("merchantId", googlePayMerchantId)
            .put("merchantName", "");

        return new JSONObject()
            .put("apiVersion", 2)
            .put("apiVersionMinor", 0)
            .put("allowedPaymentMethods", new JSONArray().put(cardPaymentMethod))
            .put("transactionInfo", transactionInfo)
            .put("merchantInfo", merchantInfo);
    }

    private void requestGooglePayPayment(Connect.ProviderMode providerMode) {
        try {
            JSONObject paymentRequest = buildGooglePayRequest();
            PaymentsClient paymentsClient = GooglePayHelper.getPaymentsClient(activity, providerMode);
            PaymentDataRequest request = PaymentDataRequest.fromJson(paymentRequest.toString());
            AutoResolveHelper.resolveTask(
                paymentsClient.loadPaymentData(request),
                activity,
                991
            );
        } catch (JSONException e) {
            error("GOOGLE_PAY_ERROR", "Failed to build Google Pay request: " + e.getMessage(), null);
        }
    }

    private void submitGooglePayTransaction(String token, String cardBrand) {
        try {
            Connect.ProviderMode providerMode = (mode != null && mode.equals("live")) ?
                Connect.ProviderMode.LIVE : Connect.ProviderMode.TEST;

            GooglePayPaymentParams paymentParams = new GooglePayPaymentParams(googlePayCheckoutId, token, cardBrand);
            paymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

            Transaction transaction = new Transaction(paymentParams);

            paymentProvider = new OppPaymentProvider(context, providerMode);
            paymentProvider.setThreeDSWorkflowListener(new ThreeDSWorkflowListener() {
                @Override
                public Activity onThreeDSChallengeRequired() {
                    return activity;
                }
            });

            paymentProvider.submitTransaction(transaction, this);
        } catch (PaymentException e) {
            error("GOOGLE_PAY_ERROR", e.getLocalizedMessage(), null);
        }
    }

    /**
     * Submits a Samsung Pay payment using a payment credential previously obtained from
     * the Samsung Pay SDK. The credential is passed via the {@code serviceId} field in
     * {@link SamsungPayUI} when calling {@code samsungPayUI()}.
     *
     * <p>To get the credential, integrate the Samsung Pay SDK in your app, present the
     * Samsung Pay sheet, and pass the resulting payment token as {@code serviceId}.
     */
    private void openSamsungPayUI() {
        try {
            Connect.ProviderMode providerMode = (mode != null && mode.equals("live")) ?
                Connect.ProviderMode.LIVE : Connect.ProviderMode.TEST;

            // SamsungPayPaymentParams(checkoutId, paymentCredential)
            // paymentCredential = the Samsung Pay token obtained from the Samsung Pay SDK.
            // Pass it as the `serviceId` field of SamsungPayUI.
            if (serviceId == null || serviceId.isEmpty()) {
                error("SAMSUNG_PAY_NOT_AVAILABLE",
                    "Samsung Pay requires a payment credential from the Samsung Pay SDK. " +
                    "Integrate the Samsung Pay SDK, get the payment token, and pass it as serviceId.",
                    null);
                return;
            }

            SamsungPayPaymentParams paymentParams = new SamsungPayPaymentParams(samsungPayCheckoutId, serviceId);
            paymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

            Transaction transaction = new Transaction(paymentParams);

            paymentProvider = new OppPaymentProvider(context, providerMode);
            paymentProvider.setThreeDSWorkflowListener(new ThreeDSWorkflowListener() {
                @Override
                public Activity onThreeDSChallengeRequired() {
                    return activity;
                }
            });

            paymentProvider.submitTransaction(transaction, this);
        } catch (PaymentException e) {
            error("SAMSUNG_PAY_ERROR", e.getLocalizedMessage(), null);
        }
    }

    // Legacy activity result handling
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        sendDebugLogToFlutter("🔄 Activity Result", "RequestCode: " + requestCode + ", ResultCode: " + resultCode);

        if (requestCode == 991) { // Google Pay request code
            switch (resultCode) {
                case Activity.RESULT_OK:
                    if (data != null) {
                        try {
                            PaymentData paymentData = PaymentData.getFromIntent(data);
                            if (paymentData != null) {
                                JSONObject paymentJson = new JSONObject(paymentData.toJson());
                                JSONObject paymentMethodData = paymentJson.getJSONObject("paymentMethodData");
                                String token = paymentMethodData
                                    .getJSONObject("tokenizationData")
                                    .getString("token");
                                String cardBrand = paymentMethodData
                                    .getJSONObject("info")
                                    .getString("cardNetwork");
                                submitGooglePayTransaction(token, cardBrand);
                            } else {
                                error("GOOGLE_PAY_ERROR", "No payment data returned", null);
                            }
                        } catch (JSONException e) {
                            error("GOOGLE_PAY_ERROR", "Failed to parse Google Pay response: " + e.getMessage(), null);
                        }
                    } else {
                        error("GOOGLE_PAY_ERROR", "No intent data returned", null);
                    }
                    break;
                case Activity.RESULT_CANCELED:
                    error("GOOGLE_PAY_CANCELED", "Google Pay was cancelled by the user", null);
                    break;
                default:
                    error("GOOGLE_PAY_ERROR", "Google Pay returned an unexpected result: " + resultCode, null);
                    break;
            }
            return true;
        }

        if (requestCode == 242) { // Our checkout request code
            switch (resultCode) {
                case CheckoutActivity.RESULT_OK:
                    sendDebugLogToFlutter("✅ Checkout OK", "Transaction completed");
                    Transaction transaction = data.getParcelableExtra(CheckoutActivity.CHECKOUT_RESULT_TRANSACTION);

                    if (transaction != null && transaction.getTransactionType() == TransactionType.SYNC) {
                        success("SYNC");
                    }
                    break;

                case CheckoutActivity.RESULT_CANCELED:
                    sendDebugLogToFlutter("⏸️ Checkout Pending", "User closed the payment");
                    error("PENDING", "Pending", null);
                    break;

                case CheckoutActivity.RESULT_ERROR:
                    sendDebugLogToFlutter("❌ Checkout Error", "Error occurred");
                    error("3", "Checkout Result Error", null);
                    break;

                default:
                    sendDebugLogToFlutter("❓ Unknown Result", "ResultCode: " + resultCode);
                    break;
            }
            return true;
        }
        return false;
    }

    public void success(final Object result) {
        handler.post(() -> {
            if (Result != null) {
                Result.success(result);
                Result = null;
            }
        });
    }

    public void error(@NonNull final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(() -> {
            if (Result != null) {
                Result.error(errorCode, errorMessage, errorDetails);
                Result = null;
            }
        });
    }

    public void notImplemented() {
        handler.post(() -> {
            if (Result != null) {
                Result.notImplemented();
                Result = null;
            }
        });
    }

    private void sendDebugLogToFlutter(String title, String message) {
        handler.post(() -> {
            try {
                String toastMessage = title + ": " + message;
//                Toast.makeText(context, toastMessage, Toast.LENGTH_LONG).show();

                Log.d("PaymentPlugin", "🔧 " + title + " - " + message);

                java.util.Map<String, Object> debugData = new java.util.HashMap<>();
                debugData.put("title", title);
                debugData.put("message", message);
                debugData.put("timestamp", System.currentTimeMillis());

                if (channel != null) {
                    channel.invokeMethod("onDebugLog", debugData);
                }

            } catch (Exception e) {
                Log.e("PaymentPlugin", "Failed to send debug log", e);
                Toast.makeText(context, "Debug Error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    public boolean onNewIntent(@NonNull Intent intent) {
        String scheme = intent.getScheme();
        String intentData = intent.getDataString();

        Log.d("PaymentPlugin", "🔥 onNewIntent called with scheme: " + scheme);
        Log.d("PaymentPlugin", "Expected ShopperResultUrl: " + ShopperResultUrl);
        Log.d("PaymentPlugin", "Intent data: " + intentData);

        sendDebugLogToFlutter("🔥 Payment Redirect Attempt",
            "Got: " + scheme + "\nExpected: " + ShopperResultUrl);

        if (scheme != null && scheme.equals(ShopperResultUrl)) {
            isWaitingForBrowserResult = false;
            Log.d("PaymentPlugin", "✅ Payment redirect successful - calling success");
            sendDebugLogToFlutter("✅ Payment Redirect SUCCESS", "Scheme matched! Redirecting to Flutter");
            success("success");
            return true;
        }

        Log.d("PaymentPlugin", "❌ Scheme mismatch - not handling this intent");
        sendDebugLogToFlutter("❌ Payment Redirect FAILED", "Expected: " + ShopperResultUrl + " Got: " + scheme);
        return false;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addOnNewIntentListener(this);
        binding.addActivityResultListener(this); // Add this for legacy support

        sendDebugLogToFlutter("🔗 Activity Attached", "Activity: " + activity.getClass().getSimpleName());

        // Try to initialize the modern checkout launcher
        try {
            if (activity instanceof androidx.fragment.app.FragmentActivity) {
                androidx.fragment.app.FragmentActivity fragmentActivity = (androidx.fragment.app.FragmentActivity) activity;
                checkoutLauncher = fragmentActivity.registerForActivityResult(
                    new CheckoutActivityResultContract(),
                    this::handleCheckoutResult
                );
                sendDebugLogToFlutter("✅ Modern Launcher", "Successfully initialized modern checkout launcher");
            } else {
                sendDebugLogToFlutter("⚠️ Legacy Mode", "Activity not FragmentActivity, using legacy method");
            }
        } catch (Exception e) {
            sendDebugLogToFlutter("❌ Launcher Init Failed", "Error: " + e.getMessage());
            Log.e("PaymentPlugin", "Failed to initialize checkout launcher", e);
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        // Keep the launcher reference
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addOnNewIntentListener(this);

        // Check if user returned from browser without completing payment
        if (isWaitingForBrowserResult && Result != null) {
            sendDebugLogToFlutter("⏸️ Browser Closed", "User returned without completing payment");
            isWaitingForBrowserResult = false;
            error("PENDING", "Pending", null);
        }
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
        checkoutLauncher = null;
    }

    // ITransactionListener implementation
    @Override
    public void transactionCompleted(@NonNull Transaction transaction) {
        if (transaction == null) {
            Log.w("PaymentPlugin", "Transaction is null");
            sendDebugLogToFlutter("⚠️ Transaction Null", "No transaction data received");
            return;
        }

        Log.d("PaymentPlugin", "Transaction completed with type: " + transaction.getTransactionType());

        if (transaction.getTransactionType() == TransactionType.SYNC) {
            Log.d("PaymentPlugin", "SYNC transaction - calling success immediately");
            sendDebugLogToFlutter("✅ Transaction Complete", "SYNC transaction - success immediate");
            success("SYNC");
        } else {
            String redirectUrl = transaction.getRedirectUrl();
            Log.d("PaymentPlugin", "ASYNC transaction - opening browser with URL: " + redirectUrl);

            sendDebugLogToFlutter("🌐 Opening Browser",
                "URL: " + redirectUrl + "\nWaiting for redirect to: " + ShopperResultUrl + "://result");

            try {
                isWaitingForBrowserResult = true;
                Uri uri = Uri.parse(redirectUrl);
                Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                activity.startActivity(intent);

                sendDebugLogToFlutter("✅ Browser Opened",
                    "Complete payment in browser. App should auto-open when done.");
            } catch (Exception e) {
                isWaitingForBrowserResult = false;
                sendDebugLogToFlutter("❌ Browser Error", "Failed to open browser: " + e.getMessage());
                error("BROWSER_ERROR", "Failed to open browser: " + e.getMessage(), "");
            }
        }
    }

    @Override
    public void transactionFailed(@NonNull Transaction transaction, @NonNull PaymentError paymentError) {
        String errorMessage = paymentError != null ? paymentError.getErrorMessage() : "Unknown transaction error";
        Log.e("PaymentPlugin", "Transaction failed: " + errorMessage);
        sendDebugLogToFlutter("❌ Transaction Failed", errorMessage);
        error("TRANSACTION_FAILED", errorMessage, "");
    }

    @Override
    public void brandsValidationRequestSucceeded(@NonNull BrandsValidation brandsValidation) {
        java.util.List<String> brands = new java.util.ArrayList<>(brandsValidation.getBrandInfoMap().keySet());
        success(brands);
    }

    @Override
    public void brandsValidationRequestFailed(@NonNull PaymentError paymentError) {
        error("BIN_LOOKUP_ERROR", "Brand detection failed", null);
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
