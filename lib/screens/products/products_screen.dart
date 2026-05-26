import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override State<ProductsScreen> createState() => _ProductsScreenState();
}
class _ProductsScreenState extends State<ProductsScreen> {
  final _sc = TextEditingController();
  @override void dispose() { _sc.dispose(); super.dispose(); }

  @override Widget build(BuildContext ctx) {
    final pp = ctx.watch<ProductProvider>();
    return Scaffold(
      appBar: AppBar(title:const Text('Products'),
        bottom:PreferredSize(preferredSize:const Size.fromHeight(60),
          child:Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),
            child:TextField(controller:_sc,
              decoration:InputDecoration(hintText:'Search products...',prefixIcon:const Icon(Icons.search),
                suffixIcon:_sc.text.isNotEmpty?IconButton(icon:const Icon(Icons.clear),onPressed:(){_sc.clear();pp.setSearchQuery('');}) :null),
              onChanged:(v)=>pp.setSearchQuery(v))))),
      body: Column(children:[
        SizedBox(height:48,child:ListView.builder(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),
          itemCount:AppConstants.categories.length,
          itemBuilder:(c,i){final cat=AppConstants.categories[i];final sel=pp.selectedCategory==cat;
            return Padding(padding:const EdgeInsets.symmetric(horizontal:4,vertical:8),
              child:FilterChip(label:Text(cat),selected:sel,onSelected:(_)=>pp.setCategory(cat),
                selectedColor:Theme.of(c).colorScheme.primary,checkmarkColor:Colors.white,
                labelStyle:TextStyle(color:sel?Colors.white:null,fontWeight:sel?FontWeight.w600:FontWeight.normal)));
          })),
        Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:4),child:Row(
          mainAxisAlignment:MainAxisAlignment.spaceBetween,
          children:[Text('${pp.products.length} Products',style:const TextStyle(color:Colors.grey,fontSize:13)),
            DropdownButton<String>(value:pp.sortBy,underline:const SizedBox(),
              items:const[DropdownMenuItem(value:'newest',child:Text('Newest')),DropdownMenuItem(value:'price_low',child:Text('Price ↑')),
                DropdownMenuItem(value:'price_high',child:Text('Price ↓')),DropdownMenuItem(value:'rating',child:Text('Top Rated'))],
              onChanged:(v){if(v!=null)pp.setSortBy(v);}),
          ])),
        Expanded(child: pp.isLoading?const Center(child:CircularProgressIndicator()):
          pp.products.isEmpty?const Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
            Icon(Icons.search_off,size:64,color:Colors.grey),SizedBox(height:16),Text('No products found',style:TextStyle(color:Colors.grey))]))
          :GridView.builder(padding:const EdgeInsets.all(16),
              gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:0.72,crossAxisSpacing:12,mainAxisSpacing:12),
              itemCount:pp.products.length,itemBuilder:(c,i)=>ProductCard(product:pp.products[i]))),
      ]),
    );
  }
}
