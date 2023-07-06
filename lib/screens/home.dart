import 'package:driveon_flutter_app/screens/my_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:google_maps_webservice/places.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_apikeys.dart';
import '../constants/app_colors.dart';
import '../controller/auth_controller.dart';
import 'package:geocoding/geocoding.dart' as geoCoding ;
import 'dart:ui' as ui;

import '../controller/polyline_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});



  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String? _mapStyle;
  AuthController authController = Get.find<AuthController>();

  //longitudes and latitudes variables
  late LatLng destination;
  late LatLng source;

  Set<Marker> markers = Set<Marker>();     // all the markers that we are going to show on map is stored in this set

  final Set<Polyline> _setPolyline = {};


  @override
  void initState() {
    super.initState();
    authController.getUserInfoFromFirebase();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    loadCustomMarker();    //its loads the custom marker for source and destination
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
              markers: markers,
              polylines: polyline,
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
              //To show seleted place on text filed controller
              Prediction? p = await authController.showGoogleAutoComplete(context);
              String selectedPlace = p!.description!;
              destinationController.text = selectedPlace;

              // List<geoCoding.Location> locations = await geoCoding.locationFromAddress(selectedPlace);  //it gives us the list of all info about location
              // destination = LatLng(locations.first.latitude, locations.first.longitude);     //stroring longitude and latitude

              //both are same
              destination = await authController.buildLongitudeAndLatitudeFromAddress(selectedPlace);

              //so now lets put RED marker on the selected place which is destination
              markers.add(Marker(
                markerId: MarkerId(selectedPlace),
                infoWindow: InfoWindow(
                  title: 'Destination: $selectedPlace',
                ),
                position: destination,

                //now show custom marker on destination
                icon: BitmapDescriptor.fromBytes(markIconsforDestination)
              ));


              //now lets automatically move our map to the selected location
              // animateCamera updates the location or view of the map on the basis of target
              myMapController!.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: destination, zoom: 14)
                //17 is new zoom level
              ));

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
              buildBottomSouceSheet();
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
                title.text.size(fontSize).fontWeight(fontWeight)
                    .color(color)
                    .make(),
                //circular avator for showing TOTAL RIDE HISTORY
                5.widthBox,
                if(isVisible == true)CircleAvatar(backgroundColor: greenColor,
                  child: "1".text.white.make(),
                  radius: 10,),
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


  //Code to load custom markers on destination and source------>>>>>>>
  late Uint8List markIconsforDestination;
  late Uint8List markIconsforSource;

  loadCustomMarker() async {
    //it loads the mrker from asset folder
    markIconsforDestination = await loadAsset('assets/dest_marker.png', 100);
    markIconsforSource = await loadAsset('assets/source_marker.png', 100);
  }

  Future<Uint8List> loadAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer.asUint8List();
  }



  //function to draw ployline between source and destination
  void drawPolyLine(String placeID){
    _setPolyline.clear();      //so that previous ployline get removed
    _setPolyline.add(Polyline(
        polylineId: PolylineId(placeID),
        visible: true,
        points: [source,destination],
        color: greenColor,
        width: 3
    ),);
  }


  //bottom souce sheet when you click on your location
  void buildBottomSouceSheet() {
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
              onTap: ()async {
                Get.back();
                source = authController.myUserModel.value.homeAddressLatLang!;
                sourceController.text = authController.myUserModel.value.hAddress!;

                if (markers.length >= 2) {
                  markers.remove(markers.last);
                }
                markers.add(Marker(
                    markerId: MarkerId(authController.myUserModel.value.hAddress!),
                    infoWindow: InfoWindow(
                      title: 'Source: ${authController.myUserModel.value.hAddress!}',
                    ),
                    position: source,
                    icon: BitmapDescriptor.fromBytes(markIconsforSource)
                ));

                await getPolylines(source,destination);
                // drawPolyline(place);

                myMapController!.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: source, zoom: 14)));
                setState(() {});

                  },
              child: Row(
                children: [
                  //showing home address
                  authController.myUserModel.value.hAddress!.text.color(Colors.black).size(12).fontWeight(FontWeight.w600).make(),
                ],
              ).box.height(50).padding(EdgeInsets.symmetric(horizontal: 10)).color(Colors.white).withDecoration(BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        spreadRadius: 4,
                        blurRadius: 10)
                  ])).make().scrollHorizontal(),
            ),
            20.heightBox,
            "Business Address".text.color(Colors.black).size(16).bold.make(),
            10.heightBox,


            InkWell(
              onTap: ()async {
                Get.back();
                source = authController.myUserModel.value.bussinessAddresLatLang!;
                sourceController.text = authController.myUserModel.value.bAddress!;

                if (markers.length >= 2) {
                  markers.remove(markers.last);
                }
                markers.add(Marker(
                    markerId: MarkerId(authController.myUserModel.value.bAddress!),
                    infoWindow: InfoWindow(
                      title: 'Source: ${authController.myUserModel.value.bAddress!}',
                    ),
                    position: source,
                    icon: BitmapDescriptor.fromBytes(markIconsforSource)
                ));

                await getPolylines(source,destination);
                // drawPolyline(place);

                myMapController!.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: source, zoom: 14)));
                setState(() {});

              },
              child: Row(
                children: [
                  //showing users business address
                  authController.myUserModel.value.bAddress!.text.color(Colors.black).size(12).fontWeight(FontWeight.w600).make(),
                ],
              ).box.height(50).padding(EdgeInsets.symmetric(horizontal: 10)).color(Colors.white).withDecoration(BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        spreadRadius: 4,
                        blurRadius: 10)
                  ])).make().scrollHorizontal(),
            ),
            20.heightBox,


            InkWell(
              onTap: () async {
                Get.back();
                Prediction? p = await authController.showGoogleAutoComplete(context);
                String place = p!.description!;
                //assigning that place value to source controller
                sourceController.text = place;

                // List<geoCoding.Location> locationssource = await geoCoding.locationFromAddress(place); //it gives us the list of all info about location
                // source = LatLng(locationssource.first.latitude, locationssource.first.longitude); //stroring longitude and latitude

                source = await authController.buildLongitudeAndLatitudeFromAddress(place);

                if (markers.length >= 2) {
                  markers.remove(markers.last);
                }
                //so now lets put RED marker on the selected place which is destination
                markers.add(Marker(
                    markerId: MarkerId(place),
                    infoWindow: InfoWindow(
                      title: 'Source: $place',
                    ),
                    position: source,
                    icon: BitmapDescriptor.fromBytes(markIconsforSource)
                ));

                //as when user put the source after that polyline will be shown
                //therefore we called here
                await getPolylines(source, destination);
                // drawPolyLine(place);


                //now lets automatically move our map to the selected location
                // animateCamera updates the location or view of the map on the basis of target
                myMapController!.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: source, zoom: 14)
                  //17 is new zoom level
                ));

                setState(() {

                });
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
        ).box.color(Colors.white).width(Get.width).height(Get.height * 0.5).padding(EdgeInsets.symmetric(horizontal: 20, vertical: 10)).margin(EdgeInsets.symmetric(horizontal: 10)).roundedSM.make()
    );
  }


}
