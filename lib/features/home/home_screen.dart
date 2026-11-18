import 'package:bn5_swd8_s1_firebase/core/app_extensions.dart';
import 'package:bn5_swd8_s1_firebase/features/home/create_product_screen.dart';
import 'package:bn5_swd8_s1_firebase/features/splash/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    FirebaseFirestore.instance.collection("products").snapshots().listen((
      data,
    ) {
      products = data.docs.map((e) => e.data()).toList();
      setState(() {});
    });
    // var data = await FirebaseFirestore.instance.collection("products").get();
    // products = data.docs.map((e) => e.data()).toList();
    // setState(() {});
    // for (var element in data.docs) {
    //   element.id;
    //   element.data();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goTo(CreateProductScreen());
        },
      ),
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              context.goOff(SplashScreen());
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),

      body: ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(products[index]["name"]),
              subtitle: Text(products[index]["price"].toString()),
            ),
          );
        },
        itemCount: products.length,
      ),
    );
  }
}
