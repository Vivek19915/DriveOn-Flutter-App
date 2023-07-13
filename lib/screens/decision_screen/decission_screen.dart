import 'package:driveon_flutter_app/screens/driver/profile_setup.dart';
import 'package:driveon_flutter_app/screens/login_screen.dart';
import 'package:driveon_flutter_app/widgets/bg_widget.dart';
import 'package:driveon_flutter_app/widgets/my_decision_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../controller/auth_controller.dart';

class DecisionScreen extends StatelessWidget {
    DecisionScreen({Key? key}) : super(key: key);


    AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          child: Column(

            children: [


              130.heightBox,
              Image.asset('assets/logo-app.png',height: 180,).box.makeCentered(),
              120.heightBox,

              DecisionButton(
                icon: 'assets/driver.png',
                text: 'Login As Driver',
                  onPressed: (){
                    authController.isLoginAsDriver = true;
                    Get.to(()=>LoginScreen());
                  },
                  width: Get.width*0.8
              ),
              40.heightBox,
              DecisionButton(
                  icon: 'assets/customer.png',
                  text: 'Login As User',
                     onPressed:  () {
                       authController.isLoginAsDriver = false;
                       Get.to(()=>LoginScreen());
                     },
                 width: Get.width*0.8
              ),
            ],
          ),
        ),
      ),
    );
  }
}
