import 'package:flutter/material.dart';

class CartItems {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItems(
      {@required this.id,
      @required this.price,
      @required this.quantity,
      @required this.title});
}

class Cart with ChangeNotifier {
  Map<String, CartItems> _items = {};

  Map<String, CartItems> get items {
    return {..._items};
  }

  double get totalAAmount {
    var total = 0.0;

    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });

    return total;
  }

  int get itemCount {
    return _items.length;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingItem) => CartItems(
                id: existingItem.id,
                price: existingItem.price,
                quantity: existingItem.quantity + 1,
                title: existingItem.title,
              ));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItems(
                id: DateTime.now().toString(),
                title: title,
                price: price,
                quantity: 1,
              ));
    }
    notifyListeners();
  }

  void removeItems(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    } 

      if (_items[productId].quantity > 1) {
        _items.update(
            productId,
            (existingCartItem) => CartItems(
                  id: existingCartItem.id,
                  price: existingCartItem.price,
                  quantity: existingCartItem.quantity - 1,
                  title: existingCartItem.title,
                ));
      }else{
        _items.remove(productId);
      }
      notifyListeners();
    }
  

  void clear() {
    _items = {};
    notifyListeners();
  }
}
