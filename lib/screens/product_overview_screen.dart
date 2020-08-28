import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';

import '../screens/cart_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

import '../providers/cart.dart';
import '../providers/products.dart';

enum FilterOption { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var isinit = true;
  var isLoading = false;


  @override
  void didChangeDependencies() {

    if(isinit == true){
      isLoading = true;
      Provider.of<Products>(context).fetchAndSetProducts().then(
        (value){
          setState(() {
            isLoading = false;
          });
        } 
      );
      isinit = false;
    }

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
            ),
            onSelected: (FilterOption selectedValue) {
              setState(() {
                if (selectedValue == FilterOption.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOption.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOption.All,
              ),
            ],
          ),
          Consumer<Cart>(

            builder:( ctx,cart,ch) =>  Badge(
                child: ch,
                value: cart.itemCount.toString()),
                
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      CartScreen.route,
                    );
                  },
                    icon: Icon(
                  Icons.shopping_cart,
        
                )),
          )
        ],
      ),
       
      drawer: AppDrawer(),
      body: isLoading? Center(
        child: CircularProgressIndicator(),
      ):ProductsGrid(_showOnlyFavorites),
    );
  }
}
