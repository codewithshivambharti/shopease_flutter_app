import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/product_card.dart';
import '../products/products_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _banners = [
    {'title':'Mega Sale','sub':'Up to 60% off Electronics','color':0xFF6C63FF,'icon':Icons.devices_rounded},
    {'title':'New Arrivals','sub':'Latest fashion collection','color':0xFFFF6584,'icon':Icons.checkroom_rounded},
    {'title':'Free Delivery','sub':'On orders above ₹499','color':0xFF43E97B,'icon':Icons.local_shipping_outlined},
  ];

  @override Widget build(BuildContext ctx) {
    final auth = ctx.watch<AuthProvider>();
    final pp = ctx.watch<ProductProvider>();
    final name = auth.userModel?.name?.split(' ').first ?? 'User';

    return Scaffold(
      appBar: AppBar(
        titleSpacing:16,
        title: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Hello, $name 👋',style:const TextStyle(fontSize:16,fontWeight:FontWeight.w600)),
          const Text('Find your perfect item',style:TextStyle(fontSize:12,color:Colors.grey)),
        ]),
        centerTitle:false,
        actions:[IconButton(icon:const Icon(Icons.search_rounded),onPressed:()=>Navigator.push(ctx,MaterialPageRoute(builder:(_)=>const ProductsScreen())))],
      ),
      body: RefreshIndicator(
        onRefresh: pp.fetchProducts,
        child: SingleChildScrollView(physics:const AlwaysScrollableScrollPhysics(),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const SizedBox(height:16),
          CarouselSlider(
            options: CarouselOptions(height:160,autoPlay:true,enlargeCenterPage:true,viewportFraction:0.9,autoPlayInterval:const Duration(seconds:3)),
            items: _banners.map((b) => _Banner(b)).toList(),
          ),
          const SizedBox(height:24),
          _Header('Categories',()=>Navigator.push(ctx,MaterialPageRoute(builder:(_)=>const ProductsScreen()))),
          SizedBox(height:90,child:ListView.builder(
            scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:16),
            itemCount:AppConstants.categories.length-1,
            itemBuilder:(c,i){
              final cat=AppConstants.categories[i+1];
              return _CatChip(cat,()=>Navigator.push(ctx,MaterialPageRoute(builder:(_)=>const ProductsScreen())));
            },
          )),
          const SizedBox(height:24),
          if(pp.featuredProducts.isNotEmpty)...[
            _Header('⭐ Featured',()=>Navigator.push(ctx,MaterialPageRoute(builder:(_)=>const ProductsScreen()))),
            SizedBox(height:250,child:ListView.builder(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:16),
              itemCount:pp.featuredProducts.length,
              itemBuilder:(c,i)=>SizedBox(width:170,child:Padding(padding:const EdgeInsets.only(right:12),child:ProductCard(product:pp.featuredProducts[i]))))),
            const SizedBox(height:24),
          ],
          if(pp.saleProducts.isNotEmpty)...[
            _Header('🔥 Flash Sale',()=>Navigator.push(ctx,MaterialPageRoute(builder:(_)=>const ProductsScreen()))),
            SizedBox(height:250,child:ListView.builder(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:16),
              itemCount:pp.saleProducts.length,
              itemBuilder:(c,i)=>SizedBox(width:170,child:Padding(padding:const EdgeInsets.only(right:12),child:ProductCard(product:pp.saleProducts[i]))))),
            const SizedBox(height:24),
          ],
          const Padding(padding:EdgeInsets.symmetric(horizontal:16),child:Text('All Products',style:TextStyle(fontSize:16,fontWeight:FontWeight.bold))),
          const SizedBox(height:12),
          pp.isLoading
            ? const Center(child:Padding(padding:EdgeInsets.all(40),child:CircularProgressIndicator()))
            : GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),padding:const EdgeInsets.symmetric(horizontal:16),
                gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:0.72,crossAxisSpacing:12,mainAxisSpacing:12),
                itemCount:pp.products.length, itemBuilder:(c,i)=>ProductCard(product:pp.products[i])),
          const SizedBox(height:24),
        ])),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final Map b;
  const _Banner(this.b);
  @override Widget build(BuildContext ctx) => Container(
    decoration:BoxDecoration(gradient:LinearGradient(colors:[Color(b['color'] as int),(Color(b['color'] as int)).withOpacity(0.7)],begin:Alignment.topLeft,end:Alignment.bottomRight),borderRadius:BorderRadius.circular(20)),
    padding:const EdgeInsets.all(20),
    child:Row(children:[
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[
        Text(b['title'] as String,style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),
        const SizedBox(height:6),Text(b['sub'] as String,style:TextStyle(color:Colors.white.withOpacity(0.85),fontSize:14)),
        const SizedBox(height:14),
        Container(padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),
          child:Text('Shop Now',style:TextStyle(color:Color(b['color'] as int),fontWeight:FontWeight.bold,fontSize:12))),
      ])),
      Icon(b['icon'] as IconData,size:80,color:Colors.white.withOpacity(0.25)),
    ]),
  );
}

class _CatChip extends StatelessWidget {
  final String cat; final VoidCallback onTap;
  const _CatChip(this.cat,this.onTap);
  IconData get _icon {
    switch(cat){
      case 'Electronics': return Icons.devices_rounded;
      case 'Fashion': return Icons.checkroom_rounded;
      case 'Home & Living': return Icons.home_rounded;
      case 'Sports': return Icons.sports_soccer_rounded;
      case 'Beauty': return Icons.face_retouching_natural;
      case 'Books': return Icons.menu_book_rounded;
      case 'Toys': return Icons.toys_rounded;
      case 'Groceries': return Icons.shopping_basket_rounded;
      default: return Icons.category_rounded;
    }
  }
  @override Widget build(BuildContext ctx) => GestureDetector(onTap:onTap,child:Container(margin:const EdgeInsets.only(right:12),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(width:56,height:56,decoration:BoxDecoration(color:Theme.of(ctx).colorScheme.primary.withOpacity(0.1),borderRadius:BorderRadius.circular(16)),
        child:Icon(_icon,color:Theme.of(ctx).colorScheme.primary,size:28)),
      const SizedBox(height:6),
      Text(cat,style:Theme.of(ctx).textTheme.bodySmall,maxLines:1,overflow:TextOverflow.ellipsis),
    ])));
}

class _Header extends StatelessWidget {
  final String title; final VoidCallback onSeeAll;
  const _Header(this.title,this.onSeeAll);
  @override Widget build(BuildContext ctx) => Padding(padding:const EdgeInsets.symmetric(horizontal:16),
    child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
      Text(title,style:Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),
      TextButton(onPressed:onSeeAll,child:const Text('See All')),
    ]));
}
