import 'package:escapeberlin/backend/types/gamepage.dart';
import 'package:flutter/material.dart';
import 'package:escapeberlin/globals.dart';
import 'package:escapeberlin/backend/types/role.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class RoleRevealPage extends StatefulWidget implements GamePage {
  final VoidCallback onFinished;

  const RoleRevealPage({super.key, required this.onFinished});

  @override
  State<RoleRevealPage> createState() => RoleRevealState();

  @override
  bool isFinished() {
    return RoleRevealState().isFinished();
  }
}

class RoleRevealState extends State<RoleRevealPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFinished = false;

  bool isFinished() {
    return _isFinished;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward().then((_) {
      setState(() {
        _isFinished = true;
      });
      widget.onFinished();
    });

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    ScaleAnimatedText(communicationProvider.currentPlayer!.role.name),
                  ],
                  isRepeatingAnimation: false,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _animation,
              child: Text(
                _getRoleDescription(communicationProvider.currentPlayer!.role),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
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
