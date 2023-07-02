import 'package:driveon_flutter_app/constants/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildNotificationIcon() {
  return Align(
    alignment: Alignment.bottomLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 30, left: 8),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.notifications,
          color: greenColor,
        ),
      ),
    ),
  );
}