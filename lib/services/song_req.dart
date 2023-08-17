import 'package:cloud_firestore/cloud_firestore.dart';

class SongRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendSongRequest(
      String djId, String songName, String message) async {
    final DocumentReference requestRef =
        _firestore.collection('requests').doc();
    await requestRef.set({
      'djId': djId,
      'songName': songName,
      'message': message,
      'isAccepted': false,
      // Other request details
    });
  }

  // Function to fetch all song requests sent by a user
  Future<List<QueryDocumentSnapshot>> getUserSongRequests(String userId) async {
    final QuerySnapshot querySnapshot = await _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs;
  }

 Stream<QuerySnapshot<Map<String, dynamic>>> streamUserRequests(String userId) {
    return _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
