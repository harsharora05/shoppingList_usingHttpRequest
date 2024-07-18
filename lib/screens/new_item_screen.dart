import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/data/categories.dart';
// import 'package:shopping/data/grocery_items.dart';
import 'package:shopping/models/category.dart';
import 'package:shopping/models/grocery_item.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  bool _isAdding = false;
  final _formKey = GlobalKey<FormState>();
  void _addItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAdding = true;
      });
      _formKey.currentState!.save();
      final url = Uri.https(
          'practice-91370-default-rtdb.firebaseio.com', 'shopping-list.json');
      final response = await http.post(
        url,
        headers: {"content": "application/json"},
        body: json.encode({
          "name": _name,
          "quantity": _quantity,
          "category": _selectedCategory.title
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (!context.mounted) {
        return;
      } else {
        Navigator.of(context).pop(GroceryItem(
            id: responseData['name'],
            name: _name,
            quantity: _quantity,
            category: _selectedCategory));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Grocery Item Added Successfully"),
        ));
      }
    }
  }

  var _name;
  var _quantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add NewItem"),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null ||
                        value.length <= 3 ||
                        value.length >= 50) {
                      return "Invalid Name";
                    } else {
                      return null;
                    }
                  },
                  maxLength: 50,
                  decoration: const InputDecoration(
                      label: Text(
                    "Name",
                    style: TextStyle(color: Colors.black),
                  )),
                  onSaved: (newValue) {
                    _name = newValue!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: TextFormField(
                      initialValue: _quantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Invalid Quantity";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _quantity = int.parse(newValue!);
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          label: Text(
                        "Quantity",
                        style: TextStyle(color: Colors.black),
                      )),
                    )),
                    const SizedBox(
                      width: 25,
                    ),
                    Expanded(
                        child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    height: 16,
                                    width: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    category.value.title,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              )),
                      ],
                      onChanged: (value) {
                        _selectedCategory = value!;
                      },
                    )),
                  ],
                ),
                const SizedBox(
                  height: 26,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          if (_isAdding) {
                            return;
                          } else {
                            _formKey.currentState!.reset();
                          }
                        },
                        child: const Text("reset")),
                    ElevatedButton(
                        onPressed: _addItem,
                        child: _isAdding
                            ? SizedBox(
                                height: 10,
                                width: 15,
                                child: const CircularProgressIndicator())
                            : const Text("Add"))
                  ],
                )
              ],
            ),
          )),
    );
  }
}
