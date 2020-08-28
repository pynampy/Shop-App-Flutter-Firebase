import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const route = '/edit-product-screen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();

  final _form = GlobalKey<FormState>();

  var _isinit = true;
  var _isLoading = false;

  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      print('Done');
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    if (_isinit) {
      final productId = ModalRoute.of(context).settings.arguments;

      if (productId != null) {
        _editedProduct = Provider.of<Products>(context).findById(productId);

        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isinit = false;
    super.didChangeDependencies();
  }







  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();

    if (!isValid)  {return;}

    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != null) {

      await Provider.of<Products>(context, listen: false)
       .updateProduct(_editedProduct.id, _editedProduct);
     

    } else {

        try{
          await Provider.of<Products>(context, listen: false)
          .addProducts(_editedProduct);
       
         }catch (error){
           print('HI');

           await showDialog(context: context,
            builder: (ctx) => AlertDialog(title:
            Text('An error Occured'),
            content: Text('Something Went Wrong!'),
            actions: <Widget>[
              FlatButton(onPressed: () {Navigator.of(ctx).pop();}, child: Text('Okay'))
            ], ));

            print('Hi2');

         }
       setState(() { _isLoading = true;});
      Navigator.of(context).pop();
         }
}

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Product'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.save), onPressed: _saveForm)
          ],
        ),
        body: _isLoading? Center(
          child: CircularProgressIndicator(),
        ):Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _form,
              child: ListView(children: <Widget>[
                TextFormField(
                  initialValue: _initValues['title'],
                  decoration: InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_priceFocusNode),
                  onSaved: (value) {
                    _editedProduct = Product(
                        id: _editedProduct.id,
                        isFavorite: _editedProduct.isFavorite,
                        title: value,
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please provide a value';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _initValues['price'],
                  decoration: InputDecoration(labelText: 'Price'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) => FocusScope.of(context)
                      .requestFocus(_descriptionFocusNode),
                  onSaved: (value) {
                    _editedProduct = Product(
                        id: _editedProduct.id,
                        isFavorite: _editedProduct.isFavorite,
                        title: _editedProduct.title,
                        price: double.parse(value),
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please Enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Please Enter a number greater than 0';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _initValues['description'],
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  focusNode: _descriptionFocusNode,
                  onSaved: (value) {
                    _editedProduct = Product(
                        id: _editedProduct.id,
                        isFavorite: _editedProduct.isFavorite,
                        title: _editedProduct.title,
                        price: _editedProduct.price,
                        description: value,
                        imageUrl: _editedProduct.imageUrl);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.length < 10) {
                      return 'Should be more than 10 characters';
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(
                          top: 8,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        )),
                        child: _imageUrlController.text.isEmpty
                            ? Text("Enter a URL!")
                            :
                            //  Text('Preview'),
                            FittedBox(
                                child: Image.network(
                                  _imageUrlController.text,
                                  //   fit: BoxFit.cover,
                                ),
                              )),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageUrlFocusNode,
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: value,
                          );
                        },
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a URL';
                          }
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'Please enter a provide value';
                          }
                          if (!value.endsWith('png') &&
                              !value.endsWith('jpg') &&
                              !value.endsWith('jpeg')) {
                            return 'Please enter a valid image type';
                          }
                          return null;
                        },
                      ),
                    )
                  ],
                )
              ])),
        ));
  }
}
