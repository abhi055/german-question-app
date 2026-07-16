import 'package:flutter/material.dart';
import 'package:question_app/functions/go_to.dart';
import 'package:question_app/screens/settings_screen.dart';

Drawer homepageDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          child: Text(
            'Speisekarte',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 24),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Heim'),
          onTap: () {
            Navigator.pop(context); // close the drawer
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Einstellungen'),
          onTap: () {
            Navigator.pop(context);
            goTo(context: context, page: const SettingsScreen());
          },
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('Um'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to about page
          },
        ),
      ],
    ),
  );
}
