// lib/screens/homepage.dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedMenuItemId = 0;

  void _onMenuItemSelected(int itemId) {
    setState(() {
      selectedMenuItemId = itemId;
    });
    Navigator.pop(context); // Tutup drawer setelah memilih item
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Home Page"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text("Home"),
              onTap: () {
                _onMenuItemSelected(0);
              },
            ),
            ListTile(
              title: const Text("Profile"),
              onTap: () {
                _onMenuItemSelected(1);
              },
            ),
            ListTile(
              title: const Text("Settings"),
              onTap: () {
                _onMenuItemSelected(2);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          "This is Home Page! Selected Item: ${selectedMenuItemId + 1}",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
