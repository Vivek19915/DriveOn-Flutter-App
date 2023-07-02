import 'package:driveon_flutter_app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

Widget buildProfileTile(){
  //wrapping with position widget since this widget is called inside stack
  return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Row(
        children: [
          Image.asset('assets/person.png',width: 70,),

          15.widthBox,

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: 'Good Morning, ',
                      style: TextStyle(color: Colors.black, fontSize: 14)),
                  TextSpan(
                      text: "Vivek ",
                      style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
              ),
              Text(
                "Where are you going?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              )
            ],
          )

        ],
      ).box.width(Get.width).make()
  );

}