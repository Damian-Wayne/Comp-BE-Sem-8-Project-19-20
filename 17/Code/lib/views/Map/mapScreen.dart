import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:pothole_scout/services/potholeDataAccess.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> allMarkers = List<Marker>();
  String _mapStyle;
  List<List<double>> coors;
  List<LatLng> marker = List<LatLng>();
  BitmapDescriptor pinLocationIcon;

  GoogleMapController _controller;

  var potholeObj = PotholeDataAccess();

  @override
  void initState() {
    super.initState();

    // Loads Custom Marker Image 
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/marker.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });

    // Loads Custom Map Style
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });

    potholeObj.getData().then((result) {
      for (int i = 0; i < result.documents.length; i++) {
        marker.add(
          LatLng(
            result.documents[i].data['Location']['Latitude'],
            result.documents[i].data['Location']['Longitude'],
          ),
        );
      }
    }).whenComplete(() {
      add();
    });
  }

  // Function to add Marker objects into a List and used for generating Markers
  void add() {
    for (int i = 0; i < marker.length; i++) {
      String id = "markerID" + i.toString();
      setState(() {
        allMarkers.add(
          Marker(
            markerId: MarkerId(id),
            draggable: false,
            onTap: () {
              print("Tapped");
            },
            position: marker[i],
            icon: pinLocationIcon,
          ),
        );
      });
    }
    print(allMarkers);
  }

  // Function to layout the Map Controller and set the Style of the Map 
  void mapCreated(controller) {
    setState(() {
      _controller = controller;
      _controller.setMapStyle(_mapStyle);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.height,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(19.0473, 73.0699),
                zoom: 15.0,
              ),
              markers: Set.from(allMarkers),
              onMapCreated: mapCreated,
            ),
          ),
        ],
      ),
    );
  }

  moveToMumbai() {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(19.0760, 72.8777),
          zoom: 15,
          bearing: 45.0,
          tilt: 45.0,
        ),
      ),
    );
  }

  moveToNaviMumbai() {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(19.0330, 73.0297),
          zoom: 15,
        ),
      ),
    );
  }
}
