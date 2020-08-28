import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart ; //show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';



class CartScreen extends StatelessWidget {
  static const route = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: Column(children: <Widget>[
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Spacer(),
                Chip(
                  label: Text(
                    '\u20B9 ${cart.totalAAmount}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                OrderButton(cart: cart)
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) => CartItems(
                    cart.items.keys.toList()[index],
                    cart.items.values.toList()[index].id,
                     cart.items.values.toList()[index].price,
                    cart.items.values.toList()[index].quantity,
                     cart.items.values.toList()[index].title,
                  )),
        )
      ]),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
         onPressed: () async {
           setState(() {
             _isLoading = true;
           });
          await Provider.of<Orders>(context,listen: false).addOrder(
            widget.cart.items.values.toList(), 
            widget.cart.totalAAmount,
            );
            setState(() {
             _isLoading = false;
           });
            widget.cart.clear();
        },
        child: _isLoading? CircularProgressIndicator() : Text(
          "Order Now",
          style: (widget.cart.totalAAmount <= 0 ) 
         ? TextStyle(color: Colors.black26)
         :TextStyle(color: Theme.of(context).primaryColor),
        ));
  }
}
