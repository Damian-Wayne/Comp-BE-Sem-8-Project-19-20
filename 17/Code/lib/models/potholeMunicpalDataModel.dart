//Sample JSON
// {
//     "startLocation": {
//         "Latitude": 32.0232,
//         "Longitude": 42.42434
//     },
//     "endLocation": {
//         "Latitude": 32.0232,
//         "Longitude": 42.42434
//     },
//     "Count": 3,
//     "Address": "ajdasdadiqwd",
//     "totalArea": 32.424141,
//   "Detections": [
//   {
//     "area": 0.15638171136379242,
//     "x1": 0.15638171136379242,
//     "y1": 0.15638171136379242,
//     "x2": 0.15638171136379242,
//     "y2": 0.15638171136379242
//   },
//   {
//     "area": 0.15638171136379242,
//     "x1": 0.15638171136379242,
//     "y1": 0.15638171136379242,
//     "x2": 0.15638171136379242,
//     "y2": 0.15638171136379242
//   }
// ]
// }

class PotholeMunicipalData {
  StartLocation startLocation;
  StartLocation endLocation;
  int count;
  String address;
  double totalArea;

  PotholeMunicipalData(
      {this.startLocation,
      this.endLocation,
      this.count,
      this.address,
      this.totalArea});

  PotholeMunicipalData.fromJson(Map<String, dynamic> json) {
    startLocation = json['startLocation'] != null
        ? new StartLocation.fromJson(json['startLocation'])
        : null;
    endLocation = json['endLocation'] != null
        ? new StartLocation.fromJson(json['endLocation'])
        : null;
    count = json['Count'];
    address = json['Address'];
    totalArea = json['totalArea'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.startLocation != null) {
      data['startLocation'] = this.startLocation.toJson();
    }
    if (this.endLocation != null) {
      data['endLocation'] = this.endLocation.toJson();
    }
    data['Count'] = this.count;
    data['Address'] = this.address;
    data['totalArea'] = this.totalArea;
    return data;
  }
}

class StartLocation {
  double latitude;
  double longitude;

  StartLocation({this.latitude, this.longitude});

  StartLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['Latitude'];
    longitude = json['Longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Latitude'] = this.latitude;
    data['Longitude'] = this.longitude;
    return data;
  }
}