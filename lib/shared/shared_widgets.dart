import 'package:flutter/material.dart';

var primaryInputDecoration = InputDecoration(
  labelStyle: const TextStyle(
      fontSize: 17, color: Color(0xFF8E8E93), fontFamily: 'Montserrat'),
  filled: true,
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
  fillColor: const Color(0xFF303030),
);

const textStyleLight = TextStyle(color: Colors.white, fontFamily: 'Montserrat');

const smallTextStyle = TextStyle(
  color: Colors.white,
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.w400,
  letterSpacing: 1,
  fontSize: 12,
);
