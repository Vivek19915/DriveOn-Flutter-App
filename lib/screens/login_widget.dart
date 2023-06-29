import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_constants.dart';
import '../widgets/text_widget.dart';


Widget loginWidget() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      textWidget(title: helloNiceToMeetYou).box.make(),
      textWidget(title: getMovingWithDriveon,fontSize: 24,fontWeight: FontWeight.bold),
      40.heightBox,

    ],
  ).box.padding(EdgeInsets.all(36)).make();

}
