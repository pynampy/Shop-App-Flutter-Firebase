import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItems> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {


  final String authToken;
  final String userId;
  List<OrderItem> _orders = [];

  Orders(this.authToken,this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future <void> fetchAndSetOrders() async {
        final url = 'https://shopapp-7bceb.firebaseio.com/Orders/$userId.json?auth=$authToken';
        final response = await http.get(url);
        final List<OrderItem> loadedOrders = [];
        final exctractedData = json.decode(response.body) as Map<String, dynamic>;  

        if(exctractedData == null){
          return;
        }

        exctractedData.forEach((orderId, orderData) {
          loadedOrders.add(OrderItem(
            id:orderId,
            amount:orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>).map((item) => 
            CartItems(id: item['id'],
            price: item['price'],
            quantity: item['quantity'],
            title: item['title']
            )).toList(),
            )
            );
         });
         _orders = loadedOrders.reversed.toList();
         notifyListeners();
  }

  Future<void> addOrder(List<CartItems> cartProducts, double total) async {

    final url = 'https://shopapp-7bceb.firebaseio.com/Orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();

    final response = await http.post(url,body: json.encode({
      'amount': total,
      'dateTime': timeStamp.toIso8601String(),
      'products' : cartProducts.map((e) => {

        'id': e.id,
        'price': e.price,
        'quantity': e.quantity,
        'title': e.title,

      }
      ).toList(),

    }));

    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: DateTime.now(),
        ));
      notifyListeners();
  }
}
