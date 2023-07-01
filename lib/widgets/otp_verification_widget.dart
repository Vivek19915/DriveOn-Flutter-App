import 'package:driveon_flutter_app/widgets/pinput_widget.dart';
import 'package:driveon_flutter_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_constants.dart';

Widget otpVerificationWidget(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      textWidget(title: phoneVerification).box.make(),
      textWidget(title: enterOtp,fontSize: 24,fontWeight: FontWeight.bold),
      30.heightBox,

      //creating otp enterning widget--->>> pinput widget
      RoundedWithShadow().box.width(Get.width).height(50).make(),

      40.heightBox,

      //combnations of text -->RICH text
      RichText(
          text: TextSpan(
              style: TextStyle(color: Colors.black,fontSize: 12),
              children: [
                TextSpan(text: resendCode +" "),
                TextSpan(text: "20 "+ seconds,style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ]
          )
      ).box.make(),
    ],
  ).box.padding(EdgeInsets.all(36)).make();
}