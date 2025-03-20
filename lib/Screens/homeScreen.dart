import 'package:flutter/material.dart';
import 'package:giuaki/Screens/addProduct.dart';
import 'package:giuaki/Screens/listViewScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.list),
            icon: Icon(Icons.list_outlined),
            label: 'List View',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Add Product',
          ),
        ],
      ),
      body: <Widget>[
        const ListViewScreen(), 
        const AddProductScreen(),
      ][currentPageIndex],
    );
  }
}
