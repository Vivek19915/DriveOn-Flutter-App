import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveon_flutter_app/controller/auth_controller.dart';
import 'package:driveon_flutter_app/screens/home.dart';
import 'package:driveon_flutter_app/widgets/bg_widget.dart';
import 'package:driveon_flutter_app/widgets/text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_colors.dart';
import '../widgets/TextFieldWidget_profilesetting.dart';
import '../widgets/green_button.dart';
import 'package:path/path.dart' as Path;

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreen();
}

class _MyProfileScreen extends State<MyProfileScreen> {

  AuthController authController = Get.find<AuthController>();

  TextEditingController nameController = TextEditingController();
  TextEditingController homeController = TextEditingController();
  TextEditingController businessController = TextEditingController();
  TextEditingController shopController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File ? selectedImage;

  //making global key for form widget
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //to store latitude and longitude
  late LatLng homeAddress;
  late LatLng businessAddress;
  late LatLng shoppingAddress;


  //function to get image
  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //imp --> since you first need to fecth the imp
    nameController.text = authController.myUserModel.value.name??"";
    homeController.text = authController.myUserModel.value.hAddress??"";
    shopController.text = authController.myUserModel.value.mallAddress??"";
    businessController.text = authController.myUserModel.value.bAddress??"";

    homeAddress = authController.myUserModel.value.homeAddressLatLang!;
    businessAddress = authController.myUserModel.value.bussinessAddresLatLang!;
    shoppingAddress = authController.myUserModel.value.shoppingAddressLatLang!;

  }


  @override
  Widget build(BuildContext context) {
    return bgWidgetprofileScreen(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            // height: Get.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                130.heightBox,
                textWidget(title: "My Profile ",fontSize: 24,color: Colors.white,fontWeight: FontWeight.bold).box.makeCentered(),
                20.heightBox,

                //profile picture section circular widget
                InkWell(
                    onTap: (){
                      getImage(ImageSource.gallery);
                    },
                    //conditonal statements for selectedImage

                    // if(authController.myUserModel.value.image == null) {show icon}
                    // else show image taken from firebase

                    child: selectedImage==null ?
                           authController.myUserModel.value.image == null ?
                           Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white,)
                        .box.width(120).height(120).margin(EdgeInsets.only(bottom: 20)).roundedFull.color(Color(0xffD6D6D6)).makeCentered()

                    //else  show image taken from firebase
                        : Image(image: NetworkImage(authController.myUserModel.value.image!),fit: BoxFit.cover,)
                        .box.width(120).height(120).margin(EdgeInsets.only(bottom: 20)).roundedFull.color(Color(0xffD6D6D6)).clip(Clip.antiAlias).makeCentered()


                    : Image(image: FileImage(selectedImage!),fit: BoxFit.cover,)
                        .box.width(120).height(120).margin(EdgeInsets.only(bottom: 20)).roundedFull.color(Color(0xffD6D6D6)).clip(Clip.antiAlias).makeCentered()

                ),


                20.heightBox,

                //entering fields
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFieldWidget(
                          title: 'Name', iconData:  Icons.person_outlined,controller:  nameController,validator: (String? input){

                          if(input!.isEmpty){
                            return 'Name is required!';
                          }

                          if(input.length<5){
                            return 'Please enter a valid name!';
                          }

                          return null;

                        },readOnly: false,OnTap: ()=>{}),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFieldWidget(
                            title: 'Home Address',iconData:  Icons.home_outlined,controller:  homeController,validator: (String? input){

                          if(input!.isEmpty){
                            return 'Home Address is required!';
                          }

                          return null;

                        },OnTap: ()async{
                          Prediction? p = await  authController.showGoogleAutoComplete(context);

                          /// now let's translate this selected address and convert it to latlng obj

                          homeAddress = await authController.buildLongitudeAndLatitudeFromAddress(p!.description!);
                          homeController.text = p.description!;
                          ///store this information into firebase together once update is clicked



                        },readOnly: true),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFieldWidget(title: 'Business Address', iconData: Icons.card_travel,
                            controller: businessController,validator: (String? input){
                              if(input!.isEmpty){
                                return 'Business Address is required!';
                              }

                              return null;
                            },OnTap: ()async{
                              Prediction? p = await  authController.showGoogleAutoComplete(context);

                              /// now let's translate this selected address and convert it to latlng obj

                              businessAddress = await authController.buildLongitudeAndLatitudeFromAddress(p!.description!);
                              businessController.text = p.description!;
                              ///store this information into firebase together once update is clicked

                            },readOnly: true),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFieldWidget(title: 'Shopping Center',
                            iconData: Icons.shopping_cart_outlined, controller: shopController,validator: (String? input){
                              if(input!.isEmpty){
                                return 'Shopping Center is required!';
                              }

                              return null;
                            },OnTap: ()async{
                              Prediction? p = await  authController.showGoogleAutoComplete(context);

                              /// now let's translate this selected address and convert it to latlng obj

                              shoppingAddress = await authController.buildLongitudeAndLatitudeFromAddress(p!.description!);
                              shopController.text = p.description!;
                              ///store this information into firebase together once update is clicked

                            },readOnly: true),
                        const SizedBox(
                          height: 30,
                        ),


                        //instead of isLoading we are using variable the we define in authcontroller ---> doing this to seperate frontend and backend\
                        //and putting it in obx since it is statful widget
                        if(authController.isProfileuploading == true) CircularProgressIndicator(color: greenColor,).box.makeCentered()
                        else  greenButton('Update Info', (){


                          if(selectedImage==null){
                            //do Nothing here
                          }
                          setState(() {
                            authController.isProfileuploading = true;
                          });
                          authController.updateUserInfo(selectedImage!, nameController.text, homeController.text, businessController.text, shopController.text);
                        }
                        ),
                        20.heightBox
                      ],
                    ),
                  ),
                )
              ],
            ),
          ).box.make().scrollVertical(),
        ),
      ),
    );
  }

}
