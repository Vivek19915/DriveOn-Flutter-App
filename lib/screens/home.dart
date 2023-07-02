import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../widgets/build_Notification_icon.dart';
import '../widgets/build_Profile_tile.dart';
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

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,    //since transparent giving green screen
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
            buildCurrentLocationIcon(),
            buildNotificationIcon(),
            buildBottomSheet(),
          ],
        ),
    );
  }
}
