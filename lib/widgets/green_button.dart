import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_colors.dart';

Widget greenButton(String title, Function onPressed) {
  return MaterialButton(
    onPressed: () => onPressed(),
    child: title.text.size(16).bold.white.makeCentered(),
  ).box.height(50).width(Get.width).roundedSM.color(greenColor).makeCentered();

}