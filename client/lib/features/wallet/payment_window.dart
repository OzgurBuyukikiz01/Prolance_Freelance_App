import 'payment_window_impl_stub.dart'
    if (dart.library.html) 'payment_window_impl_web.dart'
    as impl;

typedef IyzicoPaymentResultListener = void Function(String outcome);

/// Opens a payment tab/window when possible (web). Returns false if not opened.
bool openIyzicoPaymentWindow(String url) => impl.openIyzicoPaymentWindow(url);

void closeIyzicoPaymentWindow() => impl.closeIyzicoPaymentWindow();

void startIyzicoPaymentResultListener(IyzicoPaymentResultListener onResult) =>
    impl.startIyzicoPaymentResultListener(onResult);

void stopIyzicoPaymentResultListener() =>
    impl.stopIyzicoPaymentResultListener();
