import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_constants.dart';
import 'text_widget.dart';


Widget loginWidget(CountryCode countryCode,onCountryChange) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      textWidget(title: helloNiceToMeetYou).box.make(),
      textWidget(title: getMovingWithDriveon,fontSize: 24,fontWeight: FontWeight.bold),
      40.heightBox,

      //creating phone number enterning widget
      Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              spreadRadius: 4
            )]
        ),

        //inside portion of phone number in Container 🔥
        child:  Row(
          children: [
            //country code picker--->>
            InkWell(
              onTap: onCountryChange,
              child: Container(
                child: Row(
                  children: [
                    5.widthBox,
                    Expanded(
                      child: Container(
                        child: countryCode.flagImage(),
                      ),
                    ),
                    textWidget(title: countryCode.dialCode),
                    Icon(Icons.keyboard_arrow_down_rounded)
                  ],
                ),
              ),
            ).flexible(flex: 1),
            //striaght line sperating both
            Container().box.width(1).height(55).color(Colors.black.withOpacity(0.2)).roundedSM.make(),
            //ENter your phone no section
            TextField(decoration: InputDecoration(
              hintStyle: GoogleFonts.poppins(fontSize: 13,fontWeight: FontWeight.normal),
              hintText: enterMobileNumber,
              border: InputBorder.none,
            )).box.padding(EdgeInsets.symmetric(horizontal: 15)).make().flexible(flex: 3),
          ],
        ),
      ),

      40.heightBox,

      //combnations of text -->RICh text
      RichText(
        textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Colors.black,fontSize: 12),
            children: [
              TextSpan(text: byCreating),
              TextSpan(text: termsOfService,style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              TextSpan(text: "and "),
              TextSpan(text: privacyPolicy,style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ]
          )
      ).box.padding(EdgeInsets.symmetric(horizontal: 10 )).makeCentered(),


    ],
  ).box.padding(EdgeInsets.all(36)).make();

}
