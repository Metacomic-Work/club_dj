import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DjLiveHostingScreen extends StatefulWidget {
  @override
  _DjLiveHostingScreenState createState() => _DjLiveHostingScreenState();
}

class _DjLiveHostingScreenState extends State<DjLiveHostingScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  CollectionReference _requestsCollection =
      FirebaseFirestore.instance.collection('requests');
  List<Map<String, dynamic>> _acceptedRequests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DJ Live Hosting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            ElevatedButton(
              onPressed: () async {
                String title = _titleController.text.trim();
                String location = _locationController.text.trim();
                // Save the DJ's live hosting details

                await _startListeningForRequests();
              },
              child: Text('Start Live Hosting'),
            ),
            SizedBox(height: 20),
            Text(
              'Accepted Song Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _requestsCollection
                    .where('djId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot> requestSnapshots =
                        snapshot.data!.docs;

                    if (requestSnapshots.isEmpty) {
                      return Text('No song requests.');
                    }

                    return ListView.builder(
                      itemCount: requestSnapshots.length,
                      itemBuilder: (context, index) {
                        final requestSnapshot = requestSnapshots[index];
                        final Map<String, dynamic> requestData =
                            requestSnapshot.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(requestData['songName']),
                          subtitle: Text(requestData['message']),
                          trailing: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () async {
                                  await _acceptRequest(requestSnapshot.id);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () async {
                                  await _rejectRequest(requestSnapshot.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error fetching song requests.');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startListeningForRequests() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final String djId = user.uid;

    await FirebaseFirestore.instance
        .collection('requests')
        .where('djId', isEqualTo: djId)
        .snapshots()
        .listen((querySnapshot) {
      for (var requestDoc in querySnapshot.docs) {
        Map<String, dynamic> requestData = requestDoc.data();

        // Process the request data here
        if (requestData['status'] == 'accepted') {
          _acceptedRequests.add(requestData);
        }

        // Trigger a UI update
        setState(() {});
      }
    });
  }

  Future<void> _acceptRequest(String requestId) async {
    await _requestsCollection.doc(requestId).update({'status': 'accepted'});
  }

  Future<void> _rejectRequest(String requestId) async {
    await _requestsCollection.doc(requestId).update({'status': 'rejected'});
  }
}
