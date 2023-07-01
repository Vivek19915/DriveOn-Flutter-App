import 'dart:io';

import 'package:driveon_flutter_app/widgets/bg_widget.dart';
import 'package:driveon_flutter_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_colors.dart';
import '../widgets/TextFieldWidget_profilesetting.dart';
import '../widgets/green_button.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController homeController = TextEditingController();
  TextEditingController businessController = TextEditingController();
  TextEditingController shopController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return bgWidgetprofileScreen(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: Get.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                150.heightBox,
                textWidget(title: "Profile Setting",fontSize: 24,color: Colors.white,fontWeight: FontWeight.bold).box.makeCentered(),
                20.heightBox,

                //profile picture section
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffD6D6D6)),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ).box.width(120).height(120).margin(EdgeInsets.only(bottom: 20)).makeCentered(),

                20.heightBox,

                //entering fields
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  child: Column(
                    children: [
                      TextFieldWidget('Name', Icons.person_outlined, nameController),
                      10.heightBox,
                      TextFieldWidget('Home Address', Icons.home_outlined, homeController),
                      10.heightBox,
                      TextFieldWidget('Business Address', Icons.card_travel, businessController),
                      10.heightBox,
                      TextFieldWidget('Shopping Center', Icons.shopping_cart_outlined, shopController),
                      30.heightBox,
                      greenButton('Submit', (){}),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
