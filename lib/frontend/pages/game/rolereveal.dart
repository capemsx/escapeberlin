import 'package:flutter/material.dart';
import 'package:escapeberlin/globals.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class RoleRevealPage extends StatefulWidget {
  const RoleRevealPage({super.key});

  @override
  State<RoleRevealPage> createState() => RoleRevealState();

}

class RoleRevealState extends State<RoleRevealPage> {
  bool roleVisible = false;
  bool roleDescriptionVisible = false;

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      roleVisible = true;
    });
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      roleDescriptionVisible = true;
    });
    await Future.delayed(Duration(seconds: 5));
    gamePageIndex.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: roleVisible ? 1 : 0,
                duration: Duration(milliseconds: 1250),
                curve: Curves.easeOut,
                child: AnimatedScale(
                  scale: roleVisible ? 1 : 0,
                  duration: Duration(milliseconds: 2500),
                  curve: Curves.easeOut,
                  child: Text(communicationProvider.currentPlayer!.role.name, style: TextStyle(fontSize: 40, color: communicationProvider.currentPlayer!.role == Role.spy ? Colors.red : Colors.white, fontWeight: FontWeight.w800),)),
              ),
              const SizedBox(height: 10),
              AnimatedOpacity(
                opacity: roleDescriptionVisible ? 1 : 0,
                curve: Curves.easeOut,
                duration: Duration(milliseconds: 1250),
                child: Text(
                  _getRoleDescription(communicationProvider.currentPlayer!.role),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ]
          ),
        )
      )

    );
  }

  String _getRoleDescription(Role role) {
  switch (role) {
    case Role.spy:
      return 'Als Spitzel der Staatssicherheit bist du in die Gruppe eingeschleust worden. Deine Aufgabe ist es, alle Fluchtpläne zu sabotieren und Informationen zu sammeln, ohne aufzufallen. Achte genau darauf, was die anderen planen und versuche, ihr Vertrauen zu gewinnen.';
    case Role.smuggler:
      return 'Als Schmuggler kennst du die geheimen Wege zwischen Ost und West. Deine Kontakte ermöglichen es dir, wichtige Gegenstände über die Grenze zu bringen - von Werkzeugen bis zu Westgeld. Dein Wissen über versteckte Routen ist entscheidend für den Erfolg der Flucht.';
    case Role.coordinator:
      return 'Als Koordinator bist du das Herzstück der Gruppe. Du musst den Überblick behalten, Informationen zusammenführen und die richtigen Entscheidungen treffen. Deine Führung und strategisches Denken werden darüber entscheiden, ob die Flucht gelingt oder scheitert.';
    case Role.counterfeiter:
      return 'Als Fälscher ist deine Kunstfertigkeit unersetzlich. Mit ruhiger Hand und Auge fürs Detail stellst du die gefälschten Ausweise, Visa und Passierscheine her, die für das Überschreiten der Grenze notwendig sind. Ohne deine Dokumente kommt niemand weit.';
    case Role.escapeHelper:
      return 'Als Fluchthelfer riskierst du alles für die Freiheit anderer. Du kennst die Schwachstellen der Grenzanlagen, hast Kontakte bei den Grenztruppen und weißt, wo und wann eine Flucht am erfolgversprechendsten ist. Deine Erfahrung kann Leben retten oder kosten.';
  }
}
}
