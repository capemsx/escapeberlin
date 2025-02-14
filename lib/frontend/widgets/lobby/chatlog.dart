import 'package:flutter/material.dart';
import 'package:escapeberlin/globals.dart';
import 'package:escapeberlin/backend/types/chatmessage.dart';
import 'package:escapeberlin/backend/providers/chatprovider.dart';

class ChatLog extends StatefulWidget {
  const ChatLog({super.key});

  @override
  State<ChatLog> createState() => _ChatLogState();
}

class _ChatLogState extends State<ChatLog> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    chatProvider.onMessage().listen((message) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.8),
        border: Border.all(color: foregroundColor),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${message.username}: ${message.message}',
                    style: TextStyle(color: foregroundColor),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: foregroundColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _textController,
              style: TextStyle(color: foregroundColor),
              decoration: InputDecoration(
                hintText: 'Nachricht eingeben...',
                hintStyle: TextStyle(color: foregroundColor.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  chatProvider.sendMessage(text);
                  _textController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
}