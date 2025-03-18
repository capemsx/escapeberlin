import 'dart:ui';

import 'package:escapeberlin/backend/providers/chatprovider.dart';
import 'package:escapeberlin/backend/providers/communicationprovider.dart';
import 'package:escapeberlin/backend/providers/documentprovider.dart';
import 'package:escapeberlin/backend/providers/roundprovider.dart';
import 'package:escapeberlin/backend/repository/documentcontentrepository.dart';
import 'package:flutter/foundation.dart';
import 'package:escapeberlin/backend/providers/votingprovider.dart';

Color foregroundColor = Color(0xFF2CF633);
Color backgroundColor = Color(0xFF3C3C3C);

// Globale Anbieter
final chatProvider = ChatProvider();
final communicationProvider = CommunicationProvider();
final documentRepo = DocumentContentRepository();
final documentProvider = DocumentProvider();
final roundProvider = RoundProvider();
final votingProvider = VotingProvider();

ValueNotifier<int> gamePageIndex = ValueNotifier(0);
