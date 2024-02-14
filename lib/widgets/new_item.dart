import 'package:flutter/material.dart';
import 'package:shopping/data/categories.dart';
import 'package:shopping/models/category.dart';
import 'package:shopping/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  var _enteredName='';
  var _enteredQuantity=1;
  var _selectedCategory= categories[Categories.vegetables]!;
  final _formKey = GlobalKey<FormState>();
  var _isSending= false;
  void _saveItem() async {
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      setState(() {
        _isSending=true;
      });
      final url= Uri.https('shoppingfirebase-44a44-default-rtdb.firebaseio.com','shopping-list.json');
      final response= await http.post(url,
        headers:{'content-type': 'application/json' },
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.title}),
      );

      print(response.body);
      print(response.statusCode);
      final Map<String, dynamic >resData=json.decode(response.body);
      if(!context.mounted){
        return;
      }
      Navigator.of(context).pop(
          GroceryItem(
          id: resData['name'],
          name: _enteredName ,
          quantity: _enteredQuantity,
          category:  _selectedCategory,
      ));

      print(_enteredName);
      print(_enteredQuantity);
      print(_selectedCategory.title);
      // Navigator.of(context).pop(
      //     GroceryItem(
      //         id: DateTime.now().toString(),
      //         name: _enteredName,
      //         quantity: _enteredQuantity,
      //         category: _selectedCategory)
      // );
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new item'),
      ),
      body: Padding(
        padding:const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
            child: Column(
              children: [

                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name')
                  ),
                  validator: (value){
                    if(value==null ||
                       value.isEmpty ||
                      value.trim().length <=1 ||
                     value.trim().length>50){
                  return 'must be between 1 and 50 characters';
                    }
                    return null;
                  },
                  onSaved: (value){
                    _enteredName= value!;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        initialValue: _enteredQuantity.toString(),
                        validator: (value){
                          if( value==null ||
                              value.isEmpty ||
                              int.tryParse(value)==null||
                              int.tryParse(value)! <= 0){
                            return 'Must be a valid positive number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        onSaved: (value){
                          _enteredQuantity=int.parse(value!);
                        },
                      ),
                      
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                          items: [
                            for(final category in categories.entries)
                              DropdownMenuItem(
                                value: category.value,
                                  child: Row(
                                   children: [
                                  Container(
                                    height: 16,
                                    width: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(category.value.title),
                                ],
                              ))
                          ],
                          onChanged: (value){
                           setState(() {
                             _selectedCategory = value!;
                           });
                          }
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row( mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  TextButton(
                      onPressed:
                      _isSending ? null:(){
                        _formKey.currentState!.reset();
                      },
                      child: const Text('Reset')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: _isSending? null:
                          _saveItem,
                        child: _isSending
                            ? const SizedBox(height: 16,width: 16, child: CircularProgressIndicator())
                            : const Text('Add item'))
                ],
                ),
              ],
            )),
      ),
    );
  }
}
