import 'dart:async';
import 'package:escapeberlin/frontend/pages/game/chat.dart';
import 'package:escapeberlin/frontend/pages/game/introduction.dart';
import 'package:escapeberlin/frontend/pages/game/rolereveal.dart';
import 'package:escapeberlin/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameWrapper extends StatefulWidget {
  const GameWrapper({super.key});

  @override
  State<GameWrapper> createState() => GameWrapperState();
}

class GameWrapperState extends State<GameWrapper> {
  List<Widget> pages = [
    IntroductionPage(),
    RoleRevealPage(),
    ChatPage(),
  ];

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: gamePageIndex, builder: (ctx, val, child) {
        return pages[gamePageIndex.value];
      }
    );
  }
}
