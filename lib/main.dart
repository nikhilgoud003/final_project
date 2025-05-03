import 'package:flutter/material.dart';
import 'home.dart';
import 'register.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    initialRoute: 'login',
    debugShowCheckedModeBanner: false,
    routes: {
      'login': (context) => const MyLogin(),
      'register': (context) => MyRegister(),
      'home': (context) => const MyHome(),
    },
  ));
}
