import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

Widget textWidget({required String title,double fontSize = 12, FontWeight fontWeight = FontWeight.normal,Color color = Colors.black}){
  return Text(title, style: TextStyle(fontSize: fontSize,fontWeight: fontWeight,color: color),);
  // return title.text.size(fontSize).fontWeight(fontWeight).color(color).make();
}
