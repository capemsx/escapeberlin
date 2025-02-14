import 'package:escapeberlin/frontend/pages/gamewrapper.dart';
import 'package:escapeberlin/frontend/pages/lobby.dart';
import 'package:escapeberlin/globals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAT91oAw3AC5YfdMtx7MNmXkKc7rWA-nfw",
          authDomain: "escapeberlin-80280.firebaseapp.com",
          projectId: "escapeberlin-80280",
          storageBucket: "escapeberlin-80280.firebasestorage.app",
          messagingSenderId: "894391326223",
          appId: "1:894391326223:web:9f63e34c567bac711af57a"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: foregroundColor),
        useMaterial3: true,
        textTheme: GoogleFonts.barlowCondensedTextTheme(TextTheme(
          headlineLarge: TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.w300,
              color: foregroundColor),
          headlineMedium: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w300,
              color: foregroundColor),
          headlineSmall: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w300,
              color: foregroundColor),
          bodyLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: foregroundColor),
          bodyMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: foregroundColor),
          bodySmall: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: foregroundColor),
        )),
      ),
      home: const LobbyPage(),
    );
  }
}
