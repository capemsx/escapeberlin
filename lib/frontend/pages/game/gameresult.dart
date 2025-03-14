import 'package:flutter/material.dart';
import 'package:escapeberlin/globals.dart';
import 'package:escapeberlin/backend/types/role.dart';

class GameResultPage extends StatefulWidget {
  const GameResultPage({super.key});

  @override
  State<GameResultPage> createState() => _GameResultPageState();
}

class _GameResultPageState extends State<GameResultPage> with SingleTickerProviderStateMixin {
  bool resultVisible = false;
  bool detailsVisible = false;
  bool isLoadingResult = true;
  bool isPlayerWinner = false;
  bool isSpyEliminated = false;
  
  // Animation für Hintergrundbild-Zoom
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation Controller für Zoom-Effekt
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    
    // Zoom-Animation, die langsam von 1.0 auf 1.15 skaliert
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _checkGameResult();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkGameResult() async {
    try {
      // Prüfen, ob der Spieler ein Spy ist
      final isSpy = communicationProvider.currentPlayer?.role == Role.spy;
      
      // Prüfen, ob der Spy eliminiert wurde
      final wasEliminated = await votingProvider.wasSpyEliminated();
      
      // Gewinnbedingungen aktualisieren
      if (mounted) {
        setState(() {
          isSpyEliminated = wasEliminated;
          isPlayerWinner = isSpy == true ? !wasEliminated : wasEliminated;
          isLoadingResult = false;
        });
        
        // Animation erst starten, wenn Daten geladen sind
        startAnimation();
      }
    } catch (e) {
      print("Fehler beim Laden des Spielergebnisses: $e");
      if (mounted) {
        setState(() {
          isLoadingResult = false;
        });
        startAnimation();
      }
    }
  }

  void startAnimation() async {
    // Hintergrund-Animation starten
    _animationController.forward();
    
    // Ergebnis nach 1 Sekunde einblenden
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        resultVisible = true;
      });
    }
    
    // Details nach 2 weiteren Sekunden einblenden
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        detailsVisible = true;
      });
    }
  }

  void _resetAndLeaveHideout() async {
  // Spielerdaten sichern für den Logout
  final hideoutId = communicationProvider.currentPlayer?.hideoutId;
  final playerName = communicationProvider.currentPlayer?.name;
  
  // Alle Provider und Daten zurücksetzen
  try {
    // 1. Verlasse das Hideout in Firestore

    
    // 2. Timer und Streams stoppen
    roundProvider.dispose();
    
    
    // 4. Chat-Einstellungen zurücksetzen
    chatProvider.setHideout("");

    
    
    print("Alle Spieledaten wurden zurückgesetzt");
  } catch (e) {
    print("Fehler beim Zurücksetzen der Spieledaten: $e");
  }
  
  // Zur Lobby navigieren (erstes Element im Stack)
  Navigator.of(context).popUntil((route) => route.isFirst);
}

  @override
  Widget build(BuildContext context) {
    // Ladebildschirm anzeigen während des Ladens
    if (isLoadingResult) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Ergebnis wird geladen...",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    // Ergebnisseite anzeigen sobald Daten geladen sind
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animierter Hintergrund mit Zoom-Effekt
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.5, // Hintergrundbild leicht transparent
                    child: communicationProvider.currentPlayer?.role != Role.spy
                      ? Image.asset(
                        isPlayerWinner
                          ? 'assets/images/victory_background.jpg' // Passe diesen Pfad an
                          : 'assets/images/defeat_background.png', // Passe diesen Pfad an
                        fit: BoxFit.cover,
                      )
                      : SizedBox.shrink(),
                  ),
              );
            }
          ),
          
          // Dunkler Overlay über dem Bild
          Container(
            color: isPlayerWinner 
                ? Colors.green.shade900.withOpacity(0.75) 
                : Colors.red.shade900.withOpacity(0.75),
          ),
          
          // Inhalt (Ergebnis, Text und Button)
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hauptergebnis mit Animation
                    AnimatedOpacity(
                      opacity: resultVisible ? 1 : 0,
                      duration: Duration(milliseconds: 1750),
                      curve: Curves.easeOut,
                      child: AnimatedScale(
                        scale: resultVisible ? 1 : 0.3,
                        duration: Duration(milliseconds: 2500),
                        curve: Curves.elasticOut,
                        child: Text(
                          isPlayerWinner ? "GEWONNEN" : "ENTLARVT", 
                          style: TextStyle(
                            fontSize: 60, 
                            color: Colors.white, 
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: isPlayerWinner ? Colors.green : Colors.red,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Ergebnisbeschreibung
                    AnimatedOpacity(
                      opacity: detailsVisible ? 1 : 0,
                      curve: Curves.easeOut,
                      duration: Duration(milliseconds: 1250),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          _getResultDescription(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 22,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 50),
                    
                    // Button zum Verlassen
                    if (detailsVisible)
                      AnimatedOpacity(
                        opacity: detailsVisible ? 1 : 0,
                        duration: Duration(milliseconds: 1500),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _resetAndLeaveHideout,
                              borderRadius: BorderRadius.circular(15),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                                child: Text(
                                  "VERSTECK VERLASSEN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getResultDescription() {
  final playerRole = communicationProvider.currentPlayer?.role;
  final isSpy = playerRole == Role.spy;
  
  if (isSpy) {
    return isPlayerWinner
        ? "Du hast es geschafft! Die Fluchtpläne wurden sabotiert und deine wahre Identität blieb bis zum Ende verborgen."
        : "Du wurdest entlarvt! Die Gruppe hat dich als Spitzel identifiziert und konnte ihre Flucht ohne Störung planen und durchsetzen.";
  } else {
    return isPlayerWinner
        ? "Die Gruppe hat den Spitzel rechtzeitig entlarvt! Eure Flucht in den Westen war erfolgreich und ihr konntet euch ein neues, freies Leben ohne Überwachung aufbauen."
        : "Der verräterische Spitzel blieb unentdeckt und verriet eure Pläne. Ihr wurdet bei eurem Fluchtversuch festgenommen und müsst nun jahrelange Haftstrafen in Hohenschönhausen absitzen.";
  }
}
}