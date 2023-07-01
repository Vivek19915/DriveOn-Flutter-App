import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveon_flutter_app/screens/home.dart';
import 'package:driveon_flutter_app/screens/profile_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController{

  String userUid = '';    //for storing user uid
  var verId = '';      //for storing the verification code sent
  int? resendTokenId;    //optional integer for storing the token used to resend the verification code if it's not received within a specific time.
  bool phoneAuthCheck = false;  //to check phone auth done or not
  dynamic credentials;       // store the phone authentication credentials.

  phoneAuth(String phone) async {
    try {
      credentials = null;
      //FirebaseAuth.instance.verifyPhoneNumber ---> his function is responsible for verification using phone number send otp
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),          //how much time it take to send otp

        //once verfication completed this function will sign in user with given credentials
        verificationCompleted: (PhoneAuthCredential credential) async {
          log('Completed');
          credentials = credential;
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        forceResendingToken: resendTokenId,        //if you dont get otp in 60 seconds this will again resend

        //if verification failed this will run
        verificationFailed: (FirebaseAuthException e) {
          log('Failed');
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid.');
          }
        },

        //when otp is send it will check whether otp is correct or not
        codeSent: (String verificationId, int? resendToken) async {
          log('Code sent');
          verId = verificationId;
          resendTokenId = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      log("Error occured $e");
    }
  }

  //for verfication of otp entered
  verifyOtp(String otpNumber) async {
    log("Called");
    PhoneAuthCredential credential =
    PhoneAuthProvider.credential(verificationId: verId, smsCode: otpNumber);

    log("LogedIn");

    await FirebaseAuth.instance.signInWithCredential(credential);
  }


//this function doing two things  ---> decides routes for user
//   1--> checking whether user is login or not   
//   2--> whether user profile is complete or not
  decideRoute(){
    ///step 1- Check user login?
    User? user = FirebaseAuth.instance.currentUser;
    if(user!=null){
      //means user already login
      //step 2 --> check whether user profile exist or not
      FirebaseFirestore.instance.collection('users').doc(user.uid).get()
          .then((value) {
            if(value.exists){
              //means user profile exists ---> then navigate user to home screen
              Get.to(()=>HomeScreen());
            }
            else{
              //means user does not exists then takes it info
              Get.to(()=>ProfileSettingScreen());
            }
      });
    }
  }
}