import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _name=TextEditingController(),_email=TextEditingController(),
    _phone=TextEditingController(),_pass=TextEditingController(),_confirm=TextEditingController();
  bool _op=true,_oc=true,_loading=false;

  @override void dispose() {for(final c in [_name,_email,_phone,_pass,_confirm]) c.dispose(); super.dispose();}

  Future<void> _register() async {
    if(!_key.currentState!.validate()) return;
    setState(()=>_loading=true);
    final auth=context.read<AuthProvider>();
    final ok=await auth.registerWithEmail(name:_name.text.trim(),email:_email.text.trim(),password:_pass.text,phone:_phone.text.trim());
    if(ok&&mounted){
      final uid=auth.firebaseUser!.uid;
      context.read<CartProvider>().setUser(uid);
      context.read<OrderProvider>().setUser(uid);
      context.read<WishlistProvider>().setUser(uid);
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const MainScreen()),(r)=>false);
    } else if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(auth.error??'Registration failed'),backgroundColor:Colors.red));
    if(mounted) setState(()=>_loading=false);
  }

  @override Widget build(BuildContext ctx) => Scaffold(
    appBar: AppBar(title:const Text('Create Account')),
    body: SafeArea(child: SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,
      children:[
        Text('Join ShopEase',style:Theme.of(ctx).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.bold)),
        const SizedBox(height:8),const Text('Create your free account',style:TextStyle(color:Colors.grey)),
        const SizedBox(height:32),
        Form(key:_key,child:Column(children:[
          _f(_name,'Full Name',Icons.person_outline,cap:TextCapitalization.words),
          _f(_email,'Email',Icons.email_outlined,type:TextInputType.emailAddress,val:(v)=>(!v!.contains('@'))?'Invalid email':null),
          _f(_phone,'Phone (Optional)',Icons.phone_outlined,type:TextInputType.phone,req:false),
          _pw(_pass,'Password',_op,()=>setState(()=>_op=!_op),(v)=>v!.length<6?'Min 6 chars':null),
          _pw(_confirm,'Confirm Password',_oc,()=>setState(()=>_oc=!_oc),(v)=>v!=_pass.text?'Passwords do not match':null),
          const SizedBox(height:24),
          SizedBox(width:double.infinity,child:ElevatedButton(onPressed:_loading?null:_register,
            child:_loading?const SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)):const Text('Create Account'))),
        ])),
        const SizedBox(height:12),
        const Center(child:Text('By signing up you agree to our Terms & Privacy Policy',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey,fontSize:12))),
      ],
    ))),
  );

  Widget _f(TextEditingController c,String l,IconData ic,{TextInputType? type,bool req=true,String? Function(String?)? val,TextCapitalization cap=TextCapitalization.none})=>Padding(
    padding:const EdgeInsets.only(bottom:14),
    child:TextFormField(controller:c,keyboardType:type,textCapitalization:cap,
      decoration:InputDecoration(labelText:l,prefixIcon:Icon(ic)),
      validator:req?(v)=>v==null||v.trim().isEmpty?'$l required':val?.call(v):val));

  Widget _pw(TextEditingController c,String l,bool obs,VoidCallback toggle,String? Function(String?) val)=>Padding(
    padding:const EdgeInsets.only(bottom:14),
    child:TextFormField(controller:c,obscureText:obs,
      decoration:InputDecoration(labelText:l,prefixIcon:const Icon(Icons.lock_outline),
        suffixIcon:IconButton(icon:Icon(obs?Icons.visibility_off:Icons.visibility),onPressed:toggle)),
      validator:(v)=>v==null?'Required':val(v)));
}
