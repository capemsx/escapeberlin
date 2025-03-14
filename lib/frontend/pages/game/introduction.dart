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
  final List<String> monologue = [
  "Berlin, 1984.\nDie Stadt ist durch die Mauer geteilt. Der Kalte Krieg hält die geteilte Stadt in seinem Griff.",
  "Eure Mission: Plant die Flucht aus der DDR in den Westen und identifiziert den Spitzel unter euch.",
  "In mehreren Runden müsst ihr Treffen organisieren, Dokumente beschaffen, Routen planen und Westkontakte knüpfen.",
  "Ihr erhaltet und teilt wichtige Dokumente über einen verschlüsselten Messenger.",
  "Doch Vorsicht! Ein Stasi-Spitzel hat sich eingeschlichen und versucht, falsche Informationen zu streuen.",
  "Prüft alle Dokumente auf Widersprüche – sie könnten auf den Verräter hinweisen.",
  "Findet den Spitzel, bevor es zu spät ist. ",
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
                speed: const Duration(milliseconds: 65),
              ),
            ],
            totalRepeatCount: 1,
            pause: const Duration(milliseconds: 750),
            displayFullTextOnTap: false,
            stopPauseOnTap: false,
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
