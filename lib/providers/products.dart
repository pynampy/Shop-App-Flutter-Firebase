import 'package:flutter/material.dart';
import 'dart:convert';

import 'product.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';


class Products with ChangeNotifier{

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);
  

  List<Product> _items = [];
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Blue Jeans',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'Metal Pan',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   ];

  var showFavoritesOnly = false;


  List<Product> get favoritesItems{

    return _items.where((element) => element.isFavorite).toList();
  }


  List<Product> get items{
    
      return[..._items];
  }

  Product findById(String id){
    return _items.firstWhere((element) => element.id == id);
  }


  Future<void> updateProduct( String productId , Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == productId);
    final url = 'https://shopapp-7bceb.firebaseio.com/products/$productId.json?auth=$authToken';

    await http.patch(url, body: json.encode({
      'title': newProduct.title,
      'description' : newProduct.description,
      'iamgeUrl': newProduct.imageUrl,
      'price' : newProduct.price
    }));  
    
    if(prodIndex>=0){
      _items[prodIndex] = newProduct; 
      notifyListeners();
    }else{
      print(' ... ');
    }
  }

 Future<void> deleteProduct( String productId) async {

    final url = 'https://shopapp-7bceb.firebaseio.com/products/$productId.json?auth=$authToken';

    final existingProductIndex = _items.indexWhere((element) => element.id == productId);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);    
    notifyListeners();

    final response = await http.delete(url);
    
      if(response.statusCode > 400){
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException('Could Not Delete Product');
      }
      existingProduct = null;
  }


  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    
  String filterString = filterByUser? 'orderBy="creatorId"&equalTo="$userId"': '';

  var url = 'https://shopapp-7bceb.firebaseio.com/products.json?auth=$authToken&$filterString';
  
  try{
    final response = await http.get(url);
    final List<Product> loadedProducts =[];
    final extractedData = json.decode(response.body) as Map<String,dynamic>;
    if(extractedData == null){
      return;
    }
    url = 'https://shopapp-7bceb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
    final favoriteResponse = await http.get(url);
    final favoriteData = json.decode(favoriteResponse.body);
    extractedData.forEach((prodId, prodData) {
      loadedProducts.add(
        Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: favoriteData == null? false: favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
           
        )
      );
      _items = loadedProducts;
      notifyListeners();
    });
  }catch(error){
    throw(error);
  }}


  Future<void> addProducts(Product product) async  {

    final url = 'https://shopapp-7bceb.firebaseio.com/products.json?auth=$authToken';

    try{

      final response = await http.post(url, body: json.encode({
      'title' : product.title,
      'description' : product.description,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'creatorId': userId,
    }));

      final newProduct = Product(
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      id: json.decode(response.body)['name']);
      items.add(newProduct);
    
      notifyListeners();
      
    }catch(error){
      print(error);
      throw error;
    }
  }
}

