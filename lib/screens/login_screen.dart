
import 'package:driveon_flutter_app/constants/app_constants.dart';
import 'package:driveon_flutter_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../widgets/bg_widget.dart';
import 'login_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            150.heightBox,
            Image.asset('assets/logo-app.png',height: 200,).box.makeCentered(),
            80.heightBox,
            loginWidget(),


          ],
        )
      )
    );
  }
}
