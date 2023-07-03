

import 'package:driveon_flutter_app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_apikeys.dart';

Widget buildTextField(){
  //wrapping with position widget since this widget is called inside stack
  return Positioned(
    top: 170,
    left: 30,
    right: 30,
    child: Container(
      width: Get.width,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 1)
          ],
          borderRadius: BorderRadius.circular(8)),


      //note ---> for validation you need text form field
      child: TextFormField(

        // readOnly: true,
        onTap: () async {


          },
        style: TextStyle(
          fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: "Search for a Destination",
          hintStyle: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.bold,fontSize: 16,),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(Icons.search, color: greenColor,
            ),
          ),
          border: InputBorder.none,
        ),
      ).box.padding(EdgeInsets.only(left: 15)).make()
    ),
  );
}