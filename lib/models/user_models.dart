import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserModel {
  String? bAddress;
  String? hAddress;
  String? mallAddress;
  String? name;
  String? image;

  //constructor for assigning values
  UserModel({this.name,this.mallAddress,this.hAddress,this.bAddress,this.image});


  // Named constructor  --->>> This constructor allows you to create an instance of UserModel by providing a Map object representing JSON data.
  // this wille xtract all info from the firebase json file and assign to the given parameters
  //and these parametes we will goinf to show
  UserModel.fromJson(Map<String,dynamic> json){
    bAddress = json['business_address'];
    hAddress = json['home_address'];
    mallAddress = json['shopping_address'];
    name = json['name'];
    image = json['image'];
  }
}