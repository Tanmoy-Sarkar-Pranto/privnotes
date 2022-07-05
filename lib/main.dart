import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:privnotes/views/login_view.dart';
import 'package:privnotes/views/register_view.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView()
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // final user = FirebaseAuth.instance.currentUser;
            // final emailVerified = user?.emailVerified ?? false;
            // if (user?.emailVerified ?? false) {
            //   return const Text("Done");
            // } else {
            //   print(user);
            //   return const EmailVerifyView();
            // }
            return const LoginView();
          default:
            return const Text("Loading..");
        }
      },
    );
  }
}
