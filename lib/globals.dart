import 'dart:ui';

import 'package:escapeberlin/backend/providers/chatprovider.dart';
import 'package:escapeberlin/backend/providers/communicationprovider.dart';


Color foregroundColor = Color.fromARGB(255, 44, 246, 51);
Color backgroundColor = Color.fromARGB(255, 60, 60, 60);

CommunicationProvider communicationProvider = CommunicationProvider();
ChatProvider chatProvider = ChatProvider(communicationProvider);