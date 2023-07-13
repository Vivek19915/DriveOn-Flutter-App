import 'dart:io';

import 'package:driveon_flutter_app/widgets/bg_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:velocity_x/velocity_x.dart';

import '../../constants/app_colors.dart';
import '../../controller/auth_controller.dart';
import '../../widgets/TextFieldWidget_profilesetting.dart';
import '../../widgets/green_button.dart';
import '../../widgets/text_widget.dart';

class DriverProfileSetup extends StatefulWidget {
  const DriverProfileSetup({Key? key}) : super(key: key);

  @override
  State<DriverProfileSetup> createState() => _DriverProfileSetupState();
}

class _DriverProfileSetupState extends State<DriverProfileSetup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController liveLocationController = TextEditingController();

  late LatLng liveLocation;

   GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthController authController = Get.find<AuthController>();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

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
                textWidget(title: "Drivers Profile Setting",fontSize: 24,color: Colors.white,fontWeight: FontWeight.bold).box.makeCentered(),
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
                        TextFieldWidget(
                            title: 'Name',
                            iconData: Icons.person_outlined,
                            controller: nameController,
                            validator: (String? input){
                              if(input!.isEmpty){
                                return 'Name is required!';
                              }
                              if(input.length<5)return 'Enter a valid name';
                              return null;
                            },
                            OnTap: (){}
                        ),
                        10.heightBox,
                        TextFieldWidget(
                            title: 'Email',
                            iconData: Icons.email_rounded,
                            controller: emailController,
                            validator: (String? input){
                              if(input!.isEmpty){
                                return 'Email is required!';
                              }
                              return null;
                            },
                            // readOnly: true,
                            OnTap: () async {
                            },
                          readOnly: false,
                        ),

                        10.heightBox,
                        TextFieldWidget(
                            title: 'Phone Number',
                            iconData: Icons.phone,
                            controller: phoneController,
                            validator: (String? input){
                              if(input!.isEmpty){
                                return 'Phone no is required!';
                              }
                              if(input.length!=10){
                                return 'Enter Valid Phone number';
                              }
                              return null;
                            },
                            // readOnly: true,
                            OnTap: () async {

                            }
                        ),
                        10.heightBox,
                        TextFieldWidget(
                          title: 'Current Location',
                          iconData: Icons.location_on_outlined,
                          controller: liveLocationController,
                          // readOnly: true,
                          OnTap: () async {
                            Prediction? p = await  authController.showGoogleAutoComplete(context);
                            String selectedPlace = p!.description!;
                            liveLocationController.text = selectedPlace;
                            // / now let's translate this selected address and convert it to latlng obj
                            liveLocation = await authController.buildLongitudeAndLatitudeFromAddress(selectedPlace);
                          },
                          readOnly: true,
                        ),
                        20.heightBox,

                      if(authController.isProfileuploading == true) CircularProgressIndicator(color: greenColor,).box.makeCentered()
                      else  greenButton('Submit', (){

                      // if(formKey.currentState!.validate() == false){return;}

                      if(selectedImage==null){
                        //🔥🔥Validation for profile image
                        //if user foregot to select image
                        Get.snackbar('Warning', 'Please select the profile image',backgroundColor: Colors.red);
                        return;
                      }
                      setState(() {
                        authController.isProfileuploading = true;
                      });
                      authController.storeDriverProfile(
                          selectedImage:selectedImage!,
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          liveLocation: liveLocation);
                        }
                      )],
                    ),
                  ),
                )
              ],
            ),
          ).scrollVertical().box.height(Get.height).make(),
        ),
      ),
    );
  }

}
