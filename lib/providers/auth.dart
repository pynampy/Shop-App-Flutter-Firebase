import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:prefs/prefs.dart';

import 'dart:convert';
import 'dart:async';


class Auth with ChangeNotifier{
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer authTimer;


  String get userId{
    return _userId;
  }

  bool get isAuth {
    return token != null;
  }

  String get token{
    if(_expiryDate!= null && _expiryDate.isAfter(DateTime.now()) && _token != null){
      return _token;
    }
    return null;
  }

  Future<void> _authenticate({String email, String password, String urlSegment}) async {

  final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDKtUIeKZRrJp6bRwJgAFak1WYKik4a0iI'; 
  
  
  try{final response = await http.post(url,body: json.encode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    }));
    final responseData = json.decode(response.body);
    if(responseData['error'] != null){
      throw HttpException(responseData['error']['message']);
    }
    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn']) ));
    _autoLogout();
    notifyListeners();

   final prefs = await SharedPreferences.getInstance();
  // final prefs = await Prefs.;
    final userData = json.encode({
      'token' : _token,
      'userId' : _userId,
      'expiryDate': _expiryDate.toIso8601String(),
    });
    
    prefs.setString('userData', userData);


  }catch(error){
    throw error;

  }
    // print(json.decode(response.body));
}

  Future<void> signUp ({String email, String password}) async {
    
    return _authenticate(email:email,password:password,urlSegment:'signUp');

  }
    
  Future<void> signIn ({String email, String password}) async {

    return _authenticate(email:email,password:password,urlSegment:'signInWithPassword');

  }

  Future<bool> tryAutoLogin () async {
    print('Tried');
    final prefs = await SharedPreferences.getInstance();
    
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData'));
   

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if(expiryDate.isBefore(DateTime.now())){
      print(DateTime.now().toString());
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    print("Reached !");
    return true;


  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if(authTimer != null){
        authTimer.cancel();
        authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autoLogout(){

    if(authTimer != null){
        authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;

    authTimer = Timer(Duration(seconds: timeToExpiry),logout);
  }


}