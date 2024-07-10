import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment/firebase_options.dart';
import 'package:flutter_assignment/home_page.dart';
import 'package:flutter_assignment/main_pages/login_page/phone_number.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _handleAuthState(),
    );
  }

  Widget _handleAuthState() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If the user is logged in, show the ViewVideos page
      return const HomePage();
    } else {
      // If the user is not logged in, show the PhoneNumberScreen page
      return const PhoneNumberScreen();
    }
  }
}