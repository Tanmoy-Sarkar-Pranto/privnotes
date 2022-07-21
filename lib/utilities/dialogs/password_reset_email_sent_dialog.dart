import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Forgot Password',
    content: 'Type your email to reset password',
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}
