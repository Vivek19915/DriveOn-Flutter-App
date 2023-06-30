
import 'package:driveon_flutter_app/constants/app_constants.dart';
import 'package:driveon_flutter_app/widgets/text_widget.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:velocity_x/velocity_x.dart';

import '../widgets/bg_widget.dart';
import '../widgets/login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //initializatinon country picker
  final countryPicker = const  FlCountryCodePicker();
  CountryCode countryCode = CountryCode(name: 'India', code: "IN", dialCode: "+91");


  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            130.heightBox,
            Image.asset('assets/logo-app.png',height: 180,).box.makeCentered(),
            60.heightBox,
            loginWidget(
                countryCode,
                () async {
                        final code = await countryPicker.showPicker(context: context);
                        if (code != null) {
                          countryCode = code;
                          // print(code.name);
                          // print(code.code);
                          // print(code.dialCode);
                        };
                        setState(() {});
                }
            ),
          ],
        ).scrollVertical().box.width(Get.width).height(Get.height).make()
            //to make it scrool vertical and remove the pixel render error while
            //clicking on phone number ---> give containor height and width always 🔥🔥
      )
    );
  }
}
