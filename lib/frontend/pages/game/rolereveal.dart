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
                  child: Text(communicationProvider.currentPlayer!.role.name, style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w800),)),
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
      case Role.refugee:
        return 'Du bist ein Flüchtling. Deine Aufgabe ist es, sicher zu entkommen.';
      case Role.spy:
        return 'Du bist ein Spitzel. Deine Aufgabe ist es, Informationen zu sammeln.';
      case Role.smuggler:
        return 'Du bist ein Schmuggler. Deine Aufgabe ist es, Gegenstände zu transportieren.';
      case Role.coordinator:
        return 'Du bist ein Koordinator. Deine Aufgabe ist es, das Team zu leiten.';
      case Role.counterfeiter:
        return 'Du bist ein Fälscher. Deine Aufgabe ist es, Dokumente zu fälschen.';
      case Role.escapeHelper:
        return 'Du bist ein Fluchthelfer. Deine Aufgabe ist es, anderen zu helfen zu entkommen.';
    }
  }
}
