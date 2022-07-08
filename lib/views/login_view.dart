import 'package:flutter/material.dart';
import 'package:privnotes/constants/routes.dart';
import 'package:privnotes/services/auth/auth_service.dart';

import '../services/auth/auth_exception.dart';
import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log-in Page'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Email",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: "Password",
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase().login(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUser;
                //print(user);
                if (user?.isEmailVerified ?? false) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                } else {
                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //     verifyEmailRoute, (route) => false);
                  await showEmailVerifyDialog(context);
                }
              } on UserNotFoundAuthException catch (_) {
                await showErrorDialog(
                  context,
                  "User Not Found",
                );
              } on WrongPasswordAuthException catch (_) {
                await showErrorDialog(
                  context,
                  "Wrong Password",
                );
              } on GenericAuthException catch (_) {
                await showErrorDialog(
                  context,
                  "Authentication Error",
                );
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text("Create New Account"),
          )
        ],
      ),
    );
  }
}

Future<bool> showEmailVerifyDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Verify Email"),
        content: const Text("Please verify your email first"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
            },
            child: const Text("Go to verify"),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
