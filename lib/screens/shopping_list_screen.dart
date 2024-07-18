import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/data/categories.dart';
// import 'package:shopping/data/grocery_items.dart';

import 'package:shopping/models/grocery_item.dart';
import 'package:shopping/screens/new_item_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<GroceryItem> _groceryList = [];
  bool _isloading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https(
        'practice-91370-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);

    if (response.body == 'null') {
      setState(() {
        _isloading = false;
      });
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedList = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catitem) => (item.value['category'] == catitem.value.title))
          .value;

      loadedList.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }

    setState(() {
      _groceryList = loadedList;
      _isloading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.push<GroceryItem>(context,
        MaterialPageRoute(builder: (context) {
      return const NewItemScreen();
    }));

    if (newItem == null) {
      return;
    } else {
      setState(() {
        _groceryList.add(newItem);
      });
    }
  }

  void _onRemove(GroceryItem item) async {
    final itemPos = _groceryList.indexOf(item);
    setState(() {
      _groceryList.remove(item);
    });

    final url = Uri.https('practice-91370-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);

    //  add back if status code is 404
    if (response.statusCode >= 400) {
      setState(() {
        _groceryList.insert(itemPos, item);
      });
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Grocery Item Removed"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No Grocery Item Present"),
    );
    if (_isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryList.isNotEmpty) {
      content = ListView.builder(
          shrinkWrap: true,
          itemCount: _groceryList.length,
          itemBuilder: (context, index) {
            final item = _groceryList[index];
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Theme.of(context).colorScheme.error,
              ),
              onDismissed: (direction) {
                _onRemove(item);
              },
              child: ListTile(
                leading: Container(
                  height: 20,
                  width: 20,
                  color: item.category.color,
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Text(
                  item.quantity.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Groceries",
        ),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
        centerTitle: true,
      ),
      body: content,
    );
  }
}
