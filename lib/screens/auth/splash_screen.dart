import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade = Tween<double>(begin:0,end:1).animate(CurvedAnimation(parent:_ctrl, curve:Curves.easeIn));
    _scale = Tween<double>(begin:0.6,end:1).animate(CurvedAnimation(parent:_ctrl, curve:Curves.elasticOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    if (auth.isLoggedIn) {
      final uid = auth.firebaseUser!.uid;
      context.read<CartProvider>().setUser(uid);
      context.read<OrderProvider>().setUser(uid);
      context.read<WishlistProvider>().setUser(uid);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3F3D99)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(child: FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale, child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width:100,height:100, decoration: BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(28), boxShadow:[BoxShadow(color:Colors.black26,blurRadius:20,offset:Offset(0,10))]),
            child: const Icon(Icons.shopping_bag_rounded, size:56, color:Color(0xFF6C63FF))),
          const SizedBox(height:24),
          const Text('ShopEase', style: TextStyle(color:Colors.white,fontSize:36,fontWeight:FontWeight.bold,letterSpacing:1.2)),
          const SizedBox(height:8),
          Text('Your Smart Shopping Companion', style: TextStyle(color:Colors.white.withOpacity(0.8),fontSize:14)),
          const SizedBox(height:60),
          SizedBox(width:40,height:40, child: CircularProgressIndicator(valueColor:AlwaysStoppedAnimation(Colors.white.withOpacity(0.7)),strokeWidth:3)),
        ],
      )))),
    ),
  );
}
