import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:path/path.dart' as Path;

import '../constants/app_apikeys.dart';
import '../screens/home.dart';
import '../screens/profile_settings.dart';

class AuthController extends GetxController{

  String userUid = '';    //for storing user uid
  var verId = '';      //for storing the verification code sent
  int? resendTokenId;    //optional integer for storing the token used to resend the verification code if it's not received within a specific time.
  bool phoneAuthCheck = false;  //to check phone auth done or not
  dynamic credentials;       // store the phone authentication credentials.

  var isProfileuploading = false;

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

    await FirebaseAuth.instance.signInWithCredential(credential)
    .then((value) {
      //when verficitaion done now routes will decide where to go on
      decideRoute();
    });
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




  //this method uploads an image file to Firebase Storage and retrieves the download URL of the uploaded image.
  uploadImage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);
    var reference = FirebaseStorage.instance
        .ref()
        .child('users/$fileName'); // Modify this path/string as your need
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then(
          (value) {
        imageUrl = value;
        print("Download URL: $value");
      },
    );
    return imageUrl;
  }


  storeUserInfo(File ? selectedImage,String name,String home,String business,String shop)async{

    String url = await uploadImage(selectedImage!);    //here we get the imagurl fro above function
    String uid = FirebaseAuth.instance.currentUser!.uid;    //gives the uid of currentuser
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      //mapping --->
      'image': url,
      'name': name,
      'home_address': home,
      'business_address': business,
      'shopping_address': shop,
    }).then((value) {
      isProfileuploading = false;
      Get.to(()=>HomeScreen());
    });
  }



  Future<Prediction?> showGoogleAutoComplete(BuildContext context) async {
    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "in",
      language: "en",
      context: context,
      mode: Mode.overlay,
      apiKey: ApiConstants.APIKEY,
      components: [new Component(Component.country, "in")],
      types: [],
      hint: "Search City",
    );
    return p;
  }

}