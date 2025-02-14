import 'package:escapeberlin/frontend/pages/gamewrapper.dart';
import 'package:escapeberlin/frontend/widgets/lobby/playercounter.dart';
import 'package:escapeberlin/frontend/widgets/lobby/primarybutton.dart';
import 'package:escapeberlin/frontend/widgets/lobby/sessionidtextfield.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';
import 'package:escapeberlin/backend/providers/chatprovider.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => LobbyPageState();
}

class LobbyPageState extends State<LobbyPage> {
  String sessionId = "";
  int playerCount = 1;
  String? username;

  @override
  void initState() {
    super.initState();
    listenToPlayerCount();
  }

  void listenToPlayerCount() {
    communicationProvider.playerCountStream.listen((count) {
      print('Received new player count: $count');
      setState(() {
        playerCount = count;
      });
      if (count >= 5) {
        startGame();
      }
    });
  }


  void startGame() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GameWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: username != null,
                child: Align(alignment: Alignment.topLeft, child: playerCounter(playerCount, 5))
              ),
              Spacer(),
              Text(
                "EscapeBerlin",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              Spacer(),
              Text("Einigt euch auf einen Geheimcode:"),
              SizedBox(height: 20),
              if (username == null) ...[
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: sessionIdTextField((value) {
                    sessionId = value.trim();
                  }, () {
                    join(sessionId);
                  }),
                ),
              ] else ...[
                Text(
                  "Geheimcode: $sessionId",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  "Codename: $username",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 20),
                primaryButton("Versteck verlassen", () {
                  leaveHideout();
                }),
              ],
              Spacer(flex: 2,),
            ],
          ),
        ),
      ),
    );
  }

  void join(String sessionId) async {
    if (await communicationProvider.isHideoutFull(sessionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Versteck ist voll (max. 5 Spieler)',
            style: TextStyle(color: backgroundColor),
          ),
          backgroundColor: foregroundColor,
        ),
      );
      return;
    }
    // Restlicher Code zum Beitreten des Verstecks
    final usernameController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: foregroundColor, width: 2),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "CODENAME EINGEBEN",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                autofocus: true,
                style: TextStyle(color: foregroundColor),
                decoration: InputDecoration(
                  hintText: "Codename...",
                  hintStyle: TextStyle(color: foregroundColor.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: foregroundColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: foregroundColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (username) async {
                  if (username.trim().isNotEmpty) {
                  chatProvider.setUsername(username.trim());
                  await communicationProvider.joinOrCreateHideout(sessionId, username.trim());
                  await communicationProvider.assignRoles(sessionId);
                  communicationProvider.listenToPlayerCount(sessionId);
                  setState(() {
                    this.username = username.trim();
                  });
                  Navigator.of(context).pop();
                }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      usernameController.dispose();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "ABBRECHEN",
                      style: TextStyle(color: foregroundColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: foregroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final username = usernameController.text.trim();
                    if (username.isNotEmpty) {
                      chatProvider.setUsername(username);
                      await communicationProvider.joinOrCreateHideout(sessionId, username);
                      await communicationProvider.assignRoles(sessionId);
                      communicationProvider.listenToPlayerCount(sessionId);
                      setState(() {
                        this.username = username;
                      });
                      usernameController.dispose();
                      Navigator.of(context).pop();
                    }
                    },
                    child: Text(
                      "BESTÄTIGEN",
                      style: TextStyle(color: backgroundColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void leaveHideout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: foregroundColor, width: 2),
        ),
        title: Text(
          "Versteck verlassen",
          style: TextStyle(color: foregroundColor),
        ),
        content: Text(
          "Möchtest du das Versteck wirklich verlassen?",
          style: TextStyle(color: foregroundColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "ABBRECHEN",
              style: TextStyle(color: foregroundColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              communicationProvider.leaveHideout(sessionId, username!);
              setState(() {
                username = null;
                sessionId = "";
              });
              Navigator.of(context).pop();
            },
            child: Text(
              "BESTÄTIGEN",
              style: TextStyle(color: backgroundColor),
            ),
          ),
        ],
      ),
    );
  }
}