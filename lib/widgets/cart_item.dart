import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItems extends StatelessWidget {
  final String productId;
  final String id;
  final double price;
  final int quantity;
  final String title;

  CartItems(this.productId, this.id, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {


    return Dismissible(
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItems(productId);
      },
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 40),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(context: context, builder: (ctx) => AlertDialog(
          title: Text('Are you sure? '),
          content: Text('Do you want to remove the item?'),

          actions: <Widget>[
            FlatButton(onPressed: () {
              Navigator.of(ctx).pop(false);
            }, child: Text("No"),),
            FlatButton(onPressed: () {
               Navigator.of(ctx).pop(true);
            }, child: Text("Yes"),)
          ],

        ));
        
      },
      
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                  padding: EdgeInsets.all(5),
                  child: FittedBox(child: Text('\u20B9 $price'))),
            ),
            title: Text(title),
            subtitle: Text('Total: \u20B9 ${(price * quantity)}'),
            trailing: Text('$quantity X'),
          ),
        ),
      ),
    );
  }
}
