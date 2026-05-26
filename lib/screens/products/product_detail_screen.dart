import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _img = 0, _qty = 1;

  @override Widget build(BuildContext ctx) {
    final cart = ctx.watch<CartProvider>();
    final wl = ctx.watch<WishlistProvider>();
    final related = ctx.read<ProductProvider>().getRelated(widget.product.category, widget.product.id);
    final fav = wl.isWishlisted(widget.product.id);
    final inCart = cart.isInCart(widget.product.id);

    return Scaffold(
      body: CustomScrollView(slivers:[
        SliverAppBar(expandedHeight:320,pinned:true,
          actions:[IconButton(icon:Icon(fav?Icons.favorite_rounded:Icons.favorite_border_rounded,color:fav?Colors.red:null),onPressed:()=>wl.toggleWishlist(widget.product.id))],
          flexibleSpace:FlexibleSpaceBar(background:Stack(children:[
            CachedNetworkImage(imageUrl:widget.product.images.isNotEmpty?widget.product.images[_img]:'',fit:BoxFit.cover,width:double.infinity,height:double.infinity,
              placeholder:(_,__)=>Container(color:Colors.grey[200]),errorWidget:(_,__,___)=>Container(color:Colors.grey[200],child:const Icon(Icons.image_outlined,size:64))),
            if(widget.product.images.length>1) Positioned(bottom:12,left:0,right:0,
              child:Row(mainAxisAlignment:MainAxisAlignment.center,children:widget.product.images.asMap().entries.map((e)=>GestureDetector(
                onTap:()=>setState(()=>_img=e.key),
                child:Container(margin:const EdgeInsets.symmetric(horizontal:4),width:8,height:8,
                  decoration:BoxDecoration(shape:BoxShape.circle,color:_img==e.key?Colors.white:Colors.white54)))).toList())),
          ]))),
        SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
            decoration:BoxDecoration(color:Theme.of(ctx).colorScheme.primary.withOpacity(0.1),borderRadius:BorderRadius.circular(8)),
            child:Text(widget.product.category,style:TextStyle(fontSize:12,color:Theme.of(ctx).colorScheme.primary,fontWeight:FontWeight.w500))),
          const SizedBox(height:12),
          Text(widget.product.name,style:Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),
          const SizedBox(height:12),
          Row(children:[RatingBarIndicator(rating:widget.product.rating,itemSize:18,itemBuilder:(_,__)=>const Icon(Icons.star,color:Colors.amber)),
            const SizedBox(width:8),Text('${widget.product.rating} (${widget.product.reviewCount} reviews)',style:const TextStyle(color:Colors.grey))]),
          const SizedBox(height:16),
          Row(children:[
            Text('₹${widget.product.price.toStringAsFixed(0)}',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:Theme.of(ctx).colorScheme.primary)),
            if(widget.product.originalPrice!=null)...[
              const SizedBox(width:12),
              Text('₹${widget.product.originalPrice!.toStringAsFixed(0)}',style:const TextStyle(fontSize:18,decoration:TextDecoration.lineThrough,color:Colors.grey)),
              const SizedBox(width:8),
              Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:Colors.green.withOpacity(0.1),borderRadius:BorderRadius.circular(8)),
                child:Text('${widget.product.discountPercentage.toInt()}% off',style:const TextStyle(color:Colors.green,fontWeight:FontWeight.bold,fontSize:12))),
            ],
          ]),
          const SizedBox(height:16),
          Row(children:[Icon(widget.product.stock>0?Icons.check_circle_outline:Icons.cancel_outlined,size:16,color:widget.product.stock>0?Colors.green:Colors.red),
            const SizedBox(width:6),Text(widget.product.stock>0?'In Stock (${widget.product.stock} left)':'Out of Stock',style:TextStyle(color:widget.product.stock>0?Colors.green:Colors.red))]),
          const SizedBox(height:20),
          Row(children:[
            const Text('Quantity:',style:TextStyle(fontWeight:FontWeight.w500)),const SizedBox(width:16),
            Container(decoration:BoxDecoration(border:Border.all(color:Colors.grey.withOpacity(0.3)),borderRadius:BorderRadius.circular(12)),
              child:Row(children:[
                IconButton(icon:const Icon(Icons.remove),onPressed:_qty>1?()=>setState(()=>_qty--):null,iconSize:18),
                Text('$_qty',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16)),
                IconButton(icon:const Icon(Icons.add),onPressed:_qty<widget.product.stock?()=>setState(()=>_qty++):null,iconSize:18),
              ])),
          ]),
          const SizedBox(height:24),
          Text('Description',style:Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),
          const SizedBox(height:8),
          Text(widget.product.description,style:const TextStyle(color:Colors.grey,height:1.6,fontSize:14)),
          const SizedBox(height:24),
          Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.blue.withOpacity(0.08),borderRadius:BorderRadius.circular(12)),
            child:const Row(children:[Icon(Icons.local_shipping_outlined,color:Colors.blue),SizedBox(width:12),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('Free Delivery',style:TextStyle(fontWeight:FontWeight.bold)),
                Text('On orders above ₹499',style:TextStyle(color:Colors.grey,fontSize:12))]))
            ])),
          if(related.isNotEmpty)...[
            const SizedBox(height:24),
            Text('Related Products',style:Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),
            const SizedBox(height:12),
            SizedBox(height:250,child:ListView.builder(scrollDirection:Axis.horizontal,itemCount:related.length,
              itemBuilder:(c,i)=>SizedBox(width:170,child:Padding(padding:const EdgeInsets.only(right:12),child:ProductCard(product:related[i]))))),
          ],
          const SizedBox(height:100),
        ]))),
      ]),
      bottomNavigationBar: Container(padding:const EdgeInsets.all(16),
        decoration:BoxDecoration(color:Theme.of(ctx).scaffoldBackgroundColor,boxShadow:[BoxShadow(color:Colors.black12,blurRadius:20,offset:const Offset(0,-5))]),
        child:SafeArea(child:Row(children:[
          Expanded(child:OutlinedButton.icon(icon:Icon(inCart?Icons.check:Icons.shopping_cart_outlined),label:Text(inCart?'In Cart':'Add to Cart'),
            onPressed:widget.product.stock>0?(){
              if(!inCart){cart.addToCart(CartItem(productId:widget.product.id,productName:widget.product.name,productImage:widget.product.images.isNotEmpty?widget.product.images[0]:'',price:widget.product.price,quantity:_qty));
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content:Text('Added to cart!')));
              } else Navigator.push(ctx,MaterialPageRoute(builder:(_)=>const CartScreen()));
            }:null,style:OutlinedButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:14),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))))),
          const SizedBox(width:12),
          Expanded(child:ElevatedButton.icon(icon:const Icon(Icons.flash_on_rounded),label:const Text('Buy Now'),
            onPressed:widget.product.stock>0?(){
              cart.addToCart(CartItem(productId:widget.product.id,productName:widget.product.name,productImage:widget.product.images.isNotEmpty?widget.product.images[0]:'',price:widget.product.price,quantity:_qty));
              Navigator.push(ctx,MaterialPageRoute(builder:(_)=>const CartScreen()));
            }:null,style:ElevatedButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:14),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))))),
        ]))),
    );
  }
}
