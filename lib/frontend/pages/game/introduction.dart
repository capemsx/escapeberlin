import 'package:dot_matrix_text/dot_matrix_text.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class IntroductionPage extends StatefulWidget {

  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => IntroductionPageState();
}

class IntroductionPageState extends State<IntroductionPage>  {
  int pageIndex = 0;
  bool _isFinished = false;
  final List<String> monologue = [
    "Berlin, 1984.\nDie Stadt ist durch die Mauer geteilt.",
    "Eure Mission:\nFindet die geheimen Dokumente und flieht.",
    "Die Kommunikation ist nur über einen verschlüsselten Messenger möglich.",
    "Vorsicht, es gibt einen Spitzel in euren Reihen.",
    "Viel Glück, ihr werdet es brauchen.",
    ""
];

  

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: AnimatedTextKit(
            animatedTexts: [
              for (String line in monologue) TypewriterAnimatedText(
                line,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 34,
                  color: foregroundColor,
                ),
                speed: const Duration(milliseconds: 75),
              ),
            ],
            totalRepeatCount: 1,
            pause: const Duration(milliseconds: 1000),
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
            onFinished: () {
              setState(() {
                gamePageIndex.value++;
              });
            },
          ),
        ),
      ),
    );
  }
}
