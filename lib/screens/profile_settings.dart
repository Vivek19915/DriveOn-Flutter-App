import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController homeController = TextEditingController();
  TextEditingController businessController = TextEditingController();
  TextEditingController shopController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File ? selectedImage;


  //function to get image
  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
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


  storeUserInfo()async{
    String url = await uploadImage(selectedImage!);    //here we get the imagurl fro above function
    String uid = FirebaseAuth.instance.currentUser!.uid;    //gives the uid of currentuser
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      //mapping --->
      'image': url,
      'name': nameController.text,
      'home_address': homeController.text,
      'business_address': businessController.text,
      'shopping_address': shopController.text,
    }).then((value) {
      nameController.clear();
      homeController.clear();
      businessController.clear();
      shopController.clear();
      setState(() {
        isLoading = false;
      });
      Get.to(()=>HomeScreen());
    });

  }



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
                      if(isLoading == true) CircularProgressIndicator(color: greenColor).box.makeCentered()
                        else greenButton('Submit', (){
                        setState(() {
                          isLoading = true;
                        });
                        storeUserInfo();
                      }),
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
