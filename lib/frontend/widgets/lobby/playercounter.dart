import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

Widget playerCounter(int current, int max) {
  final color = current >= max ? Colors.red : foregroundColor;
  
  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(10),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.person, color: backgroundColor),
        const SizedBox(width: 10),
        Text(
          "${current.toString()}/${max.toString()}", 
          style: TextStyle(
            color: backgroundColor, 
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(width: 5),
      ],
    ),
  );
}