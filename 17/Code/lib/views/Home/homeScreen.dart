import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart' as loc;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:pothole_scout/models/potholeDataModel.dart';
import 'package:pothole_scout/services/potholeDataAccess.dart';
import 'package:pothole_scout/common/providerWidget.dart';
import 'package:pothole_scout/services/authService.dart';
import 'package:pothole_scout/services/userService.dart';

final primaryColor = const Color(0xFF75A2EA);

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String address;
  File _image;
  String _filename;
  String _url;
  Map<String, dynamic> _detections;
  String uid;
  String _role;
  int _id;
  String _name;
  int _count = 0;
  Position _userPosition;
  double _latitude;
  double _longitude;
  List<Detections> plotDetections = [];
  QuerySnapshot userData;
  bool isAnonymous = false;

  PotholeDataAccess potholeObj = new PotholeDataAccess();
  loc.Location location = loc.Location();

  @override
  void initState() {
    super.initState();
    _checkGps();

    AuthService().getUID().then((resultUID) {
      setState(() {
        uid = resultUID;
      });
    });

    // AuthService().checkAnonymous().then((value) {
    //   isAnonymous = value;
    // });
    //print(isAnonymous);

    UserManagement().getUserData().then((result) {
      //print(uid);
      for (int i = 0; i < result.documents.length; i++) {
        if (uid == result.documents[i].data['uid']) {
          setState(() {
            _role = result.documents[i].data['role'];
            _name = result.documents[i].data['name'];
          });
        }
        //print(_name);
      }
    });

    imageCache.clear();
  }

  // CITIZEN Functions start here

  // Function to check if User has GPS Enabled on device
  Future _checkGps() async {
    if (!await location.serviceEnabled()) {
      location.requestService();
    }
  }

  // Function to convert Coordinates to Address -- Reverse Geocode
  Future<String> getAddress(Position pos) async {
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      final Placemark pos = placemarks[0];
      return pos.thoroughfare + ', ' + pos.locality;
    }
    return "";
  }

  // Function to get the current location of the user
  getPosition() async {
    var geolocator = Geolocator();
    _userPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    _latitude = _userPosition.latitude;
    _longitude = _userPosition.longitude;
    print("User Position Lat: " + _userPosition.latitude.toString());
    print("User Position Lat: " + _userPosition.longitude.toString());
    address = await getAddress(_userPosition);
  }

  // Function for Pothole Detection API
  Future detectRequestAPI(var image) async {
    final String uriImages = "http://0.0.0.0:5000/image";

    final String uriDetections = "http://0.0.0.0:5000/detections";

    http.MultipartRequest requestDetections =
        http.MultipartRequest('POST', Uri.parse(uriDetections));
    requestDetections.files.add(
      await http.MultipartFile.fromPath(
        'images',
        image.path,
        contentType: MediaType('application', 'jpeg'),
      ),
    );

    http.MultipartRequest requestImage =
        http.MultipartRequest('POST', Uri.parse(uriImages));
    requestImage.files.add(
      await http.MultipartFile.fromPath(
        'images',
        image.path,
        contentType: MediaType('application', 'jpeg'),
      ),
    );

    http.StreamedResponse responseDetections = await requestDetections.send();
    print(responseDetections.statusCode);
    _detections = jsonDecode(
        await responseDetections.stream.transform(utf8.decoder).join());
    print(_detections);

    http.StreamedResponse responseImage = await requestImage.send();
    print(responseImage.statusCode);

    setState(() {
      _count = _detections["response"][0]["detections"].length;
    });

    print(_count);
  }

  // Function to generate a random ID
  generateID() {
    Random rnd = new Random();
    var mini = 232323;
    var max = 12315135;
    var rand = mini + rnd.nextInt(max);
    print(rand);
    _id = rand;
  }

  // Function to upload data to Firebase
  uploadFirebaseData(File image) async {
    if (_count > 0) {
      _filename = path.basename(image.path);
      StorageReference ref = FirebaseStorage.instance.ref().child(_filename);
      StorageUploadTask uploadTask = ref.putFile(image);
      StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      _url = (await downloadUrl.ref.getDownloadURL());
      print(_url);

      Location detectedLocation =
          Location(latitude: _latitude, longitude: _longitude);

      double calculateArea(double x1, double y1, double x2, double y2) {
        double x = pow((x2 - x1), 2);
        double y = pow((y2 - y1), 2);

        return (pow((x + pow((y1), 2)) * (y + pow((y1), 2)), 0.5));
      }

      for (int i = 0; i < _count; i++) {
        plotDetections.add(
          Detections(
            x1: _detections["response"][0]["detections"][i]["box"][0],
            y1: _detections["response"][0]["detections"][i]["box"][1],
            x2: _detections["response"][0]["detections"][i]["box"][2],
            y2: _detections["response"][0]["detections"][i]["box"][3],
            area: calculateArea(
              _detections["response"][0]["detections"][i]["box"][0],
              _detections["response"][0]["detections"][i]["box"][1],
              _detections["response"][0]["detections"][i]["box"][2],
              _detections["response"][0]["detections"][i]["box"][3],
            ),
          ),
        );
      }

      Map<String, dynamic> potholeData = PotholeData(
              count: _count,
              location: detectedLocation,
              filename: _filename,
              url: _url,
              citizenName: _name,
              iD: _id,
              detections: plotDetections)
          .toJson();

      potholeObj.addData(potholeData).catchError((e) {
        print(e);
      });
    }
  }

  // onSubmit Button for reporting Pothole
  void onSubmit() {
    uploadFirebaseData(_image);
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed('/homeScreen');
  }

  // CITIZEN functions end here

  // MUNICIPAL functions start here
  // ..............................
  // MUNICIPAL functions end here

  // COMMON funcitons start here

  // Function for getting Image from Gallery
  Future getGalleryImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    detectRequestAPI(image);
    generateID();
  }

  // Function for capturing image from Camera
  Future getCamreraImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
    detectRequestAPI(image);
    generateID();
  }

  // Function to return a List based on the Urgency factor identified
  List urgencyFactor(count) {
    if (count == 1) {
      return ["Low", Colors.yellow];
    } else if (count >= 2 && count <= 4) {
      return ["Medium", Colors.orange];
    } else if (count >= 5) {
      return ["High", Colors.red];
    }
    return ["None", Colors.grey];
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    print("Role: $_role");
    if (_role == null) {
      return Scaffold(
        backgroundColor: Colors.lightBlue,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitDoubleBounce(
              color: Colors.white,
            ),
            Text(
              "Loading",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (_role == "Municipal") {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                try {
                  AuthService auth = Provider.of(context).auth;
                  await auth.signOut();
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
        ),
        body: Container(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          actions: <Widget>[
            isAnonymous == true
                ? IconButton(
                    icon: Icon(Icons.account_circle),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/convertUserScreen');
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.account_circle),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/profileScreen');
                    },
                  ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                try {
                  AuthService auth = Provider.of(context).auth;
                  await auth.signOut();
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
              width: _width,
              height: _height,
              child: _image == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Container(),
                        ),
                        RaisedButton(
                          onPressed: () {
                            getPosition();
                            getCamreraImage();
                          },
                          elevation: 20.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0),
                          ),
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              // gradient: mapButton2Gradient,
                              borderRadius: BorderRadius.all(
                                Radius.circular(80.0),
                              ),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 230.0,
                                minHeight: 50.0,
                              ),
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  // style: kButtonTextStyle,
                                  children: [
                                    TextSpan(
                                      text: 'Capture Image from Camera',
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        RaisedButton(
                          onPressed: () {
                            getPosition();
                            getGalleryImage();
                          },
                          elevation: 20.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0),
                          ),
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                              // gradient: mapButton2Gradient,
                              borderRadius: BorderRadius.all(
                                Radius.circular(80.0),
                              ),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 230.0,
                                minHeight: 50.0,
                              ),
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  // style: kButtonTextStyle,
                                  children: [
                                    TextSpan(
                                      text: 'Capture Image from Gallery',
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        RaisedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/mapScreen');
                          },
                          elevation: 20.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0),
                          ),
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                              // gradient: mapButton2Gradient,
                              borderRadius: BorderRadius.all(
                                Radius.circular(80.0),
                              ),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 230.0,
                                minHeight: 50.0,
                              ),
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  // style: kButtonTextStyle,
                                  children: [
                                    TextSpan(
                                      text: 'View Map',
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    )
                  : _detections == null
                      ? FittedBox(
                          child: Image.file(_image),
                          fit: BoxFit.fill,
                        )
                      : FittedBox(
                          child: Image.network('http://0.0.0.0:5000/result',
                              fit: BoxFit.fill),
                        ),
            ),
            _detections == null
                ? SizedBox(
                    height: 0,
                  )
                : SlidingUpPanel(
                    maxHeight: _height * 0.5,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    backdropEnabled: true,
                    collapsed: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 12.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(12.0))),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Text(
                                  "Details",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 30),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    color: Colors.white,
                    panel: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: 30,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0))),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Text(
                                "Details",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 30),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: CircleAvatar(
                                child: Image.network(
                                    'http://0.0.0.0:5000/result',
                                    fit: BoxFit.fill),
                                backgroundColor: Colors.transparent,
                                radius: 40,
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Text(_count.toString(),
                                      style: TextStyle(fontSize: 15)),
                                  decoration: BoxDecoration(
                                    color: urgencyFactor(_count).elementAt(1),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.15),
                                        blurRadius: 8.0,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                Text("Count"),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Text(
                                      urgencyFactor(_count).elementAt(0),
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    decoration: BoxDecoration(
                                      color: urgencyFactor(_count).elementAt(1),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.15),
                                          blurRadius: 8.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Text("Urgency"),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              child: _userPosition == null
                                  ? CircularProgressIndicator()
                                  : Text(address),
                              // Text("Location: " +
                              //     _latitude.toString() +
                              //     ", " +
                              //     _longitude.toString()),
                            ),
                          ],
                        ),
                        _count == 0
                            ? Container(
                                child: Text(
                                    "A case can't be registered. Try taking a photo again"),
                              )
                            : Container(
                                child: Text(
                                  "ID" + _id.toString(),
                                ),
                              ),
                        SizedBox(
                          height: 30,
                        ),
                        RaisedButton(
                          onPressed: onSubmit,
                          elevation: 20.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0),
                          ),
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                              // gradient: mapButton2Gradient,
                              borderRadius: BorderRadius.all(
                                Radius.circular(80.0),
                              ),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 200.0,
                                minHeight: 50.0,
                              ),
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  // style: kButtonTextStyle,
                                  children: [
                                    _count == 0
                                        ? TextSpan(
                                            text: 'Try Again',
                                          )
                                        : TextSpan(
                                            text: 'Report Pothole',
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      );
    }
  }
}
