import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Product")),
      body: Column(
        children: [
          TextField(controller: nameController),
          TextField(controller: priceController),
          ElevatedButton(
            onPressed: () {
              /// Delete
              FirebaseFirestore.instance
                  .collection("products")
                  .doc("123")
                  .delete();

              /// Create + Edit / Update
              // FirebaseFirestore.instance.collection("products").doc("123").set({
              //   "name": nameController.text,
              //   "price": double.parse(priceController.text),
              // });

              /// Create With Auto Generated ID
              // FirebaseFirestore.instance.collection("products").add({
              //   "name": nameController.text,
              //   "price": double.parse(priceController.text),
              // });
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
