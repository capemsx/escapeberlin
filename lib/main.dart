import 'package:escapeberlin/frontend/pages/lobby.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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
          headlineLarge: TextStyle(fontSize: 70, fontWeight: FontWeight.w300, color: foregroundColor),
          headlineMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w300, color: foregroundColor),
          headlineSmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w300, color: foregroundColor),
          bodyLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: foregroundColor),  
          bodyMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: foregroundColor),
          bodySmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: foregroundColor),

        )),
      
      ),
      home: const LobbyPage(),
    );
  }
}