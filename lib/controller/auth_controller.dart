import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveon_flutter_app/screens/driver/profile_setup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:path/path.dart' as Path;

import '../constants/app_apikeys.dart';
import '../models/user_models.dart';
import '../screens/home.dart';
import '../screens/profile_settings.dart';
import 'package:geocoding/geocoding.dart' as geoCoding ;

class AuthController extends GetxController{

  String userUid = '';    //for storing user uid
  var verId = '';      //for storing the verification code sent
  int? resendTokenId;    //optional integer for storing the token used to resend the verification code if it's not received within a specific time.
  bool phoneAuthCheck = false;  //to check phone auth done or not
  dynamic credentials;       // store the phone authentication credentials.

  var isProfileuploading = false;

  bool isLoginAsDriver = false;

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

      if(isLoginAsDriver = true){
        FirebaseFirestore.instance.collection('drivers').doc(user.uid).get()
            .then((value) {
          if(value.exists){
            //means driver profile exists ---> then navigate user to home screen
            print("DriverHomeScreen");
          }
          else{
            //means user does not exists then takes it info
            Get.to(()=>DriverProfileSetup());
          }
        });
      }
      else{
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


  storeUserInfo(File ? selectedImage,String name,String home,String business,String shop,{LatLng? homeLatLng, LatLng? businessLatLng, LatLng? shoppingLatLng,})async{

    String url = await uploadImage(selectedImage!);    //here we get the imagurl fro above function
    String uid = FirebaseAuth.instance.currentUser!.uid;    //gives the uid of currentuser
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      //mapping --->
      'image': url,
      'name': name,
      'home_address': home,
      'business_address': business,
      'shopping_address': shop,
      // storing latlong values on firebase so that we can use it late on choosing source place
      'home_latlng': GeoPoint(homeLatLng!.latitude, homeLatLng.longitude),
      'business_latlng': GeoPoint(businessLatLng!.latitude, businessLatLng.longitude),
      'shopping_latlng': GeoPoint(shoppingLatLng!.latitude, shoppingLatLng.longitude),
    }).then((value) {
      isProfileuploading = false;
      Get.to(()=>HomeScreen());
    });
  }

  updateUserInfo(File? selectedImage, String name, String home, String business, String shop, {String url = '',LatLng? homeLatLng, LatLng? businessLatLng, LatLng? shoppingLatLng,}) async {
    String url_new = url;
    if (selectedImage != null) {
      url_new = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': url_new,
      'name': name,
      'home_address': home,
      'business_address': business,
      'shopping_address': shop,
      'home_latlng': GeoPoint(homeLatLng!.latitude, homeLatLng.longitude),
      'business_latlng': GeoPoint(businessLatLng!.latitude, businessLatLng.longitude),
      'shopping_latlng': GeoPoint(shoppingLatLng!.latitude, shoppingLatLng.longitude),
    },SetOptions(merge: true)).then((value) {
      isProfileuploading = false;
      Get.to(() => HomeScreen());
    });
  }

  var myUserModel = UserModel().obs;          //making it observalble sos that we can reflect changes

  //this function will provide user info so that user can able to update it in MY Profile Section
  getUserInfoFromFirebase(){
    String uid = FirebaseAuth.instance.currentUser!.uid;           //gettig user id from auth section
    FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((event) {
      myUserModel.value = UserModel.fromJson(event.data()!);

    });                    //getting all info of user from firestore using uid of user

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




  Future<LatLng> buildLongitudeAndLatitudeFromAddress(String place) async {
    //This return langitude and latitude
    List<geoCoding.Location> locations = await geoCoding.locationFromAddress(place);
    return LatLng(locations.first.latitude, locations.first.longitude);
  }




///function to determine current position -- live location
  Future<Position> determineLiveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    print("hello");
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("hellojygghh1");
    if (!serviceEnabled) {
      print("hello1");
      return Future.error('Location services are disabled');
    }
    print("helloasdasdasdasdasdadjygghh1");
    permission = await Geolocator.checkPermission();
    print("hello3");
    if (permission == LocationPermission.denied) {
      print("hello2");
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print("hello4");
        return Future.error("Location permission denied");
      }
    }
    print("hello5");
    if (permission == LocationPermission.deniedForever) {
      print("hello6");
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();
    print("hello7");
    return position;
  }



//function to determine  position name using live location
  Future<void> GetLiveLocationAddressFromLatLong(Position position,controller)async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    controller.text = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
  }




  //for card section---->>>>>
  storeUserCard(String number, String expiry, String cvv, String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cards')
        .add({'name': name, 'number': number, 'cvv': cvv, 'expiry': expiry});

    return true;
  }

  RxList userCards = [].obs;

  getUserCards() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cards')
        .snapshots().listen((event) {
      userCards.value = event.docs;
    });
  }



//storing sriver info
  storeDriverProfile(
      {
      File? selectedImage,
      String ?name,
      String ?phone,
      LatLng? liveLocation,
      String ?email,
        String url = '',
      }) async {
    String url_new = url;
    if (selectedImage != null) {
      url_new = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('drivers').doc(uid).set({
      'image': url_new,
      'name': name,
      'email': email,
      'phone_no': phone,
      'live_location': GeoPoint(liveLocation!.latitude, liveLocation.longitude),
    },SetOptions(merge: true)).then((value) {
      isProfileuploading = true;
      print("done");

    });
  }


}