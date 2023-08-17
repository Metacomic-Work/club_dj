


import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/usermodel.dart';

class DjService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch nearby active DJs based on user's location
  Future<List<DjUser>> fetchNearbyActiveDJs(double userLatitude, double userLongitude) async {
    const double radius = 10.0; // Define your radius in kilometers

    final QuerySnapshot querySnapshot = await _firestore
        .collection('djs') // Collection name
        .where('isLive', isEqualTo: true) // Filter active DJs
        .where('latitude', isGreaterThan: userLatitude - radius)
        .where('latitude', isLessThan: userLatitude + radius)
        .where('longitude', isGreaterThan: userLongitude - radius)
        .where('longitude', isLessThan: userLongitude + radius)
        .get();

    final List<DjUser> nearbyDJs = querySnapshot.docs.map((doc) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return DjUser(
        id: doc.id,
        displayName: data['displayName'],
        profileImageUrl: data['profileImageUrl'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        // Map other properties from data
      );
    }).toList();

    return nearbyDJs;
  }
}
