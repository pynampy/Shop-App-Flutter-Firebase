import 'package:flutter/material.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

import '../widgets/user_product_item.dart';
import '../screens/edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const route = '/user-product-screen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    print("...");
  //  final productData = Provider.of<Products>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Products'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () =>
                    Navigator.of(context).pushNamed(EditProductScreen.route))
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
                  future: _refreshProducts(context),
                  builder: (ctx, snapshot) => 
                  snapshot.connectionState == ConnectionState.waiting?
                  Center(child: CircularProgressIndicator()):    
                  RefreshIndicator(
            onRefresh: () {
              return _refreshProducts(context);
            },
            child: Consumer<Products>(
              builder: (ctx,productData,_) =>
                          Padding(
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                    itemCount: productData.items.length,
                    itemBuilder: (_, index) {
                      return UserProductItem(
                        productData.items[index].id,
                        productData.items[index].title,
                        productData.items[index].imageUrl,
                      );
                    }),
              ),
            ),
          ),
        ));
  }
}
