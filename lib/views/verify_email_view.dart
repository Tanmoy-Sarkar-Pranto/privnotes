import 'package:flutter/material.dart';
import 'package:privnotes/constants/routes.dart';
import 'package:privnotes/services/auth/auth_service.dart';

class EmailVerifyView extends StatefulWidget {
  const EmailVerifyView({Key? key}) : super(key: key);

  @override
  State<EmailVerifyView> createState() => _EmailVerifyViewState();
}

class _EmailVerifyViewState extends State<EmailVerifyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verify"),
      ),
      body: Column(
        children: [
          const Text("Please Verify Your Email"),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text("Send E-Mail Verification"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text("Go back to login page"),
          ),
        ],
      ),
    );
  }
}
