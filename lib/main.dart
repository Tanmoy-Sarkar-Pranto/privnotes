import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path/path.dart';
import 'package:privnotes/constants/routes.dart';
import 'package:privnotes/services/auth/bloc/auth_bloc.dart';
import 'package:privnotes/services/auth/bloc/auth_event.dart';
import 'package:privnotes/services/auth/bloc/auth_state.dart';
import 'package:privnotes/services/auth/firebase_auth_provider.dart';
// import 'package:privnotes/services/auth/auth_service.dart';
import 'package:privnotes/views/login_view.dart';
import 'package:privnotes/views/notes/create_update_note_view.dart';
import 'package:privnotes/views/notes/notes_view.dart';
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
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          FirebaseAuthProvider(),
        ),
        child: const HomePage(),
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const EmailVerifyView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const EmailVerifyView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;
//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Testing Bloc'),
//         ),
//         body: BlocConsumer<CounterBloc, CounterState>(
//           listener: (context, state) {
//             _controller.clear();
//           },
//           builder: (context, state) {
//             final invalidValue =
//                 (state is CounterStateInvalidNumber) ? state.invalidValue : '';
//             return Column(
//               children: [
//                 Text("Current Value=>${state.value}"),
//                 Visibility(
//                   visible: state is CounterStateInvalidNumber,
//                   child: Text("Invalid Input:$invalidValue"),
//                 ),
//                 TextField(
//                   controller: _controller,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter value here',
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         context.read<CounterBloc>().add(
//                               IncrementEvent(_controller.text),
//                             );
//                       },
//                       child: const Text("Increment(+)"),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         context.read<CounterBloc>().add(
//                               DecrementEvent(_controller.text),
//                             );
//                       },
//                       child: const Text("Decrement(-)"),
//                     )
//                   ],
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// @immutable
// abstract class CounterState {
//   final int value;
//   const CounterState(this.value);
// }
//
// class CounterStateValid extends CounterState {
//   const CounterStateValid(int value) : super(value);
// }
//
// class CounterStateInvalidNumber extends CounterState {
//   final String invalidValue;
//
//   const CounterStateInvalidNumber({
//     required this.invalidValue,
//     required int previousValue,
//   }) : super(previousValue);
// }
//
// @immutable
// abstract class CounterEvent {
//   final String value;
//   const CounterEvent(this.value);
// }
//
// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(String value) : super(value);
// }
//
// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(String value) : super(value);
// }
//
// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//           invalidValue: event.value,
//           previousValue: state.value,
//         ));
//       } else {
//         emit(
//           CounterStateValid(state.value + integer),
//         );
//       }
//     });
//     on<DecrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//           invalidValue: event.value,
//           previousValue: state.value,
//         ));
//       } else {
//         emit(
//           CounterStateValid(state.value - integer),
//         );
//       }
//     });
//   }
// }
