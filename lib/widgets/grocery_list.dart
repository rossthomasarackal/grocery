import 'package:flutter/material.dart';
import 'package:shopping/data/categories.dart';
//import 'package:shopping/data/dummy_items.dart';
import 'package:shopping/models/grocery_item.dart';
import 'package:shopping/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  var _isLoading=true;
 List<GroceryItem> _groceryItems=[];
 String ? _error;
 @override

  void initState() {
    super.initState();
    _loadItems();
  }
 void _loadItems()async {
   final url= Uri.https('shoppingfirebase-44a44-default-rtdb.firebaseio.com','shopping-list.json');
   final response= await http.get(url);
   if(response.statusCode>=400){
     setState(() {
       _error='Failed to Fetch data. Try again later';
     });
   }
   print(response.body);

   if(response.body=='null'){
   setState(() {
     _isLoading=false;
   });
   return;
   }


   final Map<String, dynamic>listData= json.decode(response.body);
   final List<GroceryItem> loadedItems=[];
    for (final item in listData.entries){
      final category = categories.entries.firstWhere(
              (catItem) => catItem.value.title==item.value['category']).value;
     loadedItems.add(GroceryItem(
         id: item.key,
         name: item.value['name'],
         quantity: item.value['quantity'],
         category: category)
     );
    }
    setState(() {
      _groceryItems=loadedItems;
      _isLoading=false;
    });
 }

  void _addNewItem() async {
  final newItem= await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
          builder: (ctx)=> const NewItem())
    );
  //_loadItems();
    if(newItem==null){
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item)async {
  final index= _groceryItems.indexOf(item) ;
  setState(() {
    _groceryItems.remove(item);
  });
  final url=Uri.https('shoppingfirebase-44a44-default-rtdb.firebaseio.com','shopping-list/${item.id}.json');
  final response= await http.delete(url);
  //print(response.statusCode);
  if(response.statusCode>=400){
    setState(() {
      _groceryItems.insert(index, item);
    });
  }

  }

  @override
  Widget build(BuildContext context) {
    Widget content=const Center(child: Text('Nothing to Display'));
    if(_isLoading){
      content=const Center(
        child: CircularProgressIndicator(color: Colors.white,)
      );
    }
    if(_groceryItems.isNotEmpty){
      content= ListView.builder(
        itemCount: _groceryItems.length ,
        itemBuilder: (ctx, index)=>
            Dismissible(
              key: ValueKey(_groceryItems[index].id),
              onDismissed: (direction){
              _removeItem(_groceryItems[index]);
              },
              child: ListTile(
                title:Text(_groceryItems[index].name),
                leading: Container(
                  width: 22,
                  height: 22,
                  color: _groceryItems[index].category.color,
                ),
                trailing: Text(_groceryItems[index].quantity.toString()),
              ),
            ),
      );
    }
    if(_error!=null){
    setState(() {
      content =Center(child: Text(_error!),);
    });
    }
    return Scaffold(
      appBar: AppBar(

        title: const Text('Your Groceries'),

        actions: [
          IconButton(
              onPressed: _addNewItem,
              icon:const Icon(Icons.add)),
        ],
      ),
      body: content,
    );
  }
}
