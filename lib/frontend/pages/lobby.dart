import 'package:escapeberlin/frontend/widgets/lobby/playercounter.dart';
import 'package:escapeberlin/frontend/widgets/lobby/primarybutton.dart';
import 'package:escapeberlin/frontend/widgets/lobby/sessionidtextfield.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => LobbyPageState();
}

class LobbyPageState extends State<LobbyPage> {
  String sessionId = "";

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
                Align(alignment: Alignment.topLeft, child: playerCounter(1, 5)),
                Spacer(),
                Text("EscapeBerlin", style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center,),
                Spacer(),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: sessionIdTextField((value) {
                    sessionId = value.trim();
                  }, () {
                    print("Join:" + sessionId);
                  })),
                Spacer(),
              ],
            ),
          ),
        ));
  }
}
