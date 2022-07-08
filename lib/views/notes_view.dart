import 'dart:developer' as devtool show log;

import 'package:flutter/material.dart';
import 'package:privnotes/services/auth/auth_service.dart';

import '../constants/routes.dart';
import '../enum/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main UI"),
        actions: [
          PopupMenuButton<MenuItems>(
            onSelected: (value) async {
              switch (value) {
                case MenuItems.setting:
                  devtool.log(value.toString());
                  break;
                case MenuItems.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logout();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
              }
              // devtool.log(value.toString());
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuItems>(
                  value: MenuItems.setting,
                  child: Text("Setting"),
                ),
                PopupMenuItem<MenuItems>(
                  value: MenuItems.logout,
                  child: Text("Logout"),
                ),
              ];
            },
          )
        ],
      ),
      body: const Text("Hello World"),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
