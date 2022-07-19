import 'package:flutter/material.dart';
import 'package:privnotes/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Share',
    content: "Empty Note Cannot be shared",
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}
