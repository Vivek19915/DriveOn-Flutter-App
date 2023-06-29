import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

Widget textWidget({required String title,double fontSize = 12, FontWeight fontWeight = FontWeight.normal,Color color = Colors.black}){
  return Text(title, style: GoogleFonts.poppins(fontSize: fontSize,fontWeight: fontWeight,color: color),);
}
