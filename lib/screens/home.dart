import 'package:driveon_flutter_app/screens/my_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_webservice/places.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_apikeys.dart';
import '../constants/app_colors.dart';
import '../controller/auth_controller.dart';
import '../widgets/build_Notification_icon.dart';
import '../widgets/build_bottom_sheet.dart';
import '../widgets/build_current_location_icon.dart';
import '../widgets/build_text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});



  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String? _mapStyle;
  AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    authController.getUserInfoFromFirebase();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }


  //initial camera position
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  //creating google maps controller
  GoogleMapController? myMapController;
  //for opening drawer functionality
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      drawer: buildDrawer(),
      backgroundColor: Colors.white, //since transparent giving green screen
      body: Stack(
        children: [
          //wraping it with position widget so that we can see black bg behind buildProfileTile() widget
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: GoogleMap(
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                myMapController = controller;
                myMapController!.setMapStyle(_mapStyle);
              },
              initialCameraPosition: _kGooglePlex,
            ),
          ),
          buildProfileTile(),
          buildTextField(),
          if(showSourceField == true )buildTextFieldForSource(),
          buildCurrentLocationIcon(),
          buildNotificationIcon(),
          buildBottomSheet(),
        ],
      ),
    );
  }


  Widget buildProfileTile() {
    //wrapping with position widget since this widget is called inside stack
    return Positioned(
        top: 60,
        left: 20,
        right: 20,
        child: Obx(()=> Row(
            children: [

              //for opening Drawer without using appbar-------->>>>>>>
              InkWell(
                  onTap: (){_scaffoldState.currentState?.openDrawer();},
                  child: Icon(Icons.menu,color: greenColor,)
              ),

              //NetworkImage is used to take image from network ----->>>>
              Image(image: NetworkImage(authController.myUserModel.value.image!),fit: BoxFit.cover,).box.size(80, 80).roundedFull.clip(Clip.antiAlias).make(),

              15.widthBox,

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: 'Good Morning, ',
                          style: TextStyle(color: Colors.black, fontSize: 14)),
                      TextSpan(
                          text: authController.myUserModel.value.name,
                          style: TextStyle(color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ).flexible().box.width(180).make(),
                  "Where are you going?".text.size(16).bold.black.make(),
                ],
              )

            ],
          ).box.width(Get.width).make(),
        )
    );
  }

  Future<String> showGoogleAutoComplete() async {
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

    return p!.description!;
  }

  TextEditingController destinationController = TextEditingController();
  TextEditingController sourceController = TextEditingController();

  bool showSourceField = false;



  //Widget to enter destination ---->>>>>
  Widget buildTextField() {
    //wrapping with position widget since this widget is called inside stack
    return Positioned(
      top: 170,
      left: 30,
      right: 30,
      child: Container(
          width: Get.width,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 1)
              ],
              borderRadius: BorderRadius.circular(8)),


          //note ---> for validation you need text form field
          child: TextFormField(
            controller: destinationController,
            readOnly: true,
            onTap: () async {

              String selectedPlace  = await showGoogleAutoComplete();
              destinationController.text = selectedPlace;

              setState(() {
                showSourceField = true;
              });

            },
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "Search for a Destination",
              hintStyle: TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.search, color: greenColor,
                ),
              ),
              border: InputBorder.none,
            ),
          ).box.padding(EdgeInsets.only(left: 15)).make()
      ),
    );
  }


  //Widget to enter source place ---->>>>>
  Widget buildTextFieldForSource() {
    //wrapping with position widget since this widget is called inside stack
    return Positioned(
      top: 230,
      left: 30,
      right: 30,
      child: Container(
          width: Get.width,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 1)
              ],
              borderRadius: BorderRadius.circular(8)),


          //note ---> for validation you need text form field
          child: TextFormField(
            controller: sourceController,
            readOnly: true,
            onTap: () async {

              //bottomsheet when you click on your location
              Get.bottomSheet(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      10.heightBox,
                      "Select Your Location".text.color(Colors.black).size(20).bold.make(),
                      20.heightBox,
                      "Home Address".text.color(Colors.black).size(16).bold.make(),
                      10.heightBox,


                      InkWell(
                        child: Row(
                          children: [
                            "hello".text.color(Colors.black).size(12).fontWeight(FontWeight.w600).make(),
                          ],
                        ).box.width(Get.width).height(50).padding(EdgeInsets.symmetric(horizontal: 10)).color(Colors.white).withDecoration(BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  spreadRadius: 4,
                                  blurRadius: 10)
                            ])).make(),
                      ),
                      20.heightBox,
                      "Business Address".text.color(Colors.black).size(16).bold.make(),
                      10.heightBox,


                      InkWell(
                        child: Row(
                          children: [
                            "hello1".text.color(Colors.black).size(12).fontWeight(FontWeight.w600).make(),
                          ],
                        ).box.width(Get.width).height(50).padding(EdgeInsets.symmetric(horizontal: 10)).color(Colors.white).withDecoration(BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  spreadRadius: 4,
                                  blurRadius: 10)
                            ])).make(),
                      ),
                      20.heightBox,


                      InkWell(
                        onTap: () async {
                          Get.back();
                         String place = await showGoogleAutoComplete();
                         //assigning that place value to source controller
                          sourceController.text = place;
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            "Search for Address".text.color(Colors.white).size(12).fontWeight(FontWeight.bold).make(),
                          ],
                        ).box.width(Get.width).height(50).padding(EdgeInsets.symmetric(horizontal: 10)).withDecoration(BoxDecoration(
                            color: Colors.lightGreen,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  spreadRadius: 4,
                                  blurRadius: 10)
                            ])).make(),
                      ),
                    ],
                  ).box.color(Colors.white).width(Get.width).height(Get.height*0.5).padding(EdgeInsets.symmetric(horizontal: 20,vertical: 10)).margin(EdgeInsets.symmetric(horizontal: 10)).roundedSM.make()
              );


            },
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "Your Location",
              hintStyle: TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.search, color: greenColor,
                ),
              ),
              border: InputBorder.none,
            ),
          ).box.padding(EdgeInsets.only(left: 15)).make()
      ),
    );
  }


  Widget buildCurrentLocationIcon() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 8),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green,
          child: Icon(
            Icons.my_location,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


  Widget buildNotificationIcon() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 8),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.notifications,
            color: greenColor,
          ),
        ),
      ),
    );
  }


  Widget buildBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: Get.width * 0.7,
        height: 20,
        decoration: BoxDecoration(
            color: Colors.green,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 4,
                  blurRadius: 10)
            ],
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(12), topLeft: Radius.circular(12))),
        child: Center(
            child: Container(
              width: Get.width * 0.6,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            )
        ),
      ),
    );
  }




  buildDrawerItem({required String title, required Function onPressed, Color color = Colors.black, double fontSize = 20, FontWeight fontWeight = FontWeight.w700, double height = 45, bool isVisible = false}) {
    return SizedBox(
      height: height,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        dense: true,
        onTap: () => onPressed(),
        title: Row(
          children: [
            title.text.size(fontSize).fontWeight(fontWeight).color(color).make(),
            //circular avator for showing TOTAL RIDE HISTORY
            5.widthBox,
            if(isVisible==true)CircleAvatar(backgroundColor: greenColor,child: "1".text.white.make(),radius: 10,),
          ],
        ))
    );
  }





  buildDrawer() {
    return Obx(
      ()=> Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              height: 150,
              //image and name DrawerHeader
              //lets make DrawerHeader inkwell so tha we we click on that user can go to MY PROFILE PAGE
              child: InkWell(
                onTap: (){Get.to(()=>MyProfileScreen());},
                child: DrawerHeader(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      //image
                      Image(image: NetworkImage(authController.myUserModel.value.image!)).box.height(80).roundedFull.clip(Clip.antiAlias).make(),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          "Good Morning".text.size(14).color(Colors.black.withOpacity(0.28)).fontFamily('Poppins').make(),
                          //name
                          authController.myUserModel.value.name!.text.size(20).bold.black.color(greenColor).make().flexible().box.width(140).make()
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            20.heightBox,
            Column(
              children: [


                buildDrawerItem(title: 'Payment History', onPressed: () {}),
                buildDrawerItem(title: 'Ride History', onPressed: () {}, isVisible: true),
                buildDrawerItem(title: 'Invite Friends', onPressed: () {}),
                buildDrawerItem(title: 'Promo Codes', onPressed: () {}),
                buildDrawerItem(title: 'Settings', onPressed: () {}),
                buildDrawerItem(title: 'Support', onPressed: () {}),
                buildDrawerItem(title: 'Log Out', onPressed: () {}),


              ],
            ).box.padding(EdgeInsets.symmetric(horizontal: 30)).make(),



            Spacer(),
            Divider(),


            Column(
              children: [

                buildDrawerItem(title: 'Do more', onPressed: () {}, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.15), height: 20),
                20.heightBox,
                buildDrawerItem(title: 'Get food delivery', onPressed: () {}, fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.15), height: 20),
                buildDrawerItem(title: 'Make money driving', onPressed: () {}, fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.15), height: 20),
                buildDrawerItem(title: 'Rate us on store', onPressed: () {}, fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.15), height: 20,
                ),

              ],
            ).box.padding(EdgeInsets.symmetric(horizontal: 30)).make(),

            20.heightBox,

          ],
        ),

      ),
    );
  }
}
