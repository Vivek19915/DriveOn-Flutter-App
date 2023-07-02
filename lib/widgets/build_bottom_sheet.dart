import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

Widget buildBottomSheet() {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: Get.width * 0.7,
      height: 20,
      decoration: BoxDecoration(
          color: Colors.green,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 4,
                blurRadius: 10)
          ],
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(12), topLeft: Radius.circular(12))),
      child: Center(
        child: Container(
          width: Get.width * 0.6,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
        )
      ),
    ),
  );
}