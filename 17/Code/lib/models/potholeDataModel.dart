class PotholeData {
  int count;
  int iD;
  String citizenName;
  String url;
  String filename;
  Location location;
  List<Detections> detections;

  PotholeData(
      {this.count,
      this.iD,
      this.citizenName,
      this.url,
      this.filename,
      this.location,
      this.detections});

  PotholeData.fromJson(Map<String, dynamic> json) {
    count = json['Count'];
    iD = json['ID'];
    citizenName = json['CitizenName'];
    url = json['url'];
    filename = json['filename'];
    location = json['Location'] != null
        ? new Location.fromJson(json['Location'])
        : null;
    if (json['Detections'] != null) {
      detections = new List<Detections>();
      json['Detections'].forEach((v) {
        detections.add(new Detections.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Count'] = this.count;
    data['ID'] = this.iD;
    data['CitizenName'] = this.citizenName;
    data['url'] = this.url;
    data['filename'] = this.filename;
    if (this.location != null) {
      data['Location'] = this.location.toJson();
    }
    if (this.detections != null) {
      data['Detections'] = this.detections.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Location {
  double latitude;
  double longitude;

  Location({this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
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

class Detections {
  double area;
  double x1;
  double y1;
  double x2;
  double y2;

  Detections({this.area, this.x1, this.y1, this.x2, this.y2});

  Detections.fromJson(Map<String, dynamic> json) {
    area = json['area'];
    x1 = json['x1'];
    y1 = json['y1'];
    x2 = json['x2'];
    y2 = json['y2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['area'] = this.area;
    data['x1'] = this.x1;
    data['y1'] = this.y1;
    data['x2'] = this.x2;
    data['y2'] = this.y2;
    return data;
  }
}
