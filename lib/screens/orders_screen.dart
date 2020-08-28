import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';


import 'package:provider/provider.dart';  

class OrderScreen extends StatelessWidget {


  static const route = '/orders';


  @override
  Widget build(BuildContext context) {
    print('Building');
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders")
      ),
      drawer: AppDrawer(),
      body: FutureBuilder( future: Provider.of<Orders>(context,listen: false).fetchAndSetOrders(), 
       builder: (ctx , dataSnapshot){
         if(dataSnapshot.connectionState == ConnectionState.waiting){
           return Center(child: CircularProgressIndicator(),);
         } 
         else{
           if( dataSnapshot.error != null ){
             return Center(child: Text("An error Occured"),);
           }else{ return 
             Consumer<Orders>(builder: (ctx,orderData,ch) {
               return ListView.builder(itemCount: orderData.orders.length, 
      itemBuilder: (ctx, i) => OrderItem(orderData.orders[i],)); 
             });
           }
         }
       })       
    
    
    );
  }
}