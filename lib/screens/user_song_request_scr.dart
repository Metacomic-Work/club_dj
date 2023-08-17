import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/song_req.dart';


class UserSongRequestsScreen extends StatefulWidget {
  final String userId;

  const UserSongRequestsScreen({super.key, required this.userId});

  @override
  _UserSongRequestsScreenState createState() => _UserSongRequestsScreenState();
}

class _UserSongRequestsScreenState extends State<UserSongRequestsScreen> {
  final SongRequestService _requestService = SongRequestService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Song Requests'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _requestService.streamUserRequests(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> requestSnapshots = snapshot.data!.docs;

            if (requestSnapshots.isEmpty) {
              return const Center(child: Text('You have no song requests.'));
            }

            return ListView.builder(
              itemCount: requestSnapshots.length,
              itemBuilder: (context, index) {
                final requestSnapshot = requestSnapshots[index];
                final Map<String, dynamic> requestData = requestSnapshot.data()!;
                final String requestId = requestSnapshot.id;

                return ListTile(
                  title: Text(requestData['songName']),
                  subtitle: Text(requestData['message']),
                  
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching song requests.'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
