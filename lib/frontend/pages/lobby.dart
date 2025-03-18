import 'package:escapeberlin/frontend/pages/gamewrapper.dart';
import 'package:escapeberlin/frontend/widgets/lobby/playercounter.dart';
import 'package:escapeberlin/frontend/widgets/lobby/playerlist.dart';
import 'package:escapeberlin/frontend/widgets/lobby/primarybutton.dart';
import 'package:escapeberlin/frontend/widgets/lobby/sessionidtextfield.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => LobbyPageState();
}

class LobbyPageState extends State<LobbyPage> {
  String sessionId = "";
  int playerCount = 1;
  List<String> players = [];
  String? username;

  @override
  void initState() {
    super.initState();
    listenToPlayerCount();
    listenToPlayerUpdates();
  }

  void listenToPlayerCount() {
    communicationProvider.playerCountStream.listen((count) {
      print('Received new player count: $count');
      setState(() {
        playerCount = count;
      });
      if (count >= 6) { //TODO: RESET TO 6
        startGame();
      }
    });
  }

  void listenToPlayerUpdates() {
    communicationProvider.playerListStream.listen((newPlayers) {
      setState(() {
        // Prüfe auf neue Spieler
        List<String> newPlayersList = List<String>.from(newPlayers);
        List<String> joinedPlayers = newPlayersList
            .where((player) => !players.contains(player))
            .toList();
            
        players = newPlayersList;
        
        // Zeige Benachrichtigung für neue Spieler
        if (joinedPlayers.isNotEmpty) {
          _showPlayerJoinedNotification(joinedPlayers[0]);
        }
      });
    });
  }

    void _showPlayerJoinedNotification(String playerName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$playerName ist dem Versteck beigetreten'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }



  void startGame() {
    if (!Navigator.of(context).canPop()) {
      Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
          const GameWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
        },
      ),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: backgroundColor,
    body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                    visible: username != null,
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: playerCounter(playerCount, 6))),
                Spacer(),
                Text(
                  "Checkpoint Reiki",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                if (username == null) ...[
                  Text("Einigt euch auf einen Geheimcode:"),
                  SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  PlayerList(players: players),
                  SizedBox(height: 20),
                  primaryButton("Versteck verlassen", () {
                    leaveHideout();
                  }),
                ],
                Spacer(
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
        // CrossPlay IconButton in der Ecke
        Positioned(
          top: 15,
          right: 15,
          child: Container(
            decoration: BoxDecoration(
              color: foregroundColor.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.devices, color: backgroundColor),
              tooltip: 'CrossPlay',
              onPressed: () {
                showCrossPlayDialog();
              },
            ),
          ),
        ),
      ],
    ),
  );
}

void showCrossPlayDialog() async {
  bool crossPlayEnabled = false;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => Dialog(
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
                "CROSSPLAY",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),
              Text(
                "Ermöglicht das Spielen mit Freunden in AmongReiki.",
                style: TextStyle(color: foregroundColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              SwitchListTile(
                title: Text("Aktivieren", style: TextStyle(color: foregroundColor)),
                value: crossPlayEnabled,
                activeColor: foregroundColor,
                onChanged: (value) {
                  setDialogState(() {
                    crossPlayEnabled = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "ABBRECHEN",
                      style: TextStyle(color: foregroundColor),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: foregroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Hier CrossPlay-Logik implementieren
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            crossPlayEnabled 
                                ? 'CrossPlay wurde aktiviert' 
                                : 'CrossPlay wurde deaktiviert',
                            style: TextStyle(color: backgroundColor),
                          ),
                          backgroundColor: foregroundColor,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
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
    ),
  );

  if (crossPlayEnabled) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: foregroundColor, width: 2),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Center(
        child: Image.asset(
          'assets/images/maki.png',
          fit: BoxFit.contain,
        ),
        ),
      ),
      ),
    );
  }
}

  void join(String sessionId) async {
  if (await communicationProvider.isHideoutFull(sessionId)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Versteck ist voll (max. 6 Spieler)',
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
                  await communicationProvider.joinOrCreateHideout(
                      sessionId, username.trim());
                  await communicationProvider.assignRoles(sessionId);
                  communicationProvider.listenToPlayerCount(sessionId);
                  setState(() {
                    this.username = username.trim();
                    players.add(username.trim()); // Füge den eigenen Namen zur Spieler-Liste hinzu
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
              // Prüfe, ob der Benutzername bereits existiert
              final isAvailable = await communicationProvider.isUsernameAvailable(
                sessionId, username);
              
              if (!isAvailable) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Dieser Codename wird bereits verwendet. Bitte wähle einen anderen.',
                      style: TextStyle(color: backgroundColor),
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              
              chatProvider.setUsername(username);
              await communicationProvider.joinOrCreateHideout(
                  sessionId, username);
              await communicationProvider.assignRoles(sessionId);
              communicationProvider.listenToPlayerCount(sessionId);
              setState(() {
                this.username = username;
                players.add(username);
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
