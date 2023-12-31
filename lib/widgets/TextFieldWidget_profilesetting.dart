

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_colors.dart';

//Those are in {} are the optional parameters--->>>>
TextFieldWidget({String? title, IconData? iconData, TextEditingController? controller,Function? validator,Function? OnTap, bool readOnly  = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title!.text.size(14).fontWeight(FontWeight.w600).color(Colors.black54).make(),
      5.heightBox,
      Container(
        width: Get.width,
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
          readOnly: readOnly,
          onTap: ()=>OnTap!(),
          validator: (input)=> validator!(input),
          controller: controller,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xffA7A7A7)),
          decoration: InputDecoration(
            hintText: "Enter "+title,
            hintStyle: TextStyle(color: Colors.grey,fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(iconData, color: greenColor,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      )
    ],
  );
}