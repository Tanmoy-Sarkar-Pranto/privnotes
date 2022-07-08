import 'package:flutter/material.dart';
import 'package:privnotes/constants/routes.dart';
import 'package:privnotes/services/auth/auth_service.dart';
import 'package:privnotes/views/login_view.dart';
import 'package:privnotes/views/notes_view.dart';
import 'package:privnotes/views/register_view.dart';
import 'package:privnotes/views/verify_email_view.dart';

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
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const EmailVerifyView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const EmailVerifyView();
              }
            } else {
              return const LoginView();
            }
          // final emailVerified = user?.emailVerified ?? false;
          // if (user?.emailVerified ?? false) {
          //   return const Text("Done");
          // } else {
          //   print(user);
          //   return const EmailVerifyView();
          // }
          //return const LoginView();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
