// lib/widgets/sidebar.dart
import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final Function(int) onMenuItemSelected;
  final int selectedItemId;

  const SideBar({
    super.key,
    required this.onMenuItemSelected,
    required this.selectedItemId,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header atau judul drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            selected: selectedItemId == 0,
            onTap: () {
              onMenuItemSelected(0);
              Navigator.pop(context); // Tutup drawer setelah memilih
            },
          ),
          ListTile(
            title: const Text('Profile'),
            selected: selectedItemId == 1,
            onTap: () {
              onMenuItemSelected(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            selected: selectedItemId == 2,
            onTap: () {
              onMenuItemSelected(2);
              Navigator.pop(context);
            },
          ),
          // Tambahkan lebih banyak menu sesuai kebutuhan
        ],
      ),
    );
  }
}
