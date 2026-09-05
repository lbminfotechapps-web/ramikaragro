import 'package:flutter/material.dart';

Widget logo() {
  return Container(
    height: 140,
    width: 140,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 3,
        ),
      ],
      image: const DecorationImage(
        image: AssetImage('assets/icons/logo.jpg'),
        fit: BoxFit.cover,
      ),
    ),
  );
}
