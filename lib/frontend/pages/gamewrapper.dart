import 'dart:async';

import 'package:escapeberlin/backend/types/gamepage.dart';
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
  List<GamePage> pages = [
    
  ];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pages = [IntroductionPage(onFinished: _nextPage),
    RoleRevealPage(onFinished: _nextPage)];
  }

  void _nextPage() {
    setState(() {
      pageIndex = (pageIndex + 1) % pages.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: pages[pageIndex],
    );
  }
}
