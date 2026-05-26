import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../orders/orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ✅ Razorpay instance
  late Razorpay _razorpay;
  bool _processing = false;
  final _formKey = GlobalKey<FormState>();

  // Address controllers
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ✅ Initialize Razorpay with all 3 event handlers
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    // Pre-fill user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = context.read<AuthProvider>().userModel;
      if (u != null) {
        _name.text = u.name;
        _phone.text = u.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _razorpay.clear(); // ✅ Always clear Razorpay on dispose
    for (final c in [_name, _phone, _address1, _address2, _city, _state, _pincode]) {
      c.dispose();
    }
    super.dispose();
  }

  // ✅ START RAZORPAY PAYMENT
  void _startPayment() {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();

    // Amount must be in PAISE (multiply by 100)
    final amountInPaise = (cart.totalAmount * 100).toInt();

    setState(() => _processing = true);

    // ✅ Razorpay options with rzp_test_SgnUWJM5aAchCS
    final options = {
      'key': AppConstants.razorpayKeyId,          // rzp_test_SgnUWJM5aAchCS
      'amount': amountInPaise,                    // Paise (₹1 = 100 paise)
      'currency': AppConstants.razorpayCurrency,  // INR
      'name': AppConstants.razorpayCompanyName,   // ShopEase
      'description': 'Payment for ${cart.itemCount} item(s)',
      'prefill': {
        'contact': _phone.text,
        'email': auth.userModel?.email ?? '',
        'name': _name.text,
      },
      'theme': {'color': '#6C63FF'},
      'modal': {'backdropclose': false},
      'send_sms_hash': true,
      'remember_customer': false,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _processing = false);
      _showError('Failed to open payment: $e');
    }
  }

  // ✅ PAYMENT SUCCESS HANDLER
  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _processing = false);

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();

    // Build delivery address from form
    final address = Address(
      id: const Uuid().v4(),
      label: 'Delivery',
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      addressLine1: _address1.text.trim(),
      addressLine2: _address2.text.trim().isEmpty ? null : _address2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      pincode: _pincode.text.trim(),
    );

    // Set user in order provider
    orderProvider.setUser(auth.firebaseUser!.uid);

    // Place order in Firestore
    final orderId = await orderProvider.placeOrder(
      items: List.from(cart.items),
      subtotal: cart.subtotal,
      deliveryCharge: cart.deliveryCharge,
      discount: 0,
      totalAmount: cart.totalAmount,
      deliveryAddress: address,
      paymentId: response.paymentId ?? 'N/A',   // ✅ Razorpay Payment ID
      paymentMethod: 'Razorpay',
    );

    // Clear cart after successful order
    await cart.clearCart();

    // Show success dialog
    if (mounted) {
      _showSuccessDialog(response.paymentId ?? 'N/A', orderId ?? '');
    }
  }

  // ✅ PAYMENT ERROR HANDLER
  void _onPaymentError(PaymentFailureResponse response) {
    setState(() => _processing = false);
    String msg = response.message ?? 'Payment failed';
    if (response.code == Razorpay.NETWORK_ERROR) {
      msg = 'Network error. Check internet connection.';
    } else if (response.code == Razorpay.INVALID_OPTIONS) {
      msg = 'Payment configuration error.';
    }
    _showError(msg);
  }

  // ✅ EXTERNAL WALLET HANDLER
  void _onExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog(String paymentId, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 52),
            ),
            const SizedBox(height: 20),
            const Text('Order Placed!',
                style:
                TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Your order has been confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                _InfoRow(
                    'Payment ID',
                    paymentId.length > 16
                        ? '${paymentId.substring(0, 16)}...'
                        : paymentId),
                if (orderId.isNotEmpty)
                  _InfoRow(
                      'Order ID',
                      orderId.length > 8
                          ? '#${orderId.substring(0, 8).toUpperCase()}'
                          : '#$orderId'),
                _InfoRow('Status', '✅ Confirmed'),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OrdersScreen()),
                        (route) => route.isFirst,
                  );
                },
                child: const Text('View My Orders'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Order Summary ──
          _Section(
            title: 'Order Summary',
            icon: Icons.receipt_long_rounded,
            child: Column(children: [
              ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImage,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(width: 44, height: 44, color: Colors.grey[200]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(item.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13))),
                  Text('x${item.quantity}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text('₹${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
              )),
              const Divider(height: 20),
              _SummaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(0)}'),
              const SizedBox(height: 4),
              _SummaryRow(
                'Delivery',
                cart.deliveryCharge == 0
                    ? 'FREE'
                    : '₹${cart.deliveryCharge.toStringAsFixed(0)}',
                valueColor: cart.deliveryCharge == 0 ? Colors.green : null,
              ),
              if (cart.deliveryCharge == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    Icon(Icons.local_shipping_rounded,
                        size: 14, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text('Free delivery on orders above ₹499',
                        style:
                        TextStyle(fontSize: 11, color: Colors.green[700])),
                  ]),
                ),
              const Divider(height: 20),
              _SummaryRow(
                'Total Amount',
                '₹${cart.totalAmount.toStringAsFixed(0)}',
                isBold: true,
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Delivery Address ──
          _Section(
            title: 'Delivery Address',
            icon: Icons.location_on_rounded,
            child: Form(
              key: _formKey,
              child: Column(children: [
                _Field(_name, 'Full Name', Icons.person_outline,
                    caps: TextCapitalization.words),
                _Field(_phone, 'Phone Number', Icons.phone_outlined,
                    type: TextInputType.phone,
                    validator: (v) => v == null || v.length < 10
                        ? 'Enter valid 10-digit phone'
                        : null),
                _Field(_address1, 'Address Line 1', Icons.home_outlined),
                _Field(_address2, 'Address Line 2 (Optional)',
                    Icons.location_on_outlined,
                    required: false),
                Row(children: [
                  Expanded(
                      child: _Field(_city, 'City', Icons.location_city_rounded)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _Field(_state, 'State', Icons.map_outlined)),
                ]),
                _Field(_pincode, 'Pincode', Icons.pin_drop_outlined,
                    type: TextInputType.number,
                    validator: (v) => v == null || v.length != 6
                        ? 'Enter valid 6-digit pincode'
                        : null),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // ── Payment Method ──
          _Section(
            title: 'Payment Method',
            icon: Icons.payment_rounded,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('R',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Razorpay (Test Mode)',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                            'Cards • UPI • NetBanking • Wallets • EMI',
                            style:
                            TextStyle(color: Colors.grey, fontSize: 11)),
                      ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Row(children: [
                    Icon(Icons.lock_rounded,
                        size: 12, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Secure',
                        style:
                        TextStyle(color: Colors.green, fontSize: 11)),
                  ]),
                ),
              ]),
            ),
          ),

          // ── Test Mode Note ──
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border:
              Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Test Mode Active',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.amber)),
                      Text(
                          'Use card: 4111 1111 1111 1111 | CVV: 123 | Expiry: any future date',
                          style:
                          TextStyle(fontSize: 11, color: Colors.grey)),
                    ]),
              ),
            ]),
          ),

          const SizedBox(height: 100),
        ]),
      ),

      // ── Pay Button ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _processing ? null : _startPayment,
            icon: _processing
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.payment_rounded),
            label: Text(
              _processing
                  ? 'Processing...'
                  : 'Pay ₹${cart.totalAmount.toStringAsFixed(0)} via Razorpay',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ──

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Section(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 14),
          child,
        ]),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;
  const _SummaryRow(this.label, this.value,
      {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                fontWeight:
                isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 15 : 13,
                color: Colors.grey[700])),
        Text(value,
            style: TextStyle(
                fontWeight:
                isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: isBold ? 16 : 13,
                color: valueColor ??
                    (isBold
                        ? Theme.of(context).colorScheme.primary
                        : null))),
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController c;
  final String label;
  final IconData icon;
  final TextInputType? type;
  final bool required;
  final String? Function(String?)? validator;
  final TextCapitalization caps;

  const _Field(this.c, this.label, this.icon,
      {this.type,
        this.required = true,
        this.validator,
        this.caps = TextCapitalization.none});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        textCapitalization: caps,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
        validator: validator ??
            (required
                ? (v) => v == null || v.trim().isEmpty ? '$label required' : null
                : null),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 12)),
          ]),
    );
  }
}