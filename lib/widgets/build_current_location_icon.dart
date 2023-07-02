import 'package:driveon_flutter_app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

Widget buildCurrentLocationIcon() {
  return Align(
    alignment: Alignment.bottomRight,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 30, right: 8),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.green,
        child: Icon(
          Icons.my_location,
          color: Colors.white,
        ),
      ),
    ),
  );
}