import 'package:flutter/material.dart'; 
import '../model/usermodel.dart';
import '../services/djservice.dart';

class NearbyDjsScreen extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;

  NearbyDjsScreen({required this.userLatitude, required this.userLongitude});

  @override
  _NearbyDjsScreenState createState() => _NearbyDjsScreenState();
}

class _NearbyDjsScreenState extends State<NearbyDjsScreen> {
  final DjService _djService = DjService();
  late List<DjUser> _nearbyDJs;

  @override
  void initState() {
    super.initState();
    _loadNearbyDJs();
  }

  Future<void> _loadNearbyDJs() async {
    _nearbyDJs = await _djService.fetchNearbyActiveDJs(widget.userLatitude, widget.userLongitude);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby DJs'),
      ),
      body: ListView.builder(
        itemCount: _nearbyDJs.length,
        itemBuilder: (context, index) {
          final DjUser dj = _nearbyDJs[index];
          return ListTile(
            title: Text(dj.displayName),
            subtitle: Text('Latitude: ${dj.latitude}, Longitude: ${dj.longitude}'),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(dj.profileImageUrl),
            ),
            // Implement further actions like tapping on a DJ to view their details, etc.
          );
        },
      ),
    );
  }
}
