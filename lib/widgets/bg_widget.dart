import 'package:flutter/material.dart';

Widget bgWidget({Widget ? child}){
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.png"),
          fit: BoxFit.fill,
        )
    ),
    child: child,
  );
}