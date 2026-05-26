import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override Widget build(BuildContext ctx) {
    final cart = ctx.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title:Text('Cart (${cart.itemCount})'),
        actions:[if(cart.items.isNotEmpty) TextButton(onPressed:()=>showDialog(context:ctx,builder:(c)=>AlertDialog(title:const Text('Clear Cart'),content:const Text('Remove all items?'),
          actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')),
            ElevatedButton(onPressed:(){cart.clearCart();Navigator.pop(c);},child:const Text('Clear'))])),child:const Text('Clear All'))]),
      body: cart.items.isEmpty
        ? Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.shopping_cart_outlined,size:80,color:Colors.grey[300]),
            const SizedBox(height:16),const Text('Your cart is empty',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const SizedBox(height:8),const Text('Add items to get started',style:TextStyle(color:Colors.grey)),
            const SizedBox(height:24),ElevatedButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Continue Shopping'))]))
        : Column(children:[
            Expanded(child:ListView.builder(padding:const EdgeInsets.all(16),itemCount:cart.items.length,
              itemBuilder:(c,i)=>_CartTile(item:cart.items[i]))),
            _Summary(cart:cart),
          ]),
    );
  }
}

class _CartTile extends StatelessWidget {
  final item;
  const _CartTile({required this.item});
  @override Widget build(BuildContext ctx) {
    final cart = ctx.read<CartProvider>();
    return Card(margin:const EdgeInsets.only(bottom:12),child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
      ClipRRect(borderRadius:BorderRadius.circular(10),child:CachedNetworkImage(imageUrl:item.productImage,width:80,height:80,fit:BoxFit.cover,
        placeholder:(_,__)=>Container(color:Colors.grey[200]),errorWidget:(_,__,___)=>Container(color:Colors.grey[200]))),
      const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(item.productName,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w500)),
        const SizedBox(height:4),
        Text('₹${item.price.toStringAsFixed(0)}',style:TextStyle(color:Theme.of(ctx).colorScheme.primary,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),
        Row(children:[
          Container(decoration:BoxDecoration(border:Border.all(color:Colors.grey.withOpacity(0.3)),borderRadius:BorderRadius.circular(8)),
            child:Row(mainAxisSize:MainAxisSize.min,children:[
              InkWell(onTap:()=>cart.updateQuantity(item.productId,item.quantity-1),child:const Padding(padding:EdgeInsets.symmetric(horizontal:8,vertical:4),child:Icon(Icons.remove,size:16))),
              Text('${item.quantity}',style:const TextStyle(fontWeight:FontWeight.bold)),
              InkWell(onTap:()=>cart.updateQuantity(item.productId,item.quantity+1),child:const Padding(padding:EdgeInsets.symmetric(horizontal:8,vertical:4),child:Icon(Icons.add,size:16))),
            ])),
          const Spacer(),
          Text('₹${item.totalPrice.toStringAsFixed(0)}',style:const TextStyle(fontWeight:FontWeight.bold)),
        ]),
      ])),
      IconButton(icon:const Icon(Icons.delete_outline,color:Colors.red),onPressed:()=>cart.removeFromCart(item.productId)),
    ])));
  }
}

class _Summary extends StatelessWidget {
  final CartProvider cart;
  const _Summary({required this.cart});
  @override Widget build(BuildContext ctx) => Container(
    padding:const EdgeInsets.all(20),
    decoration:BoxDecoration(color:Theme.of(ctx).scaffoldBackgroundColor,boxShadow:[BoxShadow(color:Colors.black12,blurRadius:20,offset:const Offset(0,-5))]),
    child:SafeArea(child:Column(children:[
      _Row('Subtotal','₹${cart.subtotal.toStringAsFixed(0)}'),
      const SizedBox(height:6),
      _Row('Delivery',cart.deliveryCharge==0?'FREE':'₹${cart.deliveryCharge.toStringAsFixed(0)}',vc:cart.deliveryCharge==0?Colors.green:null),
      const Divider(height:20),
      _Row('Total','₹${cart.totalAmount.toStringAsFixed(0)}',bold:true),
      const SizedBox(height:16),
      SizedBox(width:double.infinity,child:ElevatedButton(
        onPressed:()=>Navigator.push(ctx,MaterialPageRoute(builder:(_)=>const CheckoutScreen())),
        child:Text('Checkout (₹${cart.totalAmount.toStringAsFixed(0)})'))),
    ])),
  );
}
class _Row extends StatelessWidget {
  final String l,v; final bool bold; final Color? vc;
  const _Row(this.l,this.v,{this.bold=false,this.vc});
  @override Widget build(BuildContext ctx) => Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
    Text(l,style:TextStyle(fontWeight:bold?FontWeight.bold:FontWeight.normal,fontSize:bold?16:14)),
    Text(v,style:TextStyle(fontWeight:bold?FontWeight.bold:FontWeight.w500,fontSize:bold?18:14,color:vc??(bold?Theme.of(ctx).colorScheme.primary:null))),
  ]);
}
