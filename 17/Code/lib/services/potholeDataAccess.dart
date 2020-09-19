import 'package:cloud_firestore/cloud_firestore.dart';

class PotholeDataAccess {
  Future<void> addData(potholeData) async {
    Firestore.instance
        .collection('potholeDetails')
        .add(potholeData)
        .catchError((e) {
      print(e);
    });
  }

  Future getData() async {
    return await Firestore.instance.collection('potholeDetails').getDocuments();
  }
}

class PotholeMunicipalDataAccess {
  Future<void> addData(potholeMunicipalData) async {
    Firestore.instance
        .collection('potholeMunicipalDetails')
        .add(potholeMunicipalData)
        .catchError((e) {
      print(e);
    });
  }

  Future getData() async {
    return await Firestore.instance
        .collection('potholeMunicipalDetails')
        .getDocuments();
  }
}
