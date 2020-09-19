import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagement {
  storeNewUser(String email, String uid, String role, String name) {
    Firestore _firestoreInstance = Firestore.instance;
    int count = 0;
    _firestoreInstance.collection('users').getDocuments().then((userData) {
      for (int i = 0; i < userData.documents.length; i++) {
        if (uid == userData.documents[i].data['uid']) {
          count = count + 1;
        }
      }
    }).whenComplete(() {
      //Checks if user is already authenticated with the same Uid but a different method.
      if (count == 0) {
        _firestoreInstance.collection('users').add({
          'email': email,
          'uid': uid,
          'role': role,
          'name': name,
          'rewards': 0
        }).catchError((e) {
          print(e);
        });
      }
    });
  }

  Future getUserData() async {
    return await Firestore.instance.collection('users').getDocuments();
  }
}
