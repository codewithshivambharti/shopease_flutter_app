import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
  @override Widget build(BuildContext ctx) {
    final wl = ctx.watch<WishlistProvider>();
    final prods = ctx.watch<ProductProvider>().products.where((p)=>wl.isWishlisted(p.id)).toList();
    return Scaffold(
      appBar: AppBar(title:Text('Wishlist (${wl.count})')),
      body: prods.isEmpty?Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
        Icon(Icons.favorite_border_rounded,size:80,color:Colors.grey[300]),const SizedBox(height:16),
        const Text('Wishlist is empty',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),const Text('Save items you love',style:TextStyle(color:Colors.grey))]))
      :GridView.builder(padding:const EdgeInsets.all(16),
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:0.72,crossAxisSpacing:12,mainAxisSpacing:12),
          itemCount:prods.length,itemBuilder:(c,i)=>ProductCard(product:prods[i])),
    );
  }
}
