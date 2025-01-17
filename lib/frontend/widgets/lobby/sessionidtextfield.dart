import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

Widget sessionIdTextField(Function(String id) onChange, Function() onJoin) {
  return TextField(
    onChanged: (id) => onChange(id),  
    style: TextStyle(color: backgroundColor, fontSize: 25),
    decoration: InputDecoration(
      suffix: IconButton(
        onPressed: () => onJoin(),
        icon: Icon(Icons.arrow_forward, color: backgroundColor, size: 24,),
        color: backgroundColor,
      ),
      hintText: "Geheimcode",
      filled: true,
      fillColor: foregroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}