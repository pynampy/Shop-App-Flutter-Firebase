import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/orders.dart';
import './providers/cart.dart';
import './providers/products.dart';
import './providers/auth.dart';

import './widgets/splash_screen.dart';

import './screens/product_detail_screen.dart';
import './screens/product_overview_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products('null','null',[]),
            update: (ctx, auth, previousState) => Products(
              auth.token,
              auth.userId,
              previousState.items == null? []: previousState.items,
            ),
          ),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('null', 'null', []),
            update: (ctx, auth, previousState) => Orders(auth.token,auth.userId, previousState.orders),),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Shop App',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato'),
            home: auth.isAuth ? ProductOverviewScreen() :

              FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (ctx, authResultSnapshot) =>
                  authResultSnapshot.connectionState == ConnectionState.waiting?
                  SplashScreen()
                 :AuthScreen()),

  
            routes: {
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.route: (context) => CartScreen(),
              OrderScreen.route: (context) => OrderScreen(),
              UserProductScreen.route: (context) => UserProductScreen(),
              EditProductScreen.route: (context) => EditProductScreen(),
            },
          ),
        ));
  }
}
