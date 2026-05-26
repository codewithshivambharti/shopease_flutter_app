import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import 'home/home_screen.dart';
import 'products/products_screen.dart';
import 'cart/cart_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _idx = 0;
  final _screens = const [HomeScreen(),ProductsScreen(),CartScreen(),WishlistScreen(),ProfileScreen()];

  @override Widget build(BuildContext ctx) {
    final cc = ctx.watch<CartProvider>().itemCount;
    final wc = ctx.watch<WishlistProvider>().count;
    return Scaffold(
      body: IndexedStack(index:_idx, children:_screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color:Theme.of(ctx).scaffoldBackgroundColor,
          boxShadow:[BoxShadow(color:Colors.black12,blurRadius:20,offset:const Offset(0,-5))]),
        child: SafeArea(child: NavigationBar(
          selectedIndex:_idx, onDestinationSelected:(i)=>setState(()=>_idx=i),
          backgroundColor:Colors.transparent, elevation:0,
          destinations:[
            const NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home_rounded),label:'Home'),
            const NavigationDestination(icon:Icon(Icons.grid_view_outlined),selectedIcon:Icon(Icons.grid_view_rounded),label:'Products'),
            NavigationDestination(icon:badges.Badge(showBadge:cc>0,badgeContent:Text('$cc',style:const TextStyle(color:Colors.white,fontSize:10)),child:const Icon(Icons.shopping_cart_outlined)),
              selectedIcon:badges.Badge(showBadge:cc>0,badgeContent:Text('$cc',style:const TextStyle(color:Colors.white,fontSize:10)),child:const Icon(Icons.shopping_cart_rounded)),label:'Cart'),
            NavigationDestination(icon:badges.Badge(showBadge:wc>0,badgeContent:Text('$wc',style:const TextStyle(color:Colors.white,fontSize:10)),child:const Icon(Icons.favorite_border_rounded)),
              selectedIcon:badges.Badge(showBadge:wc>0,badgeContent:Text('$wc',style:const TextStyle(color:Colors.white,fontSize:10)),child:const Icon(Icons.favorite_rounded)),label:'Wishlist'),
            const NavigationDestination(icon:Icon(Icons.person_outline_rounded),selectedIcon:Icon(Icons.person_rounded),label:'Profile'),
          ],
        )),
      ),
    );
  }
}
