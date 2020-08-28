import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(
      context,
    ).settings.arguments as String;

    final loadedProduct = Provider.of<Products>(context).findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: productId,
                              child: Image.network(loadedProduct.imageUrl,
                    fit: BoxFit.cover, width: double.infinity),
              )
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [SizedBox(height: 10),
                  Text('\u20B9 ${loadedProduct.price}', style: TextStyle(
                    color: Colors.grey,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,),
                  SizedBox(height: 10),


                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,

                    child: Text(loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,),
                    ),
                    SizedBox(height: 1000,)
                    
                    ]
            ) 
            
            ),
        ],
            
                  
        ),
      
    );
  }
}
