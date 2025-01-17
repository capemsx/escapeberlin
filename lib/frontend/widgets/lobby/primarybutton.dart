import 'package:escapeberlin/globals.dart';
import 'package:flutter/material.dart';

Widget primaryButton(String text, Function onPressed) {
  return ElevatedButton(
    onPressed: () => onPressed(),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text),
    ),
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(foregroundColor),
      padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      )),
    ),
  );
}