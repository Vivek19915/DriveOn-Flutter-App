import 'package:driveon_flutter_app/constants/app_colors.dart';
import 'package:driveon_flutter_app/screens/login_screen.dart';
import 'package:driveon_flutter_app/widgets/bg_widget.dart';
import 'package:driveon_flutter_app/widgets/otp_verification_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:velocity_x/velocity_x.dart';


class OtpVerfication extends StatefulWidget {
  const OtpVerfication({super.key});

  @override
  State<OtpVerfication> createState() => _OtpVerficationState();
}

class _OtpVerficationState extends State<OtpVerfication> {
  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: SafeArea(
        child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.heightBox,
                //containor ke ander conatinor since we used 2 box
                InkWell(
                    onTap: (){Get.to(()=>LoginScreen());},
                    child: Icon(Icons.arrow_back,color: greenColor,).box.size(50, 50).white.roundedFull.make().box.padding(EdgeInsets.symmetric(horizontal: 30)).make()),
                55.heightBox,
                Image.asset('assets/logo-app.png',height: 180,).box.makeCentered(),
                60.heightBox,
                otpVerificationWidget(),

              ],
            ).scrollVertical().box.width(Get.width).height(Get.height).make()
        ),
      )
    );
  }
}
