import 'dart:ui';

import 'package:escapeberlin/backend/providers/chatprovider.dart';
import 'package:escapeberlin/backend/providers/communicationprovider.dart';
import 'package:escapeberlin/backend/providers/documentprovider.dart';
import 'package:escapeberlin/backend/providers/roundprovider.dart';
import 'package:flutter/foundation.dart';


Color foregroundColor = Color.fromARGB(255, 44, 246, 51);
Color backgroundColor = Color.fromARGB(255, 60, 60, 60);

CommunicationProvider communicationProvider = CommunicationProvider();
ChatProvider chatProvider = ChatProvider();
final roundProvider = RoundProvider();
final documentProvider = DocumentProvider();

ValueNotifier<int> gamePageIndex = ValueNotifier(0);
