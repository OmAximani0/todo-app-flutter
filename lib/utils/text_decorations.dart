import 'package:flutter/material.dart';

final InputDecoration landingFields = InputDecoration(
  border: OutlineInputBorder(
    borderSide: const  BorderSide(color: Colors.white, width: 1),
    borderRadius: BorderRadius.circular(5),
  ),
  hintStyle: const TextStyle(
    color: Colors.grey
  ),
  filled: true,
  fillColor: Colors.white,
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white, width: 1),
    borderRadius: BorderRadius.circular(5),
  ),
);