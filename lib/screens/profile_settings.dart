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
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_colors.dart';
import '../widgets/TextFieldWidget_profilesetting.dart';
import '../widgets/green_button.dart';
import 'package:path/path.dart' as Path;

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {

  AuthController authController = Get.find<AuthController>();

  TextEditingController nameController = TextEditingController();
  TextEditingController homeController = TextEditingController();
  TextEditingController businessController = TextEditingController();
  TextEditingController shopController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File ? selectedImage;

  //making global key for form widget
  GlobalKey<FormState> formKey = GlobalKey<FormState>();


  //function to get image
  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
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
                textWidget(title: "Profile Setting",fontSize: 24,color: Colors.white,fontWeight: FontWeight.bold).box.makeCentered(),
                20.heightBox,

                //profile picture section circular widget
                InkWell(
                  onTap: (){
                    getImage(ImageSource.gallery);
                  },
                    //conditonal statements for selectedImage
                  child: selectedImage == null ? Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white,)
                        .box.width(120).height(120).margin(EdgeInsets.only(bottom: 20)).roundedFull.color(Color(0xffD6D6D6)).makeCentered()

                       //else  image go selected then show it
                      : Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover
                      )
                    ),
                  ).box.width(120).height(120).margin(EdgeInsets.only(bottom: 20)).roundedFull.color(Color(0xffD6D6D6)).clip(Clip.antiAlias).makeCentered()
                ),


                20.heightBox,

                //entering fields
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFieldWidget('Name', Icons.person_outlined, nameController,(String? input){
                          if(input!.isEmpty){
                            return 'Name is required!';
                          }
                          if(input.length<5)return 'Enter a valid name';
                          return null;
                        }),
                        10.heightBox,
                        TextFieldWidget('Home Address', Icons.home_outlined, homeController,(String? input){
                          if(input!.isEmpty){
                            return 'Home Address is required!';
                          }
                          return null;
                        }),
                        10.heightBox,
                        TextFieldWidget('Business Address', Icons.card_travel, businessController,(String? input){
                          if(input!.isEmpty){
                            return 'Business Address is required!';
                          }
                          return null;
                        }),
                        10.heightBox,
                        TextFieldWidget('Shopping Center', Icons.shopping_cart_outlined, shopController,(String? input){
                          if(input!.isEmpty){
                            return 'Shopping Center is required!';
                          }
                          return null;
                        }),
                        20.heightBox,

                        //instead of isLoading we are using variable the we define in authcontroller ---> doing this to seperate frontend and backend\
                        //and putting it in obx since it is statful widget
                        if(authController.isProfileuploading == true) CircularProgressIndicator(color: greenColor,).box.makeCentered()
                         else  greenButton('Submit', (){

                           if(formKey.currentState!.validate() == false){return;}

                           if(selectedImage==null){
                             //🔥🔥Validation for profile image
                             //if user foregot to select image
                             Get.snackbar('Warning', 'Please select the profile image',backgroundColor: Colors.red);
                                 return;
                             }
                           setState(() {
                             authController.isProfileuploading = true;
                           });
                           authController.storeUserInfo(selectedImage!, nameController.text, homeController.text, businessController.text, shopController.text);
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
